#!/bin/sh
# Install the Coral extension into Zed (Linux/macOS/Windows shells).
#
# The artifact is prebuilt: it contains extension.wasm, the tree-sitter
# grammar, queries and an index entry. Rust, clang and tree-sitter are NOT
# needed. Zed must be restarted afterwards.
#
# Usage:
#   sh install.sh                    # latest from coralc-lang/coralc
#   sh install.sh --data-dir DIR     # custom Zed data directory
#   sh install.sh --version 0.4.0
#   sh install.sh --file coral-zed-0.4.0.tar.gz
#
# From the web:
#   curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/zed/install.sh | sh
#
# Resolution of the Zed data directory:
#   Linux:   ${XDG_DATA_HOME:-$HOME/.local/share}/zed
#   macOS:   $HOME/Library/Application Support/Zed
#   Windows: %LOCALAPPDATA%\Zed  (Git Bash/MSYS/Cygwin)
set -eu

BASE=${CORAL_EXTENSIONS_BASE:-https://raw.githubusercontent.com/coralc-lang/coralc/main}
VERSION=""
URL=""
FILE=""
DATA=""

while [ $# -gt 0 ]; do
    case "$1" in
        --data-dir) [ $# -ge 2 ] || { echo "--data-dir needs a path" >&2; exit 2; }; DATA=$2; shift 2 ;;
        --data-dir=*) DATA=${1#--data-dir=}; shift ;;
        --version) [ $# -ge 2 ] || { echo "--version needs a value" >&2; exit 2; }; VERSION=$2; shift 2 ;;
        --version=*) VERSION=${1#--version=}; shift ;;
        --url) [ $# -ge 2 ] || { echo "--url needs a value" >&2; exit 2; }; URL=$2; shift 2 ;;
        --url=*) URL=${1#--url=}; shift ;;
        --file) [ $# -ge 2 ] || { echo "--file needs a path" >&2; exit 2; }; FILE=$2; shift 2 ;;
        --file=*) FILE=${1#--file=}; shift ;;
        -h|--help) sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

if [ -z "$DATA" ]; then
    case "$(uname -s 2>/dev/null || echo Linux)" in
        Darwin) DATA="$HOME/Library/Application Support/Zed" ;;
        MINGW*|MSYS*|CYGWIN*)
            [ -n "${LOCALAPPDATA:-}" ] || { echo "LOCALAPPDATA is not set" >&2; exit 1; }
            DATA="$LOCALAPPDATA/Zed" ;;
        *)
            DATA="${XDG_DATA_HOME:-$HOME/.local/share}/zed" ;;
    esac
fi

EXT="$DATA/extensions"
DEST="$EXT/installed/coral"
mkdir -p "$EXT/installed"

if [ -z "$FILE" ]; then
    if [ -z "$VERSION" ]; then
        here=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true)
        if [ -n "$here" ] && [ -f "$here/VERSION" ]; then
            VERSION=$(cat "$here/VERSION")
        else
            VERSION=$(curl -fsSL --retry 3 "$BASE/extensions/zed/VERSION" 2>/dev/null || true)
        fi
        [ -n "$VERSION" ] || { echo "cannot determine the latest version; pass --version" >&2; exit 1; }
    fi
    [ -n "$URL" ] || URL="$BASE/extensions/zed/coral-zed-$VERSION.tar.gz"
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM
ARCHIVE="$TMP/coral-zed.tar.gz"

if [ -n "$FILE" ]; then
    [ -f "$FILE" ] || { echo "no such file: $FILE" >&2; exit 1; }
    cp "$FILE" "$ARCHIVE"
else
    echo "downloading $URL"
    if command -v curl >/dev/null 2>&1; then
        curl -fL --retry 3 --retry-delay 2 -o "$ARCHIVE" "$URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$ARCHIVE" "$URL"
    else
        echo "curl or wget is required" >&2
        exit 1
    fi
fi

if [ "$(head -c 2 "$ARCHIVE" | od -An -tx1 | tr -d ' \n')" != "1f8b" ]; then
    echo "downloaded file is not a gzip archive" >&2
    exit 1
fi

mkdir -p "$TMP/unpack"
tar -xzf "$ARCHIVE" -C "$TMP/unpack"
for f in extension.toml extension.wasm grammars/coral.wasm index-entry.json; do
    [ -f "$TMP/unpack/$f" ] || { echo "package is missing $f" >&2; exit 1; }
done

rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$TMP/unpack/." "$DEST/"

if ! command -v python3 >/dev/null 2>&1; then
    echo "warning: python3 not found; installed files but could not update" >&2
    echo "         $EXT/index.json. Start Zed and use 'Install Dev Extension'" >&2
    echo "         on $DEST, or install python3 and rerun this script." >&2
    exit 1
fi

python3 - "$EXT/index.json" "$DEST/index-entry.json" <<'PY'
import json, os, shutil, sys

index_path, entry_path = sys.argv[1:3]
entry = json.load(open(entry_path))
if os.path.exists(index_path):
    with open(index_path) as f:
        index = json.load(f)
    shutil.copyfile(index_path, index_path + ".pre-coral.bak")
else:
    index = {}

extensions = index.setdefault("extensions", {})
extensions["coral"] = entry["extension"]
languages = index.setdefault("languages", {})
languages.update(entry.get("language", {}))
icon_themes = index.setdefault("icon_themes", {})
icon_themes.update(entry.get("icon_theme", {}))
index.setdefault("themes", {})

tmp = index_path + ".tmp"
with open(tmp, "w") as f:
    json.dump(index, f, indent=2)
    f.write("\n")
os.replace(tmp, index_path)
print(f"registered coral in {index_path}")
PY

echo "installed: $DEST"
if ! command -v coralc >/dev/null 2>&1 && ! command -v coralc.exe >/dev/null 2>&1; then
    echo "note: coralc is not on PATH; syntax highlighting works but the"
    echo "      language server needs the compiler installer."
fi
echo "restart Zed to load the extension"

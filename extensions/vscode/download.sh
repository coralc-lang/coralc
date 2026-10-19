#!/bin/sh
# Download the Coral VS Code extension (.vsix) into your Downloads folder.
#
# This script intentionally does NOT install anything. A .vsix works in
# VS Code, VSCodium, Cursor, Windsurf, Positron, Kiro and other VS Code
# forks; open the file in your editor, or use its own CLI:
#
#   code --install-extension ~/Downloads/coral-<version>.vsix
#   codium --install-extension ...
#   cursor --install-extension ...
#
# Usage:
#   sh download.sh [--out DIR] [--version VERSION] [--force]
#   sh download.sh --url URL
#
# Run it straight from the web:
#   curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/download.sh | sh
set -eu

BASE=${CORAL_EXTENSIONS_BASE:-https://raw.githubusercontent.com/coralc-lang/coralc/main}
VERSION=""
OUT=""
URL=""
FORCE=0

while [ $# -gt 0 ]; do
    case "$1" in
        --out) [ $# -ge 2 ] || { echo "--out needs a directory" >&2; exit 2; }; OUT=$2; shift 2 ;;
        --out=*) OUT=${1#--out=}; shift ;;
        --version) [ $# -ge 2 ] || { echo "--version needs a value" >&2; exit 2; }; VERSION=$2; shift 2 ;;
        --version=*) VERSION=${1#--version=}; shift ;;
        --url) [ $# -ge 2 ] || { echo "--url needs a value" >&2; exit 2; }; URL=$2; shift 2 ;;
        --url=*) URL=${1#--url=}; shift ;;
        --force) FORCE=1; shift ;;
        -h|--help)
            cat <<'EOF'
Download the Coral VS Code extension (.vsix) into your Downloads folder.

Usage: download.sh [--out DIR] [--version VERSION] [--force]
       download.sh --url URL
EOF
            exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
done

if [ -z "$OUT" ]; then
    if [ -n "${XDG_DOWNLOAD_DIR:-}" ]; then
        OUT=$XDG_DOWNLOAD_DIR
    elif command -v xdg-user-dir >/dev/null 2>&1; then
        OUT=$(xdg-user-dir DOWNLOAD 2>/dev/null || true)
    fi
    [ -n "$OUT" ] || OUT=$HOME/Downloads
fi
mkdir -p "$OUT"

get_url() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --retry 3 "$1"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$1"
    else
        return 1
    fi
}

if [ -z "$VERSION" ] && [ -z "$URL" ]; then
    here=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true)
    if [ -n "$here" ] && [ -f "$here/VERSION" ]; then
        VERSION=$(cat "$here/VERSION")
    else
        VERSION=$(get_url "$BASE/extensions/vscode/VERSION" 2>/dev/null || true)
    fi
    [ -n "$VERSION" ] || { echo "cannot determine the latest version; pass --version" >&2; exit 1; }
fi

if [ -z "$URL" ]; then
    URL="$BASE/extensions/vscode/coral-$VERSION.vsix"
fi

NAME=$(basename "$URL")
DEST="$OUT/$NAME"
if [ -f "$DEST" ] && [ "$FORCE" -eq 0 ]; then
    echo "already downloaded: $DEST"
    echo "use --force to download it again"
    exit 0
fi

TMP="$DEST.part"
trap 'rm -f "$TMP"' EXIT INT TERM
echo "downloading $URL"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 3 --retry-delay 2 -o "$TMP" "$URL"
elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$TMP" "$URL"
else
    echo "curl or wget is required" >&2
    exit 1
fi

if [ "$(head -c 2 "$TMP")" != "PK" ]; then
    echo "downloaded file is not a .vsix (zip) archive" >&2
    exit 1
fi
mv "$TMP" "$DEST"
trap - EXIT INT TERM

SIZE=$(wc -c < "$DEST" | tr -d ' ')
echo "saved: $DEST ($SIZE bytes)"
echo
echo "Install it in your editor (VS Code or any fork):"
echo "  code --install-extension \"$DEST\""

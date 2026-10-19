#!/bin/sh
# coralc installer: download (or use the current checkout), pull the prebuilt
# coralc out of that folder, and install into $CORAL_HOME (default ~/.coral).
#   curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/install.sh | sh
# or from a checkout: sh install.sh [--prefix DIR]
set -eu

PREFIX=${CORAL_HOME:-$HOME/.coral}
while [ $# -gt 0 ]; do
    case "$1" in
        --prefix) PREFIX=$2; shift 2 ;;
        --prefix=*) PREFIX=${1#--prefix=}; shift ;;
        *) echo "usage: install.sh [--prefix DIR]" >&2; exit 2 ;;
    esac
done

add_path() {
    case ":${PATH}:" in
        *":$PREFIX/bin:"*) return ;;
    esac
    line="export PATH=\"$PREFIX/bin:\$PATH\""
    for rc in "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
        [ -e "$rc" ] || [ "$rc" = "$HOME/.profile" ] || continue
        if ! grep -qF "$PREFIX/bin" "$rc" 2>/dev/null; then
            printf '\n# coralc\n%s\n' "$line" >> "$rc"
        fi
    done
    echo "added $PREFIX/bin to PATH in your shell profile (open a new shell)"
}

SRC=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || pwd)
TMP=""
if [ ! -f "$SRC/compiler/coral.crlb" ]; then
    if ! command -v git >/dev/null 2>&1; then
        echo "coralc: git is required to download the repository" >&2
        exit 1
    fi
    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT INT TERM
    echo "coralc: cloning coralc-lang/coralc"
    git clone --depth 1 https://github.com/coralc-lang/coralc.git "$TMP/coralc"
    SRC="$TMP/coralc"
fi

BIN=""
for candidate in "$SRC/coralc" "$SRC/dist/coralc" "$SRC/build/coralc"; do
    if [ -f "$candidate" ]; then
        BIN=$candidate
        break
    fi
done

if [ -z "$BIN" ]; then
    echo "coralc: no prebuilt coralc binary found in $SRC" >&2
    exit 1
fi

mkdir -p "$PREFIX/bin"

# stop any running coralc (e.g. editor language servers) so the install
# copy can overwrite the binary instead of failing with ETXTBSY.
pkill -f "$PREFIX/bin/coralc" 2>/dev/null || true
rm -f "$PREFIX/bin/coralc"

cp "$BIN" "$PREFIX/bin/coralc"
chmod +x "$PREFIX/bin/coralc"

rm -rf "$PREFIX/lib"
cp -R "$SRC/lib" "$PREFIX/lib"

add_path

echo
echo "coralc installed to $PREFIX/bin/coralc"
echo
echo "editor support:"
echo "  Zed:            curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/zed/install.sh | sh"
echo "  VS Code / fork: curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/download.sh | sh"
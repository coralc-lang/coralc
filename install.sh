#!/bin/sh
# coralc installer: download (or use the current checkout), build, and
# install into $CORAL_HOME (default ~/.coral). Run it straight from the web:
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

cd "$SRC"

# ADDED: stop any running coralc (e.g. editor language servers) so the
# install copy can overwrite the binary instead of failing with ETXTBSY.
pkill -f "$PREFIX/bin/coralc" 2>/dev/null || true
rm -f "$PREFIX/bin/coralc"

if command -v make >/dev/null 2>&1; then
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*) make windows ;;
        *) make linux ;;
    esac
    make install PREFIX="$PREFIX"
else
    echo "coralc: make not found; compiling dist/coralc-linux.c directly" >&2
    mkdir -p "$PREFIX/bin"
    ${CC:-cc} -std=gnu11 -O0 -o "$PREFIX/bin/coralc" dist/coralc-linux.c -lm
    rm -rf "$PREFIX/lib"
    cp -R lib "$PREFIX/lib"
fi

add_path

echo
echo "coralc installed to $PREFIX/bin/coralc"
"$PREFIX/bin/coralc" --version < /dev/null || true
echo
echo "editor support:"
echo "  Zed:            curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/zed/install.sh | sh"
echo "  VS Code / fork: curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/download.sh | sh"
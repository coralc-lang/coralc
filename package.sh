#!/bin/sh
# Internal release packaging: emit the compiler as C for both platforms,
# with the default std platform baked in. This script produces C files only;
# building executables is the Makefile's job (make linux / make windows).
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"
DIST="$ROOT/dist"
mkdir -p "$DIST"

if [ -x "$ROOT/compiler/build/coralc" ]; then
    CORALC="$ROOT/compiler/build/coralc"
elif [ -x "$ROOT/coralc" ]; then
    CORALC="$ROOT/coralc"
elif [ -x "$HOME/.coral/bin/coralc" ]; then
    CORALC="$HOME/.coral/bin/coralc"
else
    echo "package: no coralc seed found; run make first" >&2
    exit 1
fi

emit() {
    plat=$1
    tmp="$DIST/.$plat.crlb"
    log="$DIST/.$plat.log"
    sed \
        -e "s#root       = \".*\";#root       = \"$ROOT/compiler\";#" \
        -e "s#output     = \".*\";#output     = \"$DIST/coralc-$plat\";#" \
        -e "s#module_map = \".*\";#module_map = \"$DIST/.$plat.map\";#" \
        -e "s#cache_dir  = \".*\";#cache_dir  = \"$DIST/.$plat-cache\";#" \
        -e "s#flags = \[\"--strict\"\];#flags = [\"--strict\", \"host=$plat\", \"platform=$plat\"];#" \
        compiler/coral.crlb > "$tmp"
    ( cd compiler && "$CORALC" build -f "$tmp" --force --dry-run --emit-c ) \
        > "$log" 2>&1 || {
            echo "package: compiler build failed for $plat (see dist/.$plat.log)" >&2
            exit 1
        }
    rm -f "$tmp" "$log"
    rm -rf "$DIST/.$plat-cache"
    echo "package: dist/coralc-$plat.c"
}

emit linux linux
emit windows windows

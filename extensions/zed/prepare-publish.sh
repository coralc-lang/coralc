#!/usr/bin/env bash
# Prepare the Coral extension for submission to zed-industries/extensions.
#
#   extensions/zed/prepare-publish.sh --build   also rebuild extension.wasm
#                                               and the downloadable artifacts
#
# The grammar lives in coral-zed/tree-sitter-coral, alongside the extension.
# Zed's builder clones [grammars.coral].repository into <extension>/grammars/coral
# and then appends `.path`. The source cannot live at grammars/coral itself:
# that path is the builder's clone destination, and it must not already exist.
#
# Commit grammar changes first: the manifest revision must contain both
# tree-sitter-coral/src/parser.c and tree-sitter-coral/grammar.js.
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO="$(CDPATH= cd -- "$ROOT/../.." && pwd)"
ZED_DIR="${CORAL_ZED_DIR:-$REPO/../coral-zed}"
BUILD=0

for arg in "$@"; do
    case "$arg" in
        --build) BUILD=1 ;;
        -h|--help)
            echo "usage: $0 [--build]"
            exit 0 ;;
        *) echo "unknown argument: $arg" >&2; exit 2 ;;
    esac
done

[ -f "$ZED_DIR/extension.toml" ] || {
    echo "missing $ZED_DIR/extension.toml" >&2
    exit 1
}
[ -f "$ZED_DIR/LICENSE" ] || {
    echo "missing $ZED_DIR/LICENSE; the registry rejects extensions without an accepted license" >&2
    exit 1
}
for f in tree-sitter-coral/grammar.js tree-sitter-coral/src/parser.c; do
    [ -f "$ZED_DIR/$f" ] || {
        echo "missing $ZED_DIR/$f" >&2
        exit 1
    }
done

if [ -n "$(git -C "$ZED_DIR" status --porcelain -- tree-sitter-coral)" ]; then
    echo "error: tree-sitter-coral has uncommitted changes." >&2
    echo "       Commit the grammar first so the manifest revision contains it:" >&2
    echo "         git -C $ZED_DIR add tree-sitter-coral && git -C $ZED_DIR commit" >&2
    exit 1
fi

REV=$(git -C "$ZED_DIR" rev-parse HEAD)
for f in tree-sitter-coral/grammar.js tree-sitter-coral/src/parser.c; do
    if ! git -C "$ZED_DIR" cat-file -e "$REV:$f" 2>/dev/null; then
        echo "error: $f is not committed at $REV" >&2
        exit 1
    fi
done

VERSION=$(python3 -c 'import sys,tomllib; print(tomllib.load(open(sys.argv[1],"rb"))["version"])' \
    "$ZED_DIR/extension.toml")

python3 - "$ZED_DIR/extension.toml" "$REV" <<'PY'
import pathlib, re, sys

path, rev = sys.argv[1:3]
text = pathlib.Path(path).read_text()
zed_url = 'https://github.com/coralc-lang/coral-zed'
grammar_path = 'tree-sitter-coral'

text = re.sub(
    r'(?m)^(repository\s*=\s*)"[^"]*"',
    rf'\1"{zed_url}"', text, count=1)


def set_key(document, header, key, value):
    pattern = rf'(?ms)(^\[{re.escape(header)}\]\s*$.*?)(?=^\[|\Z)'
    match = re.search(pattern, document)
    if not match:
        raise SystemExit(f'missing [{header}]')
    block, count = re.subn(
        rf'(?m)^{re.escape(key)}\s*=.*$',
        f'{key} = "{value}"', match.group(1), count=1)
    if count != 1:
        raise SystemExit(f'missing {key} in [{header}]')
    return document[:match.start(1)] + block + document[match.end(1):]


text = set_key(text, 'grammars.coral', 'repository', zed_url)
text = set_key(text, 'grammars.coral', 'path', grammar_path)
text = set_key(text, 'grammars.coral', 'rev', rev)
pathlib.Path(path).write_text(text)
print(f'stamped grammar rev {rev}')
PY

if [ "$BUILD" -eq 1 ]; then
    ( cd "$ZED_DIR" && cargo build --release --target wasm32-wasip2 )
    cp "$ZED_DIR/target/wasm32-wasip2/release/coral_extension.wasm" "$ZED_DIR/extension.wasm"
    "$REPO/extensions/package.sh"
fi

echo
echo "extension manifest:"
sed -n '1,30p' "$ZED_DIR/extension.toml"
echo
echo "registry check:"
for url in \
    "https://raw.githubusercontent.com/coralc-lang/coral-zed/main/extension.toml" \
    "https://raw.githubusercontent.com/coralc-lang/coral-zed/$REV/tree-sitter-coral/src/parser.c"
do
    if curl -fsSL -o /dev/null --max-time 15 "$url" 2>/dev/null; then
        echo "  OK  $url"
    else
        echo "  MISSING/PRIVATE  $url"
    fi
done
cat <<EOF

Before submitting:
  1. Push coral-zed; the submodule commit must be on a branch.
  2. Make the repository public; the registry clones it anonymously.
  3. Verify the extension in Zed at the exact submodule commit.
  4. Open one PR against zed-industries/extensions:

       git submodule add https://github.com/coralc-lang/coral-zed.git extensions/coral
       # extensions.toml:
       # [coral]
       # submodule = "extensions/coral"
       # version = "$VERSION"
       pnpm sort-extensions

  5. Keep extension.toml's version equal to the extensions.toml version.
EOF

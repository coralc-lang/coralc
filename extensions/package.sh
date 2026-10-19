#!/usr/bin/env bash
# Package the Coral editor extensions into this repository.
#
#   extensions/vscode/coral-<version>.vsix   (side-loadable in VS Code forks)
#   extensions/zed/coral-zed-<version>.tar.gz (prebuilt wasm, no Rust needed)
#
# Sources stay in the sibling checkouts so this repository only carries the
# artifacts users download:
#
#   CORAL_VSCODE_DIR=/path/to/coral-vscode
#   CORAL_ZED_DIR=/path/to/coral-zed
#
# The Zed artifact is installed by extensions/zed/install.sh or install.ps1;
# the VSIX is only ever downloaded, never installed, by our scripts.
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO="$(CDPATH= cd -- "$ROOT/.." && pwd)"
VSCODE_DIR="${CORAL_VSCODE_DIR:-$REPO/../coral-vscode}"
ZED_DIR="${CORAL_ZED_DIR:-$REPO/../coral-zed}"

die() { echo "package-extensions: $*" >&2; exit 1; }

[ -f "$VSCODE_DIR/package.json" ] || die "missing $VSCODE_DIR/package.json"
[ -f "$ZED_DIR/extension.toml" ] || die "missing $ZED_DIR/extension.toml"
[ -f "$ZED_DIR/extension.wasm" ] || die "missing $ZED_DIR/extension.wasm (build it first)"
[ -f "$ZED_DIR/grammars/coral.wasm" ] || die "missing $ZED_DIR/grammars/coral.wasm (build it first)"

for f in "$ZED_DIR/extension.wasm" "$ZED_DIR/grammars/coral.wasm"; do
    [ "$(head -c 4 "$f" | od -An -tx1 | tr -d ' \n')" = "0061736d" ] \
        || die "$f is not a WebAssembly module"
done

VS_VERSION=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' \
    "$VSCODE_DIR/package.json")
ZED_VERSION=$(python3 -c 'import sys,tomllib; print(tomllib.load(open(sys.argv[1],"rb"))["version"])' \
    "$ZED_DIR/extension.toml")
ZED_REV=$(git -C "$ZED_DIR" rev-parse HEAD 2>/dev/null || echo unknown)

echo "== VS Code extension $VS_VERSION"
python3 "$VSCODE_DIR/tools/package-vsix.py" \
    --out "$ROOT/vscode/coral-$VS_VERSION.vsix"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM
STAGE="$TMP/coral"
mkdir -p "$STAGE/grammars" "$STAGE/languages"

for f in extension.wasm grammars/coral.wasm; do
    cp "$ZED_DIR/$f" "$STAGE/$f"
done
cp -R "$ZED_DIR/languages/coral" "$STAGE/languages/coral"
for d in icons icon_themes; do
    [ -d "$ZED_DIR/$d" ] && cp -R "$ZED_DIR/$d" "$STAGE/$d"
done
for f in README.md LANGUAGE-SERVER.md PROTOCOL.md; do
    [ -f "$ZED_DIR/$f" ] && cp "$ZED_DIR/$f" "$STAGE/$f"
done

python3 - "$ZED_DIR/extension.toml" "$STAGE" "$ZED_REV" <<'PY'
import json, pathlib, re, sys, tomllib

src, stage, rev = sys.argv[1:4]
toml_path = pathlib.Path(src)
text = toml_path.read_text()
data = tomllib.loads(text)

# The artifact must be portable: never ship a file:// grammar URL or a stale
# revision. `rev` is the local extension commit that produced the wasm.
stamp = text
stamp = re.sub(
    r'(?m)^(repository\s*=\s*)"[^"]*"',
    r'\1"https://github.com/coralc-lang/coral-zed"',
    stamp, count=1)
stamp = re.sub(
    r'(?m)^(repository\s*=\s*)"[^"]*"',
    r'\1"https://github.com/coralc-lang/coral-zed"',
    stamp)
stamp = re.sub(r'(?m)^(rev\s*=\s*)"[^"]*"', rf'\1"{rev}"', stamp)
stage = pathlib.Path(stage)
(stage / 'extension.toml').write_text(stamp)

langs = pathlib.Path(stage) / 'languages' / 'coral'
queries = sorted(langs.glob('*.scm'))
query_lines = sum(len(p.read_text().splitlines()) for p in queries)

manifest = {
    'id': data['id'],
    'name': data['name'],
    'version': data['version'],
    'schema_version': data['schema_version'],
    'description': data.get('description', ''),
    'repository': 'https://github.com/coralc-lang/coral-zed',
    'authors': data.get('authors', []),
    'lib': {'kind': 'Rust', 'version': data['version']},
    'themes': data.get('themes', []),
    'icon_themes': data.get('icon_themes', []),
    'languages': data.get('languages', []),
    'grammars': data.get('grammars', {}),
    'language_servers': {},
    'context_servers': {},
    'slash_commands': {},
    'snippets': None,
    'capabilities': data.get('capabilities', []),
}
for name, body in data.get('language_servers', {}).items():
    manifest['language_servers'][name] = {
        'name': body.get('name', name),
        'language': body.get('language'),
        'languages': body.get('languages', []),
        'language_ids': body.get('language_ids', {}),
        'code_action_kinds': body.get('code_action_kinds'),
    }

index_entry = {
    'extension': {'manifest': manifest, 'dev': False},
    'language': {
        data['name']: {
            'extension': data['id'],
            'path': 'languages/coral',
            'matcher': {
                'path_suffixes': ['crl', 'coral'],
                'first_line_pattern': None,
                'modeline_aliases': [],
            },
            'hidden': False,
            'grammar': 'coral',
            'query_files': query_lines,
        }
    },
    'icon_theme': {
        name: {'extension': data['id'], 'path': path}
        for name, path in {'Coral': 'icon_themes/coral.json'}.items()
        if (pathlib.Path(stage) / path).is_file()
    },
}

(stage / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
(stage / 'index-entry.json').write_text(json.dumps(index_entry, indent=2) + '\n')
print(f"   manifest: {data['name']} {data['version']}, grammar rev {rev[:12]}")
PY

echo "== Zed extension $ZED_VERSION"
tar -czf "$ROOT/zed/coral-zed-$ZED_VERSION.tar.gz" -C "$STAGE" .

printf '%s\n' "$VS_VERSION" > "$ROOT/vscode/VERSION"
printf '%s\n' "$ZED_VERSION" > "$ROOT/zed/VERSION"

echo
echo "artifacts:"
for f in "$ROOT/vscode/coral-$VS_VERSION.vsix" "$ROOT/zed/coral-zed-$ZED_VERSION.tar.gz"; do
    printf '  %s  %s bytes\n' "$(sha256sum "$f" | cut -d' ' -f1)" "$(stat -c%s "$f")"
    printf '  %s\n' "$f"
done

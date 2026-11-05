# coralc — final plan (agreed)

One document for the build system + self-host import rework. Authoritative until
changed here. Specs it refines: `build_sys.md`, `imports.md`.

## 1. One executable

`coralc` = builder + compiler in a **single binary**.

- Entry: `compiler/coral-frontend/coralc.crl` — `main()`, eternal args (read
  `/proc/self/cmdline`, no argc/argv), `variant Command`, `variant Flag`.
- Links `coral-build` (crlb parse, walk, fingerprints, map output) as a leaf
  module. Dependency direction: `coral-frontend → coral-build` (acyclic;
  coral-build never imports the frontend).
- Commands: `build` (default), `map`, plus follow-ups (`init`, `run`) later.
- Flags: build file path (`-f`), `--strict`, `--dry-run` (compile, no output —
  used for edge collection), unused-local warnings (always on), opt/debug passthrough.
- `test_builder.crl` stays as a plain test file, not part of the binary.

## 2. `coralc map` — auto module discovery

- Walks `root` (from the build file) for every folder containing `lib.crl`.
- Registers finds as modules: splices entries into the build file's
  `modules = [...]` array, **commented out** (`// "newmod",`) — you uncomment
  what you accept. Re-running is idempotent (skips already-listed names).
- **Edit method: line splice on raw text** (locate the `modules` array, insert
  before its closing `]`). Preserves your formatting/comments; no reserialize.
  The map command is rare and human-reviewed, so textual splicing is enough.
- Aliases are never auto-generated for use. `coralc map` may drop suggested
  alias lines, commented, next to the module block; real aliases are written by
  hand (or uncommented).
- `include "other.crlb";` in the root build file pulls other workspace build
  files (already parsed by the crlb parser, `NodeKind::Include`); the map
  command updates the file that owns the `modules` array it splices.

## 3. Builder responsibilities (post-rework)

Does:

- Parse the `.crlb` (schema/strict/build/alias/include/task).
- E1001 `lib.crl` existence per module (`bScanLib`), E1003 alias validation
  (`bValidateAliases`).
- Walk module dirs → per-module **file lists** + **content fingerprints**
  (staleness input). Fingerprint pass is split out of `bScanImports`.
- Hand file lists + modules + aliases to the compiler **in-process** (no temp
  files, no second parse).
- Write `.coral/modules.map` (`+ module → dir`, `@ alias → folder`).

Does **not** do:

- **No import scanning. `bScanImports` deleted** (E1005 goes with it — imports
  are the compiler's business, at compile time).
- No re-export parsing (compiler reads `lib.crl` itself).

## 4. Import syntax — self-host only

**Bootstrap is never touched.** Existing `.crl` sources keep their current
string syntax (bootstrap compiles them); the self-host is where the language
evolves.

Valid (self-host):

```crl
mod token   = import coral-common::token;   // prefix from map (module or alias), rest = file in that folder
mod lexer   = import lexer;                 // bare name = own-dir file, no extension
pub mod lexer = import lexer;               // export: own dir only, no extension, lives in lib.crl
import file::math::core { square };         // symbol import via namespace path
import(lib) std::math { pow };              // KEEP: global space (~/.coral/lib, ./lib), not the user project
pub mod math = import(lib) std::math;       // (lib) with mod — stays
import std { ios { print, read }, string }; // nested groups — new, self-host parser
```

Invalid (self-host, everywhere):

```crl
import "path";              // bare string — always an error
mod x = import "path";      // string target removed entirely
pub mod m = import "path";  // incl. exports
```

Nested groups: parser flattens leaves to qualified paths at parse time
(`ios { print, read }` → `ios::print`, `ios::read`; alias and `*` still work on
leaves). No `ImportSymbol` shape change.

Resolution (compile time):

1. Split path at `::`. Single name → file in the importing file's own dir.
2. Prefix → modules.map: `@ alias` or `+ module` → folder; remaining path →
   `<folder>/<name>.crl`.
3. `(lib)` → skip project entirely, resolve in global space.
4. Loading a module prefix means loading its `lib.crl`; visibility comes from
   its re-exports (own-dir files only, since string/`..` imports are gone).

## 5. Dependency graph & staleness

Edges are **not scanned**. They are produced by compilation:

- A compilation that produces no output (`--dry-run`) or any subsequent
  compilation with changes resolves every import → knows `src file → target
  module` edges → reports them to the builder, which persists `.coral/graph`.
- Runs with no recorded graph compile everything (cold start), then write it.
- Topo order + E1006 cycle detection run off the recorded graph — only stale
  modules are re-decided via fingerprints (content hash per module, existing
  scheme).

Decision (per "you decide"): **module-level edges, newline records
`<module> -> <module>`, merged incrementally** — trivially append/diffable, no
rehash of unchanged files, DFS topo stays as-is (`bDfs`).

## 6. Implementation order

1. **Self-host parser**: remove String branches from `parseImportDecl` and
   `parseModReexport` (String → clean error, no capture); add nested import
   groups in `parseImportSymbols` (flatten to qualified paths).
2. **Tests**: update self-host cases (`test.crl:580/598/616/717-725`) from
   `"path"` strings to name-paths; add nested-group + string-rejection cases.
   Suite green (`****done****`, exit 0) after this step.
3. **Builder**: delete `bScanImports` (+ E1005, `::` branches); split file
   walk/fingerprint into its own pass; keep E1001/E1003/map writer. Builder
   gcc-clean; test_builder green (it is just a test).
4. **coralc.crl**: main, Command/Flag variants, wire `build` (parse → walk →
   hand files → compile → collect edges → write graph/map).
5. **Edge collection**: compiler reports resolved import edges from a compile;
   builder merges into `.coral/graph`; topo + E1006 off the graph.
6. **`coralc map`**: lib.crl walk + commented line-splice into `modules`.
7. Cleanup: pointer warnings, structParamName switch, file splits, EBNF +
   docs update (`build_sys.md`, `imports.md`), std roadmap, `coral-entities`
   scaffold.

## 7. Efficiency notes / known issues

- Single process (no Python spawn), one parse pass with inline resolution,
  in-process file handoff — all wins.
- Content-hash fingerprints re-read every file each run; can move to
  mtime/size later without changing the graph format.
- Informational (bootstrap, untouched): `_module_map_candidates` matches the
  whole import path against map keys, so alias-prefixed paths (`ast::decl`)
  won't hit `@ ast` lines — but bootstrap resolves them anyway via
  `_import_name` → `ast/decl` file search only for `::` paths whose prefix is a
  real folder. No action now; matters only if/when the bootstrap must honor
  aliases.
- Migration of the tree's own `.crl` sources to name-path syntax is a later,
  separate step (bootstrap still compiles string imports — do not batch it
  with this work).

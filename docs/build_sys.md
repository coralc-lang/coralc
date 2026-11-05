Got it — locking in your decisions:

- **Q4:** **B** — explicit `modules = [...]` list. Plus **aliases** so files write `import lexer::table` instead of `import coral_lexer::table`.
- **Q5:** **Option 1** — builder writes `.coral/modules.map`, compiler reads it.
- **Entry:** `coral-frontend` (not `coral-lexer`).
- **Compiler does NOT walk the tree.** Only the builder walks. (I'll explain why this is correct below, since you asked for the reason against A.)

Let me answer the "A vs B" question properly first, then write the full spec.

---

## Why B is correct here (and why A is wrong for your pipeline)

You asked: *"making the compiler walk everything is stressful of the pipeline, as the overhead from compiling all these files comes — or is that not what happens?"*

You're half-right. Let me separate the two concerns:

**Concern 1: Who walks the tree?**
- **A (auto-walk):** builder walks, discovers modules. Compiler doesn't walk — compiler reads the map. So A doesn't make the *compiler* slow.
- **B (explicit list):** builder walks only the listed folders. Compiler reads the map. Same compiler behavior.

So **A vs B is not about compiler speed** — both keep the compiler dumb. A vs B is about **who owns the source of truth for "what modules exist."**

**Concern 2: Why B wins for you**

1. **Determinism.** With A, a stray `lib.crl` you accidentally leave in `compiler/` (backup folder, scratch dir, vendor dump) silently becomes a module. With B, you list what's real. The build graph can't be changed by accident.
2. **Skip lists fall out naturally.** You said folders can be skipped. With A you need `skip = [...]` on top of the walk. With B, skipping = not listing it. One concept, not two.
3. **Aliases need a home.** `import lexer::table` needs a mapping `lexer → coral-lexer`. Where does that mapping live? Naturally in the build file next to the module list. With A, aliases have no obvious anchor.
4. **You can still `coralc map` for discovery.** You said `coralc map` re-scans and adds new `lib.crl` files. So the "don't want to hand-maintain the list" problem is solved by a *tool*, not by making the walk implicit. Explicit list + auto-update tool = best of both.
5. **Incremental + cache-friendly.** Cache fingerprint = list of modules + their file hashes. Explicit list = stable fingerprint. A walk = fingerprint changes when unrelated folders change.

**The one thing A does better:** zero-config for new projects. But you already planned `coralc init` and `coralc map`, which covers that.

So: **B is correct.** Compiler stays dumb, builder stays explicit, `coralc map` keeps the list fresh.

Now the full spec.

---

# `crl` Build System — Full Specification

## 0. Naming

| Thing | Name | Extension |
|---|---|---|
| Source language | Coral | `.crl` |
| Build file | Coral Build | `.crlb` |
| Compiler | `coralc` | — |
| Builder | `coralc` | — |
| Module map | `modules.map` | — |
| Cache dir | `.coral/` | — |

---

## 1. Directory layout (example)

```
myproject/
├── coral.crlb                     # the build file (root)
├── .coral/                        # cache + generated
│   ├── modules.map
│   ├── cache/
│   └── graph.dot
├── compiler/
│   ├── coral-ast/
│   │   └── lib.crl
│   ├── coral-backend/
│   ├── coral-common/
│   │   ├── lib.crl
│   │   ├── slice.crl
│   │   └── token.crl
│   ├── coral-context/
│   ├── coral-diagnostics/
│   │   ├── lib.crl
│   │   └── lexer_diag.crl
│   ├── coral-entities/
│   ├── coral-frontend/            # entry
│   ├── coral-ir/
│   ├── coral-lexer/
│   │   ├── lib.crl
│   │   ├── base.crl
│   │   ├── escape.crl
│   │   ├── ident.crl
│   │   ├── lexer.crl
│   │   ├── number.crl
│   │   ├── operator.crl
│   │   ├── skip_ws.crl
│   │   ├── string.crl
│   │   └── table.crl
│   ├── coral-module/
│   ├── coral-parser/
│   │   ├── lib.crl
│   │   └── expr.crl
│   ├── coral-semantics/
│   └── coral-source/
└── build/
    └── coralc                    # output
```

---

## 2. Build file grammar (`.crlb`)

```ebnf
build_file    = { decl } ;
decl          = build_decl | alias_decl | task_decl | include_decl ;

build_decl    = "build" STRING "{" { build_field } "}" ;
build_field   = field | modules_field | skip_field | override_block ;

field         = IDENT "=" value ";" ;
modules_field = "modules" "=" "[" [ STRING { "," STRING } [ "," ] ] "]" ";" ;
skip_field    = "skip"    "=" "[" [ STRING { "," STRING } [ "," ] ] "]" ";" ;

override_block = "override" STRING "{" { field } "}" ;

alias_decl    = "alias" IDENT "=" STRING ";" ;
task_decl     = "task" STRING "{" { task_field } "}" ;
task_field    = field | "after" "=" list ";" | "exec" "=" STRING ";" ;

include_decl  = "include" STRING ";" ;

value         = STRING | NUMBER | BOOL | list ;
list          = "[" [ value { "," value } [ "," ] ] "]" ;

IDENT         = /[A-Za-z_][A-Za-z0-9_-]*/ ;
STRING        = '"' { /[^"\\]/ | "\\" . } '"' ;
NUMBER        = /[0-9]+/ ;
BOOL          = "true" | "false" ;

(* comments *)
comment       = "#" { /[^\n]/ } ;
```

### Reserved build fields

| Field | Type | Meaning |
|---|---|---|
| `root` | string | Root dir of the source tree (for paths) |
| `entry` | string | Module name that is the executable |
| `target` | string | `native-x86_64`, `native-arm64`, `wasm32`, `bytecode` |
| `opt` | string | `debug`, `release`, `size` |
| `output` | string | Output binary path |
| `module_map` | string | Where to write `modules.map` (default `.coral/modules.map`) |
| `cache_dir` | string | Default `.coral/cache` |
| `flags` | list | Extra flags passed to `coralc` |
| `modules` | list | **Required.** Which folders are build modules |
| `skip` | list | Subfolders to exclude during any scan |
| `alias` | decl | `name → folder` mapping for imports |
| `override` | block | Per-module field overrides |
| `task` | decl | Named task (run/test/clean/etc.) |

---

## 3. Builder's view of `lib.crl`

The builder parses `lib.crl` **only** to extract re-export lines. Everything else in the file is ignored (it's the compiler's problem).

```ebnf
lib_file      = { lib_item } ;
lib_item      = pub_mod | other ;      (* other = anything, skipped by builder *)
pub_mod       = "pub" "mod" IDENT "=" "import" STRING ";" ;
```

Extraction rule:

- Scan for `pub mod NAME = import "PATH";` at any nesting depth that the builder can safely detect (line-oriented is fine).
- Each match registers: **`<this_folder>::<NAME>` → resolved(PATH)** in the global module table.
- `PATH` is resolved **relative to the `lib.crl` file's folder**.

Resolution of `PATH`:

1. If `<folder>/<PATH>.crl` exists → that file.
2. Else if `<folder>/<PATH>/lib.crl` exists → that folder's surface.
3. Else → error `E1004 unresolved re-export path`.

---

## 4. The global module table

Built by the builder in one pass. Stored in `.coral/modules.map`.

### Format

Plain text, line-oriented, stable, diff-friendly:

```
# coral modules.map v1
# <folder>::<export>  →  <resolved-path>
common::token       →  compiler/coral-common/token.crl
common::slice       →  compiler/coral-common/slice.crl
diagnostics::lexer_diag  →  compiler/coral-diagnostics/lexer_diag.crl
lexer::base         →  compiler/coral-lexer/base.crl
lexer::escape       →  compiler/coral-lexer/escape.crl
lexer::ident        →  compiler/coral-lexer/ident.crl
lexer::lexer        →  compiler/coral-lexer/lexer.crl
lexer::number       →  compiler/coral-lexer/number.crl
lexer::operator     →  compiler/coral-lexer/operator.crl
lexer::skip_ws      →  compiler/coral-lexer/skip_ws.crl
lexer::string       →  compiler/coral-lexer/string.crl
lexer::table        →  compiler/coral-lexer/table.crl
parser::expr        →  compiler/coral-parser/expr.crl

# aliases (from build file)
@lexer::table             →  compiler/coral-lexer/table.crl
@lexer::lexer             →  compiler/coral-lexer/lexer.crl
@parser::expr             →  compiler/coral-parser/expr.crl
```

- Lines starting with `#` are comments.
- Unaliased entries use the raw folder name.
- Aliased entries start with `@` and are what source files actually write.

### Why text and not JSON

- Diffs cleanly in git.
- Trivially greppable.
- No parser dependency.
- Fast to load (one line scan).

---

## 5. Aliases

Source files write:

```crl
import lexer::table { TokenTable };
import parser::expr  { Expr };
```

Not:

```crl
import coral-lexer::table { TokenTable };
import coral-parser::expr { Expr };
```

Aliases are declared in the build file:

```crlb
alias lexer  = "coral-lexer/lib.crl";
alias parser = "coral-parser/lib.crl";
alias common = "coral-common/lib.crl";
alias diag   = "coral-diagnostics/lib.crl";
```

The builder applies aliases when writing `modules.map`, so the compiler never sees `coral-lexer::` — it sees `lexer::` directly.

**Rules:**

- An alias must point to a folder in `modules`.
- An alias name must not collide with another alias or a bare folder name.
- Aliases are only for **module imports**. Path imports (`import "token"`) are unaffected.

---

## 6. Import forms (compiler + builder)

| Form | Kind | Resolver |
|---|---|---|
| `import "token" { ... }` | Path | Compiler, relative to current file |
| `import ".." { ... }` | Path | Compiler |
| `import "../foo" { ... }` | Path | Compiler |
| `import lexer::table { ... }` | Module | **Builder** via `modules.map` |
| `import common::token { ... }` | Module | Builder |
| `import common { ... }` | Module (surface) | Builder — pulls everything `coral-common/lib.crl` re-exports |

The compiler sees `import lexer::table` and asks the module map: "give me the path for `lexer::table`." The map answers. The compiler never walks.

---

## 7. Build algorithm

```
coralc build
  1. read coral.crlb
  2. resolve `root`, `modules`, `skip`, `alias`
  3. for each module in `modules`:
       - locate <root>/<module>/lib.crl
       - error E1001 if missing
       - parse for `pub mod NAME = import "PATH";`
       - for each, resolve PATH to a file or folder
       - register in module table under <module>::NAME
  4. error E1002 on duplicate <module>::NAME
  5. error E1003 on alias pointing to missing module
  6. write .coral/modules.map   (unaliased + aliased entries)
  7. for each module, for each .crlin it:
       - scan for `import x::y` module-imports
       - resolve via map
       - add edge  <this-module> → <target-module>
  8. error E1005 on unresolved module import
  9. error E1006 on cycle (with trace)
 10. topo-sort modules
 11. for each module in order:
       - fingerprint = hash(lib.crl+ all .crlin folder + dep fingerprints)
       - if fingerprint in cache, skip
       - else:  coralc --emit-obj --module-map=.coral/modules.map <folder>/*.crl
 12. link entry module → output
 13. write cache
```

---

## 8. Error formats

Consistent, single-line first, details after:

```
E1001  missing lib.crl
  module: coral-frontend
  path:   compiler/coral-frontend/lib.crl
  hint:   run `coralc init coral-frontend` or add a lib.crl

E1002  duplicate module export
  name:   coral-lexer::table
  first:  compiler/coral-lexer/lib.crl:4
  second: compiler/coral-lexer/alt/lib.crl:2

E1003  alias points to unknown module
  alias:  lexer
  target: coral-lexer
  list:   modules = [...]

E1004  unresolved re-export path
  file:   compiler/coral-common/lib.crl:3
  path:   "token"
  tried:  compiler/coral-common/token.crl
          compiler/coral-common/token/lib.crl

E1005  unresolved module import
  file:   compiler/coral-lexer/lexer.crl:1
  import: common::token
  map:    .coral/modules.map
  hint:   is coral-common in `modules`?

E1006  dependency cycle
  cycle:  coral-lexer → coral-parser → coral-lexer
  paths:
    compiler/coral-lexer/lib.crl
    compiler/coral-parser/lib.crl
```

---

## 9. CLI spec

```
coralc init [dir]              scaffold empty project:
                              dir/
                                coral.crlb
                                .coral/
                                <module>/
                                  lib.crl

coralc build                   run full build (uses cache)
coralc build --force           ignore cache
coralc build --module NAME     build one module + deps
coralc build --emit-map        write modules.map only, no compile

coralc map                     rescan tree; add any new lib.crlto `modules`
coralc map --dry               show what would be added, don't write

coralc run                     build entry, then exec output
coralc clean                   wipe .coral/cache and build/
coralc graph                   dump .coral/graph.dot
coralc doctor                  validate build file, aliases, cycles
```

---

## 10. Worked example — your tree

### `coral.crlb`

```crlb
build "coralc" {
    root       = "compiler/"
    entry      = "coral-frontend/coral.crl"
    target     = "native-x86_64"
    opt        = "release"
    output     = "build/coralc"
    module_map = ".coral/modules.map"
    cache_dir  = ".coral/cache"

    flags = ["--strict"]

    modules = [
        "coral-ast",
        "coral-backend",
        "coral-common",
        "coral-context",
        "coral-diagnostics",
        "coral-entities",
        "coral-frontend",
        "coral-ir",
        "coral-lexer",
        "coral-module",
        "coral-parser",
        "coral-semantics",
        "coral-source",
    ]

    skip = ["target", "vendor"]
}

# short names for imports
alias lexer   = "coral-lexer/lib.crl";
alias parser  = "coral-parser/lib.crl";
alias common  = "coral-common/lib.crl";
alias diag    = "coral-diagnostics/lib.crl";
alias ast     = "coral-ast/lib.crl";
alias ir      = "coral-ir/lib.crl";
alias sem     = "coral-semantics/lib.crl";
alias src     = "coral-source/lib.crl";

# per-module overrides
override "coral-lexer" {
    flags = ["--no-inline"];
}

override "coral-parser" {
    opt = "debug";           # parser is hot, keep symbols
}

# tasks
task "run" {
    after = ["build"];
    exec  = "build/coralc";
}

task "test" {
    after = ["build"];
    exec  = "build/coralc --self-test";
}
```

### `compiler/coral-common/lib.crl`

```crl
pub mod token = import "token";
pub mod slice = import "slice";

# regular code is allowed too
pub str version() {
    return "0.1.0";
}
```

### `compiler/coral-lexer/lib.crl`

```crl
pub mod base     = import "base";
pub mod escape   = import "escape";
pub mod ident    = import "ident";
pub mod lexer    = import "lexer";
pub mod number   = import "number";
pub mod operator = import "operator";
pub mod skip_ws  = import "skip_ws";
pub mod string   = import "string";
pub mod table    = import "table";
```

### `compiler/coral-lexer/lexer.crl` (uses module import)

```crl
import common::token { TokenKind, Token };
import common::slice { Slice };

import "ident"  { scan_ident };
import "number" { scan_number };

pub Token lex(Slice src) {
    # ...
}
```

Note:
- `common::token` → module import → resolved by builder via `modules.map`.
- `"ident"` → path import → sibling file, resolved by compiler locally.

### `.coral/modules.map` (generated)

```
# coral modules.map v1 — generated by `coralc build`, do not edit
common::token        →  compiler/coral-common/token.crl
common::slice        →  compiler/coral-common/slice.crl
diag::lexer_diag     →  compiler/coral-diagnostics/lexer_diag.crl
lexer::base          →  compiler/coral-lexer/base.crl
lexer::escape        →  compiler/coral-lexer/escape.crl
lexer::ident         →  compiler/coral-lexer/ident.crl
lexer::lexer         →  compiler/coral-lexer/lexer.crl
lexer::number        →  compiler/coral-lexer/number.crl
lexer::operator      →  compiler/coral-lexer/operator.crl
lexer::skip_ws       →  compiler/coral-lexer/skip_ws.crl
lexer::string        →  compiler/coral-lexer/string.crl
lexer::table         →  compiler/coral-lexer/table.crl
parser::expr         →  compiler/coral-parser/expr.crl
...
```

### Build graph (edges derived from imports)

```
coral-common
    ↑
coral-lexer ──→ coral-parser ──→ coral-ast
    ↑                                ↑
coral-frontend ─────────────────────┘
    ↓
coral-ir ──→ coral-semantics
```

(Exact edges depend on what your `.crl` files import. The builder derives them, you don't write them.)

---

## 11. `coralc init` and `coralc map`

### `coralc init myproject`

```
myproject/
├── coral.crlb
├── .coral/
└── src/
    └── lib.crl         # empty
```

`coral.crlb`:

```crlb
build "myproject" {
    root   = "src/"
    entry  = "src"
    target = "native-x86_64"
    opt    = "debug"
    output = "build/myproject"
    modules = ["src"]
}
```

`src/lib.crl`:

```crl
# public surface of src
```

### `coralc map`

Walks `root/`, finds every folder containing `lib.crl`, and:

- adds any missing folder to `modules = [...]`
- removes any listed folder with no `lib.crl`
- refreshes `modules.map`
- reports the diff

```
$ coralc map
+ added   coral-module
+ added   coral-context
~ updated modules.map  (14 entries, 3 aliases)
```

With `--dry`, prints but doesn't write.

---

## 12. Caching

Each module gets a fingerprint:

```
fingerprint(module) = hash(
    hash(every .crlin module folder, sorted),
    hash(lib.crl),
    for each dep in module: fingerprint(dep),
    build_flags_for(module),
    compiler_version,
)
```

Stored in `.coral/cache/<module>.fp`. On build:

- fingerprint match → skip compilation
- mismatch → recompile, cascade to dependents

`coralc clean` wipes `.coral/cache/`.

---

## 13. Reference builder pseudocode

```pseudo
function build(build_file):
    cfg = parse_crlb(build_file)
    root = cfg.root
    modules = cfg.modules
    skip = cfg.skip or []
    aliases = cfg.aliases or {}

    # 1. scan lib.crlfiles
    table = {}                       # "folder::name" → path
    for m in modules:
        libpath = join(root, m, "lib.crl")
        if not exists(libpath):
            error E1001(m, libpath)
        src = read(libpath)
        for (name, path) in scan_pub_mod(src):
            resolved = resolve_path(join(root, m), path)
            if resolved == null:
                error E1004(libpath, path)
            key = m + "::" + name
            if key in table:
                error E1002(key, table[key], resolved)
            table[key] = resolved

    # 2. validate aliases
    for (alias_name, target_folder) in aliases:
        if target_folder not in modules:
            error E1003(alias_name, target_folder)

    # 3. write modules.map (aliased + unaliased)
    emit_map(table, aliases)

    # 4. build import graph
    edges = {}                       # module → set(module)
    for m in modules:
        for file in walk_crl(join(root, m), skip):
            for imp in scan_module_imports(file):
                # imp looks like "lexer::table" or "common"
                folder = resolve_module(imp, table, aliases)
                if folder == null:
                    error E1005(file, imp)
                if folder != m:
                    edges[m].add(folder)

    # 5. cycle check
    if cycle = find_cycle(edges):
        error E1006(cycle)

    # 6. topo-sort
    order = topo_sort(edges)

    # 7. compile
    for m in order:
        fp = fingerprint(m, edges[m])
        if cached(m, fp) and not force:
            continue
        sources = walk_crl(join(root, m), skip)
        run("coralc",
            "--module-map", ".coral/modules.map",
            "--emit-obj",
            "--target", cfg.target,
            "--opt", cfg.opt,
            *module_flags(m, cfg),
            *sources)
        store_cache(m, fp)

    # 8. link
    link(cfg.entry, cfg.output)

    # 9. tasks
    run_pending_tasks(cfg, triggered_by="build")
```

---

## 14. Summary of design decisions

| Decision | Choice | Why |
|---|---|---|
| Build file extension | `.crlb` | Distinct from source |
| Build file syntax | Block + `key = value` | Familiar, readable, diff-friendly |
| Module list | Explicit (`modules = [...]`) | Deterministic, alias anchor, skip = not listed |
| Aliases | In build file | Short imports, no folder names in source |
| Compiler walks tree? | No | Only builder walks; compiler reads `modules.map` |
| Module map location | `.coral/modules.map` | Well-known, overridable |
| Module map format | Line-oriented text | Diffable, greppable, fast |
| `lib.crl` role | Source + re-export surface | Builder reads only `pub mod` lines |
| Path imports | `import "x"` | Compiler-local, sibling files |
| Module imports | `import x::y` | Builder-resolved via map |
| Caching | Fingerprint per module | Cascades through deps |
| Scaffolding | `coralc init`, `coralc map` | Zero to working project, auto-refresh |

---

If you want, next I can:

- write the **lexer/parser for `.crlb`** in your `.crl` language,
- or write the **`modules.map` reader** that `coralc` uses,
- or add a **`workspace`** concept (multiple `.crlb` files, one root).


// priority
another thing, importing wia string paths, woulld require a binding to a module alias, because the item is nameless

Here's the .crlb grammar exactly as we agreed on it — the EBNF from the spec, plus the field tables and the decisions you made about how it behaves.

EBNF

```ebnf
build_file    = { decl } ;
decl          = build_decl | alias_decl | task_decl | include_decl ;

build_decl    = "build" STRING "{" { build_field } "}" ;
build_field   = field | modules_field | skip_field | override_block ;

field         = IDENT "=" value ";" ;
modules_field = "modules" "=" "[" [ STRING { "," STRING } [ "," ] ] "]" ";" ;
skip_field    = "skip"    "=" "[" [ STRING { "," STRING } [ "," ] ] "]" ";" ;

override_block = "override" STRING "{" { field } "}" ;

alias_decl    = "alias" IDENT "=" STRING ";" ;
task_decl     = "task" STRING "{" { task_field } "}" ;
task_field    = field | "after" "=" list ";" | "exec" "=" STRING ";" ;

include_decl  = "include" STRING ";" ;

value         = STRING | NUMBER | BOOL | list ;
list          = "[" [ value { "," value } [ "," ] ] "]" ;

IDENT         = /[A-Za-z_][A-Za-z0-9_-]*/ ;
STRING        = '"' { /[^"\\]/ | "\\" . } '"' ;
NUMBER        = /[0-9]+/ ;
BOOL          = "true" | "false" ;

comment       = "#" { /[^\n]/ } ;
```

Reserved build fields

Field Type Meaning
root string Root dir of the source tree
entry string Module name that is the executable
target string native-x86_64, native-arm64, wasm32, bytecode
opt string debug, release, size
output string Output binary path
module_map string Where to write modules.map (default .coral/modules.map)
cache_dir string Default .coral/cache
flags list Extra flags passed to coralc
modules list Required. Which folders are build modules
skip list Subfolders to exclude during scan
alias decl name → folder mapping for imports
override block Per-module field overrides
task decl Named task (run/test/clean/etc.)

Decisions we locked in

· Extension: .crlb
· Syntax style: block + key = value (TOML-ish inside braces)
· Module list: explicit modules = [...] — not auto-walk
· Aliases: declared in the build file (alias lexer = "coral-lexer";) so source files write import lexer::table instead of import coral-lexer::table
· skip: folders excluded from the scan; not listing a folder in modules also excludes it
· override: per-module field overrides (flags, opt, etc.)
· task: named tasks with after and exec
· include: pulls in another .crlb (declared in grammar, not yet demonstrated in examples)
· Comments: # to end of line
· Trailing commas: allowed in lists

Canonical example

```crlb
build "coralc" {
    root       = "compiler/"
    entry      = "coral-frontend"
    target     = "native-x86_64"
    opt        = "release"
    output     = "build/coralc"
    module_map = ".coral/modules.map"
    cache_dir  = ".coral/cache"

    flags = ["--strict"]

    modules = [
        "coral-ast",
        "coral-backend",
        "coral-common",
        "coral-context",
        "coral-diagnostics",
        "coral-entities",
        "coral-frontend",
        "coral-ir",
        "coral-lexer",
        "coral-module",
        "coral-parser",
        "coral-semantics",
        "coral-source",
    ]

    skip = ["target", "vendor"]
}

alias lexer   = "coral-lexer";
alias parser  = "coral-parser";
alias common  = "coral-common";
alias diag    = "coral-diagnostics";
alias ast     = "coral-ast";
alias ir      = "coral-ir";
alias sem     = "coral-semantics";
alias src     = "coral-source";

override "coral-lexer" {
    flags = ["--no-inline"];
}

override "coral-parser" {
    opt = "debug";
}

task "run" {
    after = ["build"];
    exec  = "build/coralc";
}

task "test" {
    after = ["build"];
    exec  = "build/coralc --self-test";
}
```

Not yet shown in examples (grammar supports it, examples don't)

· include "other.crlb"; — never demonstrated
· Global flags = [...] at top level — mentioned but not shown
· store { ... } block for the content store — added later, not in the base grammar above
· Custom task names beyond run / test

If you want, I can fold the store block into the grammar properly, or add include examples so that piece stops being a dangling promise.

Here's a menu of additions, grouped by what they buy you. I'll mark each with value (how much it matters) and cost (how hard it is to build + how much it complicates the language). Pick the ones you want and I'll spec them out.

---

1. Project structure & workspace

workspace block

Multiple .crlb files, one root, shared cache + store. For monorepos.

```crlb
workspace "coral" {
    members = ["compiler", "runtime", "tools/*"];
    shared_cache = ".coral/cache";
}
```

· Value: high for anything beyond one project
· Cost: medium — needs a resolution order, inheritance rules

extends — build file inheritance

A project .crlb extends a base config.

```crlb
build "coralc" extends "base.crlb" {
    entry = "coral-frontend";
}
```

· Value: medium — cuts duplication across similar projects
· Cost: low — merge two maps, child wins

profiles — dev / release / ci

Named flag sets selected at invocation.

```crlb
profile "dev" {
    opt    = "debug";
    flags  = ["--debug-info"];
}

profile "release" {
    opt    = "release";
    flags  = ["--strict", "--lto"];
}

profile "ci" extends "release" {
    flags  = ["--deny-warnings"];
}
```

Then crl build --profile=ci.

· Value: high — everyone reinvents this badly
· Cost: low — it's just named overrides

---

2. Module & dependency controls

provides — capability declaration

A module says "I provide X" and dependents say "I need X" without naming the module.

```crlb
override "coral-lexer" {
    provides = ["lexer"];
}

override "coral-frontend" {
    requires = ["lexer", "parser"];
}
```

· Value: medium — decouples dependents from concrete module names
· Cost: medium — needs a resolution pass + conflict rules

features — conditional compilation

Cargo-style feature flags.

```crlb
features {
    default  = ["std"];
    std      = [];
    no_std   = [];
    debug_ir = ["dump-ir"];
}

override "coral-backend" {
    features = ["debug_ir"];
}
```

Source files gate on them. Build system enables/disables.

· Value: high for anything user-facing
· Cost: high — the compiler needs to know about feature flags too

exclude / include patterns

Glob filtering of files inside a module.

```crlb
override "coral-lexer" {
    exclude = ["**/*_test.crl", "**/scratch_*.crl"];
    include = ["**/*.crl"];
}
```

· Value: medium — useful once folders get big
· Cost: low — you already walk files

dep_versions / lockfile

Pin module versions across a workspace.

```crlb
deps {
    coral-common = "1.4.2";
    coral-ast    = "^2.0.0";
}
```

Emits coral.lock.

· Value: low unless you have external deps
· Cost: high — you need a registry concept

---

3. Build phases & steps

phase blocks — explicit pipeline stages

Instead of one build, name the stages.

```crlb
phase "lex" {
    on     = ["src/**/*.crl"];
    run    = "coralc --emit-tokens";
    output = ".coral/tokens/{stem}.tok";
}

phase "parse" {
    on     = [".coral/tokens/*.tok"];
    run    = "coralc --emit-ast";
    output = ".coral/ast/{stem}.ast";
    after  = ["lex"];
}
```

· Value: medium-high — gives you a real pipeline instead of a single compile
· Cost: medium — you need a phase scheduler

hook blocks — lifecycle callbacks

Run commands at fixed points.

```crlb
hook "pre-build" {
    run = "scripts/check-version.crl";
}

hook "post-build" {
    run = "scripts/sign-binary.sh";
    on  = "success";   # or "failure" / "always"
}
```

· Value: medium
· Cost: low

env — environment variables

Per-module or global env for spawned compiler processes.

```crlb
env = {
    CORAL_HOME = "./.coral";
    RUST_BACKTRACE = "1";
}

override "coral-backend" {
    env = { CORAL_OPT = "-O3"; };
}
```

· Value: medium — everyone needs it eventually
· Cost: low

shell / exec inline commands

Run a shell command as part of the build, capture output.

```crlb
task "gen-version" {
    exec   = "git describe --tags";
    output = ".coral/version.txt";
}
```

· Value: medium
· Cost: low

---

4. Targets & outputs

target blocks — multiple build outputs

One project, several binaries.

```crlb
target "coralc" {
    entry  = "coral-frontend";
    output = "build/coralc";
}

target "corald" {
    entry  = "coral-daemon";
    output = "build/corald";
}
```

· Value: high if you have more than one binary
· Cost: medium — the current entry/output fields become shorthand for the single-target case

link block — linker control

Explicit linker flags, libraries, ordering.

```crlb
link "coralc" {
    libs      = ["m", "pthread"];
    flags     = ["-static"];
    script    = "linker/coral.ld";
    strip     = true;
}
```

· Value: medium — needed for real projects
· Cost: low

artifact block — packaging

Describe the built artifact's metadata.

```crlb
artifact "coralc" {
    kind     = "executable";   # executable | library | object | archive
    format   = "elf64";        # elf64 | macho | wasm | pe
    install  = "/usr/local/bin";
}
```

· Value: medium
· Cost: low

---

5. Testing & quality

test blocks — declarative tests

First-class test declarations the builder runs.

```crlb
test "lexer basics" {
    module = "coral-lexer";
    exec   = "build/coralc --test-lexer";
    inputs = ["tests/lexer/*.crl"];
    expect = "tests/lexer/expected/";
}

test "parser roundtrip" {
    module = "coral-parser";
    exec   = "build/coralc --roundtrip";
    timeout = "30s";
}
```

Then crl test.

· Value: high — keeps test config out of shell scripts
· Cost: low-medium

bench blocks

Same shape as test, but timing.

```crlb
bench "lex throughput" {
    exec  = "build/coralc --bench-lex";
    input = "corpus/big.crl";
    runs  = 10;
}
```

· Value: low-medium
· Cost: low

lint / fmt blocks

Wire up formatters and linters as first-class tasks.

```crlb
lint {
    exec  = "coralc --lint";
    deny  = ["warnings"];
    paths = ["src/**/*.crl"];
}
```

· Value: medium
· Cost: low

---

6. Observability

verbose levels

Control output without CLI flags.

```crlb
log {
    level     = "info";        # error | warn | info | debug | trace
    timings   = true;
    format    = "human";       # human | json
}
```

· Value: medium
· Cost: low

metrics block

Emit build metrics to a file or endpoint.

```crlb
metrics {
    emit   = ".coral/metrics.json";
    fields = ["duration", "cache_hit", "object_size"];
}
```

· Value: low-medium — great for CI dashboards
· Cost: low

---

7. External integration

remote cache/store block

Point the content store at a remote.

```crlb
remote {
    url      = "https://cache.coral.dev";
    auth     = "token:${CORAL_CACHE_TOKEN}";
    fallback = "local";        # local | error
}
```

· Value: high once you have multiple machines
· Cost: high — needs a server

ci block

Describe what runs in CI, so local and CI share config.

```crlb
ci {
    profiles = ["ci"];
    tasks    = ["lint", "build", "test"];
    artifacts = ["build/coralc"];
}
```

· Value: medium
· Cost: low

deps block — external dependencies

Pull in third-party modules.

```crlb
deps {
    "github.com/foo/bar" = { tag = "v1.2.3"; };
    "crates.io/serde"    = { version = "1.0"; };
}
```

· Value: depends — only worth it if you have an ecosystem
· Cost: very high — registry, resolver, lockfile, fetcher

---

8. Language hygiene

schema versioning

Explicit schema version at the top of every file.

```crlb
schema = 1;

build "coralc" { ... }
```

Lets you evolve the grammar without breaking old files. The builder reads schema first and dispatches to the right parser.

· Value: high long-term
· Cost: low now, saves pain later

strict mode

Reject unknown fields, unknown blocks, unused aliases.

```crlb
strict = true;

build "coralc" {
    moduless = [...];   # typo → error, not silently ignored
}
```

· Value: high — catches typos that silently do nothing
· Cost: low

doc fields

Documentation attached to any block.

```crlb
build "coralc" {
    doc = "The reference Coral compiler.";
    ...
}

alias lexer = "coral-lexer";
alias lexer.doc = "short name for the lexer module";
```

· Value: low
· Cost: low

---

9. Editor / tooling support

lsp block

Hints for the language server.

```crlb
lsp {
    root    = "compiler/";
    exclude = ["vendor/**"];
}
```

· Value: medium if you build an LSP
· Cost: low

format block

Canonical formatting rules so crl fmt is deterministic.

```crlb
format {
    indent    = 4;
    align     = "=";
    max_width = 100;
}
```

· Value: medium
· Cost: low

---

10. Things I'd add first (my recommendation)

If you want a short list, in priority order:

1. schema version — one line now, saves you from a painful migration later
2. strict = true — turn it on by default; catches typos
3. profile blocks — dev/release/ci is a real need
4. target blocks — even if you have one binary today, you'll have two soon
5. test blocks — keeps test config in the build file, not in shell
6. env block — small, universally needed
7. phase blocks — the moment you want preprocessing or codegen, you need these
8. hook blocks — pre/post build, cheap to add
9. remote cache — once the local content store works
10. workspace — when the repo grows

Everything else can wait until a real need shows up.

---

What I'd avoid

· deps with a registry — you don't have an ecosystem, and building a resolver is months of work. Wait.
· features unless the language itself supports conditional compilation — otherwise the build system is lying about what it can gate.
· provides/requires — nice idea, but premature. Explicit folder deps are fine for now.
· metrics to a remote endpoint — file output is enough until CI asks for more.
· doc fields — the comments in the file do the job. Add later if you build a doc generator.

---

Want me to spec out any of these properly — grammar, semantics, examples, interactions with the existing pieces? I'd suggest starting with schema + strict + profile + target + test, since together they turn .crlb from "a build config" into "a real project description" without adding much surface area.

Here's the full updated grammar with all the additions folded in. I've grouped them so you can see what's core vs optional, and marked which ones are new vs the original.

---

Full .crlb grammar (v2)

```ebnf
build_file      = [ schema_decl ] [ strict_decl ] { top_decl } ;

schema_decl     = "schema" "=" NUMBER ";" ;
strict_decl     = "strict" "=" BOOL ";" ;

top_decl        = build_decl
                | workspace_decl
                | alias_decl
                | task_decl
                | test_decl
                | bench_decl
                | hook_decl
                | profile_decl
                | include_decl
                | lsp_decl
                | format_decl
                | ci_decl
                | remote_decl
                | deps_decl
                ;

(* ─── build ─────────────────────────────────────────────── *)
build_decl      = "build" STRING [ "extends" STRING ] "{" { build_field } "}" ;
build_field     = field
                | modules_field
                | skip_field
                | override_block
                | env_block
                | link_block
                | target_block
                | artifact_block
                | features_block
                | log_block
                | metrics_block
                | doc_field
                ;

field           = IDENT "=" value ";" ;
doc_field       = "doc" "=" STRING ";" ;

modules_field   = "modules" "=" list ";" ;
skip_field      = "skip"    "=" list ";" ;

override_block  = "override" STRING "{" { override_field } "}" ;
override_field  = field
                | "provides" "=" list ";"
                | "requires" "=" list ";"
                | "exclude"  "=" list ";"
                | "include"  "=" list ";"
                | "features" "=" list ";"
                | env_block
                | doc_field
                ;

(* ─── workspace ──────────────────────────────────────────── *)
workspace_decl  = "workspace" STRING "{" { workspace_field } "}" ;
workspace_field = field
                | "members"      "=" list ";"
                | "shared_cache" "=" STRING ";"
                | doc_field
                ;

(* ─── profiles ───────────────────────────────────────────── *)
profile_decl    = "profile" STRING [ "extends" STRING ] "{" { profile_field } "}" ;
profile_field   = field | doc_field ;

(* ─── aliases ────────────────────────────────────────────── *)
alias_decl      = "alias" IDENT "=" STRING ";" ;

(* ─── tasks ──────────────────────────────────────────────── *)
task_decl       = "task" STRING "{" { task_field } "}" ;
task_field      = field
                | "after"  "=" list ";"
                | "exec"   "=" STRING ";"
                | "output" "=" STRING ";"
                | env_block
                | doc_field
                ;

(* ─── tests ──────────────────────────────────────────────── *)
test_decl       = "test" STRING "{" { test_field } "}" ;
test_field      = field
                | "module"  "=" STRING ";"
                | "exec"    "=" STRING ";"
                | "inputs"  "=" list ";"
                | "expect"  "=" STRING ";"
                | "timeout" "=" STRING ";"
                | env_block
                | doc_field
                ;

bench_decl      = "bench" STRING "{" { bench_field } "}" ;
bench_field     = field
                | "exec"    "=" STRING ";"
                | "input"   "=" STRING ";"
                | "runs"    "=" NUMBER ";"
                | "timeout" "=" STRING ";"
                | doc_field
                ;

(* ─── hooks ──────────────────────────────────────────────── *)
hook_decl       = "hook" STRING "{" { hook_field } "}" ;
hook_field      = field
                | "run" "=" STRING ";"
                | "on"  "=" STRING ";"      (* "success" | "failure" | "always" *)
                | env_block
                | doc_field
                ;

(* ─── phases ─────────────────────────────────────────────── *)
phase_decl      = "phase" STRING "{" { phase_field } "}" ;
phase_field     = field
                | "on"     "=" list ";"
                | "run"    "=" STRING ";"
                | "output" "=" STRING ";"
                | "after"  "=" list ";"
                | env_block
                | doc_field
                ;

(* ─── targets ────────────────────────────────────────────── *)
target_block    = "target" STRING "{" { target_field } "}" ;
target_field    = field
                | "entry"  "=" STRING ";"
                | "output" "=" STRING ";"
                | link_block
                | artifact_block
                | doc_field
                ;

(* ─── link ───────────────────────────────────────────────── *)
link_block      = "link" [ STRING ] "{" { link_field } "}" ;
link_field      = field
                | "libs"   "=" list ";"
                | "flags"  "=" list ";"
                | "script" "=" STRING ";"
                | "strip"  "=" BOOL ";"
                ;

(* ─── artifact ───────────────────────────────────────────── *)
artifact_block  = "artifact" [ STRING ] "{" { artifact_field } "}" ;
artifact_field  = field
                | "kind"    "=" STRING ";"
                | "format"  "=" STRING ";"
                | "install" "=" STRING ";"
                ;

(* ─── features ───────────────────────────────────────────── *)
features_block  = "features" "{" { feature_decl } "}" ;
feature_decl    = IDENT "=" list ";" ;

(* ─── env ────────────────────────────────────────────────── *)
env_block       = "env" "=" "{" { env_pair } "}" ";" ;
env_pair        = IDENT "=" STRING ";" ;

(* ─── logging / metrics ──────────────────────────────────── *)
log_block       = "log" "{" { log_field } "}" ;
log_field       = "level"   "=" STRING ";"
                | "timings" "=" BOOL   ";"
                | "format"  "=" STRING ";"
                ;

metrics_block   = "metrics" "{" { metrics_field } "}" ;
metrics_field   = "emit"   "=" STRING ";"
                | "fields" "=" list   ";"
                ;

(* ─── lint / fmt ─────────────────────────────────────────── *)
lint_decl       = "lint" "{" { lint_field } "}" ;
lint_field      = "exec"  "=" STRING ";"
                | "deny"  "=" list   ";"
                | "paths" "=" list   ";"
                ;

format_decl     = "format" "{" { format_field } "}" ;
format_field    = "indent"    "=" NUMBER ";"
                | "align"     "=" STRING ";"
                | "max_width" "=" NUMBER ";"
                ;

(* ─── LSP ────────────────────────────────────────────────── *)
lsp_decl        = "lsp" "{" { lsp_field } "}" ;
lsp_field       = "root"    "=" STRING ";"
                | "exclude" "=" list   ";"
                ;

(* ─── CI ─────────────────────────────────────────────────── *)
ci_decl         = "ci" "{" { ci_field } "}" ;
ci_field        = "profiles"  "=" list ";"
                | "tasks"     "=" list ";"
                | "artifacts" "=" list ";"
                ;

(* ─── remote cache ───────────────────────────────────────── *)
remote_decl     = "remote" "{" { remote_field } "}" ;
remote_field    = "url"      "=" STRING ";"
                | "auth"     "=" STRING ";"
                | "fallback" "=" STRING ";"
                ;

(* ─── external deps ──────────────────────────────────────── *)
deps_decl       = "deps" "{" { dep_entry } "}" ;
dep_entry       = STRING "=" "{" { dep_field } "}" ";" ;
dep_field       = "version" "=" STRING ";"
                | "tag"     "=" STRING ";"
                | "rev"     "=" STRING ";"
                | "path"    "=" STRING ";"
                ;

(* ─── include ────────────────────────────────────────────── *)
include_decl    = "include" STRING ";" ;

(* ─── shared ─────────────────────────────────────────────── *)
value           = STRING | NUMBER | BOOL | list ;
list            = "[" [ value { "," value } [ "," ] ] "]" ;

IDENT           = /[A-Za-z_][A-Za-z0-9_-]*/ ;
STRING          = '"' { /[^"\\]/ | "\\" . } '"' ;
NUMBER          = /[0-9]+/ ;
BOOL            = "true" | "false" ;

comment         = "#" { /[^\n]/ } ;
```

---

What's new in v2 vs the original

Addition Kind Where it slots in
schema = N; top-level first line, optional
strict = true; top-level before build
extends modifier on build and profile
workspace top-level decl replaces bare build for monorepos
profile top-level decl named overrides
phase top-level decl pipeline stages
target block inside build multiple outputs
link block inside build / target linker control
artifact block inside build / target packaging metadata
test / bench top-level decls declarative tests
hook top-level decl lifecycle callbacks
env block global, per-module, per-task
features block inside build conditional compilation
provides / requires field inside override capability declaration
exclude / include field inside override glob filtering
doc field anywhere documentation
log / metrics block inside build observability
lint / format top-level decls tooling config
lsp top-level decl editor hints
ci top-level decl CI config
remote top-level decl remote cache
deps top-level decl external dependencies

---

Order of top-level declarations

The grammar allows any order, but the canonical order (what crl fmt enforces) is:

1. schema
2. strict
3. workspace or build
4. profile blocks
5. alias declarations
6. include declarations
7. features (inside build)
8. phase blocks
9. hook blocks
10. task blocks
11. test / bench blocks
12. lint / format blocks
13. lsp block
14. ci block
15. remote block
16. deps block

This is a convention, not a rule. But enforcing it in crl fmt keeps files consistent.

---

Canonical example using the new grammar

```crlb
schema = 2;
strict = true;

workspace "coral" {
    members      = ["compiler", "runtime", "tools/*"];
    shared_cache = ".coral/cache";
    doc          = "The Coral compiler, runtime, and tooling.";
}

profile "dev" {
    opt   = "debug";
    flags = ["--debug-info"];
}

profile "release" {
    opt   = "release";
    flags = ["--strict", "--lto"];
}

profile "ci" extends "release" {
    flags = ["--deny-warnings"];
}

build "coralc" {
    root       = "compiler/";
    target     = "native-x86_64";
    output     = "build/coralc";
    module_map = ".coral/modules.map";
    cache_dir  = ".coral/cache";
    doc        = "The Coral reference compiler.";

    flags = ["--strict"];

    modules = [
        "coral-ast",
        "coral-backend",
        "coral-common",
        "coral-context",
        "coral-diagnostics",
        "coral-entities",
        "coral-frontend",
        "coral-ir",
        "coral-lexer",
        "coral-module",
        "coral-parser",
        "coral-semantics",
        "coral-source",
    ];

    skip = ["target", "vendor"];

    env = {
        CORAL_HOME = "./.coral";
    };

    target "coralc" {
        entry  = "coral-frontend";
        output = "build/coralc";

        link {
            libs  = ["m", "pthread"];
            strip = true;
        }

        artifact {
            kind   = "executable";
            format = "elf64";
        }
    }

    target "corald" {
        entry  = "coral-daemon";
        output = "build/corald";
    }

    features {
        default  = ["std"];
        std      = [];
        no_std   = [];
        debug_ir = ["dump-ir"];
    }

    log {
        level   = "info";
        timings = true;
        format  = "human";
    }

    metrics {
        emit   = ".coral/metrics.json";
        fields = ["duration", "cache_hit", "object_size"];
    }
}

alias lexer  = "coral-lexer";
alias parser = "coral-parser";
alias common = "coral-common";
alias diag   = "coral-diagnostics";
alias ast    = "coral-ast";
alias ir     = "coral-ir";
alias sem    = "coral-semantics";
alias src    = "coral-source";

override "coral-lexer" {
    flags    = ["--no-inline"];
    provides = ["lexer"];
    exclude  = ["**/*_scratch.crl"];
}

override "coral-parser" {
    opt      = "debug";
    requires = ["lexer", "ast"];
}

phase "lex" {
    on     = ["src/**/*.crl"];
    run    = "coralc --emit-tokens";
    output = ".coral/tokens/{stem}.tok";
}

phase "parse" {
    on     = [".coral/tokens/*.tok"];
    run    = "coralc --emit-ast";
    output = ".coral/ast/{stem}.ast";
    after  = ["lex"];
}

hook "pre-build" {
    run = "scripts/check-version.crl";
}

hook "post-build" {
    run = "scripts/sign-binary.sh";
    on  = "success";
}

task "run" {
    after = ["build"];
    exec  = "build/coralc";
}

task "docs" {
    exec   = "tools/gen-docs";
    output = "docs/api/";
}

test "lexer basics" {
    module  = "coral-lexer";
    exec    = "build/coralc --test-lexer";
    inputs  = ["tests/lexer/*.crl"];
    expect  = "tests/lexer/expected/";
}

bench "lex throughput" {
    exec  = "build/coralc --bench-lex";
    input = "corpus/big.crl";
    runs  = 10;
}

lint {
    exec  = "coralc --lint";
    deny  = ["warnings"];
    paths = ["src/**/*.crl"];
}

format {
    indent    = 4;
    align     = "=";
    max_width = 100;
}

lsp {
    root    = "compiler/";
    exclude = ["vendor/**"];
}

ci {
    profiles  = ["ci"];
    tasks     = ["lint", "build", "test"];
    artifacts = ["build/coralc"];
}

remote {
    url      = "https://cache.coral.dev";
    auth     = "token:${CORAL_CACHE_TOKEN}";
    fallback = "local";
}

deps {
    "github.com/foo/bar" = { tag = "v1.2.3"; };
    "crates.io/serde"    = { version = "1.0"; };
}
```

---

Notes on the grammar

Optional STRING on link and artifact. When written inside a target block, the label is implied; when written at build level, the label names the target it applies to. This keeps single-target projects terse.

env appears in three places — global (in build), per-module (in override), per-task (in task / hook / phase / test). Same shape, three scopes.

features is a block of IDENT = list; — not field = value. This is deliberate: features are a map of name → dependencies on other features. A flat field would lose that structure.

dep_entry uses a STRING key. Registry paths aren't identifiers, so they need quoting. Everything else in the grammar uses IDENT keys.

phase requires on and run. The grammar allows them to be omitted, but semantically they're required. The builder enforces this; the parser doesn't.

extends on build and profile but not workspace. A workspace is a root by definition; extending it doesn't make sense. Builds and profiles compose.

No switch / if / for. Conditional logic stays out of the build file. Use profiles for variants, hooks for dynamic behavior, and let the CLI handle selection. This is a deliberate cap.

deps and remote are parsed but not evaluated yet. They're reserved for the future. Parser accepts them, builder can ignore them (with a warning in strict mode).

schema = 2; must be the first non-comment token if present. The builder reads it before parsing anything else. If absent, assume schema 1 (the original grammar) for backward compatibility.

---

What I did not add, and why

· if / for / conditionals — build logic should be in tasks, not in the config. Adding a scripting layer to .crlb makes it a programming language, and then you have two languages to maintain.
· depend expressions — dependencies are deps = ["folder"] inside lib.crl or module imports in source. The build file shouldn't duplicate that.
· version on modules — versioning belongs in the module's lib.crl or a manifest, not in the build file. Keeps the build file about building, not distributing.
· Multiple workspaces per file — one file, one workspace. If you need two, use two files and include.

---

Grammar size summary

Category Decls Blocks Fields
Core 1 (build) 2 (override, env) 12
Workspace 1 — 3
Profiles 1 — 1
Aliases 1 — —
Tasks 1 — 5
Tests 2 — 6
Phases 1 — 6
Targets — 2 (target, link, artifact) 8
Features — 1 1
Hooks 1 — 4
Tooling 4 (lint, format, lsp, ci) — 11
Infra 2 (remote, deps) — 6

Total: ~15 top-level declarations, ~10 block types, ~60 fields. That's a real language, but a small one. Everything is key = value, name { ... }, or name "label" { ... }.

---

Want me to:

· Write the parser for this grammar in .crl?
· Write the builder's evaluation order — which blocks are processed in what sequence, and what overrides what?
· Trim it down — pick the 5 declarations you actually need now and drop the rest?
· Design crl fmt — canonical formatting rules for every construct above?

Confirmed, and that's the cleaner reading — it's purely a one-line convenience over the two-statement form, nothing more:

```c
mod alias = import "path" { symbol, symbol2 };

alias::anything_else();   // module is still fully bound, every pub item reachable via ::
symbol();                  // just these two also pulled in unqualified
```

No new semantics, no change to visibility/re-export rules, no `pub` interaction to resolve — it's syntactic collapsing of the two-line pattern into one, and the module binding still carries its full export table regardless of what got pulled into unqualified scope alongside it. That closes out the verbosity question cleanly, and with it the module system is fully settled.
# Planned Self-Host Import Revision (later)

Status: **planned only** — not implemented yet. The bootstrap compiler and the
current self-host keep string-path imports working until this lands.

## What changes

Only in the **self-hosted compiler**. String/path-based imports go away:

```crl
import "token" { Token };        # removed
import "../coral-ast/id" { NodeId };  # removed
```

Replaced by **sibling-file imports**: same directory, bare file name, no
extension, no quotes:

```crl
import token { Token };          # resolves ./token.crl next to this file
import lexer { lex };            # resolves ./lexer.crl
```

Module imports stay as-is, resolved by the builder via `.coral/modules.map`:

```crl
import lexer::table { TokenTable };   # builder-resolved, unchanged
```

## Rules

- Resolution is relative to the **importing file's directory**, siblings only.
- The bare name is the file name without `.crl`.
- No `../`, no `/`, no strings — if it is not a sibling, it is a module
  import (`name::export`) or a re-export through a `lib.crl` surface.
- Path strings are nameless: `import "token"` introduces no usable binding
  without an alias. Bare sibling names are self-identifying and greppable.

## Nested (grouped) imports — also planned

Rust-style nesting is wanted alongside the sibling revision:

```crl
import(lib) std { io::{print, read}, string };
# brings std::io::print, std::io::read, std::string

import lexer::{ table, ident::{scan_ident, is_ident_start} };
# sibling modules, one line, arbitrary depth
```

Rules (planned):

- `name` alone → one item at the current depth.
- `name::{a, b}` → recurse into `name`'s namespace, each `a`/`b` imported bare.
- Nesting is purely textual grouping — final bindings are always the last
  segment (`io::{print}` binds `print`).
- A trailing comma after the last group is allowed.
- Works for both module imports (`x::{y}`) and `import(lib)` surfaces.
- Name collisions are an error (no silent shadowing).

## Scope

- Bootstrap (`bootstrap/*.py`): unchanged for now; it still accepts string
  paths so the transition can be staged.
- Self-host (`compiler/**`): this is the revision target. When it lands, all
  `import "..."` / `import ".."` forms in the self-host sources migrate to
  bare sibling names in one pass, the parser drops string-path imports, and
  the import parser gains `::{ ... }` grouping.

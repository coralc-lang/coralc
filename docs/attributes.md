# Attributes in coralc

`#[[name]]` / `#[[name(args), …]]` attribute lists are the only annotation
channel. Multiple groups may be chained (`#[[reorder, packed]]` or
`#[[packed]] #[[reorder]]`); each group carries a comma-separated list.

Implementation status:

- Parser: `Parser.parseAttrListTo` (coral-parser/decl.crl) parses every
  group, materializes each name (arguments are skipped today), returns the
  `const` bit. Unknown names parse without error.
- Storage: `Attribute { name, args, argsLen, loc }` on `Decl.attrs`,
  `Stmt.attrs` and `File.attrs`.
- File-level attributes must appear before the first declaration; only
  `no_drop_all` is currently recognized there. File attributes are copied
  onto every top-level decl of that file at parse time so they survive
  lib-merge.
- Statement-level attributes that mean nothing at statement position emit
  warning `[P0022]` (`condassign`, `fallthrough`, `no_drop` are exempt).

## 1. Honoured (semantics implemented)

### `#[[no_drop_all]]`

- Target: **file** (before the first declaration).
- Disables drop-trait auto-RAII for the entire file: sema does not resolve
  drop methods for locals, codegen emits no unwind calls. Ownership is
  manual (explicit `free`/`dispose`) as before.
- Since lib files manage their own frees, every file under `lib/` and the
  compiler's own sources carry it. Files without it (user code) get
  automatic RAII for any local whose type implements `@drop`.
- Survival through merges: the attribute rides on each decl, not just the
  `File`, so a lib file merged into a user unit keeps its opt-out.
- Example:

  ```coral
  #[[no_drop_all]]

  pub struct Arr<T, N> { … }
  ```

### `#[[no_drop]]`

- Targets: a **variable declaration statement** or a **scoped block**.
- The annotated local (or every local inside the annotated block, nested
  included) is excluded from drop-trait auto-RAII.
- Example:

  ```coral
  #[[no_drop]] String keep = String::from("stays alive");
  #[[no_drop]] { File f = File::open("x"); }   // f is not dropped here
  ```

### `#[[const]]`

- Targets: declarations; also spelled as the `const` position on a method
  (`Ret name(params) const { … }`).
- Marks a const method/function: parameters (and for methods, self) cannot
  be mutated; the sema const-check honors the bit.
- Example: `#[[const]] i32 peek(self) { … }`

### `#[[condassign]]`

- Target: the next statement's condition (`if`, `while`, `for`, `switch`).
- Allows a bare `=` at the top level of that condition without the
  assignment-in-condition diagnostic.
- Example: `#[[condassign]] if (line = next()) { … }`

### `#[[fallthrough]]`

- Target: a statement inside a `switch` case.
- Marks intentional fallthrough; currently informational (cases fall
  through naturally when no `break` is present) and silences the
  statement-attribute warning.

## 2. Parsed but NOT honoured (no semantics yet)

These parse, are stored by name, and do nothing:

- `#[[packed]]` — packed struct layout. Layout is unchanged today.
- `#[[reorder]]` — reorder fields for the most efficient layout. Not done.
- `#[[inline]]` — inlining hint. Not emitted to C.
- `#[[deprecated]]` — use-site warning. Only the LSP hover card mentions
  it today; the compiler does not warn.
- `#[[noalias]]` — pointer does not alias. Not emitted.
- `#[[threadlocal]]` — static storage is thread-local. Static locals emit
  plain `static`.
- `#[[hot]]`, `#[[cold]]` — branch/function weight hints. Not emitted.
- `#[[no_mangle]]` — keep the source symbol name. Honoured by the wallvm
  backend: the emitted symbol is the raw name (same exemption as `extern`).
  The C backend still mangles it. Two definitions that emit the same raw
  name (e.g. `no_mangle`/`extern` colliding) are a compile-time error.
- `#[[generate(...)]]` — derive-style boilerplate generator; planned
  spelling `#[[generate(Drop, Add)]]`. Arguments are skipped by the parser.
- `#[[freestanding]]` — file-level attribute: disables the builtin prelude
  (no implicit `core::str`, `core::error`, `std::ios`, `std::string`,
  `std::option`, `std::result`, `std::vec`, `std::arr`). Explicit imports
  still work. `assert`/`assertOut` and the runtime error builtins (`@panic`,
  `@unreachable`, `@report`, `@reportHex`, `@abortNow`, `@assertEq`, …,
  `@backtraceTo`) are rejected in a freestanding file.
- `#[[extern]]` — future slot; `extern` already exists as a keyword form.
- `#[[test]]`, `#[[bench]]`, `#[[cfg]]`, `#[[link]]`, `#[[simd]]` — future
  slots, accepted and ignored.
- `#[[pub]]` — deliberately **not** an attribute; `pub` is the visibility
  keyword itself.

Reminder: any unknown identifier between `#[[ … ]]` parses and is ignored
(no "unknown attribute" diagnostic yet).

## 3. Should have (roadmap)

- Store attribute **arguments** (`Attribute.args`): `deprecated("use x")`,
  `link("m")`, `cfg(target_os = linux)`, `generate(Drop, Eq)`, alignment.
- Honoured `#[[generate(...)]]`: emit trait/impl boilerplate (`Drop`,
  `Eq`, `Debug`, `Clone`) as the "derive vs import" note in grammar.md
  outlines.
- Layout attributes with teeth: `packed`, `reorder`, `align(N)`.
- Codegen hints: `inline(always|never)`, `noalias`, `hot`, `cold`,
  `noreturn`, `pure`/`mayDiscard`, `section("…")`, `used`, `weak`.
- Tooling: `test`, `bench`, `cfg`, `simd`, `link`, `threadlocal`.
- Validation: unknown-attribute diagnostic, duplicate/conflicting
  attribute checks (`packed` + `reorder` are mutually exclusive), and
  target validation (attribute applies to file/decl/stmt/member only).
- Attributes on struct/union **fields** and **parameters** are parsed at
  member positions today but their name lists are discarded; keep and
  honor them (`noalias` on params, `packed` per field).

## Related: built-in traits (not attributes)

Spelled in trait position with `@`: `extend T : @drop { void drop() { … } }`,
`@toStr`. `@drop` is what drives the RAII documented above. The full set
the language should eventually resolve (`toStr`, `iterable`, `eq`/`ne`/
`ord`, `clone`/`default`/`debug`, markers `copy`/`send`/`sync`) is listed
in HANDOFF.md.

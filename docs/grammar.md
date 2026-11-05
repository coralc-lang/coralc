# coral grammar reference (for coralc)

This is the concrete syntactic/production-level language model as reflected by the
self-host compiler parsers in `compiler/coral-parser/*.crl` and the AST in
`compiler/coral-ast/*.crl`. `coral-docs/reason.crl`, `coral-docs/imports.md`,
`coral-docs/build_sys.md`, and `coral-docs/coralc_plan.md` add the semantic intent.
Where the implementation differs from the docs, this file wins for parsing, and the
docs win for *intended* semantics.

## 1. Lexical categories

- Whitespace, `// line`, `/* block */` (block comments are not nested).
- Doc comments: `///` lines. A contiguous run (no blank lines between) directly
  above a declaration is one doc block; `////` is a plain comment and ends the
  block. The parser stores the block against the declaration's name line and
  the LSP renders it in hover; nothing else consumes docs yet. (`//!` module
  docs are future work.)
- Tokens: keywords, identifiers, numbers, string/char literals, operators/delimiters.
- Identifiers: XID_Start / XID_Continue (ASCII reduced form is optimized; many
  Unicode ranges are hardcoded — a correctness smell, not full UAX31).
- Numbers: decimal, `0x` hex, `0b` binary, `0o` octal; `_` separators; unsigned
  suffix `u`/`U` (`32u`, `5ull`); a single float token with optional exponent;
  `127`, `0xFF`, `1e5`, `3.14f` accepted.
- String literals `"…"` with escapes `\n \t \\ \"` and, at lex level, continues
  over newlines (a gap; doc says strings do terminate on newline). Raw strings
  `R"(…)"` / `R"<n>(…)"`.

## 2. Declarations (top level, in `parseFile`)

A file is a sequence of declarations interleaved with imports and
(static-)`Type name(...)` decls. Each decl goes through `parseDecl`, which first
consumes any `#[[ attr ]]` attributes and then dispatched on modifiers:

- modifiers: `pub` (and one of `extern("C")`, `static`).
- keyword decls: `struct`, `variant`, `union`, `enum`, `trait`, `extend`,
  `comptime`, `const`, `typedef`, `distinct`, `flag`?, `import`, `mod`.
- Sonst: `<Type> <name>` → `parseFuncOrVarDecl`, and `Name<…>` → field types /
  extends handled structurally.

`#[[attr]]` attributes are the only annotation channel. Today they parse but
are **not** stored/honored. The full set coralc should eventually support:

- `#[[no_drop_all]]` to turn off the drop trait from performing auto raii, on a whole file. lib files will need this, because frees are done automatically.
- it is done, so the std would comile faster than it would waiting on auto raii. though user files u=not top declarig it will have auto raii for types thata implement it.
- `#[[no_drop]]` for single variables or scoped blocks. 
- `#[[packed]]` — packed structs. 
- `#[[reorder]]` — reorder the memory layout to the most efficient.
- `#[[inline]]` — hint the fn is inlinable (recognized spelling like inline)
- `#[[const]]` — const method/fn (cannot mutate self/params) ⇐ also spelled
  `Type name(params) const {}`.
- `#[[no_std]]`? not yet. `#[[extern]]`? fn extern already uses `extern name()` or `extern("C") name()`.
- `#[[threadlocal]]` — static storage is thread-local
- `#[[noalias]]` — the pointer arg does not alias
- `#[[condassign]]` — allow `=` (assign) at the top level of the next condition
- `#[[hot]]`, `#[[cold]]`
- `#[[pub]]` on items? no —`pub` is the visibility keyword itself. not allowed!
- `#[[generate(...)]]` (planned) — the **generator** attribute like Rust `derive`,
  produces trait/impl boilerplate. Suggested spelling: `#[[generate(Drop, Eq)]]`
  (see "derive vs import" below).
- `#[[fallthrough]]` for switches when you dont want to add for all cases or use an `else` case,
- `#[[no_mangle]]`, `#[[test]]`, `#[[bench]]`, `#[[cfg]]`,
  `#[[link]]`, `#[[simd]]` — future slots.
- Adding multiple attributes(chained), but should be compatible, say: `#[[reorder, packed]] struct foo {...}`

Renaming idea: the `mod name = import …;` keyword is a candidate to become
`derive` (same length, so lexing is unchanged and it slots in where `import` sits
— noted for a future keyword audit).

## 3. Type syntax

`parseType` (parser/type.crl):

- `Const` prefix: `const T` → `Const(T)`.
- `Comptime` prefix: `comptime T` → `ComptimeT`.
- Base ( `parseBaseType` ): scalar keyword, named type, `(T)`, `struct(…)` tuple,
  `(…)` fn-ptr, type refs, `str`, etc.
- Fn-ptr over a base: `base(Params)` → `makeFunctionPointer(0, base, params)`:
  `void(u64)`, `u32(rawptr)`, `bool(T, T) less`.
- Pointers/arrays: postfix `T*` → `makePointer`, `T[N]` → array, `[]` → slice.
- Named type with generics: `Option<T>`, `HashMap<K, V>`.
- `any <Trait>` (dyn-trait object type) — decided syntax, not implemented.
- No explicit `self` parameter is written; a method's receiver is implicit.
  `const` methods (declared via `#[[const]]` or trailing `const`) may not mutate `self`.

## 4. Types (used as annotations)

`Type` = `Named` (primitive or concrete/generic decl name), `Pointer`, `Const`,
`Comptime`, `Slice` (`T[]`), `Array` (`T[N]`), `Rawptr` (`rawptr`), `FnPtr`,
Tuple, `TypeParam`, `Distinct`, plus `Str` used as a `u8*` interned-id in AST.

## 5. Declarations

- **struct**: `struct [gen] Name<T,…> { fields; methods; }` where fields are
  `Type name;`, methods are `Type name(params) const? {…}` (implicit self),
  and constructors are `static Name new(...){…}` / `static map(...)`.
- **variant**: `variant [gen] Name<T> { VariantName { Type field; }, UnitName, … }`.
  Methods live in a `pub extend<T> Name<T> {…}` below.
- **union**, **enum** (`EnumName { A, B = 1 }`), **trait** (`trait Name {fn(inline list of methods);}`), **extend** (`pub extend<T> Type<T> { methods }`), **extend trait** (`extend S : Trait {…}`).
- **const / constant**: `const Type name = expr;` (sema must constant-fold where required).
- **`typedef` / `pub typedef Name = Type;`**.
- **`pub extern[c] Name<params>;`** → extern variable.
- **`distinct`**: `pub distinct <Name> = <Type>;` (or `flag(Arch){…}` — unsupported).
- **import** (4 legal forms, no string literal, no `.crl`):
  - `import name { syms };`   (sibling `name.crl`)
  - `import mod::sub { syms };`  (builder-resolved module)
  - `import(lib) std::x { syms };`  // typed import from lib
  - `import(lib) std;`  // whole lib surface, no braces
- **`mod` reexport**: `pub mod name = import path[:symbols];`
- Generic params declared via `<T, …>`; monomorphised per use-site.

## 6. Function / method syntax

`Type name<[T,…]>[(params)][const] { body } | extern("C") | static ...`
- Params: `type name, …`; unnamed `type, …`; variadic last `...` (Param.flags&16).
- Methods: no explicit `self` parameter in the source (the receiver is implicit
  and a pointer in the generated C). `const` (or `#[[const]]`) on a method forbids
  mutating `self`/params.
- Static fn: `flags & 4` → no receiver; instance methods and `const` methods
  (flags bit 16 — decided, currently: `#[[const]]` or post-parens `const`).

## 7. Statements (parser/stmt.crl)

- Local declaration `Type name = expr;` and `var name = expr;` — `var` exists to drive **type inference**;
  the concrete `name: Type` forms are not part of local decl.
- `flag` declarations are also allowed as statements where the flag value is
  evaluated for its side effect.
- `for (init; cond; inc) {…}` (C-style) and `for (Type/var name : iterable) {…}` (range-based), plus `for (const type/var [ name, name2, ... ] : iterable )` plus `if`/`else`, `while`, and `switch` may
  all be expressions and may appear at statement level.
  `comptime {…}` (stub), `defer expr;` (unsupported in codegen), `asm "…" {outputs}` (partially supported), `return expr;`, `break;`,
  `continue;`, `<block as expr>`, expression-statements, `defer expr;`.
- Switch cases: `pattern => { body },`; patterns via `PatternKind`:
  `Wildcard` (`_`), `Lit(expr)`, `Variant{variantName, fieldNames, fieldNodes?}`
  (`Some { value } => …`), `Enum`, `Path`, `Ident`, `Or` (multiple alternatives),
  `Else` guard (`else`) — a `,` separator between cases today; the
  **decided** form is `pat1 | pat2 => body` (not implemented).


## comptime semantics (observed in lib/std/x86_64/linux/io/ios.crl)
- `comptime { … }` is a general compile-time block; it may contain switches,
  ifs, loops, and arbitrary logic that SELECTS/emits code — it is NOT limited
  to showing switches/ifs. Types in it are resolved at compile time.
- A generic parameter may be marked `comptime`, i.e. `print<comptime T>(T fmt,
  ...)`. A `comptime T` parameter means the caller does NOT specify T:
  T is auto-deduced by the logic inside the function's `comptime { … }` block.
- Semantic rule (to be enforced): any function whose generic list uses a
  `comptime T` parameter MUST contain a `comptime { … }` block in its body
  (otherwise there is nowhere to derive T). This is part of the type-erasure
  / tmp inference that replaces a dispatch argument at each call site.
- `@compileError(...)`, `@isFormatLiteral`, `@assert(cond)`, `@assertOut(...)`
  are compile-time attributes used inside comptime blocks.

## 8. Expressions (parser/expr.crl)

- Precedence (low→high) via binary levels: `=, +=, -=, *=, /=, %=` are separate
  Assign stmts with LPArench considerations; conditional `a ? b : c` handled in
  parsePrimaryExpr via a bracket speculation (no natural precedence today).
- Binary levels from `prec()`: `1 => lowest`, `&|^`, `==/!=`, `< <= > >=`, `<< >>`?, `+ -`, `* / %`, `**` (absent), unary small.
- Unary: `!`(Not), `~`(BitNot), `-`(Neg), `&`(AddressOf), `*`(Deref), `++`/`--` pre/post.
- Postfix: call `(args)`, `.field`, `p->field`(DerefField), `a[i]`(Index), struct-literal field init in brackets `Name { .field = x }`.
- Interpolation?: none. String ops via libc. `str` is an interned pointer.

## 9. Expression grammar goto (relevant cases)

- `ExprKind`: Lit, Ident, TypeRef, Path, Call, MethodCall, Index, Field,
  DerefField, Block, IfExpr, MatchExpr/SwitchExpr, TupleExpr, ArrayLiteral,
  StructLiteral, Cast, AddressOf, Deref, UnaryOp(Neg/Not/BitNot/PreInc/PreDec/PostInc/PostDec),
  Binary(...) exprs.
- Match arms `Variant{…} => { .. }` inside struct bodies and `switch` calls;
  `VariantLiteral` via `Type::Some { .field = x }`.

## 10. Types-as-expressions

- `TypeRef(Ty)`, `Ident`(name), `Path`, `Field`, `TypeParam`; `Name<args>` parsers a
  generic-variant literal. Tuple-typed composite of one or more exprs between `(…)`.

## 11. Notes mapping to the front-end (for agents)

- Every parser fn is a method on `Parser` in `compiler/coral-parser/*.crl` with
  `pub extend Parser` blocks in `decl.crl`, `expr.crl`, `type.crl`, `stmt.crl`,
  `pattern.crl`, `recovery.crl`, `file.crl`, `parser.crl`, `base.crl`.
- AST enums: `compiler/coral-ast/expr.crl` `ExprKind`, `decl.crl` `DeclKind`,
  `pat.crl` `PatKind`.
- Cross refs: `@compiler/coralc_plan.md` (staged plan), `imports.md`, `build_sys.md`
  (build manifests), `reason.crl` (design intent & event registry),
  `compiler-pipeline.md` (per-module responsibilities).

### Known parse gaps (std lib that does not parse today)
- Local array decls in a fn body (`u8 tmp[72];`) → parse error.
- Fn-pointer params with names (`usize(K) hf`).
- Struct field array decls with const-size exprs.
- `comptime {}` blocks and `asm {}` blocks are parsed then dumped.
- `#[[inline]]` etc.: parsed but not semantic.
- `pub distinct X = flag(…)`, `any TraitName`, switch `|` syntax — decided but
  unimplemented.

## Imports — nested path-listed items (decided, NOT implemented)
An allow-list may specify nested module→symbol mappings using distinct-scope braces
with `::` selectors, one item per line/comma:

```crl
import(lib) std::text {
    string::{ String },
    strutil::{ splitVec, trim, indexOfChar }
};
```
meaning: from the `std::text` library surface, bring in
`std::text::string::String` and `std::text::strutil::{splitVec, trim, indexOfChar}`.

Note: the current parser already supports a braces-only nesting
(`std::text { string { String } }`) by recursing with a `::`-joined prefix,
but does **not** accept the `module::{ … }` form above (the `::` before the inner
`{` is a parse error). Decide and implement the latter before the lib port relies on it.
See `compiler/coral-test/nested_import.crl`.

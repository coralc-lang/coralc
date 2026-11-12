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


I went through the grammar for constructs that parse (or are silently accepted) but have no diagnostic, so they fall through to codegen. This is a lot of codes, but most are one-liners. I'd tackle them in this order:

1. The "parsed but not implemented" constructs, because they currently fail with a codegen error or nothing at all.
2. Missing statement and expression checks (`return`, `break`, `var`, operators).
3. Const, generic and trait checks.
4. Imports and driver errors.

Numbers continue from your current table. Renumber freely.

## 1. Recognised but not implemented

The grammar lists many constructs that parse and are then dumped, ignored, or unsupported. These need an honest error or warning instead of a codegen crash.

| Code | Message |
|---|---|
| **P0025** | `{construct}` is decided syntax but not implemented yet. Covers `any Trait`, `distinct X = flag(...)`, `pat1 \| pat2 =>` arms, and the `module::{ ... }` import form. |
| **G0003** | `{construct}` cannot be lowered yet. Covers `defer`, `asm`, and `comptime {}` stubs. |
| **T0027** (warning) | attribute `#[[x]]` is parsed but has no effect yet. Covers `inline`, `hot`, `cold` and the other attributes the grammar says are not honored. |

## 2. Statements and expressions

| Code | Message |
|---|---|
| **T0025** | `void` expression used as a value (from earlier) |
| **T0026** | `{type}` cannot be assigned with a brace initializer (from earlier) |
| **T0028** | condition must be `bool`, found `{type}` |
| **T0029** | `return` value does not match the function's return type |
| **T0030** | `void` function returns a value, or non-void function has `return;` |
| **T0031** | `var` needs an initializer it can infer a type from (none, `null`, or an empty literal) |
| **T0032** | `break` or `continue` outside a loop |
| **T0033** | operator `{op}` is not defined for `{type}` (for example unary `-` on unsigned, `!` on non-bool, `+` on structs) |
| **T0034** | cannot dereference or use `->` on non-pointer `{type}` |
| **T0035** | cannot take the address of a non-lvalue |
| **T0036** | `{type}` cannot be indexed, or the index is not an integer |
| **T0037** | `{type}` is not callable |
| **T0038** | `++` or `--` needs an assignable numeric operand |
| **T0039** | constant division by zero or shift amount out of range |
| **T0040** | constant expression overflows `{type}` (T0010 only covers literals) |
| **T0041** | the branches of `? :`, `if` or `switch` expressions have different types |
| **T0042** | `if` expression used as a value has no `else` |
| **T0043** | block used as an expression has no final value |
| **T0044** | struct literal is missing field `{f}` or sets it twice (unknown field stays T0006) |
| **T0045** | array literal elements differ in type, or the length does not match the declared size |
| **T0046** | tuple arity mismatch or tuple index out of range |
| **T0047** | use of uninitialized variable `{a}` |
| **T0048** | destructuring in `for` has `{n}` names but the element has `{m}` fields |

## 3. Const, generics, comptime, types, traits

| Code | Message |
|---|---|
| **T0049** | `const` method mutates `self` or a parameter |
| **T0050** | cannot call a non-const method on a const receiver |
| **T0051** | conversion discards `const` |
| **T0052** | `self` used in a `static` function |
| **T0053** | `const` initializer is not a constant expression |
| **T0054** | wrong number of generic arguments (expected `{n}`) |
| **T0055** | generic arguments on a non-generic type, or missing on a generic one |
| **T0056** | cannot infer generic parameter `{T}` |
| **T0057** | function with a `comptime T` parameter must contain a `comptime { }` block (the grammar says "to be enforced") |
| **T0058** | `comptime` parameter cannot be given explicitly at the call site |
| **T0059** | runtime value used in a comptime context, or comptime evaluation limit exceeded |
| **T0060** | unknown intrinsic `@{name}` (P0018 only covers `@sizeof` syntax) |
| **T0061** | generic instantiation depth exceeded (likely infinite recursion) |
| **T0062** | type `{T}` contains itself and has infinite size |
| **T0063** | `typedef` or `distinct` cycle |
| **T0064** | duplicate enum value, or the value is not a constant |
| **T0065** | `extend {S} : {Trait}` is missing required method `{m}` |
| **T0066** | method `{m}` does not match the trait's signature |
| **T0067** | conflicting implementation, or a method duplicates an existing one on this type |

## 4. Attributes, modifiers, parameters

| Code | Message |
|---|---|
| **P0026** | attribute `#[[x]]` takes no arguments, or its arguments are invalid (`generate(...)`) |
| **T0068** | attribute `#[[x]]` does not apply to this declaration (`packed` on a fn, `noalias` on a non-pointer, `fallthrough` outside a switch) |
| **T0069** | attributes `{a}` and `{b}` cannot be combined |
| **P0027** | conflicting modifiers (`extern static`, and so on; P0008 only covers repeats) |
| **P0028** | variadic `...` must be the last parameter |
| **P0029** | parameters mix named and unnamed forms |
| **T0070** | pattern kind does not match the subject type (`Enum` pattern on an integer) |
| **T0071** | variant pattern names unknown fields or the wrong number of them |
| **T0072** | alternatives in an or-pattern bind different names |
| **T0073** | arm after `else` or `_` is unreachable (T0021 only says "duplicate") |

`#[[pub]]` is explicitly disallowed in the grammar. Give it its own P0012 hint ("`pub` is a keyword, not an attribute") instead of the generic "closest match" suggestion.

## 5. Functions, extern, entry point

| Code | Message |
|---|---|
| **T0074** | function has no body (only `extern` may omit it), or an `extern` function has one |
| **T0075** | missing, duplicate, or wrongly typed `main` |
| **T0076** | `extern("C")` signature uses a non-C-ABI type (slice, tuple by value, generic, type with methods) |

## 6. Imports

The grammar has four import forms and none of the failure cases is covered.

| Code | Message |
|---|---|
| **T0077** | module `{m}` has no symbol `{s}` (currently reported as T0001, which is misleading) |
| **T0078** | `{s}` is not `pub` and cannot be imported (also for `pub mod` re-exporting a non-pub item) |
| **T0079** | import cycle: `a → b → a` |
| **T0080** | imported names `{x}` collide with an existing declaration |
| **T0081** | unknown library `{lib}` in `import(lib)` |

## 7. Lexer and driver

| Code | Message |
|---|---|
| **L0010** | character is not valid in an identifier. This matters because the grammar says the Unicode ranges are hardcoded. |
| **D0004** | the C backend failed. The grammar mentions "generated C", so a missing or failing C compiler or linker needs a driver error. |
| **D0005** | cannot write the output file |
| **D0006** | invalid build manifest (`build_sys.md`) |
| **D0007** | unknown target |

## Things that need fixes, not new codes

- **Strings over newlines:** the lexer continues strings across newlines, but the docs say they should end there. L0002 already exists and should fire.
- **Parse gaps:** local `u8[72] tmp;`, named fn-pointer params and const-size struct field arrays currently give a parse error. If they surface as P0001 or P0005, the message won't match the real cause, so either fix the parser or special-case the message.
- **Duplicates:** P0017 overlaps T0020 and P0019 overlaps T0016, as noted earlier. Retire one of each.
- **`flag`:** the grammar mentions `flag` as a statement and expression without defining it, so I couldn't write specific diagnostics for it. Once you settle its syntax, it will need its own set.

Several existing codes (T0012, T0018, T0019, T0027) read like warnings. If you want `-Werror` or per-code allowing, consider a separate `W` prefix before the table grows further. I can lay out the final table in your `if (code.equals(...))` form if you'd like.

a couple of these are actually here, I think, but do verify





Agreed. A compiler that only has fatal errors can't tell users about the things that merely look wrong, and most of these checks are cheap because the type checker already has the information. I'd use a `W` prefix with three levels:

- **Default on:** shown but non-fatal.
- **Pedantic:** off unless requested (`-Wpedantic`).
- **Deprecation:** for syntax you plan to remove.

Add , `-Wno-W0007`, and `#[[allow(W0007)]]` on declarations. That also gives `#[[maybe_unused]]` a home, which your T0012 hint mentions but your attribute list doesn't.

## Move out of the T range

T0012 (unused), T0018 (unreachable code) and T0019 (no-op assignment) behave like warnings already. Make them `W` codes and retire the T numbers, so a warning can never stop a build.

## Unused and dead code

| Code | Warns when | Hint |
|---|---|---|
| **W0001** | local variable is never read | remove it, read it, or `#[[maybe_unused]]` |
| **W0002** | parameter is never used | name it `_`, or `#[[maybe_unused]]` |
| **W0003** | imported symbol is never used | remove it from the braces |
| **W0004** | non-`pub` function, const, type or `mod` is never used | remove it or make it `pub` |
| **W0005** | variable is assigned but never read afterwards (dead store) | the value is overwritten or ignored |
| **W0006** | unreachable code (was T0018) | remove it or move the diverging statement |
| **W0007** | unreachable switch arm after `else` | remove the arm |
| **W0008** | generic parameter is never used | remove `<T>` |
| **W0009** | `comptime` parameter or block has no effect | the block never derives T |

## Likely bugs

| Code | Warns when | Hint |
|---|---|---|
| **W0010** | no-op assignment `a = a` (was T0019) | assign something else or remove it |
| **W0011** | condition is always true or false (`u32 < 0`, `while (1)`) | the comparison can't vary |
| **W0012** | empty body after `if`, `while` or `for` (`if (x);`) | stray semicolon |
| **W0013** | value of a must-use call is discarded | bind it or cast to `void` |
| **W0014** | comparing signed with unsigned | cast one side explicitly |
| **W0015** | implicit narrowing (`i64` to `i32`, float to int) | add an explicit cast |
| **W0016** | float compared with `==` or `!=` | compare against a tolerance |
| **W0017** | shift amount is at least the type width (non-constant) | mask or widen the operand |
| **W0018** | returning or storing the address of a local | the pointer dangles after return |
| **W0019** | variable may be uninitialized on some path (T0047 is the definite case) | initialize at the declaration |
| **W0020** | a `switch` arm falls through without `#[[fallthrough]]` | add it, or end the arm with `break`/`return` |
| **W0021** | variable shadows an outer one | rename it |
| **W0022** | redundant cast to the same type | remove the cast |
| **W0023** | a non-`const` method never mutates `self` (pedantic) | mark it `const` | or a const method mutates self
| **W0024** | large struct passed by value (pedantic) | pass a pointer |
| **W0025** | explicit `0` or `null` used as a pointer where `rawptr` is expected | use an explicit `null` |

## Imports and declarations

| Code | Warns when | Hint |
|---|---|---|
| **W0026** | same symbol is imported twice | remove the duplicate |
| **W0027** | `import x { };` has an empty list | list symbols or drop it |
| **W0028** | `pub mod` re-export is never used | remove it |
| **W0029** | empty `struct`, `enum` or `trait` | probably unfinished |
| **W0030** | variant or enum value is never constructed or matched (pedantic) | remove it |

## Drop and RAII

| Code | Warns when | Hint |
|---|---|---|
| **W0031** | `#[[no_drop]]` on a type with no drop method | the attribute has no effect |
| **W0032** | `#[[no_drop_all]]` in a user file | intended for library files, which free manually |
| **W0033** | variable that needs a drop may leak because of `#[[no_drop]]` and no explicit free | free it before scope exit |
| **W0034** | `defer` is accepted but ignored | codegen does not implement it yet |

## Attributes, deprecated and not yet implemented

| Code | Warns when | Hint |
|---|---|---|
| **W0035** | attribute has no effect yet (`inline`, `hot`, `cold`, ...) | parsed but not honored |
| **W0036** | deprecated syntax or API | use the replacement named in the message |
| **W0037** | `comptime {}` or `asm {}` block is parsed but not lowered | the block is skipped |

## Lexical and style

| Code | Warns when | Hint |
|---|---|---|
| **W0038** | lookalike character inside a string or comment (L0009 stays an error in code) | replace it with the ASCII spelling |
| **W0039** | string literal spans a newline (interim for the lexer gap) | close the string, or use a raw string |
| **W0040** | `/*` inside a block comment (comments don't nest) | the inner opener is ignored |
| **W0041** | doc comment `///` is separated from its declaration by a blank line | the doc block attaches to nothing |
| **W0042** | numeric literal has a confusing form (leading zero like `0755`, ambiguous suffix) | use `0o` for octal |
| **W0043** | naming style: types should be `PascalCase`, values `camelCase`, consts per your convention (pedantic) | rename |

Your `P0023` ("documentation comments belong on declarations") should be a warning when the doc comment is dangling or misplaced. The current error is stronger than it needs to be.

## Notes (not warnings)

Many existing errors need a secondary label pointing at related code. Add this as a mechanism instead of codes, rendered as `note: ...` under the main message:

- T0004: "first declared here".
- T0020: "variant `{v}` is not handled".
- T0003: "function declared here".
- T0011: "return type declared here".
- W0021: "outer variable declared here".

Notes carry no code of their own. Their value is that users don't have to hunt for the second location.

## Order of work

1. Move T0012/T0018/T0019 to W codes and add the severity plumbing (`-Werror`, allow attributes).
2. Add W0001–W0013. They need no new analysis passes.
3. Add W0035–W0037, so unimplemented features never fail silently.
4. Do the rest as the relevant passes get built (W0019 needs flow analysis, W0033 needs drop tracking).
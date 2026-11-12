 

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
4. Do the rest as the relevant passes get built (W0019 needs flow analysis, W0033 needs drop tracking)..

I read both files. I can only see the error table, not your compiler, so I'm inferring which code fires from the table and the source.

## The two bugs

**`chained_method_call_on_void.crl`:** `var g = "hello world".asString().print();` should be rejected because `print()` returns `void`, and a void expression can't be a value. No code in your table covers this. The closest is T0002 (type mismatch), but there's no mismatch here, and a void used as a value isn't a type error in the usual sense. Add a new code:

- **T0025**: "expression of type `void` used as a value", with the hint "this call returns nothing; remove the binding or return a value from the function".

The same check should cover `.print().foo()`, since the file name suggests you also want a chained call on a void result caught. It should fire anywhere a void expression is used as an operand, argument, initializer, or receiver.

**`the_fuck.crl`:** `a { 4 };` on an `i32` because that assignment should not be available for an i32

- The real problem is that the subject isn't a type this construct accepts, which is a type error and not an exhaustiveness error.

Add a new code:

- **T0026**: "type `i32` cannot be used as the subject of this construct", with a hint listing the types that are allowed.

Check the subject type before the arm and exhaustiveness checks, so the user sees the root cause first.

## Reused or overlapping codes

| Code(s) | Problem | Suggested split |
|---|---|---|
| **T0002** | Catch-all for binary operands, assignment, return, condition, argument and void-as-value mismatches | Keep it for plain mismatches. Give conditions (`bool` required), return types, and void-as-value their own codes. |
| **T0003** | Argument count and argument type share one code | Split into wrong arity and wrong argument type. |
| **T0001** | Unresolved variable, type, function and module all share one code | At least separate unknown type from unknown value. |
| **T0006** | No such field, method or variant | Split into no such field and no such method. |
| **T0004** | Duplicate function, variable, field, parameter and variant | Fine to share if the message names the kind, but consider splitting at least locals from top-level items. |
| **T0012** | Unused variable, parameter and import | Warnings deserve per-kind codes so users can allow them selectively. |
| **P0001** | Catch-all "missing closer or required token" | It overlaps P0006 (EOF) and P0014 (stray closer). Keep it as the fallback and make sure the more specific ones win. |
| **P0007 / T0008** | Both say "can't assign to this" | The parser flags non-lvalues and the type checker flags constants. Fine if intentional, but confirm there's no double-reporting. |
| **P0019 / T0016** | Both say array sizes must be literals, consts or generics | These are duplicates. Keep one, probably T0016. |
| **P0011 / T0023** | Both describe import path rules | Same duplication across stages. |
| **L0001 / L0007** | "Stray character" and "cannot start a token" | Almost the same case. L0009 (lookalike characters) is a good example of the right granularity. |
| **P0017 / T0020** | Both cover non-exhaustive matches | Keep T0020 and retire P0017 for this case. |
| **P0015 / T0017** | Both concern for-in destructuring and iteration | Probably fine, but check that each fires at its own stage. |

## Small cleanups

- The L0006 hint has a typo ("on digits in the matching base" is missing a verb). It should read something like "expected digits in the matching base".
- `404-0000` breaks your `X0000` scheme. Consider renaming it to something like `G0003` or an `I0001` internal-error prefix.
- Several hints are inconsistent in tone. T0014 describes what the message is instead of telling the user what to do.


Thanks, that changes my read. I assumed `a { 4 };` was a switch-like construct, but it's a brace-style assignment (an initializer or aggregate form) applied to a scalar `i32`.

The error should say that a scalar can't be assigned with brace syntax. The "no arm matched" family (P0017, T0020) doesn't apply. My guess is that P0017 fires today because the parser takes `a { ... }` for a flag statement, but tell me what it actually prints and I'll confirm.

Here is the corrected suggestion:

- **T0026**: "`i32` cannot be assigned with a brace initializer", with the hint "brace initializers are for structs, arrays and tuples; assign a scalar with `a = 4;`".

Where to check:

- **Type checker:** once `a` resolves to a non-aggregate type, reject the brace form there. Don't rely on the parser's guess about what `a {` means.
- **Parser:** if `a { ... }` is ambiguous with the flag statement, the parser shouldn't commit to flag parsing when the subject isn't a flag type. Or it should defer that decision to the type checker. That ambiguity is probably why the wrong code appears.
- **Message:** name the actual type (`i32`) in the message so the mismatch is obvious.

The same code should also cover the other misuse cases: a brace initializer on a `bool`, a pointer, an enum, or a `str`. Assigning the wrong number of elements to a struct is a different problem and deserves its own code (arity of initializer).

Please disregard my earlier note about checking the subject type before exhaustiveness. It was based on the wrong construct. The "uninitialized read" gap I mentioned also doesn't apply to this file, though it's still a missing code in general.
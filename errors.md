# Mu — error and diagnostic message catalog

Status: living document. Every code the **compiler** (`Mu_coral`) can emit today,
every message the **engine** (`Mu_engine`) can produce today, the panic surface
specified but not yet implemented, and the codes/messages proposed next.

Compiler codes follow `E<band><nn>` / `W<band><nn>`:

| band | stage | owner |
|---|---|---|
| `E0000` | internal sentinel | diagnostics |
| `E01xx` | lexer | `mu-lexer` |
| `E02xx` | parser | `mu-parser` |
| `E03xx` | semantics (types, names) | `mu-sema` |
| `E04xx` | memory phase (ownership, slices, alloc/free) | `mu-sema` memory phase |
| `W01xx` | parser warnings | `mu-parser` |

The engine has **no code scheme** — plain, scope-prefixed string literals
(`bind:`, `load:`, `[mu:error]`, …). A proposed engine band (`E1xxx`) is in the
proposals section.

---

## 1. Compiler — implemented codes

Format produced by `Diags::emit` (`src/mu-diagnostics/diag.crl`):
`error <code>  <title>` + `at file:line:col` + source line + caret, with
optional `why:` / `help:` / `also at` satellites. Cap: `error E0000  too many
errors, aborting after 100`.

### 1.1 Lexer — `E0101`–`E0116` (`src/mu-lexer/lexer.crl`)

| code | message |
|---|---|
| E0101 | unexpected character |
| E0102 | unterminated block comment |
| E0103 | unterminated string literal |
| E0104 | unterminated character literal |
| E0105 | empty character literal |
| E0106 | character literal holds more than one character |
| E0107 | unknown escape sequence |
| E0108 | unterminated escape sequence |
| E0109 | unicode escape: missing `{` / hex digits / `}`, or too many digits |
| E0110 | invalid Unicode scalar value |
| E0111 | missing digits after radix prefix |
| E0112 | invalid digit for this base |
| E0113 | leading zeros are not allowed |
| E0114 | invalid numeric suffix |
| E0115 | exponent has no digits |
| E0116 | invalid UTF-8 in character literal |

### 1.2 Parser — `E0200`–`E0225` + `W0101`/`W0102` (`src/mu-parser/*.crl`)

| code | message (representative; one code covers a family) |
|---|---|
| E0200 | expected `X`, found `Y` (token/name/type/generic/label/… expectations) |
| E0201 | unexpected closing token at file scope · expected a field name · `let` requires an initializer |
| E0202 | manifest directive must appear before any code |
| E0203 | expected a declaration / method, found `Y` |
| E0204 | expected an expression, found `Y` |
| E0205 | expected a pattern, found `Y` |
| E0206 | expected a type, found `Y` |
| E0207 | duplicate definition/parameter/method/field/variant case `X` |
| E0208 | mismatched / unclosed `X` (bracket pairing) |
| E0209 | comparison operators cannot be chained |
| E0210 | invalid assignment target |
| E0211 | `else` must be the last prong |
| E0212 | duplicate `else` prong |
| E0213 | `else` prongs cannot have a guard |
| E0214 | unknown manifest group `X` |
| E0215 | modifier errors: duplicate `pub`/`async`/`@extern`; `@extern` placement/body rules; decls inside fn body |
| E0216 | label errors: label not on a loop; duplicate/unknown label; `break`/`continue` outside loop |
| E0217 | Mu has no `case` keyword · `default` is not a prong |
| E0218 | `@` cannot start an expression |
| E0219 | unknown attribute `X` |
| E0220 | duplicate attribute `X` |
| E0221 | attribute argument errors (arity, kind, `@system` phase, `@repr`, `@deprecated`, `@doc`) |
| E0222 | attribute not valid on this field/declaration |
| E0223 | unknown system phase `X` |
| E0224 | `else` without a matching `if` |
| E0225 | `self` outside a method / unavailable / not first / annotated |
| E0226 | user-defined generics are not supported (type parameters on `fn`/`struct`/`variant`, bounds); built-in containers keep their type arguments |
| W0101 | unreachable code |
| W0102 | unused value |

### 1.3 Semantics (types/names) — `E0300`–`E0395` (`src/mu-sema/sema.crl`)

| code | message |
|---|---|
| E0300 | duplicate definition of name |
| E0310 | type mismatch family: const initializer / var initializer / assignment / field type |
| E0320 | extend does not satisfy trait |
| E0330 | if/while condition must be bool · guard must be bool |
| E0331 | for iterates over array, slice, range, string, or a built-in container |
| E0332 | missing return value · return type mismatch |
| E0340 | pattern does not match scrutinee (int/float/str/char/bool/range) |
| E0341 | unknown variant case |
| E0350 | unknown name |
| E0360 | cannot negate non-numeric / non-bool |
| E0361 | no such field · field access on non-struct |
| E0362 | index must be numeric · cannot index non-array |
| E0363 | invalid cast |
| E0364 | range bounds must be numeric |
| E0365 | array elements must have a common type |
| E0366 | built-in container arity: `Set<T>`/`Queue<T>`/`Pool<T>` take one argument, `Map<K, V>` takes two, `Bitset` is non-generic |

| E0370 | arithmetic/comparison/bitwise operand kind errors |
| E0371 | mismatched numeric operand types |
| E0372 | cannot compare these types |
| E0373 | logical operator requires bool |
| E0380 | cannot assign to an immutable binding |
| E0381 | compound assignment requires numeric |
| E0390 | unknown function |
| E0391 | argument type mismatch |
| E0392 | wrong number of arguments |
| E0393 | not a struct |
| E0394 | spread base type mismatch |
| E0395 | unknown field in struct literal |

### 1.4 Memory phase — `E0400`–`E0404` (`src/mu-sema/sema.crl`, new)

Implemented by the memory phase that runs at the end of `checkAll()` when the
program is otherwise error-free: escape analysis decides stack vs heap per
owning local (DESIGN §4–§6), injects scope-exit / early-return `drop()` +
`__mu_free` calls, and enforces the slice borrow rule (DESIGN §5).

| code | message | trigger |
|---|---|---|
| E0400 | use of a moved value | an owning local is read after its ownership escaped (returned, `?`-propagated, stored into an escaping target, or passed to a callee that retains it). Textual order, conservative on branches; only fires when the move-elision pass classified the init as a genuine move. |
| E0401 | slice outlives its backing storage | a named slice is returned (or `?`-propagated) while its backing local is not returned with it. §5 rule 1. |
| E0402 | owner used while frozen by a live slice | between a slice's creation and its last use, the backing owner is read, written, or moved (other slices of the same buffer are exempt). §5 rule 2, non-lexical span. |
| E0403 | cannot slice a temporary | `expr[a..b]` where the receiver is not a binding — the backing dies at end of statement. |
| E0404 | assignment to a moved value | write to a local after its ownership escaped. Same move-elision gate as E0400. |

Companion (non-error) output of the same phase:

- `Expr.mem` annotation on allocation sites: `McStack` (frame storage, no
  alloc/free), `McHeap` (injected `__mu_alloc` at lowering), `McTransfer`
  (ownership left the function: alloc, never free), `McAuto` (follows
  enclosing storage / defaults).
- Injected synthetic statements: `x.drop();` (when the type has a `drop()`
  method — the `@drop` leak guard) followed by `__mu_free(x);` at scope exits,
  before `return`, and before `break`/`continue` (all enclosing scopes,
  innermost first, reverse declaration order). Heap values whose ownership
  escaped get no free. A `drop()` also fires for stack-classified owners, so
  resources held by frame-local values are released too.
- `memQs` records for each `?` operator the cleanup set the IR stage must run
  on the early-return edge.

Known v1 limits (by design, see §4): parameters are never auto-freed;
for/switch pattern bindings of owning element type are not tracked; name-level
resolution conflates shadowed bindings; `?` cleanups are recorded, not yet
spliced into the AST. Additional documented limits:

- Non-literal owning initializers are tracked when the value's type resolves:
  an explicit annotation, an array/map literal, a struct literal, a call whose
  callee return type resolves (free function, member, or `extend` method), or a
  tuple whose first owning element resolves. Such locals are heap-classified and
  freed at scope exit. Initializers from unresolvable callees (variant
  constructors such as `Some(x)`, unknown functions) get no `Own`, hence no
  classification and no cleanup for that local.
- Control-flow-expression initializers (`if`/`switch`/`while` bodies) and
  owning locals declared *inside* a `return` expression are not cleaned up.
- `break`/`continue` clean up owns declared inside the innermost loop body;
  `switch` prongs do not create a cleanup boundary (coral `switch` has no
  `break`, so a jump inside a prong targets the enclosing loop).
- Slices that are returned as temporaries (`return a[0..2]`) or passed to
  escaping callees are not range-checked; only named slices at `return`/`?`
  are.
- Calling a method that no summary exists for (unknown or bodyless trait
  method) retains the receiver conservatively: the receiver is treated as
  escaping, never as a genuine use-after-move.
- Escape propagated through a name-to-name alias does not by itself make
  later uses of the source an error: the source is only a genuine move site
  when the move-elision pass (`memCheckMoves`) decides it is.

---

## 2. Engine / runtime — implemented messages

No codes, no severity levels, no warning channel. Two styles:

- printed (`println`) — the only engine diagnostics a user sees today;
- returned (`Result<T, str>` / `Result<T, String>`) — caller decides whether
  to print; the strings are listed here because they are the contract.

### 2.1 Printed

| message | trigger | site |
|---|---|---|
| `[mu] {msg}` | `core::logInfo` | `src/core/core.crl:16` |
| `[mu:error] {msg}` | `core::logError` | `src/core/core.crl:21` |
| `[mu:error] unresolved Mu:: library symbol: {name}` | `ScriptHost.require()` miss at load | `src/script/script.crl:149` |
| `[mu] script loaded (M1 stub — executes at M2): {path}` | load notice (scripts do not execute yet) | `src/script/script.crl:161` |
| `[mu:script] {msg}` | native `Mu::log::info` | `src/script/script.crl:261` |
| `[mu:script:error] {msg}` | native `Mu::log::error` | `src/script/script.crl:266` |
| `[mu:script] setParent rejected: {err}` | `Scene::setParent` returned `Err` | `src/script/script.crl:299` |

### 2.2 Returned error strings

| string | trigger | site |
|---|---|---|
| `native registry: duplicate name` | duplicate `Mu::…` registration | `script.crl:76` |
| `native registry: table full` | registry capacity exhausted | `script.crl:79` |
| `load: unresolved library symbol (path above)` | `require()` miss (pairs with printed #3) | `script.crl:150` |
| `bind: no scene bound` | bind before a scene exists | `script.crl:215` |
| `bind: entity is dead or invalid` | despawned/out-of-range id at bind | `script.crl:217` |
| `bind: table full` | binding capacity exhausted | `script.crl:219` |
| `setParent: child is dead or invalid` | `Scene::setParent` | `scene.crl:129` |
| `setParent: parent is dead or invalid` | idem | `scene.crl:133` |
| `setParent: cycle rejected - parent is a descendant of child` | cycle guard | `scene.crl:135` |
| `component add: entity id out of range` | store add | `scene.crl:182` |
| `component add: slot already used` | duplicate component | `scene.crl:184` |
| `component registry: duplicate name` | registry add | `scene.crl:245` |
| `component registry: table full` | registry capacity | `scene.crl:248` |
| `component registry: null store` | null store pointer | `scene.crl:250` |
| `{vendor text}` / `stb_image: decode failed` | image decode | `stb.crl:100-101` |
| `{vendor text}` / `tinyexr: decode failed` | EXR decode | `tinyexr.crl:76-78` |

Silent-by-design (`Option`/`bool`/`void`): scene full → `None`; destroy
idempotent; `alive` false; store remove/has/get misses; registry lookup miss;
`spawn` → `NIL` when full; `despawn` → `false`; drlibs loaders → `None`.

Vendor extern error surfaces (not engine messages): `JoltC_GetLastError`,
`SDL_GetError`, `ktxErrorString`, `ZSTD_getErrorName`, `glGetError`, WebGPU
status enums.

### 2.3 Documented behavior with no message yet

- Panic handler (DESIGN §8, §14): receives message + file/line + script stack;
  default print-and-stop the context. **Not implemented** — zero panic paths in
  engine or compiler output today.
- Panics specified for: OOB index, div/mod by zero, overflow-trap flag,
  failed unwrap, invalid `u32 as char`, script stack overflow, `panic("msg")`.
- Opaque handles with generation checks (DESIGN §14): despawned use panics.
  **Not implemented** — ids are plain `u32` + alive flag (open item).
- `@extern` loader signature verification (DESIGN §14: “fails loudly on
  mismatch”). **Not implemented** — registry checks names only.

---

## 3. Proposed — add to the compiler next

| code | message | rationale |
|---|---|---|
| E0405 | cannot move out of a container element | `var x = arr[i];` where T owns and the element slot cannot be vacated — completes the single-owner story for containers. |
| E0406 | moved value captured by an escaping closure | reserved for when closures land (DESIGN §6 capture rules). |
| E0407 | returning a reference to a local | reserved for when `&T` references land in the type system. |
| E0408 | double-free shape rejected | invariant guard: two canonical owners of one buffer. Should be unreachable by construction; kept as an ICE-class error if the analysis ever needs to refuse. |
| W0401 | value escapes without a drop implementation | heap-transferred value of a type with resources but no `drop()` — leak-guard lint. |
| W0402 | stack frame exceeds configured size | large stack-class aggregates once constant-size layout exists. |

Implementation notes for the above: E0405/E0408 slot into the existing
memory-phase walk (`memCheckMoves` / classification); E0406/E0407 wait on
language features; W0401 is a one-line check in `memCheckEscapes`.

## 4. Proposed — engine side

The engine should adopt codes so hosts and tools can key off them (today only
the compiler has a scheme; ENGINE.md itself plans “error underlines from `muc`
diagnostics” for the editor, which needs stable ids):

| code | message | maps to |
|---|---|---|
| E1001 | unresolved library symbol `{path}` | printed #3 above |
| E1002 | native registry duplicate `{path}` | `native registry: duplicate name` |
| E1003 | native registry full | `native registry: table full` |
| E1004 | bind: no scene bound | existing string |
| E1005 | bind: dead or invalid entity | existing string |
| E1006 | bind: table full | existing string |
| E1007 | extern signature mismatch `{path}` | unimplemented loader check (DESIGN §14) |
| E1008 | use of despawned handle | unimplemented generation check (DESIGN §14) |
| E1999 | script panic: `{msg}` at `{file}:{line}` | unimplemented panic handler (DESIGN §8) |

Rule: the printed line keeps its `[mu…]` prefix for humans; the code is
appended (`[mu:error] E1001 unresolved …`) so logs stay greppable either way.

## 5. Reserved bands (do not allocate without updating this file)

- `E0001–E0100` — reserved for driver/IO failures (file-not-found, manifest
  I/O) once muc reports them through `Diags`.
- `E0117–E0199` — lexer future (raw strings, byte strings).
- `E0226–E0299` — parser future.
- `E0396–E0399` — sema future.
- `E0405+` — see proposals above.
- `E05xx` — reserved for the IR/lowering stage (trap insertion, monomorph
  explosion, async lowering).
- `W01xx` — parser warnings; `W02xx` — sema warnings; `W04xx` — memory-phase
  warnings.

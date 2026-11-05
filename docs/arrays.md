# Arrays and array casting — coral

Audience: contributors and coding models. This is the authoritative summary of
coral's array syntax and the pointer↔array casts as of the `T[N]` unification.

## Arrays are types

An array is a first-class type spelled `T[N]`, where `N` is a comptime integer
(an integer literal, a same-file `const` int, or a generic parameter). The type
reads exactly like C's declarator suffix, but it is a *type*, so it appears
anywhere a type appears:

```coral
i32[3] a = { 10, 20, 30 };      // local
const u8[16] KEY = { … };       // constant
u8[2][3] grid;                  // multi-dim: 2 rows of 3 (rightmost dim innermost)
i32[4]* pa;                     // pointer-to-array (see Casting)
void f(i32[4] buf);             // parameter (decays to a pointer in C, like C arrays)
struct S { u8[8] id; }          // field
i32[3] ret();                   // return type
```

Slices (`T[]`) are the non-fixed-size form: a `{ptr, len}` pair that carries
its length. Slices are indexable and bounds-checked like fixed arrays.

## Declarations: `T[N] name` is the ONLY form

The old C-style declarator form was removed:

```coral
i32[3] a;    // ✓
i32 a[3];    // ✗ P0025: invalid/unsupported array declaration syntax
```

The removal covers every declaration context: locals, globals, `const`/`var`,
parameters, and struct fields. The parser reports `P0025:
invalid/unsupported array declaration syntax` with the help line
`write the array as the type: T[N] name` and skips the bracket group so the
rest of the file keeps parsing. `compiler/`, `lib/`, and `test/` are fully
migrated; nothing in the tree uses the old form.

## Literals and assignment

Array literals use braces and may nest for multi-dimensional arrays:

```coral
i32[2][2] grid = { { 1, 2 }, { 3, 4 } };
grid = { { 5, 6 }, { 7, 8 } };        // whole-array assignment
i32[2][2] copy = grid;                // whole-array copy (value semantics)
```

C forbids array assignment and initialization-from-expression, so codegen
lowers all of the above to `memcpy` of the target's bytes. Field values in
struct literals and array-literal elements may be brace literals
(`{ .cells = { 9, 8 } }`).

## Indexing: what is indexable

`x[i]` is accepted on exactly:

- **arrays** `T[N]` — result type `T`; a literal index against a fixed length
  is bounds-checked at compile time (`T0013`).
- **slices** `T[]` — result type `T` (runtime bounds-checked where enabled).
- **`str`** — result type `char` (a UTF-32 codepoint; cast to `u8` for bytes:
  `(u8)s[i]`).

**Pointers are not indexable.** `p[i]` on `T*`/`rawptr` was removed: a raw
pointer carries no element type contract or length, so indexing it was a C
foot-gun. To index through a pointer, cast it first (below) or use a
slice/`str` (which pair the pointer with a length).

## Casting between pointers and arrays

Two distinct casts, both explicit:

### `(T[N])p` — pointer → array VALUE (a copy)

```coral
u8* p = …;
u8[3] copy = (u8[3])p;      // 3 bytes memcpy'd out of p
```

C has no cast-to-array-type, so codegen lowers the cast to a deref of a
pointer-to-array — `*(uint8_t(*)[3])(p)` — an array lvalue. Where the value is
consumed by initialization or assignment, that becomes a `memcpy` (the same
lowering as `x = y` on arrays). Array→array reinterprets the same way
(`(u8[4])someI32Array`), going through `&arr`.

Sema rejects sources that are neither pointers nor arrays
(`T0002: cannot cast to array type '…': the source must be a pointer or an
array`) — an integer or slice source used to die as an internal codegen
failure.

### `(T[N]*)p` — pointer → pointer-to-ARRAY (a zero-copy view)

```coral
i32[4]* pa = (i32[4]*)p;    // view: pa indexes the array p points at
pa[0][2] = 99;              // write through the view (pa[0] is the i32[4])
```

This is C's `int32_t(*)[4]`. Because C declarations need the identifier
*inside* the declarator (`int32_t (*pa)[4]`), which a context-free type
spelling cannot produce, codegen emits a typedef per pointer-to-array type —
`typedef int32_t (*PA_int32_t_4)[4];` — usable in declarations, parameters,
fields, and casts alike. Multi-dimensional arrays produce the full suffix
(`PA_int32_t_2_2` → `typedef int32_t (*PA_int32_t_2_2)[2][2];`).

### Which to use

- Need the bytes owned elsewhere (a local buffer, a struct field)? `(T[N])p` —
  a copy.
- Need to read/write the caller's memory in place with element typing? Cast to
  `(T[N]*)p` and index the view.
- Have a pointer + a runtime length? Build a slice (`T[]`) instead of casting;
  slices are the length-carrying form and are directly indexable.

## char and the byte types

`char` is coral's UTF-32 codepoint type — it is **not** a byte. The C byte
types are `u8`, `i8`, and `cchar` (C `char`); they mix freely with each other
(assignment, arguments, pointer signs — clang's `-Wpointer-sign` family). A
`char` VALUE needs an explicit cast to narrow (`(u8)c`). Char *literals* are
untyped and still fit byte targets (`u8 b = 'x'`, `{ 'a', 'b' }`) the same way
small integer literals do.

## Error codes

- `P0025` — invalid/unsupported array declaration syntax (the removed
  declarator form).
- `T0002` — type mismatch, including the array-cast source guard.
- `T0013` — constant array index out of bounds.

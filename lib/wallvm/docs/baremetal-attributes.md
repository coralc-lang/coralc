# Bare-metal entry and naked-function attributes

Status: language design plus current linker support. The Coral frontend does
not implement these attributes yet. The wallvm linker already implements the
lowering contract described below for ELF and PE outputs.

## Goals

Bare-metal Coral programs need to say two things that ordinary hosted
programs get from a runtime or a linker script:

1. which function the CPU starts executing at, and
2. which functions must be emitted as an exact instruction sequence, with no
   compiler-generated prologue, epilogue, or stack frame.

The attributes are deliberately small. They do not replace a linker script
and do not define a complete freestanding runtime.

## Syntax

### `#[[entry]]`

Marks the program entry function.

```coral
#[[entry]]
void _start() {
    // normal Coral body
}
```
- Because it is a function attribute, it can be paired with #[[no_mangle]],
- #[[naked]]. we can even have #[[entry, no_mangle, naked]]
- and any other compatible attribute. incompatible function attributes
- should never be merged, hot, cold, inline, should never
- At most one `#[[entry]]` may exist in the whole program.
- The attributed declaration must be a defined function, not an extern,
  prototype, generic, or variable.
- The function keeps its source-level symbol name and is emitted/retained.
- The compiler also emits a global alias named `__coral_entry` for the same
  address. That alias is the linker contract.
- If no `#[[entry]]` is present, a hosted/toolchain wrapper may still pass
  `--entry SYMBOL` or use the conventional `_start` symbol.

### `#[[entry(address)]]`

Marks a literal start address instead of a function. The current attribute
grammar accepts one integer literal. Decimal, hexadecimal (`0x`), and
underscores are accepted; the value must fit the target address width.

```coral
#[[entry(0x80000000)]]
void reset_vector() {
    // normal Coral body
}
```

- The function is still emitted normally, but its address is not used as the
  entry address.
- The compiler emits an absolute symbol named `__coral_entry_addr` whose
  value is the literal address. The linker contract is:
  - `__coral_entry_addr` must have `SHN_ABS` type in ELF output;
  - its value is the final virtual address, not an offset from the image
    base;
  - the address must fall inside an executable output section.
- This form is intended for raw/bare-metal images and fixed-address ROM/RAM
  layouts. It is not meaningful for PIE or dynamically relocated output.
- `#[[entry]]` and `#[[entry(address)]]` are mutually exclusive in one
  program.

### `#[[naked]]`

Marks a function whose body is written as assembly and must be emitted
verbatim, without compiler-generated entry/exit code.

```coral
#[[entry, naked]]
void reset_vector() {
    asm { "cli" }
    asm { "jmp kmain" }
}
```

Semantics for the initial implementation:

- No prologue or epilogue is generated.
- No stack frame, spill slots, callee-saved register saves, stack protector,
  or landing pad is generated for the function.
- The body must not rely on Coral local variables, parameters, return values,
  or normal statements that require register allocation or stack slots. The
  intended body is inline assembly plus, at most, declarations that lower to
  no code.
- The function must not fall through into compiler-generated code. It must
  transfer control explicitly (`ret`, `jmp`, `hlt`, a tail call, and so on).
- The compiler still emits the symbol, section, alignment, and size metadata,
  so debuggers and symbol tables can find the function.
- Inlining a naked function into another function is forbidden. Taking its
  address is allowed.
- `#[[naked]]` changes code generation only. The assembler and linker treat
  the result as ordinary text; no new object-file section or relocation type
  is required.

A naked function may also be the entry function. This is the normal reset
vector / boot trampoline shape.

## Linker contract

The current wallvm linker already supports the entry-selection pieces of the
design:

| Input | Behavior |
| --- | --- |
| `linktool <entry> <out> ...` | Legacy positional entry symbol. |
| `--entry-address ADDR` | Explicit literal entry address; overrides symbol lookup. |
| `__coral_entry` defined | Used as the entry symbol when no explicit entry/address was given. |
| `__coral_entry_addr` defined | Used as an absolute entry address when no explicit entry/address was given. |
| Both reserved symbols | Link error. |
| `__coral_entry_addr` not `SHN_ABS` | Link error. |
| Address outside an executable output section | Link error. |
| ELF shared object or PE DLL without an entry | Allowed; entry remains zero. |

Precedence is: explicit command-line entry or `--entry-address`, then the
reserved symbol emitted by the attributes, then the toolchain default. A
future compiler driver should pass an empty entry when it has already lowered
`#[[entry]]`, or emit the reserved symbols and let the linker resolve them.

For static archives, `__coral_entry` and `__coral_entry_addr` are treated as
extraction roots. An entry object stored in an archive is therefore pulled in
even when no ordinary undefined reference mentions it. If both names are
undefined and absent, extraction falls back to the normal unresolved-symbol
roots.

Example raw image:

```sh
linktool --shared kernel.elf --entry-address 0x80000000 boot.o kernel.o
```

Example symbol entry:

```sh
linktool _start kernel.elf boot.o kernel.o
```

PE DLL outputs set the entry RVA to zero when no entry is selected. PE
executables require an entry; `--entry-address` is validated against an
executable section before the headers are written.

## Assembler support

No assembler changes are required for `#[[naked]]`: the frontend produces
normal `.text` instructions after suppressing its own prologue/epilogue.
The assembler already emits `.globl` aliases and function symbols, so a
frontend can lower `#[[entry]]` to `__coral_entry` without a new directive.

There is currently no assembler directive for declaring an absolute entry
address. The planned compiler lowering for `#[[entry(address)]]` emits
`__coral_entry_addr` directly as an absolute symbol. A future low-level
directive such as `.coral_entry_addr <value>` can share the same object
contract if hand-written assembly needs it.

## Diagnostics

The implementation should reject these cases before or during linking:

- more than one `#[[entry]]` or `#[[entry(address)]]` in the program;
- entry attribute on a non-function or an undefined function;
- both `__coral_entry` and `__coral_entry_addr` defined;
- `__coral_entry_addr` without `SHN_ABS`;
- entry address outside executable mapped memory;
- naked function containing code that requires a compiler-generated frame;
- inlining or cloning a naked function.

## Implementation status

| Piece | Status |
| --- | --- |
| Attribute syntax and diagnostics | Specified, frontend not implemented |
| `#[[naked]]` codegen | Specified, frontend not implemented |
| `__coral_entry` linker lookup | Implemented |
| `__coral_entry_addr` linker lookup | Implemented |
| `--entry-address` and validation | Implemented |
| Archive extraction roots | Implemented |
| ELF shared / PE DLL entry handling | Implemented |
| Assembler `.coral_entry_addr` directive | Not implemented; not required for the compiler lowering |

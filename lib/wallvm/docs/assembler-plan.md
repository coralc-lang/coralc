# wallvm assembler plan — x86, x86_64, arm32, arm64, wasm

Status: **planned** — written down because it cannot start immediately; the
passes/regalloc ports and their verification land first. This document is the
committed scope and phasing so nothing is lost.

## Why

Inline asm must just work: a user writes correct asm for a supported target,
with correct constraints, and the toolchain assembles it. Wide mnemonic
coverage is the requirement — people reach for inline asm precisely when the
compiler won't emit the instruction they need, so a thin "common cases only"
table would defeat the point.

### The gap this fills (confirmed)

- IR carries `InlineAsm { asmString, asmConstraints, asmClobbers,
  asmNumSideEffects }` end to end: parser builds it, passes treat it as a
  memory barrier.
- **No target in `lib_old/wallvm/target/` handles `IrOpcode::InlineAsm` at
  all** — zero references. Inline asm is silently dropped on every backend.
  That is the toolchain-critical hole this plan closes.
- There is no arm32/arm64 target at all, and wasm only prints WAT text —
  no path from asm text to machine bytes anywhere.

## Current state inventory

| Piece | State |
|---|---|
| IR inline-asm fields + parser | done (new tree, `irParser` inlineAsm) |
| `rules/asm_rules.crl` | IR opcode → mnemonic/operand tables; porting now |
| x86_64 `X86_64Emitter` | emits text for IR-selected insns only — not an assembler |
| wasm backend | emits WAT text; no binary encoding |
| arm32/arm64 | nothing |
| Inline-asm handling in targets | missing (the gap) |
| Research inputs | `lib_old/wallvm/docs/opcodes.txt`, `new-instructions-research.md` (696 lines) |

## Design

Two layers, table-driven everywhere so adding an instruction is a table row
plus a fixture, not a code change:

1. **Shared front end** (`lib/wallvm/asm/common.crl`) — lexer for asm text
   (mnemonics, registers, memory operands, immediates, labels, directives,
   comments), parse to a target-neutral operand model, plus the constraint
   parser for inline-asm constraint strings (`"=r"`, `"+r"`, `"m"`, `"i"`,
   `"r"`, clobbers).
2. **Per-target encoder backends** — one module per ISA, each with its
   mnemonic table (form → encoding recipe) and a validate/encode entry:
   - `x86_64.crl` (+ shared `x86_common.crl`: ModRM/SIB/displacement/REX)
   - `x86.crl` (32-bit, shares `x86_common`)
   - `arm64.crl`, `arm32.crl` (fixed-width encoders, separate tables)
   - `wasm.crl` (WAT text → binary sections; complements the existing text
     emission mode, eventually lets the backend emit `.wasm` directly)

**Inline asm path:** `InlineAsm` inst → target asm module: parse text,
validate operand forms against the mnemonic table, check constraints against
the attached values (register class vs `"r"`, memory vs `"m"`, early-clobber
etc.), then either (a) encode to bytes, or (b) pass through into the emitted
`.s` text **after** validation, so even the gas-based pipeline rejects bad
asm with a real diagnostic instead of shipping it.

**Recommended sequencing of the two outputs:** validation-first (text
passthrough stays the emission mode while the encoder matures), direct
object emission later. The wasm target has no system assembler to lean on,
so its encoder is required for binary output regardless.

## External toolchain alternative — TinyCC (user note, 2026-10-08)

We might just use TinyCC's assembler and the linkers it provides instead of
writing every encoder ourselves.

- tcc ships an integrated, GAS-compatible assembler (text → object) and a
  linker for ELF and PE targets, so inline asm and final link could both be
  delegated: validate constraints on our side, hand the asm text to the tcc
  path, let it assemble and link.
- What it buys: full GAS-syntax coverage and battle-tested encodings for
  x86/x86_64/ARM without maintaining our own tables, plus linking for free.
- What it costs: an external dependency (or an embedded C codebase), less
  control over diagnostics, and no wasm target — the wasm text→binary
  encoder (P4) stays ours regardless.
- Constraint/operand validation against the IR stays ours either way (the
  InlineAsm gap closes the same); what changes is who turns validated text
  into bytes.
- If this route is taken, P1-P3 collapse into a tcc integration task (embed
  or subprocess, diagnostics mapping); the golden-encoding fixtures stay
  valuable either way — they double as equivalence tests against tcc output.

## Instruction breadth (the "wide amount" requirement)

- **x86 / x86_64:** mov family (mov, movzx, movsx, movsxd, lea, xchg,
  cmovcc), stack (push, pop, leave), full integer ALU (add sub adc sbb and
  or xor cmp test neg not inc dec), shifts/rotates ( shl shr sar rol ror rcl
  rcr), mul family (mul imul div idiv), control (jmp jcc call ret loop,
  setcc), string ops with rep prefixes (movs stos cmps scas lods), bit ops
  (bt bts btr bsf bsr popcnt tzcnt lzcnt), lock-prefixed atomics (xadd
  cmpxchg xchg, mov), nop/nopd padding forms, syscall/sysenter/int3, and an
  SSE/SSE2 working set (movss/sd, movaps/up, movdqa/u, movd/movq, add/sub/
  mul/div ss/sd, cvtsi2ss/sd, cvttss/sd2si, sqrtss/sd, pxor/pand/por/andps,
  ucomiss/sd, comiss/sd). AVX subset as a later table extension.
- **arm64:** full data-processing (mov movn movk, add sub adc sbc cmp cmn,
  and orr eor bic mvn, lsl lsr asr ror, mul madd msub sdiv udiv, csel cset),
  load/store all widths with pre/post-index and pair forms (ldr/str ldrb/
  strb ldrh/strh ldrsw ldp/stp, unsigned immediates, literal loads, adr/adrp),
  branches (b bl b.cond cbz cbnz tbz tbnz ret), bitfield (ubfx sbfx ubfiz
  bfxil lsr/lsr immediate forms), system (nop yield svc brk dmb dsb isb mrs
  msvc), a practical FP subset (ldr/str d and s, fadd fsub fmul fdiv fcmp
  scvtf fcvtzs).
- **arm32:** data processing (mov mvn add adc sub sbc rsb and orr eor bic
  mul mla umull smull udiv sdiv, cmp cmn tst teq), shifts on operands,
  load/store word/byte/half with writeback, ldm/stm including push/pop,
  branches (b bl bx blx cond), mrs/msr, coprocessor FP subset.
- **wasm:** the full WAT instruction surface — control (block loop if else
  end br br_if br_table return call call_indirect unreachable drop), locals/
  globals (local.get/set/tee, global.get/set), memory (i32/i64.load*/store*
  with offsets, memory.size/grow, memory.copy/fill), numeric (all i32/i64
  arith, div/rem signed+unsigned, bit ops, shifts/rotates, clz ctz popcnt),
  comparisons (eqz, eq ne lt gt le ge signed+unsigned), float ops (all f32/f64
  arith, comparisons, neg abs ceil floor trunc nearest sqrt), conversions
  (all wrap/trunc/promote/demote/convert signed+unsigned, reinterpret),
  consts, select, nop, plus module-level sections the backend already
  prints (type/import/func/table/memory/global/export/elem/code/data).

## Verification strategy (per phase, non-negotiable)

1. **Golden encodings:** every mnemonic form gets a fixture — input text →
   expected bytes — fixtures generated once from a trusted assembler (GNU as
   / llvm-mc) and checked in. Encoder output must match byte for byte.
2. **Round trip:** where cheap, decode the emitted bytes back and compare
   the instruction form; catches operand-order and ModRM/SIB mistakes.
3. **Inline-asm corpus:** a suite of snippets exercising each constraint
   class and clobber form; both accepted (valid) and rejected (must produce
   diagnostics) cases.
4. **Diagnostics:** invalid register/operand combinations must fail with a
   message naming the instruction and operand — never silently pass through.
5. **No stubs:** coverage tables must say what is supported; anything listed
   as supported has at least one passing fixture.

## Phases

- **P0 (now):** this document; the confirmed inline-asm gap recorded above.
- **P1:** shared front end + constraint parser + x86_64 encoder core
  (mov/alu/jcc/lea/stack/call/ret/SSE working set) + golden fixtures.
  Highest value — x86_64 is the primary native target.
- **P2:** x86 32-bit on the shared core; breadth push toward the full list.
- **P3:** arm64 + arm32 encoders.
- **P4:** wasm text→binary (then the wasm backend can emit binary directly).
- **P5:** atomics prefixes, wider SSE/AVX tables, fuzz the mnemonic tables
  against the fixture corpus, wire inline-asm validation into every target
  emitter (also the fix for the dropped-`InlineAsm` bug: the `Noret`-
  style default arm must no longer swallow the opcode).

Ordering note: P1 can start as soon as the passes/regalloc ports and their
verification are through — encoder work does not depend on the optimizer
passes, but the `asm_rules` tables being ported feed the mnemonic lists and
should land first as input.

## Non-goals (for now)

- Full ISA encyclopedias for every vendor extension — tables grow by need
  and fixture.
- x87 (long double), x87 and MMX — out until someone needs them.
- Macro assemblers (gas `.macro`, ARM pseudo-instruction aliases beyond the
  common ones like `movs`/`lsl` immediate forms) — a documented subset.

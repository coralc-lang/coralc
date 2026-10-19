# Codegen Quality Reference (gcc study → wallvm audit)

Goal: measure our x86 backend (`lib/wallvm/target/x86_64/x86_64_base.crl`,
`lib/wallvm/target/x86/x86_base.crl`) against what GCC actually emits, per
construct, and turn the gap into a prioritized fix list.

**Revalidated 2026-10-09 against the current tree.** The original audit is
substantially stale in both directions: several rows are fixed, and the
backend has gained optimizations no row mentions. Line numbers drifted by
roughly +300 in `x86_64_base.crl` — cite function names, not the old lines.
Changes in this revision:

- **Fixed since the audit:** leaf/alloca frame handling (fix 10), and the
  `lea`/shift strength-reduction for small constant multipliers (fix 11's
  first half) — see "Optimizations the original audit missed".
- **Regressed then fixed:** tail calls (fix 9). The old `isTailCall` was
  hardwired off after the "already-emitted sequence" flaw; real tail calls
  landed 2026-10-09 — see the table row and pipeline-gaps G34.
- **New miscompile, worse than the audit stated:** unsigned div/rem emits
  `cqo` before `divq` instead of `xorl %edx, %edx`. The audit framed the
  32-bit row as a possibly-unheld invariant; it is a plain wrong-answer bug
  (`pipeline-gaps.md` G42/A20). **Fixed 2026-10-09** — `emitDiv`/`emitRem`
  branch on `isSigned` now.
- **Another new miscompile, found and fixed 2026-10-09:** parameter
  seeding emitted `movq <abiReg>, <home>` per store in one pass, and a
  home can be a register a later parameter arrives in (SysV homes start
  at rcx/rdx/rsi/rdi; rdx is argument 2's) — so the walk could overwrite
  an incoming argument before reading it. Now two-phase: stage every
  bank word to the stack, then commit to homes (`pipeline-gaps.md`
  G44/A21).
- The 32-bit backend is *better* on width and div/remainder than the audit
  credited; it is not "blind".

Corpus: `/tmp/wallvm_corpus/corpus.c` (~60 tiny functions covering integer
add/sub/mul/div/rem (signed+unsigned), shifts, compares, selects, i8/i16/i32/i64
loads/stores, arrays + struct field access, float add/mul/div/compare, calls
(leaf/non-leaf), loops (sum, memset-like), abs/min/max, constant materialization,
pointer arithmetic, div by constant). Built with
`gcc -O0/-O1/-O2/-O3 -S -masm=att` (GCC 16.1.1). Representative -O2 output is in
`/tmp/wallvm_corpus/o2.s`. **Note: `/tmp` does not survive a restart — the
corpus and `o2.s` need regenerating before the comparison can be redone.**

## Section 1 — What GCC emits and why it is good

### 1.1 Width-correct mnemonics everywhere
GCC picks the mnemonic to match the C type: `addl/subl/imull/idivl/shrl/sarl/cmpl/movl`
for 32-bit ops; `movq/imulq` only when the type is 64-bit. It never materializes a
64-bit op for 32-bit data. Writing a 32-bit result zero-extends into the 64-bit
register for free, so the upper half needs no separate cleanup.

### 1.2 `xorl %eax,%eax` for zero
`zero()`, `uzero()` compile to `xorl %eax, %eax; ret`. `xor reg,reg` is handled
as a zero-idiom (no dependency on the old value, breaks the dependency chain,
1 cycle). Same trick sets `%edx` before unsigned `divl` (`xorl %edx,%edx`).

### 1.3 `leal` for adds and scaled adds
`a+b` → `leal (%rdi,%rsi), %eax`. `a*3-b` → `leal (%rdi,%rdi,2), %eax`. `x*7` →
`leal 0(,%rdi,8), %eax; subl %edi, %eax`. `i*stride+j` → a single `imull` +
`movlslq` + one SIB load. LEA costs one cycle, no flags, and folds scale-by-1/2/4/8
plus displacement for free — the canonical replacement for mul-by-small-constant and
for an explicit add.

### 1.4 Memory operands folded into ALU ops
`a[i] += v` on the same address compiles to `addl (%rdi), %eax` / `add w/l/q, (%r)` —
one instruction instead of load+op+store. `sum += a[i]` → `addl (%rdi), %eax`.
`p->y = v` → `movl %esi, 4(%rdi)`. `p->x` → `movl (%rdi), %eax`. Struct field offsets
fold into the displacement (`4(%rdi)`, `8(%rdi)`, `10(%rdi)`).

### 1.5 `test` vs `cmp $0`
Guarding a loop with a zero/non-zero check: `testl %esi, %esi; jle`/`je` rather than
`cmp $0`. A compare against zero is just a subtract — `test` sets the same ZF and
documents intent; more importantly the incoming flag may already hold the answer.

### 1.6 `cmov` / `setcc` for small selects
`max(a,b)` → `cmpl %edi, %esi; movl %edi, %eax; cmovle %esi, %eax`. Compare →
zeroed rax → `setle %al`. `abs` → `negl; cmovs %edi, %eax`. Branchless, no
misprediction, both inputs already evaluated.

### 1.7 Sign/zero-extension folding into loads
`char`, `short` loads emit `movzbl/movzwl` (zero-extend) or `movsbl/movswl` (sign-extend)
*directly from memory* — no separate `movzbl reg, reg` after a plain load, no
dest-suffix trickery. Small struct fields likewise (`sz` → `movswl 8(%rdi), %eax`,
`sw` → `movsbl 10(%rdi), %eax`).

### 1.8 `idiv` only when necessary; magic-multiply for constant divisors
Runtime divisor → real `cdq`/`idiv` (or `xorl %edx,%edx`/`divl` unsigned). Constant
divisor 7 → `imulq $-1840700269` + shifts (the Granlund–Montgomery magic-number
division sequence), which turns a ~20–40-cycle `idiv` into a 3-cycle multiply + shift.
GCC also special-cases powers of two (`sar/shrl` by k, with bias correction for
signed division) — fixed shifts instead of a divide.

### 1.9 Branch layout: hot path falls through
The loop body (`addl (%rdi), %eax; addq $4, %rdi; cmpq %rdx, %rdi; jne`) keeps the
back-edge taken/not-taken so the fall-through path is the loop body; the cold path
(`.L36:`, `.L39:`) is placed after the hot path. PDE/idiom loops become `jmp memset@PLT`
— one tail call instead of a byte loop.

### 1.10 Tail calls
`memset_like` lowers to `tail jmp memset` with no stack frame — the frame is torn
down before the jump, reusing the caller's frame.

### 1.11 Leaf-function stack-frame avoidance
Every tiny function has no prologue at all: no `push %rbp; mov %rsp, %rbp`, no
`subq $N, %rsp`. GCC proves nothing needs memory, keeps everything in registers,
and emits just the body + `ret`.

### 1.12 No redundant moves
`square(x)+square(x+1)` is inlined and scheduled in-place; `leaf(a,b)*2` →
`leal(%rdi,%rdi,2); subl; addl %eax,%eax` (add self, no mov-then-add). A return in
`%eax` that is already in `%eax` emits no move (`f2i` → bare `ret` when the input
and output registers already match).

### 1.13 Constant materialization
Small constants are immediates in the ALU op or a single `movl $imm, %eax`.
Float constants come from a constant pool (`.rodata.cst4` + RIP-relative
`addss .LC0(%rip), %xmm0`) — never a `movq $0x3F800000` + `movq2xmm` dance.

### 1.14 Pointer arithmetic folding
`a[i*stride+j]` → `imull %ecx,%esi; addl %edx,%esi; movslq %esi,%rsi; movl (%rdi,%rsi,4),%eax`
— the index is sign-extended once and the SIB form does base+index*4 in the load
itself. GEP with constant offset → displacement, no `lea` at all when nothing needs
the address itself.

## Section 2 — Audit of our backend

Verdict legend: **good** (we match GCC), **partial** (exists but narrow/incorrectly
gated), **naive** (missing / always-64-bit / wrong-width).

| GCC behavior | Our emitter | Evidence |
|---|---|---|
| Width-correct mnemonics | **naive**: every arithmetic path copies with `movq` and uses the 64-bit op; the width-argument `lOp` is accepted but never emitted. | `emitBinOp` — x86_64_base.crl:2078 (always `movq`, always `qOp`; callers pass `"addl"` etc. but it is dropped). `emitDiv`/`emitRem` — x86_64_base.crl:2098/2125 (always `%rax`/`cqo`/`idivq`). `emitShift` — x86_64_base.crl:2152 (always `movq`, `%cl` op, 64-bit). `emitUnOp`, `Neg`, `Not`, `emitICmp` — x86_64_base.crl:2173, 1747-1768, 2244 (always `movq`/`notq`/`negq`/`cmpq`). |
| `xor reg,reg` for zero | **partial**: only `x*0` gets `xorq dst,dst` (64-bit, wrong for 32-bit) and only when `src1`/`dst` aliases are handled; general `x^x`, zero-return, and `%edx`-zeroing before unsigned div are absent. | x86_64_base.crl:876-889 (`iselEmitMulConst` `c==0` → `xorq`), x86_64_base.crl:3109 (xor is only used to zero the vararg xmm count, i.e. by hand). |
| `lea` for add/scale | **fixed, then some**: standalone `emitGep` uses `leaq` with base/index/scale and now derives the scale from the operand type rather than defaulting to 8; more importantly the ALU paths gained `leaq`/shift strength reduction that the original audit recorded as entirely absent (see "Optimizations the original audit missed"). | `iselEmitMulConst` — x86_64_base.crl:1218-1385 (×2 `leaq (r,r)`, pow2 `shlq`, and `lea` sequences for ×3/5/6/7/9/10/12). `iselEmitAddSelf` — :1445-1456 (`x+x` → `leaq (r,r)`). `emitGep` — :2788-2820 (scale from `ops[0]->type->width`). Remaining gap: all of it is 64-bit (`leaq`/`shlq`), and `emitGep` still ignores a constant index. |
| Add folding into load/store address (op-with-memory-source) | **partial**: `iselTryFoldLoadOpStore` covers `load→op→store` same-address for add/sub/and/or/xor with widths 8/16/32/64 (x86_64_base.crl:1378-1446) — but there is no fold for "use memory operand as ALU source" (`addl (%rdi), %eax` where the value is used once), so arithmetic loads a register copy first. | `iselTryFoldLoadOpStore` gate `loadInst->ops[0] != addrVal` — x86_64_base.crl:1422; no equivalent for a bare Load+Op use. |
| Store constant to memory | **naive**: `store i32 %c, p` copies the constant into a register first, then `movl` to memory. No `mov $c,(%r)` and no `add $c,(%r)` folding. | `emitStore` / `emitStoreWidth` — x86_64_base.crl:2200-2210, 1253-1296. |
| GEP+load/store folding (disp + SIB) | **partial**: `iselTryFoldGepLoad`/`GepStore` exist (x86_64_base.crl:1447-1568) but only when the GEP has a *register* index with scale 1/2/4/8 and no constant displacement — a struct field `p->y` (constant offset) never folds to `movl 4(%rdi), %eax`; it still materializes a separate `leaq` + load. | x86_64_base.crl:1447-1506 (fold requires `addrInst->nops >= 3` and uses idx register + hard-coded scale 4 in `(base, idx, 4)` — no disp/literal index path). |
| `test` vs `cmp $0` | **good** for the literal-0 rhs case only: `iselTryFoldCmpZero` covers `icmp x, 0` (x86_64_base.crl:1570-1589) — but `emitCondBr` unconditionally emits a fresh `testq cond,cond` even when `cond` is already an `icmp` result (so compare+branch
work), and a general "reuse incoming flags" is absent. | x86_64_base.crl:1570, 2327-2345. |
| xor-zeroing result registers before `setcc` | **naive**: `emitICmp` uses `%al` without zeroing it first and moves with `movzbq %al, dst` — fine, but compared to gcc's `xorl %eax,%eax; setl %al` it leaves `%rax` upper garbage semantics unhandled and has no path to reuse. Minor. | x86_64_base.crl:2244-2265. |
| `cmov` for small selects | **partial**: `emitSelect` emits `testq cond,cond; cmovne src1; cmovz src2` (x86_64_base.crl:2955-2984) — correct skeleton but 64-bit unconditional (`dst` never truncated to 32-bit), and it forgets that both operands must be materialized; GCC's `cmp; mov; cmov` form avoids one partial-flag idiom. | `emitSelect` — x86_64_base.crl:2955; compare-driven cmov from an `icmp` predicate is not used (gcc maps max/min select to `cmp`+`cmov` directly). |
| Sign/zero-extension folding into loads | **good**: `iselTryFoldExtLoad` emits `movzbl/movzwl/movsbl/movswl/movslq` directly from memory (x86_64_base.crl:1298-1377). | — |
| Constant-divisor magic multiply | **partial**: pow-2 only (`iselEmitSDivPow2`/`iselEmitUDivPow2`, x86_64_base.crl:1085-1140) and divmod.crl fuses div+rem into mul/sub; general constant-divisor magic-multiply (GCC's `imul`+shift sequence for 7, etc.) is absent — non-pow2 constants fall to `idivq`. | divmod.crl:1-15 (fuse only); x86_64_base.crl:1085, 1118; generic `emitDiv` at 2098. |
| Branch layout / inversion | **naive for layout, improved at IR**: `emitCondBr` still jumps to the true target and falls through to an unconditional `jmp` of the false target with both edges as jumps; no hot/cold ordering. But the original audit's claim that branch passes have "no evidence of wiring" is stale — `irPassBranchInversionFlat` is in the L1 and L3 pipelines and `macro_fusion` is in L3, hoisting `ICmp` next to its `CondBr`. Neither is block *layout*, so the layout half stands. | `emitCondBr` — x86_64_base.crl:2905-2922; blocks in IR order — linux.crl:38-48. Wiring — wallvm.crl:213, :273, :293; `passes/macro_fusion.crl:31-63`. |
| Tail calls | **fixed (x86_64)**: `emitCall` decides the tail shape before emitting — `tailShapeOk`/`inTailPosition` require a direct named callee, register-only args, the call as the block's second-to-last instruction with its result feeding only the immediately following `Ret`, and a frameless function with no callee-saves/spill/vararg area. Success emits the arg moves then `jmp target[@PLT]` instead of `call`, skips the result sink, and the `Ret` emits nothing (`tailJmpCall`). A staged parallel copy or Win64 shadow needing an un-emitted restore drops back to the ordinary call before the stack adjustment. Still out of scope: stack-arg or framed sibling calls (needs epilogue-before-jump + signature-aware shifting) and cross-block call/ret. The broken 32-bit heuristic is removed. | `tailShapeOk`/`inTailPosition` — x86_64_base.crl; tail skip — `emitRet`; 32-bit removal — x86_base.crl; passes/tco.crl (unrelated accumulator pass). |
| Leaf-function frame avoidance | **fixed**: leaf + no spills + no allocas + no stack args takes a red-zone path with an early `return` and no `push %rbp`; `needFrame` requires a frame for any of those four conditions. `emitAlloca` no longer does a per-alloca `subq $8` — the prologue reserves `allocaBytes` once and each alloca gets a fixed `leaq -off(%rbp), dst`. Shrink-wrapping of callee saves is also present. | red zone — x86_64_base.crl:593-600; frame gate — :719-753; alloca sizing/placement — :460-514, :2753-2786; shrink-wrap — :406-448, :721-728. |
| Redundant move elimination | **naive**: `emitBinOp`, `emitShift`, `emitDiv`, `emitCast`, `emitRet` all `movq` whenever `src != dst` string-compare says so — which is true after register allocation *for the copy of the operand into the op*, not a real coalescing pass; no peephole removes `movq %rax, %rax` sequences across isel folds (`movq rax; movq r10, rax; addq...` is common in generated code because every op copies its first operand). | x86_64_base.crl:2078-2096, 2152-2171, 2244-2265. |
| Constant materialization | **partial**: immediates for ALU ops exist (`iselIsConstInt` gate at x86_64_base.crl:859); float constants via data section (good). But `ret 0`/generic zero paths have no `xor-zeroing` and constants loaded via `movq $` without a `movl $, %eax` 32-bit fast path anywhere in the generic emitter. | x86_64_base.crl:859, 1167-1170. |
| memset-loop → memset call | **partial**: `idiom.crl` exists; `memset_like` would want a single `tail jmp memset` — no direct evidence the isel path emits it; the IR-level idiom pass may, but the emitter has no loop-idiom lowering of its own. | passes/idiom.crl (not reviewed line-by-line here); emitter has no equivalent. |
| 32-bit shift/div clobber correctness | **div/rem fixed 2026-10-09**: `emitDiv`/`emitRem` branch on `isSigned` now — `cqo` only for signed, `xorl %edx, %edx` for unsigned — so the audit's "unconditional `cqo`" claim (and the wrong quotient it produced for any unsigned dividend with bit 63 set) no longer applies. The 32-bit port's sequence was the model. `emitShift`'s width handling is still naive (tracked as item 1). | fixed sites — `emitDiv`/`emitRem` (x86_64_base.crl, around the old :2625-2677 bodies); correct 32-bit sequence — x86_base.crl:670-674, :708-712. |
| `imulq` clobbering for 64-bit mul | **partial, improved**: `Mul` falls back to three-operand `imulq src2, dst`, but the "no `lea` for powers of two" sub-claim is now **wrong** — `iselEmitMulConst` lowers small constant multiplies through `leaq`/`shl` for {2,3,4,5,6,7,8,9,10,12}, which is GCC-shaped strength reduction. What is still missing is width-correctness of those sequences (all `leaq`/`shlq`). | fallback — x86_64_base.crl:2265; `iselEmitMulConst` — :1218-1385. |

## Section 3 — Prioritized fix list

Ordered by expected value (correctness first, then speed on typical code, then size).

**Revalidated 2026-10-09.** Item order below is current. Two items were
promoted to correctness-first that the original audit rated as quality:
item 6's unsigned-divisor half is a wrong-answer bug (new item **0**), and
item 9 (tail calls) regressed to "not implemented on 64-bit".

0. ~~**NEW — unsigned div/rem must zero `%rdx`, not `cqo`.**~~ **FIXED
   2026-10-09** — `emitDiv`/`emitRem` now emit `cqo` only when `isSigned`
   and `xorl %edx, %edx` otherwise, the two-line sequence the 32-bit port
   already had. Before the fix a dividend with bit 63 set divided against
   an all-ones high word and yielded a wrong quotient. (Retained as the
   record; `pipeline-gaps.md` A20/G42.)

1. **Width-aware mnemonic selection (i32/i16/i8) in all ALU paths.**
   Naive: every op copies with `movq`, always uses the 64-bit op (`addl` passed but ignored).
   Target: pick by `inst->base.type->width` like `emitLoadWidth`/`emitStoreWidth` already do —
   `movl`/`movl`+`addl`/`subl`/`imull` for 32-bit, `movw`/`movb` for 16/8, `movq` only for 64-bit.
   Change: `emitBinOp`, `emitDiv`/`emitRem` (use `cdq`+`idivl` for i32, `cltd/divl` unsigned),
   `emitShift` (emit `%cl` with `shll/sarl/shrl` for i32), `emitUnOp`, `Neg`/`Not`, `emitICmp`
   (`cmpl`/`cmpw`/`cmpb`), `emitSelect`/`emitCondBr` (`testl`).
   Win: correctness (64-bit ops on 32-bit data can silently change semantics after
   partial-register clobbers) and ~2× smaller on i32-heavy code; this is the single
   biggest audit finding.

2. **Compare-flags reuse + one instruction from compare to branch.**
   Naive: `emitICmp` materializes via `setcc` into a register, then `emitCondBr`
   re-tests it (`testq cond,cond`), an extra block of instructions; no inversion.
   Target: directly from `icmp`+`condbr` on the same value, emit `cmpl %es, %edi` +
   `jl/jge/...` — one fused compare+branch, true-target laid out as the hot fall-through
   or after an inversion pass.
   Change: isel fold `ICmp` feeding `CondBr` (cond consumed only by branch) +
   block-layout pass that orders hot successor as fall-through; plumb
   `branch_inversion.crl`.
   Win: 2–4 fewer instructions per branch, better PDE prediction; small/medium.

3. **GEP displacement folding into memory operands for constant offsets.**
   Naive: `iselTryFoldGepLoad/GepStore` only handle register index * scale; every
   struct field (`p->y`, `p->z`) materializes `leaq` + separate load even though the
   offset is a constant that fits the disp field.
   Target: fold `Gep(base, constOffset)` → `movl N(%base), %eax` / `movb N(%base), %r8b`;
   fold `Gep(base, idx)` with element size → SIB `(base, idx, scale)` plus disp for the
   constant part; reserve `leaq` for when the address is itself the result.
   Win: 1–2 instructions per field access, less register pressure; medium.

4. **Op-with-memory-source fold (load-op as single ALU op with memory operand).**
   Naive: a load used once by an arithmetic op goes through a register, then the op.
   Target: `sull = load p; x = sull + k` → `movl (%r), %eax` folded to
   `addl (%r), %eax` — same shape as GCC's `addl (%rdi), %eax` in reduction loops.
   Change: isel hook on ALU op whose operand is a single-use Load; reuse the same
   same-address discipline as `iselTryFoldLoadOpStore`.
   Win: 1 instruction per folded op, smaller loops; medium.

5. **Magic-multiply for constant divisors (any constant, not just pow2).**
   Naive: only pow2 divisors (`iselEmitSDivPow2`/`iselEmitUDivPow2`) and divmod.crl
   div+rem fusion; all other constant divisors emit full `cqo`+`idivq` (and 64-bit!).
   Target: GCC's Granlund–Montgomery sequence — for nonzero constant `d`, precompute
   `M = ceil(2^(32+L)/d)` etc., emit `movslq $M`+`imulq`+`shrq`+adjust; reuse for u32.
   Change: new isel helper `iselEmitDivConstMul` used from the `trySelect` dispatch in
   `Add..Lshr` (x86_64_base.crl:1171-1216), plus width-correct 32-bit variant.
   Win: replaces ~20–40-cycle `idiv` with ~3-cycle multiply+shift in divisor-heavy
   code; medium-high on such loops.

6. **xor-zeroing for 0-valued definitions and div/rem's `%edx`.**
   *(The correctness half moved to new item 0 — do it first.)*
   Remaining: `x*0` → `xorq` is still 64-bit-only (wrong width for i32), and
   there is no general `x^x` → zero-register xor idiom at the emitter level
   (`peephole.crl:311` folds `x^x` to a *constant*, not to an xor
   instruction), nor a `xorl %eax,%eax` fast path for `ret 0`/zero returns.
   Target: width the existing xor with the op width; emit `xorl %eax,%eax` for
   zero-valued definitions and results.
   Win: smaller/faster zero materialization; subsumed by item 1's width work.

7. **`cmov` directly from icmp; width-aware `emitSelect`.**
   Naive: `emitSelect` always `testq cond,cond; cmovne; cmovz` with 64-bit moves.
   Target: when select condition is an icmp, fuse to `cmpl; movl %esi,%eax; cmovle`;
   use `cmovl` (etc.) keyed off the real predicate, width-correct.
   Change: isel fold on Select whose cond is a single-use ICmp; pass the predicate's
   width through.
   Win: removes the test idiom and a register copy; small.

8. **Constant-to-memory stores/loads (`mov $c,(%r)` / `mov $c,%reg` with no movq dance).**
   Naive: constants are loaded to a register, then stored; no `movl $42, (%rdi)`.
   Target: `store i32 %c, p` → `movl $c, (%r)`.
   Change: `emitStoreWidth` checks if `inst->ops[1]` is a `ConstInt` and emits the
   immediate form.
   Win: one fewer mov per store; small.

9. **Tail-call coverage.** *(regressed since the original audit)*
   `isTailCall` is now an unconditional `return false` with a comment
   explaining why and naming G34 as still-open, so `emitRet`'s tail branch is
   dead code and 64-bit tail calls are gone entirely — worse than the "thin
   coverage" the audit found. Reinstating it requires a real lowering
   (`ret call` → jump with moved argument registers and the frame already
   released), not a peephole: the audit's target of "reuse the IR TCO pass"
   would hit exactly the re-run hazard the new comment cites. The `tco.crl`
   accumulator pass and the 32-bit `isTailCall` are unaffected.

10. ~~**Frame avoidance for alloca-less functions; one slot per alloca, not `subq $8` each.**~~
     **DONE.** Leaf functions with no spills, allocas or stack args take a
     red-zone path with no `push %rbp`; `scanAllocas` sums type-sized
     (16-rounded) allocas once and the prologue reserves the region; each
     alloca gets a fixed `leaq -off(%rbp), dst`. Shrink-wrapping also landed.

11. **`lea` for constant-indexed adds instead of `imul`+add, and `negq`/`notq`/`movq` width fixes.**
     **Half done.** The `lea` half is done and beyond the ask:
     `iselEmitMulConst` covers ×2/3/4/5/6/7/8/9/10/12 and `iselEmitAddSelf`
     handles `x+x`. The width half (`negq`/`notq`/unconditional `movq`) is
     not, and collapses into fix 1.

12. **Loop-idiom lowering for memset/memcpy in the emitter or a guaranteed idiom pass.**
    Naive: byte-store loops compile as literal load/cmp/store blocks.
    Target: GCC's single `tail jmp memset`.
    Change: verify `idiom.crl` runs before isel for hot loops; otherwise lower
    recognizable write-loops in the emitter pass through a helper.
    Win: large for such loops (vectorized memset vs byte loop).

## Optimizations the original audit missed

Present in the current tree, absent from every row of the original Section 2
and fix list. Recorded 2026-10-09 so the audit is not read as a complete
picture of the backend.

- **Small-constant multiply strength reduction** — `leaq`/`shl` for
  {2,3,4,5,6,7,8,9,10,12} (`iselEmitMulConst`, x86_64_base.crl:1218-1385)
  and `x+x` → `leaq (r,r)` (`iselEmitAddSelf`, :1445-1456). The original
  audit's `lea` row described this as missing.
- **Identity and small-immediate folding** — `add x,0`, `sub x,0`,
  `and x,-1`, `or x,0`, `shl x,0` fold to a bare copy; `+1`/`-1` → `incq`/
  `decq`; `xor x,-1` → `notq`; `0 - x` → `negq`
  (`iselTryFoldIncDec` :1918-1977, :1897-1914, :1981-1999).
- **Signed div-by-power-of-two with bias correction** (`sarq $63` / `shrq` /
  `addq` / `sarq`, :1389-1420) — GCC's exact sequence. The audit mentions
  "pow-2 only" as a limitation without noting the form is already GCC's.
- **Shrink-wrapping + deferred frame push** (`emitDeferredCalleeSaves`
  :406-448, `canShrinkWrap` :721-728, gated on `blockUsesReg` :374-388).
  `pipeline-gaps.md` B10 still says "no shrink-wrapping" — stale for 64-bit.
- **Non-leaf frame-pointer omission** (`omitFramePointer` default true, :311;
  gates :689, :729-735): a non-leaf function with no spills, allocas or
  stack args emits no frame at all. Unmentioned anywhere.
- **Single-instruction bit/popcount lowering** — `ctpop`/`ctlz`/`cttz`/`bswap`/
  `rotl`/`rotr` with CPU-feature gates and software fallbacks (:4010-4113,
  dispatched :2581-2587). The other docs mention these only as *idiom-pass*
  patterns, never as backend lowering.
- **`SMin`/`SMax`/`UMin`/`UMax` → single `cmp` + `cmov`** (`emitMinMax`
  :4116-4146, dispatched :2588-2591) — GCC's §1.6 `cmov` shape. The audit's
  `cmov` row only ever examined `emitSelect`.
- **`abs` → `neg` + `cmovns`** (:3994-4008), i.e. GCC's `negl; cmovs` in
  branchless form.

## Notes

- All audit citations refer to `lib/wallvm/target/x86_64/x86_64_base.crl` unless
  named. Line numbers drifted by roughly +300 during the 2026-09 revalidation;
  prefer function names.
- **The 32-bit port is better than the original Notes claimed.** It uses
  `movl`/`cmpl`/`testl` throughout (x86_base.crl:621, :634, :657, :732, :842,
  :897) — it is not width-blind — and it gets div/remainder *right*
  (`cltd` if signed, else `xorl %edx, %edx`, :670-674, :708-712) where the
  64-bit backend is wrong. It is the better-maintained of the two on these
  points.
- `divmod.crl` fuses div+rem into mul/sub; `tco.crl`, `branch_inversion.crl`,
  `macro_fusion.crl`, `select_to_branch.crl` and `jump_thread.crl` exist at IR
  level. More of them are wired now than when this was written
  (`branch_inversion_flat` in L1/L3, `macro_fusion` and `sel2br` in L3,
  `jump_thread` in L2/L3), so the original "several are not fed into the x86
  emitter path" note is overstated — though the emitter-side fusions these
  would enable (items 2, 7) still do not exist.

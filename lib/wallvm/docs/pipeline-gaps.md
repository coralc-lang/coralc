# Wallvm Pipeline Gap Analysis

Status: analysis document. Compares the wallvm pass pipeline and backends as
they exist today against a production optimizer/codegen pipeline (clang
-O1/-O2, new pass manager, plus the LLVM machine-code layer). Every claim was
verified against the tree; suspected bugs are marked **[verify]** where the
code is ambiguous or the convention split is systemic.

**Revalidated 2026-10-09 against the current tree.** Several headline items
have since been fixed and their rows are marked FIXED rather than deleted, so
the audit trail stays readable. Line numbers in the original rows drifted by
roughly +300 in `x86_64_base.crl` — cite function names, not old line numbers.
Corrections in this revision:

- **G21/A1 fixed** — the spill contract is now implemented end-to-end.
- **G27/A5 fixed** — the emitter already used the builder's store convention;
  the doc's claim of an inversion, and its "one side must be wrong" hedge,
  were both wrong.
- **G30/A4, G32/A8 fixed** — realoca/alloca frame model and call-site ABI
  details landed.
- **G3, A12 fixed** — abi_lower's userdata contract and sroa's use-list
  maintenance.
- **G22's array off-by-one fixed**; the clobber half is still real.
- **G34 fixed** — real tail calls on x86_64 (see the row below).
- **NEW, not in the original audit: unsigned div/rem emits `cqo` before
  `divq`** (`emitDiv`/`emitRem`), which is a miscompile, not a quality gap.
  See G42. **Fixed the same day** — `emitDiv`/`emitRem` branch on
  `isSigned` now (`cqo` vs `xorl %edx, %edx`).
- **G43 fixed** — `stack_layout` only gathers allocas whose `parent` is
  the entry block, and the rebuild checks the new allocation for null and
  refuses to write past it.
- **G14 partly fixed** — `jump_thread` now requires
  `target->parent == func && target->npreds == 1` before emptying a
  block, and `select_to_branch.createBlock` names its blocks `sel2br<N>`
  (snprintf), so the emitter's `.L` + name can no longer collide. The
  broader simplifycfg pass is still absent.
- **G23 fixed** — the emitter decodes LSRA indices through
  `intRegNameFor`, which picks `X86_64_INT_REGS` or the new
  `X86_64_INT_REGS_WIN64` off `isWindows`; on the lsra side the dead
  pre-pin block (wrong index tables, `isWin` hardcoded false,
  overwritten by the scan anyway) was removed rather than repaired.
- **NEW, not in the original audit: parameter seeding could overwrite a
  later argument's incoming register before reading it** — see G44.
  Found and fixed the same day.

Sources read: `wallvm.crl` (driver), all 41 passes in `passes/`,
`regalloc/{lsra,graph}.crl`, `rules/asm_rules.crl`, `target/{x86,x86_64,wasm}`,
`target/x86_64/linux/abi_lower.crl` (+ windows/x86 variants), `noret/`,
`base/{irtypes,irOps,irBuilder,domtree,irMetadata}.crl`, `ffi/`, `gc/`,
`docs/assembler-plan.md`, `IR.md`.

---

## 1. The actual pipeline, stage by stage

### 1.1 Driver shape (`wallvm.crl`)

`irCompile` (wallvm.crl:406) loops over module functions and runs, per
function:

```
irOptimize(func, ctx, optLevel)      // one of pipelineLevel0..3, iterated
irStructureLane(func, ctx)           // borrowcheck, [unroll], validate
regalloc (lsra, or graph for O3 leaf fns ≤ 8 blocks; skipped for wasm)
```

then `irCodegen` on the whole module. There is **no module-level pass stage**
(call graph, globals, COMDAT); everything is a function pass. `PassPipeline`
is a flat array run by `runOnFuncIterate` until no pass reports change, with
maxIters = 1 / 2 / 5 / 8 for L0 / L1 / L2 / L3 (wallvm.crl:285).

### 1.2 L0 (wallvm.crl:158)

validate → simplify → constfold → sccp → dce → validate.

No mem2reg, no phi lowering. Frontend-emitted phis (legal per IR.md §1)
reach regalloc and codegen directly; the x86_64 emitter has **no Phi case**
(falls into the `else` comment arm, x86_64_base.crl:2074).

### 1.3 L1 (wallvm.crl:170)

validate → **abi_lower** → comm_canon → simplify → constfold → involution →
sccp → range → range_br_elim → branchprop → branch_inv_flat → cse →
cast_elim → dse → jump_thread → idiom → peephole → dce → validate.

Notable: no mem2reg/SROA at all (L1 optimizes raw alloca traffic), no LICM,
no GVN, no lower_phis (same phi-into-codegen problem as L0).

### 1.4 L2 (wallvm.crl:195)

validate → **abi_lower** → mem2reg → sroa → comm_canon → simplify →
constfold → involution → range → range_br_elim → branchprop → sccp → adce →
alias → mssa → licm → gvn → loopcse → jump_thread → **inline** → cast_elim →
idiom → peephole → dse → **lowrphis** → validate. Iterated ≤ 5 times.

### 1.5 L3 (wallvm.crl:227)

L2 plus: stack_layout, lex_canon, branch_inv_flat, branch_fact, divmod,
loop_interchange, loop_distribute, tail_dup, tco (accumulator), simd_vec,
idempotent, macro_fusion, machine_opt (MemorySSA store/load forwarding —
an IR pass despite the name), sel2br. Iterated ≤ 8 times.

### 1.6 Structure lane (wallvm.crl:295)

borrowcheck (diagnostic) → unroll (only with `--funroll`) → validate. Runs
**after** the optimization pipeline and **again** inside `irCompileAsm`
(wallvm.crl:477), so unrolling is applied twice when both entry points are
used.

### 1.7 Regalloc contract (wallvm.crl:344-398)

- `useCalleeSave = false` for SystemV/Win64 (caller-save only; call-spanning
  values are force-spilled), `true` for 32-bit x86.
- `backendHandlesSpills = true` for all x86 targets: lsra **does not** insert
  spill loads/stores (lsra.crl:913-915); it writes `SPILL_BIT|slot` or
  `FLOAT_BIT|reg` into `valData` (lsra.crl:1050-1074) and the backend is
  expected to decode it.
- wasm: no regalloc (stack machine).

### 1.8 Codegen dispatch (wallvm.crl:507-525)

SystemV/SyscallX86_64/SyscallMacOS → x86_64 linux; Win64 → windows;
Cdecl/Stdcall/SyscallX86 → x86; Wasm32 → wasm; **everything else → x86_64
bare** — including Wasm64, Aapcs64, Riscv64 (wrong target silently).

---

## 2. Reference pipeline (clang -O1/-O2, condensed)

```
module:  cgscc(inline bottom-up ↔ function simplification), globalopt,
         ipsccp, deadargelim, globaldce, function-attr inference
function: sroa → mem2reg(promote) → early-cse → jump-threading →
         correlated-prop → simplifycfg → instcombine ⇄ (repeat) →
         sccp/bdce/adce → reassociate → constraint-elim →
         loop-simplify + LCSSA → licm → loop-rotate → licm → unswitch →
         indvars(SCEV) → loop-idiom → loop-deletion → unroll →
         loop-distribute(O3) → loop-vectorize → slp → memcpyopt →
         sccp/bdce/dse → tailcallelim → simplifycfg
codegen:  isel (SelectionDAG/GISel) → machine-{cse,licm,copyprop} →
         pre-RA scheduling → regalloc (greedy: live-range splitting,
         rematerialization, coalescing, shrink-wrapping in PEI) →
         stack-slot-coloring (spill-slot packing) → post-RA scheduling →
         machine block placement (branch chaining/fall-through) →
         machine peephole → branch relaxation → emit (CFI/.eh_frame,
         DWARF, section flags, relocations)
```

Section 3 maps each divergence. Categories: **[C]** correctness/ABI,
**[Q]** code quality, **[N]** nice-to-have.

---

## 3. Gap inventory

### 3.1 Driver / pipeline structure

**G1 [C] — `irPassValidate`'s return value defeats fixpoint iteration.**
`validateFunc` returns `nerrors == 0` (validate.crl:247), i.e. **true when
the IR is valid**. `runOnFuncIterate` treats true as "changed, keep
iterating" (wallvm.crl:140-155). Validate sits at the head and tail of every
pipeline, so every function at L1-L3 always burns all 2/5/8 iterations.
Compile-time blowup and a masking effect over real non-convergence (see G2).
Belongs to: driver (`wallvm.crl`) + `passes/validate.crl` (needs a separate
"ran" vs "changed" contract, or validate must return false).

**G2 [C] — mem2reg ↔ lower_phis ping-pong.** L2/L3 end with `irLowerPhis`,
which turns each phi into a fresh alloca + per-pred stores + a load
(lower_phis.crl). On the next global iteration mem2reg re-promotes every
non-loop phi-alloca (they pass its promotability screen) and lower_phis
re-lowers them — the pipeline cannot converge whenever a non-loop phi
exists. Belongs to: driver ordering + `passes/lower_phis.crl` design.

**G3 — FIXED 2026-10-09 — `irABILower`'s userdata contract is no longer
type confusion.** The audit flagged that the pass contractually required the
`IrModule*` while the driver passed an `IrContext*` to every pass, so unless
the function was pre-marked by an external module-level run the pass walked
garbage. **[verify]** is now resolved: the SysV pass reads `func->parent` as
the module of record and only falls back to `userdata` when `parent` is null
(target/x86_64/linux/abi_lower.crl:906-916); the MS pass has the same shape.
`IrModule.addFunc` sets `f->parent = self` (base/irtypes.crl:547) and the
only construction site is the parser (text/irParser.crl:2169), so every
module function has a valid parent before `irOptimize` runs. The "external
module-level pre-marking" the doc speculated about does not exist.

**G4 [C] — SysV `irABILower` still runs for the wrong calling conventions.**
abi_lower is now selected per-`cc` (wallvm.crl:190-198), so Win64 gets the MS
pass — an improvement over the audit's "SysV for everything". But the i386
pass (`target/x86/linux/abi_lower.crl`) is still referenced nowhere, so
Cdecl/Stdcall/SyscallX86 still get SysV eightbyte classification. Belongs to:
driver — add the i386 arm alongside the existing per-cc selection.

**G5 [Q] — abi_lower placement is pipeline-head, not codegen-adjacent.**
LLVM lowers the ABI at isel. Here it runs first, before mem2reg and before
inline; the scratch-alloca byte round-trips it emits (abi_lower.crl:439-451)
must be seen through by every downstream pass, and inlining after ABI
lowering mixes lowered and unlowered conventions. It happens to work because
both sides of each call are rewritten (abi_lower.crl:840-881) — but only
for direct calls; indirect calls are explicitly "an IR gap"
(abi_lower.crl:20-21). Belongs to: driver ordering; document the invariant
or move to codegen.

**G6 [Q] — structure lane runs after `irOptimize`, but borrowcheck's own
comment demands it run before any pass that moves loads/stores**
(wallvm.crl:299-304 vs call order at 429-433). After LICM/GVN/DSE/machine_opt
the reported load/store relationships no longer reflect the source. Also,
`irCompileAsm` re-runs the lane (wallvm.crl:477) → double borrowcheck and
**double unroll**. Belongs to: driver.

**G7 [Q] — no CGSCC/module layer.** Inlining is a function pass with a local
cost model (inline.crl:546-642); callers are optimized in module order,
possibly before their callees are optimized; there is no globalopt,
constant merging, dead global/function elimination, or attribute inference
(`noreturn`/`readonly` metadata parsed but unused). `ipa_cp` exists but is
wired into **no** pipeline. Belongs to: new module-pass stage in the driver.

**G8 [Q] — `cse` is L1-only; L2/L3 use only dom-scoped `gvn`.** After the
late inline + sel2br + lower_phis churn there is no cheap local CSE/DCE
cleanup in the same iteration. Belongs to: pipeline tables.

**G9 [N] — no pass-timing, opt-bisect, or `-print-after` debugging hooks**;
validation errors are silently discarded (`lastError` never leaves
`irPassValidate`). Belongs to: driver + validate.

### 3.2 SSA construction and CFG

**G10 [C] — mem2reg refuses to promote any alloca touched inside a loop**
(mem2reg.crl:449-519), justified by a comment claiming lsra mis-assigns
registers across back-edges. This is the tail wagging the dog: loop-carried
scalars stay in memory, so LICM/GVN/range/unroll/simd_vec all see loads and
stores instead of values, and unroll's own comment expects "the canonical
loop form produced by mem2reg" (unroll.crl:3-6) — a form mem2reg never
produces. The correct fix is in lsra/phi lowering (see G13, G24), not in
mem2reg. Belongs to: `passes/mem2reg.crl` + `regalloc/lsra.crl`.

**G11 [Q] — mem2reg runs before `sroa`, and "sroa" is not SROA.** (The
companion **[verify]** / A12 is FIXED: `sroa.crl` now maintains use lists
properly — `removeUser`/`addUser` around the operand rewrite (:135-137),
plus `removeUser` on the load's own operands (:143-144) and on the alloca and
store (:150-157). It also gained safety checks the audit did not credit: an
unhandled-opcode user makes the transform unsafe (:66-81), loads must be
dominated by the single store (:94-116), and more than 16 loads bails rather
than reading out of bounds (:88-89).)

The main claim stands: `sroa.crl` is still single-store forwarding that bails
on any GEP/atomic use (:53-59), so there is no aggregate splitting and
struct/array allocas are never scalarized — they can never be promoted.
mem2reg still precedes sroa (wallvm.crl:230-231); clang order is sroa →
mem2reg. Belongs to: pipeline order + a real SROA in `passes/sroa.crl`.

**G12 [C] — no critical-edge splitting pass anywhere.** lower_phis dodges
the classic miscompile by round-tripping through a private alloca per phi
(correct but pure memory traffic; verified the per-pred-store scheme is
sound on critical edges). But jump_thread/tail_dup/sel2br create critical
edges and nothing materializes them; any future move-based phi lowering or
edge placement needs real splitting. Belongs to: new `passes/split_edges.crl`
(or fold into lower_phis).

**G13 [Q] — phi lowering is alloca-based; there is no parallel-copy
lowering.** Every phi becomes store-per-edge + load-at-top (lower_phis.crl),
inserted after the last optimization pass, so the copies are never
coalesced (lsra's `tryCoalesce` is a no-op, lsra.crl:769-827) and never
seen by DSE. LLVM lowers phis to parallel copies that regalloc coalesces.
Belongs to: `passes/lower_phis.crl` + `regalloc/lsra.crl`.

**G14 [Q] — no simplifycfg.** No empty/merged block folding, no common-tail
sinking/hoisting, no unconditional-branch-to-empty-block elimination.
jump_thread and tail_dup cover only passthrough chains. There is no
simplifycfg pass. **[verify]** partially resolved: `tail_dup` now requires
`target->npreds == 1` (and `target->parent == func`) in all three patterns
(tail_dup.crl:43, :98, :131), so it can no longer gut a
multiply-predecessor block. **Fixed 2026-10-09:** `jump_thread`'s
pattern 1 got the same guard — it now requires
`target->parent == func && target->npreds == 1` before emptying a block
and rewriting branches, so it can no longer leave a surviving predecessor
aimed at a block with no terminator; and `select_to_branch.createBlock`
no longer emits nameless blocks — it snprintfs a unique `sel2br<N>` name
per conversion, so the emitter's `.L` + `name` + `:` cannot produce three
identical `.L:` labels. DCE's unreachable-block removal (dce.crl:50-132)
still leaves stale entries in successors' `preds` and nulls phi value
operands (:113-124), which later passes must tolerate. Belongs to: new
`passes/simplifycfg.crl` (still missing).

**G15 [Q] — no reassociation pass.** lex_canon sorts operands within a
commutative chain (lex_canon.crl) but there is no global reassociation for
CSE/loop strength reduction; GVN (gvn.crl) is dominator-scoped redundancy
elimination with no PRE. Belongs to: new `passes/reassociate.crl`, PRE in
`passes/gvn.crl`.

**G16 [N] — no memcpy/memset/memmove idiom formation** (idiom.crl covers
rotate/bswap/minmax/abs/fma only); no SLP vectorizer (simd_vec is
loop-only); no switch→jump-table lowering (IR.md §9 defers it; there is no
switch opcode at all).

### 3.3 Loop optimization

**G17 [Q] — no loop canonicalization: no loop-simplify form, no LCSSA, no
loop rotation.** loop_detect reports one "loop" per (header, latch) pair
(loop_detect.crl:28-101); LICM builds its own preheader (licm.crl:16-185);
unroll/interchange/distribute/simd_vec each re-derive the induction pattern
by hand. Without rotation, loops keep a header test + backedge jump instead
of a fall-through backedge, which also defeats branch chaining (G31) and
macro-fusion at the loop bottom. Belongs to: new `passes/loop_canon.crl`
(rotation + dedicated exits + LCSSA).

**G18 [C] — LICM speculation safety.** `isLoopInvariant` admits loads
(licm.crl:194-199) and hoisting only checks alias-vs-stores
(licm.crl:379-399); there is no dereferenceability proof and no
"instruction dominates all exits" check. A load conditional in the loop is
executed unconditionally in the preheader — it can fault. LLVM only hoists
such loads when the address is known dereferenceable. Belongs to:
`passes/licm.crl`.

**G19 [Q] — no SCEV/indvars.** range.crl is a value-range analysis with
branch elimination, not an induction-variable analysis; unroll computes
trip counts ad hoc; simd_vec matches counted loops by hand; loop strength
reduction does not exist. Belongs to: new `passes/indvars.crl`.

**G20 [Q] — unroll placement.** It lives in the structure lane, after the
entire optimizer (wallvm.crl:307), so the unrolled body is never
re-simplified in the same compile (only validate follows) — and it can run
twice via `irCompileAsm` (G6). Clang unrolls inside the loop pipeline with
cleanup after. Belongs to: driver.

### 3.4 Register allocation (`regalloc/`)

**G21 — FIXED 2026-10-09 — the spill contract now works end-to-end.**
The original audit said spills were broken: every spilled value decoded to
`rax`, `valueIsSpill` was "defined but never called", and no spill-slot
frame existed. All three were true when written; none are now.

The 64-bit backend now has a real spill frame:

- `spillSlotCount` / `spillFrameBytes` emitter fields (x86_64_base.crl:296-297),
  computed by `countSpillSlots` (:2199-2231), which walks every block and
  every instruction looking for the spill bit.
- `spillFrameBytes = spillSlotCount * 16`, reserved in the prologue
  (:575-576, :775-796) and released in the epilogue (:1030-1037).
- `slotText` (:2028-2043) turns a slot index into an rbp-relative operand,
  and `opForReg` / `opForRegF` / `outForInt` / `sinkInt` / `sinkFloat`
  (:2047-2197) decode spills at materialization time.
- `valueIsSpill` is called from ~40 sites, not zero.
- Frame, red-zone and shrink-wrap decisions are all gated on
  `spillSlotCount == 0` (:593, :719-729), so a spilling function always gets
  a real frame.

The 32-bit backend has the equivalent (`x86_base.crl:436-451`, :247-248,
:295-315). What remains here is a *quality* gap, not a correctness one, and
it is tracked as G24 (one slot per vreg, no packing, no remat).

**G42 — NEW (found 2026-10-09) — unsigned div/rem emits `cqo` before
`divq`, a live miscompile.** `emitDiv` / `emitRem` emit `cqo`
unconditionally, then select `idivq` vs `divq` on `isSigned`
(x86_64_base.crl:2625-2650 for div, :2652-2677 for rem). `cqo` sign-extends
`%rax` into `%rdx`; unsigned division requires `xorl %edx, %edx`. For an
unsigned dividend with bit 63 set, `%rdx` becomes all-ones and `divq`
returns a wrong quotient — not a slow one. The 32-bit port gets this right
(`x86_base.crl:672`, :710: `cltd` if signed, else `xorl %edx, %edx`), so the
fix is a port of a two-line sequence. Classified **[C]** because it
produces wrong answers, and it is reachable from ordinary unsigned divide.
**Fixed 2026-10-09:** `emitDiv`/`emitRem` now emit `cqo` only under
`isSigned` and `xorl %edx, %edx` otherwise (the xorl form is also correct
for 64-bit — 32-bit writes zero the upper half implicitly).

**G43 — NEW (found 2026-10-09) — `stack_layout` can write past `newInsts`
and double-parents allocas.** This is the surviving half of A18, escalated
here because it is heap corruption inside the optimizer rather than a layout
heuristic. `stack_layout.crl:156-157` sizes the rebuilt entry-block
instruction array as `newCap = entry->ninsts`, then at :173-190 appends
**all** `nvars` function-wide allocas — including ones gathered from
non-entry blocks (the pass's own comment at :171-172 admits this). So
`newCount = (entry->ninsts - entryAllocas) + nvars` exceeds `newCap` whenever
any alloca lives outside the entry block: an unchecked write past the end of
a fresh heap allocation. The moved allocas also keep `inst->parent`
pointing at their original block while also appearing in `entry->insts`
(:192-195), double-parenting them. Reachable at O3 (the pass is in L3,
wallvm.crl:264). **Fixed 2026-10-09:** the gather loop accepts only
allocas whose `parent` is the entry block (which is also what makes the
move single-parented), the allocation is null-checked, and the append
refuses to run if `newCount` would exceed `newCap`.

**G44 — NEW (found 2026-10-09) — parameter seeding could overwrite a
later argument's incoming register before reading it — FIXED the same
day.** `emitParamSeeding` walked the entry stores one at a time: for
each register parameter it emitted `movq <abiReg>, <home>` (floats went
through `sinkFloat`: `movsd`/`movdqa <abiReg>, <home>`), where `<home>`
is the register lsra assigned to that parameter's value. lsra picks
homes from whatever the scan left free — the same bank the caller passes
arguments in — so a home can be a register a LATER parameter arrives in.
Concretely on SysV: allocatable is `rax,rcx,rdx,rsi,rdi,r8,r9` with rax
usually held by the return value, so four integer parameters get homes
`rcx,rdx,rsi,rdi`, while the incoming bank is `rdi,rsi,rdx,rcx,…` — the
walk emits `movq %rdi,%rcx; movq %rsi,%rdx;` and then parameter 2's
`movq %rdx,%rsi` reads the value parameter 1 just wrote into rdx. The
same shape hits three-or-more float parameters (homes start at `xmm2`,
because xmm0/xmm1 are reserved scratch, and xmm2 is argument 2's
incoming register) and structs-in-registers (word0 can land in a home
that is word1's incoming register, within one parameter). Which homes
come out free is scan-dependent, so the bug is config-dependent, but
nothing in the pipeline avoided it — the old lsra pre-pin that might
have was dead (G23). Stack-sourced parameters (kinds 0/4) were never at
risk — their source is memory. The fix runs the walk twice over the
same stores: phase one moves every incoming bank word into a staging
area on the function's own stack (`subq` sized by classifyCallArg's
bank limits: at most 6 integer words + 8 fp words, 8/16 bytes each),
phase two commits staging into homes and allocas. All ABI reads
therefore happen before any home write, for every ordering and both
ABIs; the commit pass routes spill-slot and alloca writes through the
reserved `r11`/`xmm15` scratch where memory-to-memory moves are needed.
`sinkFloat`, whose only caller was the old kind-2 arm, was removed.
Belongs to: `target/x86_64/x86_64_base.crl`
(`emitParamSeeding`/`walkParamSeeds`).

**G22 [C] — no fixed-register / clobber modeling between isel and
regalloc.** (The off-by-one sub-claim is FIXED: the reserved arrays are now
4 and 3 elements with matching counts, x86_64_base.crl:13-19 /
wallvm.crl:413-416. The clobber half below is still real.)

The emitter clobbers concrete registers that lsra happily allocates to
unrelated live values. Only `rsp`, `rbp`, `r10`, `r11` are reserved
(`X86_64_RESERVED_INT`, x86_64_base.crl:13-15) — so `rax`, `rcx`, `rdx`,
`rsi`, `rdi` are all allocatable (`X86_64_INT_REGS`, :25-27) — while
`emitDiv`/`emitRem` destroy rax+rdx (:2625-2677), `emitShift` destroys rcx
(:2679-2705), `emitICmp`/`emitFCmp` write %al/%cl (:2822-2891), and
`VecDiv` walks lanes through r10/r11/rax/rdx (:2405-2445). Any function with
a divide, shift or compare alongside an unrelated live value in one of those
registers is silently miscompiled. LLVM models these as tied operands /
fixed-reg constraints / clobbers in the instruction descriptors. Belongs to:
`regalloc/lsra.crl` (constraint modeling) + the reserved-register tables.

**G23 [C] — Win64 register tables disagree between lsra and the emitter —
FIXED 2026-10-09 (both halves), with the lsra half resolved by deletion.**
The original claim was accurate: lsra names registers from
`abi.callerSaveRegs` minus reserved, so Win64 yields `rax, rcx, rdx, r8,
r9…` (asm_rules.crl:137), while the emitter decoded LSRA index *i* as
`X86_64_INT_REGS[i]` = `rax, rcx, rdx, rsi, rdi, …` — indices ≥ 3 named a
different physical register on Win64. The emitter now decodes through
`intRegNameFor`, which returns `X86_64_INT_REGS_WIN64` entries when
`isWindows` and the SysV table otherwise, at both decode sites
(`getRegName` and `opFor`).
The compounding half was worse than stated and is now gone rather than
repaired: `isWin` was hardcoded `false`, so the Win64 param-mapping arrays
never ran; the whole pre-pin block was dead anyway because `linearScan`
assigns `physReg` for every interval it scans, overwriting the pin before
anything reads it; and the index tables did not even match the layout they
claimed to decode (`{5,4,2,1,6,7}` for SysV and `{1,2,8,9}` for Win64
number physical registers, not `callerSaveRegs`-minus-reserved — where
Win64's whole allocatable set is five registers wide, so indices 8/9 did
not exist). The fp pins could never work at all: `xmm0`/`xmm1` are
reserved scratch, so a float parameter's incoming register is not in
`floatRegNames` to be pinned to. The pin, `isWin` and both index tables
were therefore deleted from `computeIntervals`, with the contract
documented there: the scan assigns parameter homes, and the backend's
`emitParamSeeding` walks the ABI bank — using `isWindows` — into those
homes. Which is also what makes the seeding safe; see G44. (The separate
`defs`/`spillWeight` initialisation claim from the audit was fixed
earlier — every `LiveInterval` field is now seeded at creation.)
Belongs to: `regalloc/lsra.crl` +
`target/x86_64/x86_64_base.crl` (single source of truth for register order).

**G24 [Q] — allocator feature set vs "gcc/clang quality":** no
rematerialization (constants get spilled like any value), no live-range
splitting, no real coalescing (`tryCoalesce` only lengthens intervals —
the opposite of coalescing), **one spill slot per vreg, never packed**
(lsra.crl:742,760), caller-save-only policy with `useCalleeSave=false`
force-spills every value that spans a call (lsra.crl:663-665), float
allocation is limited to the 8 ABI **argument** registers (lsra.crl:144,
152-156 — xmm8-xmm15 never used). Also `irGraphRegAlloc` runs lsra first
and then recolors intervals whose results are **never written back to
valData** — a pure no-op refinement that ignores pre-colored params and
would corrupt them if applied (graph.crl:317-355). No shrink-wrapping in
RA (the emitter's deferred-push approximation is fragile, G33). Belongs to:
`regalloc/lsra.crl` (remat, splitting, packing, callee-save support);
retire or repair `regalloc/graph.crl`.

**G25 [C] — lsra depends on block layout it doesn't control.** Intervals
are computed over the raw `func->blocks` order with ends only extended
forward (lsra.crl:466-532). Any layout where a def sits after a dominated
use (nothing enforces RPO) breaks the interval. There is no block-ordering
pass; see G31. Belongs to: `regalloc/lsra.crl` (compute over RPO) + driver
(layout pass).

**G26 [Q] — quadratic scans everywhere:** interval lookup per operand is
O(n²) (lsra.crl:500-531), GVN/CSE tables are linear scans
(gvn.crl:153-159), mem2reg's DF walk is cubic. Belongs to: hashtable-based
value maps in the respective passes.

### 3.5 Frame, ABI, calls

**G27 — FIXED 2026-10-09 — store operand order already matches the IR.**
The original audit claimed the emitter treated `ops[0]` as the address and
`ops[1]` as the value, inverting `irBuilder.store(val, ptr)`, with the width
taken from the pointer side. **[verify]** was flagged because the split was
systemic across both backends, and the doc conceded "at least one side is
wrong". Both halves of that are now false.

The convention in force is the builder's: value in `ops[0]`, address in
`ops[1]`, width from the value. Confirmed in every emitter path —
`emitStoreWidth` reads `src = ops[0]`, `dst = ops[1]`, `width =
ops[0]->type->width` (x86_64_base.crl:1557-1562); `iselTryFoldLoadOpStore`
(`:1687-1701`); `iselTryFoldGepStore` (`:1818-1824`); `emitStore`
(`:2742-2745`); 32-bit equivalents (`x86_base.crl:783-786`, :810, :824). The
prologue param-seeding code in the same file agrees (`:830`, :852), and all
IR passes agree (`mem2reg.crl:189`, `dse.crl:102`, `alias_analysis.crl:405`,
`memory_ssa.crl:201`, `simd_vec.crl:650` — the last with an explicit
`ops[0]=value, ops[1]=address` comment). No inversion exists.

**G28 [C] — unhandled opcodes are emitted as comments.** `emitInst`'s
`else` arm emits a comment and nothing else (x86_64_base.crl:2592,
x86_base.crl:606): Phi, Noret, Unreachable, all four atomics, Fence,
InlineAsm, ExtractValue, InsertValue, ExtractElement, InsertElement,
GcRoot, GcWriteBarrier, GcSafepoint, LandingPad. Because `Unreachable` and
`Noret` are terminators, such a block ends with no terminator and execution
falls into the next block's bytes — silent code omission. `noret/` and
`noretTemplate` (asm_rules.crl:881-961) exist but are not called from the
emitter. The wasm backend's loud `failOp` (wasm.crl:1240, :1722) is the
correct behaviour. Belongs to: `target/x86_64/x86_64_base.crl` (+ x86) —
must trap or emit, never comment; wire `noret`.

**G29 [C] — no module data emission on native targets.** x86_64 emits only
`.section .text`; x86 emits an empty `.data` then `.text`. No backend except
wasm emits globals, string constants, `.rodata`, `.bss`, `.align`, or
`.size`. The emitter's `dataSection` buffer accumulates (:139) but
`getOutput()` returns only `self.output` (:153) — **the data section is never
flushed into the output** — and `emitFabs` writes a fixed label
`.Lfabs_mask:` into it per use (:3187-3192): duplicate labels if `fabs`
appears twice, absolute (non-RIP-relative) addressing, and the definition
never reaches the assembler anyway. Belongs to: backends — a module-level
data/constant-pool emitter (per-section, with alignment and relocations).

**G30 — FIXED 2026-10-09 (A18 survives as G43) — allocas now have a real
frame model.** The original claim was `subq $8, %rsp` at the alloca's
execution point, always 8 bytes, no frame. All of that is gone:

- `allocaSlotSize` reads `irTypeSizeOf(inst->base.type->elem)` and rounds to
  16 (x86_64_base.crl:460-468), so aggregates and arrays are sized from the
  IR type.
- `scanAllocas` sums them function-wide (:473-488) and `allocaSlotOf` replays
  the same walk to place each one (:494-513).
- The prologue reserves `allocaBase + allocaBytes` with an odd-8 pad for call
  alignment (:776-796), and `emitAlloca` emits `leaq -off(%rbp), reg`
  (:2764-2772). The `subq $sz, %rsp` fallback (:2778-2785) is now
  unreachable when `allocaBytes > 0`, because the frame gates at :593-594 and
  :719-722 require a frame in exactly that case.

Loop allocas no longer grow the stack, aggregates get their real size, and
slots are aligned. The remaining problem in this area is `stack_layout`
itself, which is now tracked as **G43** (heap write out of bounds).

**G31 [Q] — no block placement / branch chaining.** Blocks are emitted in IR
order (linux.crl:38-48); every `cond_br` becomes `testq` + `jne` + `jmp`
with both edges as jumps (x86_64_base.crl:2905-2922); no fall-through
placement, no loop-aware layout, no branch relaxation. Interacts with G17
(rotation) and with lsra's layout sensitivity (G25). Note `branch_inversion`
*is* now wired into L1/L3 (wallvm.crl:213, :273), but it inverts IR
`CondBr` semantics — it does not reorder blocks. Belongs to: new
`passes/block_layout.crl` (or a backend-side placement) consumed by the
emitters.

**G32 — FIXED 2026-10-09 — the call-site ABI details landed.** All four
original sub-claims now hold: a single 16-rounded `subq` keeps the stack
aligned (x86_64_base.crl:3543-3550, with `pad`/odd-count fixups at
:769-773, :784-787); `%al` is set to the vector-register count for vararg
calls (:3781-3790); stack arguments are written once at computed offsets with
no double push (:3346-3412, :3552-3663); parameters past the 6th (SysV) /
4th (Win64) are seeded from the caller's frame at `16+outOff(%rbp)`
(:808-1022), including spilled params (:864-870, :890-895, :935-948,
:985-1018). The double-push `rsp` imbalance is gone.

**G33 [Q] — prologue/epilogue strategy.** `emitDeferredCalleeSaves` pushes
callee saves at the first block that uses them (x86_64_base.crl:406-448) —
if that block is in a loop the pushes repeat with no matching pops (stack
blowup; reachable on 32-bit targets where `useCalleeSave=true`, since
`X86_INT_REGS` includes ebx/esi/edi). The gating and the placement are
otherwise sound on 64-bit: `canShrinkWrap` (:721-728) and `hasDeferredFrame`
are honoured, and red-zone/shrink-wrap are disabled whenever a frame or
spills exist (:593, :719-729). Every `ret` still duplicates the full
epilogue and each function gets a trailing epilogue appended after its last
block (linux.crl:52) — no epilogue merging. Belongs to:
`target/x86_64/x86_64_base.crl` (+ PEI-style pass in `regalloc/`).

**G34 [Q] — tail calls: FIXED on x86_64 (2026-10-09).** The old mechanism
was a broken heuristic: `isTailCall` fired *after* the call's whole
sequence (stack adjustment, register copy, result sink) had already been
emitted, so the `jmp` in `emitRet` re-ran the callee with clobbered
arguments and skipping the epilogue leaked the frame; it was hardwired
off. The fix moves the decision into `emitCall`, where the shape is known
before anything is emitted. `tailShapeOk` requires a direct named callee,
register-only arguments (classified before the stack adjustment), the
call as the block's second-to-last instruction, its result feeding only
the immediately following `Ret`, and `inTailPosition` additionally
requires a frameless function with no callee-saves, no spill area, and no
vararg window. A staged parallel copy or a Win64 shadow that would need a
restore we will not emit drops the tail shape before the stack
adjustment; the ordinary path then runs unchanged. On success the
argument moves emit as usual, `jmp target[@PLT]` replaces `call`, the
result-sink is skipped (the callee's own `ret` returns to our caller), and
the following `Ret` emits nothing because `tailJmpCall` matches it. The
32-bit `isTailCall` (which had the same already-emitted flaw plus an
always-taken stack-arg problem) is removed. Still open: sibling calls with
stack arguments or a non-trivial frame (needs epilogue-before-jump and
signature-aware arg shifting), cross-block call/ret pairs, and a
guaranteed-TCO marker. `tco.crl` (accumulator recursion → loop) is
unaffected and orthogonal. Belongs to: backends.

### 3.6 Machine level

**G35 [Q] — no instruction scheduling, pre- or post-RA.** AsmRule rows
carry `latency` "for scheduling" (asm_rules.crl:41) and nothing reads
them. `macro_fusion` is an IR-level cmp-adjacency nudge whose effect the
emitter's fixed order may not preserve. Belongs to: new
`target/*/scheduler` (list scheduler over a machine representation that
doesn't exist yet — see G36).

**G36 [Q] — no machine IR; the emitter *is* the machine layer.** All
"machine" optimizations are ad-hoc `iselTry*` pattern folds dispatched
inside `emitInst` (x86_64_base.crl:1723-2076) — single pass, no iteration,
no cross-pattern exposure, no post-RA peephole, no redundant-move
elimination beyond same-instruction src==dst checks. `machine_opt`
(passes/machine_opt.crl) is IR-level MemorySSA forwarding, misnamed.
Belongs to: longer-term — a machine-instruction layer between regalloc and
emission; short-term — a dedicated post-RA peephole pass over emitted
sequences.

**G37 [C] — no PIC/relocations.** Absolute symbol references for data
(G29), no `%rip`-relative addressing, no GOT; `@PLT` is appended only for
extern calls on SysV (x86_64_base.crl:2897-2902); no `.long/.quad`
relocation records, no section flags beyond `.text`. Anything but a
non-PIE static executable is unbuildable. Belongs to: backends + a
relocation/section model (see assembler-plan.md).

**G38 [C] — no unwind/EH metadata.** No `.eh_frame`, no `.cfi` directives;
`landingpad` is reserved in the IR (IR.md §10) and dropped by G28. Any
C++-interop or profiler/unwinder scenario is impossible; frame changes
(subq per alloca) would need CFI anyway. Belongs to: backends (emit CFI
from the frame model of G30).

**G39 [Q] — debug info is parsed, preserved, and then dropped.** The IR
carries `debug.file/line/col` and `var` metadata (IR.md §7.4); inline and
tco copy it (inline.crl:265-272, tco.crl cloneInst); no backend emits
`.file`, `.loc`, or any `.debug_*` section. Belongs to: backends — a
DWARF (or at least line-table) emitter keyed off `debugLoc`.

**G40 [C] — inline asm is dropped silently on every native backend.**
Confirmed by docs/assembler-plan.md ("No target handles
`IrOpcode::InlineAsm` at all … silently dropped"); the IR/parser side is
complete and the constraint/clobber data exists. Wasm fails loudly. The
planned two-layer assembler in assembler-plan.md is the fix. Belongs to:
`lib/wallvm/asm/` (new) per that plan.

**G41 [N] — CPU feature detection.** The linux driver hard-enables
AVX2/FMA/BMI/LZCNT (linux.crl:11-24) — emitted binaries won't run on
pre-2013 hardware; there is no `-mcpu`/host detection. Also no
`.note.GNU-stack` (linker will mark the stack executable) and no `.size`
directives on functions. Belongs to: target drivers + emission.

### 3.7 Whole subsystems missing

- **Atomics lowering** (G28): no `lock` prefix, no `cmpxchg` loops, no fence
  emission — the IR opcodes exist end-to-end and die at the emitter.
- **GC opcodes**: `gc_root`/`gc_writebarrier`/`gc_safepoint` have runtime
  support in `gc/gc.crl` but no codegen hookup (G28).
- **EH**: landingpad reserved, nothing else (G38).
- **Assembler**: text-out only; assembler-plan.md phases the real one (G40).
- **ARM32/ARM64/RISC-V/other backends**: rule tables exist
  (asm_rules.crl:1000-1355) but `irCodegen` silently routes those CCs to the
  x86-64 bare emitter (§1.8); Wasm64 likewise.
- **PGO**: `weight.true/false` metadata parsed and unused.

---

## 4. Severity ranking

### (a) Correctness / ABI blockers

Revalidated 2026-10-09. Rows marked ~~struck~~ were fixed and are retained
only to show what the audit originally claimed; do not re-file them. G42,
G43 and G44 are new since the audit; all three were found and fixed the
same day (A19–A21).

| # | Gap | Ref | Status |
|---|-----|-----|--------|
| ~~A1~~ | ~~Spilled values decode as `rax`; no spill slots exist~~ | G21 | **FIXED** — real spill frame, `slotText`, ~40 decode sites |
| A2 | No fixed-reg/clobber modeling: div/shift/icmp/fcmp/vecdiv destroy allocatable regs (rax, rcx, rdx, rsi, rdi are allocatable) | G22 | **REAL** (array off-by-one fixed) |
| A3 | Unhandled opcodes (noret, unreachable, atomics, fence, extract/insert*, gc_*, inlineasm) emitted as comments; `unreachable` falls through | G28 | **REAL** |
| ~~A4~~ | ~~alloca → `subq $8` at execution point; loop allocas grow stack; aggregates get 8 bytes~~ | G30 | **FIXED** — type-sized, prologue-reserved, rbp-relative |
| ~~A5~~ | ~~Store operand order inverted vs IR convention (both native backends)~~ | G27 | **FIXED / claim was wrong** — `ops[0]`=value everywhere |
| ~~A6a~~ | ~~abi_lower `IrModule*`/`IrContext*` type confusion~~ | G3 | **FIXED** — uses `func->parent` |
| A6b | i386 abi_lower unwired; SysV pass still applied to Cdecl/Stdcall/SyscallX86 | G4 | **REAL** |
| ~~A7~~ | ~~Win64 lsra↔emitter register-name mismatch (index ≥3); `isWin` hardcoded false; param intervals uninitialized (`defs` never set, `alloc` not zeroed)~~ | G23 | **FIXED** — emitter decodes through a Win64-aware `intRegNameFor`; the dead pre-pin/`isWin` block is removed; interval fields seeded |
| ~~A8~~ | ~~No call-site stack alignment; no `%al` for varargs; stack-arg cleanup miscount; params >6 never seeded~~ | G32 | **FIXED** — all four sub-claims hold |
| A9 | No globals/rodata/bss emission; `dataSection` never flushed; duplicate `.Lfabs_mask` labels; no relocations/PIC | G29, G37 | **REAL** |
| A10 | LICM hoists possibly-trapping loads without dereferenceability/exit-domination checks | G18 | **REAL** |
| A11 | lsra interval correctness depends on unenforced block layout | G25 | **REAL** |
| ~~A12~~ | ~~sroa rewrites operands without use-list maintenance~~ | G11 | **FIXED** — `removeUser`/`addUser` present |
| ~~A13~~ | ~~jump_thread still orphans predecessors into emptied blocks; sel2br creates nameless blocks (three per conversion, all labelled `.L:`)~~ | G14 | **FIXED** — `jump_thread` now requires `target->parent == func && target->npreds == 1`; sel2br blocks named `sel2br<N>` (tail_dup fixed earlier) |
| A14 | Frontend phis at L0/L1 reach codegen unlowered (no Phi case in emitter) | §1.2 | **REAL** |
| A15 | Wasm64 and all non-x86 CCs silently dispatch to the x86-64 bare backend | §1.8 | **REAL** |
| A16 | Deferred callee-save pushes can land in loops (32-bit targets) | G33 | **REAL** |
| A17 | validate-as-changed forces maxIters; hides non-convergence and double work | G1, G2 | **REAL** |
| ~~A19~~ | ~~`stack_layout` writes past `newInsts` and double-parents allocas (heap corruption at O3)~~ | G43 | **FIXED** — entry-parent gather, null check, capacity guard |
| ~~A20~~ | ~~Unsigned div/rem emits `cqo` before `divq` — wrong results~~ | G42 | **FIXED** — `cqo` only under `isSigned`, else `xorl %edx, %edx` |
| **A21** | **Parameter seeding writes homes in one pass, so a home can be a later argument's incoming register — overwritten before it is read** | G44 | **FIXED** — two-phase staging walk |

### (b) Code-quality blockers (gcc/clang-quality goal)

| # | Gap | Ref |
|---|-----|-----|
| B1 | mem2reg refuses loop allocas → all loop-carried scalars stay in memory; every loop pass degraded | G10 |
| B2 | Phi lowering = alloca round-trip; no parallel copies, no coalescing | G13, G24 |
| B3 | Caller-save-only RA; call-spanning values always spill; float pool = 8 arg regs; no remat/splitting/slot packing; graph-RA is a no-op | G24 |
| B4 | No block placement/branch chaining/loop rotation → both edges of every branch are jumps; macro-fusion defeated | G31, G17 |
| B5 | No instruction scheduling; latency tables unread; no machine IR or post-RA peephole | G35, G36 |
| B6 | No simplifycfg / reassociate / PRE / indvars(SCEV) / real SROA | G14, G15, G19, G11 |
| B7 | No CGSCC/module stage; ipa_cp unwired; no globalopt/globaldce/attr-inference | G7 |
| B8 | Pipeline ordering: abi_lower at head; unroll post-optimizer (and twice); no cleanup after inline in-iteration | G5, G20, G6 |
| B9 | L1 has no mem2reg/SROA; L2/L3 lack a late local CSE; borrowcheck after opts | §1.3, G8, G6 |
| B10 | Epilogue duplication per ret; deferred callee-save pushes can land in loops (32-bit) | G33 |
| B11 | No general tail-call optimization | G34 |
| B12 | Quadratic data structures in hot passes | G26 |

### (c) Nice-to-have

| # | Gap | Ref |
|---|-----|-----|
| C1 | Debug-info emission (metadata exists end-to-end) | G39 |
| C2 | Inline-asm assembler layer (already planned) | G40 |
| C3 | EH/unwind tables | G38 |
| C4 | PIC/GOT + full relocation model | G37 |
| C5 | CPU feature detection; `.note.GNU-stack`; `.size` directives | G41 |
| C6 | Atomics/fence lowering, GC opcode hookup | §3.7 |
| C7 | ARM/ARM64/RISC-V/Wasm64 backends (rules tables exist) | §3.7 |
| C8 | memcpy/memset idiom formation; SLP; jump tables | G16 |
| C9 | PGO wiring for `weight.*` metadata | §3.7 |
| C10 | Pass timing, opt-bisect, IR dumps, validator diagnostics channel | G9 |

---

## 5. The three most urgent items

**Revalidated 2026-10-09 — this section was rewritten.** The original top
item (A1, the spill contract) is fixed, and the original second and third
items were partly wrong (A5 was not a bug; A4 was fixed). The ordering below
is the current one. Later the same day A20 and A19 — plus the newly found
A21 — were fixed too; item 1 is kept as the record of what was wrong, and
the live ordering starts at item 2.

### 1. A20 + A19 — two live miscompiles (G42, G43) — both fixed

Both were wrong-answer bugs, not quality gaps, and both were small to
fix; the fixes landed 2026-10-09:

- **A20**: `emitDiv`/`emitRem` now emit `cqo` only when `isSigned`, and
  `xorl %edx, %edx` otherwise — the sequence the 32-bit backend already
  used, ported. Before the fix, any unsigned divide/remainder whose
  dividend had bit 63 set returned a wrong answer.
- **A19**: `stack_layout` gathers only allocas whose `parent` is the
  entry block (which also ends the double-parenting), null-checks the
  rebuilt array, and refuses to append past `newCap`. Before the fix a
  non-entry alloca wrote past a fresh heap allocation at O3.

A third wrong-answer bug found the same day — **A21/G44**, parameter
seeding overwriting an incoming argument register — is fixed too (see
the tables above). The standing correctness items after these three are
A2's clobber half (G22) and A3 (G28).

### 2. A2 + A6b — the register and calling-convention boundary

The allocator has no model of fixed-register constraints, so the emitter's
`div`/`rem`/`shift`/`cmp` sequences clobber rax/rcx/rdx while lsra keeps live
values there — and rax, rcx, rdx, rsi, rdi are all allocatable because only
rsp/rbp/r10/r11 are reserved (x86_64_base.crl:13-27). The i386 ABI pass is
still unwired, so 32-bit Cdecl/Stdcall/SyscallX86 get SysV eightbyte
classification. (The Win64 half of this cluster that the audit also listed
— the lsra↔emitter index mismatch, `isWin` hardcoded false, uninitialised
param-interval fields — is fixed under G23, and G44 fixed the seeding
hazard it exposed.) What separates "compiles benchmarks" from "links
against the world" is now the clobber modeling and the 32-bit ABI wiring:
any div/shift under register pressure, or any 32-bit non-Windows target,
is currently wrong.

### 3. A3 + A9 — emitter conformance to the IR (G28, G29, G37)

The emitter still does not implement the IR it consumes. An entire tail of
the opcode space — noret, unreachable, the atomics, fences,
extract/insertvalue/element, gc ops, inline asm — falls into a comment arm
that emits *nothing*, with `unreachable` falling through into the next
block's bytes. And no native backend emits data at all: `dataSection`
accumulates but `getOutput()` never flushes it, there are no globals,
`.rodata`, `.bss`, or relocations, and `emitFabs` writes a duplicate
`.Lfabs_mask:` label per use into that dead buffer. Any build that is not a
self-contained leaf-function static binary cannot be produced or linked.

Before pass ordering, before regalloc quality, before vectorization: every
opcode must either be emitted correctly or loudly rejected (the wasm
backend's `failOp` is the model), and there must be a module-level data
emitter.

### Also still open, just below the top three

- **G2** — mem2reg ↔ lower_phis ping-pong: the pipeline cannot converge when
  a non-loop phi exists, which combined with G1 hides real non-convergence.
- **G18** — LICM hoists loads out of conditionals without a
  dereferenceability proof, so a conditional load can be executed
  unconditionally and fault.
- **G25** — lsra interval ends depend on block order that nothing enforces.

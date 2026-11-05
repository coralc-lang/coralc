# wallvm — current todos / handoff state

Last updated: 2026-10-23. Working commit: `df3ff9b` ("wallvm: commutative
operand1 coalescing, fold-gated register ops, dead callee-save push fix").

## Done (committed in df3ff9b)

- **TODO #1 dead `incq`** — `canFoldLoadOpStore` (pure predicate) +
  `opFeedsOnlyFusedStores` peek + skip-guard at top of `emitInst` for
  Add/Sub/And/Or/Xor. `array_sum_O2` body is only `addq $0x1, (%rdi)`.
- **TODO #2 operand1 coalescing** — `isCommutativeOp` (Add/Mul/And/Or/Xor/
  FAdd/FMul) + operand-1 block in lsra `scanClass` (only if op0 path gave
  nothing) + `isCommutativeX86` + Option B in `emitBinOp` (64- and 32-bit)
  and `emitFloatBinOp`. `sum_loop` body: single `addq %r8, %r9`.
- **Dead pushes** — `parkUnallocatedResults()` in lsra.crl: instruction
  results with no vreg (stores/br/cond_br/ret) kept stale `valData` (a bare
  small int) which `getRegName` reads as a physreg index (Br leftover 4 →
  %rbx) → false `funcUsesReg` → dead callee-save pushes. Fixed: park on
  `0x3FFFFFFF` in `rewrite()` + zero-vreg early-return path.
  Result: `sum_loop` 3→1 pushes, `fib_rec` lost dead r15, `array_sum` lost
  r13. Suite 64/64.

## PAUSED: TODO #3 — make rax/rcx/rdx allocatable (design agreed, not coded)

r10/r11 explicitly OUT of scope (emitter's universal scratch in ~20 sites:
const movabsq, spill bounce, GEP index, addr materialization, fold address —
separate emitter-rewrite project).

### Design (approved by user: "commit wallvm, then do accordingly")

1. Per-function reserved regs instead of static `X86_64_RESERVED_INT`
   (7 = rsp,rbp,rax,rcx,rdx,r10,r11). Baseline `{rsp,rbp,r10,r11}` + gates:
   - func has Shl/Ashr/Lshr → +rcx
   - func has SDiv/UDiv/SRem/URem → +rax,+rdx,+rcx (dominates the other two)
   - func has a vararg call → +rax (emitCall DOES write `%al`, x86_64_base.crl
     ~4653-4662 — clobbers low byte of rax before arg copies)
2. Interval flags `usesShift` / `usesDiv` on `LiveInterval`; scanClass free
   loop, coalesce-target selection, and eviction victim selection skip
   forbidden registers by NAME (`intRegNames[r]`).
3. spansCall already excludes caller-saves (searchStart=calleeStart) —
   rax/rcx/rdx are caller-save → call-crossing values can't take them, no
   new machinery needed.
4. Graph path (O3): graph reuses lsra's intervals wholesale
   (`irGraphRegAlloc` runs `lsra.allocate` first) → flags available;
   honor them in graph coloring candidate loop + belt-and-braces in the
   `allColored` validity check (like the existing spansCall check).

### Research findings (verified, do not re-derive)

- **emitShift** (x86_64_base.crl, `void emitShift`): 64-bit path does
  `movq src2, %rcx` + `shl %cl, work` unconditionally; `needSink =
  dstSpill || dst=="rcx"` already handles a result in rcx (sinks via r10).
  So shifts only endanger **rcx**; a shift RESULT in rax/rdx is safe.
- **emitDivRemCore** (x86_64_base.crl:3197): register literals =
  {rax, rcx, rdx, r10, r11} → div/rem flag must block **rax, rdx, rcx**
  (r10/r11 stay reserved anyway). Confirms the gate set exactly.
- **isel pow2 div** (iselEmitSDivPow2:1807 / iselEmitUDivPow2:1869) runs at
  ISel — before regalloc — so its shift sequences are real Shl/Ashr insts by
  the time flags are computed; the SDiv opcode position is flagged anyway.
- **spansCall semantics** (lsra.crl ~726): loop starts at `start+1`,
  `p <= end` → a call AT the interval's start (call result) does NOT span,
  a call at end (arg values) DOES. Call results may take rax (safe: written
  by the call); arg values are callee-only (safe from AL clobber).
- **`tryCoalesce()` runs in `linearScan()` AFTER `computeIntervals`** and
  extends `dstI->start/end` (phi union, bitcast union) — interval ranges can
  grow across div/shift positions that neither side covered. → compute the
  flags in `linearScan()` right after `tryCoalesce()`, not in
  `computeIntervals`. Separate method `computeIntervalRegFlags()`.
- **scanClass** (lsra.crl:870): guard points are (a) the free-reg loop
  `for r in searchStart..regCount` (~1034), (b) the coalesce take
  `if (coalescePhysReg != NO_REG && freeSet[...] && ...)` (~1026) — add
  name-based forbidden check, (c) eviction victim loop (~1096) — skip
  candidates whose `physReg` is forbidden for `cur`. `scanClass` has no name
  array param → add helper `str regNameAt(u32 r, bool isFloat)` using
  `intRegNames`/`floatRegNames`; float names never match rax/rcx/rdx so the
  check is class-safe. Prefer a free function
  `pub bool intervalRegForbidden(LiveInterval* li, str regName)` in lsra.crl
  so graph.crl can reuse it.
- **Reserved-set plumbing**: `regallocConfigFor(cc)` (wallvm.crl:442, NOT
  pub, only used at :501 irCompile and :550 irCompileAsm) returns a struct
  with `reservedIntRegs` POINTER into globals. Plan: keep base fn, add
  `applyFuncRegGates(RegAllocConfig* cfg, IrFunc* func)` called per-function
  (struct copy `RegAllocConfig fcfg = cfg;` inside the func loop); gate
  only when `cfg->reservedIntRegs == X86_64_RESERVED_INT` (pointer equality
  = x86_64 branch). New global arrays in x86_64_base.crl, style
  `pub str[] X = { ... }`:
  - `X86_64_RESERVED_T3_BASE`   = {rsp,rbp,r10,r11}                          (4)
  - `X86_64_RESERVED_T3_SHIFT`  = {rsp,rbp,rcx,r10,r11}                      (5)
  - `X86_64_RESERVED_T3_RAX`    = {rsp,rbp,rax,r10,r11}                      (5)
  - `X86_64_RESERVED_T3_RAX_SHIFT` = {rsp,rbp,rax,rcx,r10,r11}               (6)
  - div case reuses `X86_64_RESERVED_INT` itself                             (7)
- **Gate detection**: walk `func->blocks[].insts[]` once per function:
  opcode Shl/Ashr/Lshr → hasShift; SDiv/UDiv/SRem/URem → hasDiv; Call →
  callee `ops[0]->type` — null OR `kind==Func && type->isVararg` →
  hasVarargCall (conservative on missing type). Early-out when all three set.
- **Caller/callee order**: SYSV_CALLER_SAVE first in `intRegNames`, then
  callee (lsra `new()` ~155-185) → rax/rcx/rdx sit below `calleeStart` →
  spansCall exclusion works via existing `searchStart` with zero changes.

### Verification checklist (T3.4)

- `./mv` + rebuild irtool (OOM retry loop), `timeout --kill-after=10 600
  ./run.sh` in test/wallvm → expect **64/64**.
- Push-count diff on all `output/*.s`: expect `array_sum_O2` 3→~1
  (addresses move off rbx/r12), `sum_loop` stays 1, `fib_rec` unchanged
  (temps genuinely span calls). r10/r11 must never appear as homes.
- Cases cover gcd (div) and any shift cases; scratch-verify a vararg + shift
  + div .ir through irtool manually (do NOT add cases to the user's suite
  without asking — it is 16 cases × 4 levels = 64).
- If a wrong-code class survives the suite: suspect a missed special-role
  site in the emitter — grep the opcode's emitter body for quoted register
  names (method used above).

## Upper pipeline (ACTIVE — resumed 2026-10-23)

Roadmap: `lib/wallvm/docs/pipeline-gaps.md` (G-items) and `codegen-quality.md`.
Items known pending:

- Vectorizer: `lib/wallvm/passes/simd_vec.crl` needs test coverage /
  validation (untouched so far this session).
- pipeline-gaps.md open items (as of last session): G1, G20, G6, G10, G14,
  G15, G17, G19 — read the doc for current status markers.
- `meta_all.ir` + `--roundtrip` verification.

## Standing rules (user directives)

- Never change anything via git except when the user explicitly says
  "commit" (then stage ONLY wallvm paths — `compiler/` is off-limits).
- Do not touch the Wasm assembler work (another model's), `compiler/`.
- Local `lib/` is the source of truth; run `./mv` after every source edit.
- Coral: no local/inner functions; `for` headers have no comma operator;
  switch cases do not fall through; `str` comparison via `.equals()`.
- Test: `cd test/wallvm && timeout --kill-after=10 600 ./run.sh` (64/64).
- Do not resume/discuss: mimalloc, `__`-rename error API, std @assert
  migration, macos/android work, `@toStr` 8-byte-garbage bug.

# Raw AI audit output — WallVM backend

**Date:** 2026-10-20  
**Root:** `/home/cerie/Documents/coral/lib/wallvm`  
**Status:** Static audit only. No source, test, or build files changed.  
**Purpose:** Preserve the complete raw AI/subagent audit output in one place. The synthesized report is in `backend-audit-2026-10-20.md`.

---

## Part 1 — Pipeline, optimizer correctness, and completeness

Static audit only; no files changed. Root: /home/cerie/Documents/coral/lib/wallvm.

### 1. What the pipeline actually does

Driver: `irOptimize` selects L0-L3, runs `runOnFuncIterate`, then clears analysis caches. Iteration caps are 1/2/5/8 for L0/L1/L2/L3 (`wallvm.crl:318`). `irStructureLane` runs after optimization and contains `borrowcheck`, optional `unroll`, `validate`. `irCompile` ignores the optimizer return value and does not check validation errors (`wallvm.crl:462-466`).

```
L0 (1): validate → simplify → constfold → sccp → dce → validate

L1 (2): validate → abi_lower → comm_canon → simplify → constfold →
        involution → sccp → range → range_br_elim → branchprop →
        branch_inv_flat → cse → cast_elim → dse → jump_thread →
        idiom → peephole → dce → validate

L2 (5): validate → abi_lower → mem2reg → sroa → comm_canon → simplify →
        constfold → involution → range → range_br_elim → branchprop →
        sccp → adce → alias → mssa → licm → gvn → loopcse →
        jump_thread → inline → cast_elim → idiom → peephole → dse →
        lowrphis → validate

L3 (8): validate → abi_lower → mem2reg → sroa → stack_layout →
        comm_canon → lex_canon → simplify → constfold → involution →
        range → range_br_elim → branchprop → branch_inv_flat →
        branch_fact → divmod → sccp → adce → alias → mssa → licm →
        gvn → loopcse → loop_interchange → loop_distribute →
        jump_thread → tail_dup → inline → tco → simd_vec → idiom →
        idempotent → cast_elim → macro_fusion → peephole →
        machine_opt → sel2br → dse → lowrphis → validate
```

Important placement facts:

- `abi_lower` is at the head of L1-L3, not codegen-adjacent. `abiLowerPassFor` selects the Windows pass for Win64/SyscallWin64, otherwise SysV; i386 remains unwired (`wallvm.crl:191-198`).
- L2/L3 have no ordinary DCE. They run only `adce`, which is not real ADCE.
- L1 has CSE; L2/L3 do not.
- L2/L3 run `inline` near the end, after LICM/GVN/loopcse.
- `lower_phis` is the last optimizer pass in L2/L3.
- L0/L1 leave frontend phis unlowered; the x86_64 emitter has no Phi case.
- `validate` returns true for valid IR (`validate.crl:253,291`), so `runOnFuncIterate` always reports “changed” and always exhausts maxIters. It also increments `analysisGeneration` every iteration (`wallvm.crl:130-170`).
- The structure lane runs after the optimizer; unroll is opt-in and therefore never reoptimized. `irCompileAsm` skips optimization but still runs the structure lane, so unroll can run twice if both entry points are used.

### 2. Correctness findings

#### P0 — memory corruption, crash, or wrong-code

1. **`mem2reg` use-after-free and double-free** — `passes/mem2reg.crl:495,507,515,518`. It deallocates `inLoop`, reads it twice in the `anyLoopAlloca` path, then deallocates it again. Trigger: any loop alloca. This is not just a leak; it is heap corruption reachable at O2/O3.

2. **`select_to_branch` null dereference + heap OOB + stale CFG/phi** — `passes/select_to_branch.crl:43-48,79-87,129-138`.
   - `createTerminator` allocates a bare `IrInst` with `ops == null`, then writes `ops[0..2]`.
   - The original `Select` has `capOps == 3`; the pass sets `nops = 4` and writes `ops[3]`.
   - It leaves the old condition as a stale user, duplicates users for the selected values, and does not rewrite successor phis when redirecting successors from `bb` to `mergeBB`.

3. **`inline` maps the wrong values and creates duplicate labels** — `passes/inline.crl:363-381,335,353,427`.
   - Function arguments are `IrValueKind::Arg` values (`text/irParser.crl:2174`), not entry instructions. `inlineCall` maps `oldEntry->insts[i]` for `i < nparams` to call arguments, then skips the first `nparams` cloned entry instructions. Real callee instructions can be dropped; `estimateFuncCost` makes the same wrong assumption.
   - `after_inline` and `cont_inline` are fixed names; cloned callee blocks reuse `ob->base.name`. The Linux emitter writes `.L` + block name (`target/x86_64/linux/linux.crl:42-43`), so multiple inlines or repeated callee names produce duplicate assembly labels.
   - Continuation phi counts can mismatch void/mixed returns. Inline is not bottom-up and has no call-graph/SCC layer.

4. **`stack_layout` violates def-before-use at O3** — `passes/stack_layout.crl:178-205`.
   - It rebuilds entry as all non-alloca instructions first, then all allocas. Entry loads/stores/GEPs that use an alloca now execute before the alloca is defined.
   - The emitter places `emitAlloca` at the instruction position and uses the alloca value as the pointer operand, so this can produce uninitialized pointer values/wrong addresses.
   - It sets `changed = true` whenever there are at least two entry allocas, even when ordering is unchanged.
   - `lower_phis` then starts insertion at `entry->ninsts` when the first instruction is not an alloca and appends new allocas after the terminator (`passes/lower_phis.crl:60-73`).

5. **SCCP leaves invalid phi/CFG state and dangling values** — `passes/sccp.crl:1001-1008,1048-1066`.
   - Folding a constant `CondBr` removes the not-taken predecessor but does not remove its phi incoming pair.
   - It deallocates instructions in unreachable blocks without nulling uses in reachable phis, leaving dangling operands.
   - Empty unreachable blocks remain in `func->blocks`; L2/L3 have no DCE to clean them up.
   - Because SCCP is in L0, this affects every optimization level.

6. **LICM/loopcse speculate possibly-trapping loads** — `passes/licm.crl:194-200`; `passes/loopcse.crl` shares the same hoisting helpers.
   - Any `Load` is considered loop-invariant; there is no dereferenceability proof, no “dominates all exits” check, and no zero-trip guard.
   - A load inside a conditional or a loop that never executes can be moved to the preheader and fault.
   - `createPreheader` always creates a block named `preheader`; it never reuses an existing one. Multiple loops/functions produce duplicate `.Lpreheader` labels. `loopcse` can reuse `lp->preheader`, but does not fix the naming.

7. **`machine_opt` forwards across non-dominating stores; GVN crosses atomics/fences** —
   - `passes/machine_opt.crl:232-259`: `crossBlockLoadForward` scans predecessor candidates by array index `pi < bi`, not dominance. A later-indexed block can still lie on the path, or an earlier-indexed block can be unrelated.
   - `passes/memory_ssa.crl`: linear block-order memory versioning, not CFG/dominance SSA; the pass returns false and never publishes to `FunctionAnalysisCache`.
   - `passes/gvn.crl:171-199`: invalidates loads on `Store`, `Call`, and `InlineAsm`, but not `AtomicStore`, `AtomicRmw`, `AtomicCmpXchg`, `Fence`, or GC barriers. Normal loads can be CSE’d across synchronization.

8. **`jump_thread`/`tail_dup` move phis without repairing CFG/phi invariants** —
   - `jump_thread.crl:35-39` correctly guards multi-predecessor targets, but patterns 1 and 2 still move target phis into `bb`, rewrite incoming blocks to `bb`, and create self/duplicate incoming pairs in `finalTarget`/`taken`. The target is emptied but remains in `func->blocks`.
   - `tail_dup.crl:39-150`: pattern 1 moves target phis into `bb` and rewrites destination phis to `bb`, creating duplicate `bb` incoming pairs while leaving some target→destination edges/preds stale. Pattern 2 does not rewrite destination phis at all.
   - These produce invalid phi/pred state that `lower_phis` and the validator cannot repair.

9. **`loop_distribute` writes operands with zero capacity** — `passes/loop_distribute.crl:245,255-277`.
   - It creates clones with `createInst(..., null, 0, 0, 0)`, then sets `clone->nops = inst->nops` and writes `clone->ops[oi]`. `capOps` is zero; for any clone with more than one operand this is an OOB write.
   - New blocks use `createBlock(null)`; the emitter labels them `.L:`, producing duplicate empty labels.
   - The pass is wired into L3 and can fire on loops with at least two loads/stores and an induction variable.

#### P1 — invalid IR, compile failure, or major wrong optimization

- **`sroa` deletes legitimate `Noret` terminators** — `passes/sroa.crl:163-174`. It marks alloca/store/load as `Noret` then compacts every `Noret` in the function. Real `noret` terminators disappear; blocks can lose their terminator. It also leaks the removed instructions/users.
- **`simd_vec` deletes legitimate `Noret` terminators** — `passes/simd_vec.crl:1023-1052`. Its cleanup removes every `Noret`, including real source `noret` terminators, while using `Noret` as a transient marker for neutered scalar chains.
- **`dce` leaves stale predecessor edges and null phi operands** — `passes/dce.crl:50-132`. `removeUnreachableBlocks` compacts `func->blocks` but does not remove dead-block entries from live successors’ `preds` arrays or repair phis. `irPassAdce` (`dce.crl:316`) is not real ADCE: no CFG liveness, no dead-branch removal.
- **`branch_inversion_flat` is dead** — `passes/branch_inversion.crl:25-26` requires the previous instruction to be `CondBr`, making the later `ICmp`/`FCmp` constant-fold arms unreachable. Even if reached, it changes `CondBr` to `Br` without removing CFG edges or preds.
- **`branch_factoring` half-dead and incomplete** — `passes/branch_factoring.crl:180-181` requires an `ICmp` as the last instruction of a successor, impossible on valid IR. `collapseInversions` can fire but changes `CondBr` to `Br` without full pred/phi cleanup.
- **`idempotent` main patterns are dead** — `passes/idempotent.crl:64-80,107-120`: backward scans break at the first `Store` before reaching the earlier identical-store checks.
- **`lex_canon` rebuilds and discards chains** — `passes/lex_canon.crl:203-210`. `flattenSortChain` creates instructions that are never inserted or freed; only the two operands of the current instruction are sorted. The doc claim about “stale use lists” is wrong: `createInst` does not add users.
- **`loop_detect` can leak/overflow** — `passes/loop_detect.crl:22,92`: allocates `n + 1` loop slots but can emit more than one loop per latch; `IrLoop` and blocks objects are leaked.
- **`validate` does not check dominance/def-before-use** — it checks terminator/phi/pred consistency and use-def user lists, but not whether an operand’s definition dominates its use. It also discards errors instead of failing compilation.
- **`unroll`/`loop_distribute` create unnamed blocks** — `unroll.crl:456`, `loop_distribute.crl:245`; duplicate `.L:` labels when enabled.
- **`ipa_cp` is a stub** — `passes/ipa_cp.crl` has a TODO/null-deref path and is wired nowhere.

### 3. Completeness vs clang/gcc `-O2`

The pipeline is roughly “O1-shaped scalar canonicalization plus a narrow O3 vectorizer”; it is not close to `-O2`.

| Area | Current state | Gap vs `-O2` |
|---|---|---|
| CFG | No simplifycfg, block merge, empty-block fold, branch-to-empty removal, or real ADCE. `branch_inversion` dead; `branch_factoring` half-dead. | Major. `-O2` relies heavily on simplifycfg/BDCE/ADCE and block placement. |
| Scalar | `mem2reg`/SROA limited and unsafe; no reassociation, PRE, early-cse, or real instcombine. CSE is local; GVN dominance-scoped only. constfold/SCCP exist but have phi/CFG bugs. | Major. Local folding exists, but the core scalar fixpoint is missing and broken. |
| Loops | No loop-simplify, LCSSA, rotation, indvars, SCEV, unswitch, deletion, or strength reduction. LICM/loopcse speculate loads; unroll runs after optimization; interchange/distribute are unverified or crash. | Severe. Loop substrate is effectively absent. |
| Memory/alias | Object-based no-alias AA; `isMustAlias` only identical IDs. DSE is single-block and conservative. No memcpy/memset/memmove idiom formation or runtime alias versioning. | Major. Field/GEP-sensitive AA and memory optimization are missing. |
| IPA/module | No module pass stage, call graph, bottom-up inline, IPSCCP, globalopt, globaldce, argpromotion, or attribute inference. Inline is function-local and currently wrong. | Absent. This is the largest architectural gap. |
| Vectorization | Loop-only elementwise/reduction vectorization with static divisible trip counts; no SLP, runtime checks, remainder loops, cost model, or runtime alias checks. | Narrow. Not comparable to `-O2`/`-O3` vectorization. |
| Tail calls | Accumulator-recursion transform only; emitter has a local call; `ret → jmp` peephole. | Limited; no general tailcallelim. |
| Codegen | Excluded from this audit, but stack ordering, duplicate labels, and regalloc constraints cap optimizer value. | Separate but release-blocking. |

### 4. Severity and top-10 actions

Severity: P0 = memory corruption, crash, or wrong-code on ordinary input; P1 = invalid IR/compile failure on less common shapes or large missed optimizations; P2 = dead code, leaks, docs.

**No optimization level is production-safe today.** SCCP is in L0, so even O0/O1 are exposed to phi/CFG corruption. O2 adds mem2reg UAF and inline bugs. O3 adds stack_layout use-before-def, select_to_branch, loop_distribute, and duplicate-label failures.

Top 10 actions, prioritized:

1. **P0 Fix `mem2reg` memory safety** — remove the `inLoop` double-free/UAF and make loop promotion all-or-nothing.
2. **P0 Fix `select_to_branch`** — allocate terminator operands, enforce `capOps`, rewrite users, successor phis, preds, and succs; otherwise disable it.
3. **P0 Fix `inline`** — map `IrFunc::args` instead of entry instructions, stop skipping real instructions, make continuation phis correct, and use globally unique block labels.
4. **P0 Fix `stack_layout` + `lower_phis`** — preserve alloca def-before-use and never insert phi allocas after a terminator; add dominance checking to the validator.
5. **P0 Fix SCCP** — remove phi pairs when folding edges, recompute/clean unreachable blocks, and never deallocate values used by live phis.
6. **P0 Fix or disable unsafe loop hoisting** — LICM/loopcse must require dereferenceability and domination of all exits for loads; fix preheader naming.
7. **P0 Fix memory forwarding** — `machine_opt` must use dominance-aware MemorySSA; GVN must invalidate on atomics, fences, and GC barriers.
8. **P0 Fix CFG/phi passes** — `jump_thread`, `tail_dup`, `branch_factoring`, and `sel2br` must update preds/succs/phis atomically; remove dead `branch_inversion_flat`.
9. **P0/P1 Fix O3 crash/label paths** — `loop_distribute` zero-cap operand writes, all `createBlock(null)` sites, and function-global label uniquing (`preheader`, `after_inline`, `cont_inline`, `acc_loop`, `sel2br`).
10. **P1/P2 Build the missing infrastructure** — hard-fail validation, true mutation flags, real DCE/ADCE, simplifycfg, safe mem2reg/SROA, reassociation/PRE, loop canonicalization/indvars/SCEV, then module/IPA and vectorization. Update docs/tests last.

### 5. Realistic path and quality score

Current score: about **30/100** as an `-O2`-class optimizer. Rough breakdown:

- Scalar local simplification/canonicalization: 55-65/100
- CFG: 20-25/100
- Loop optimization: 20-25/100
- Interprocedural: 5-10/100
- Vectorization: 10-15/100
- Correctness/robustness: 10/100

The local scalar passes are real, but the CFG/loop/IPA layers are not production-grade, and several P0 bugs make benchmarking misleading.

Realistic path:

1. **Correctness foundation (2-4 weeks):** fatal validator, true change tracking, unique block naming, CFG/pred/phi utilities, fix the P0 memory/CFG bugs. Goal: O0-O3 compile every function reliably.
2. **Scalar O2 core (2-4 months):** safe mem2reg/SROA, simplifycfg, instcombine-like canonicalization, reassociation, real DCE/ADCE, dominance-aware GVN/PRE, jump threading/tail merging.
3. **Interprocedural layer (2-3 months):** correct inline with call graph/bottom-up ordering, IPSCCP, globalopt, globaldce, argpromotion, attribute inference.
4. **Loop infrastructure (2-4 months):** LoopInfo, LoopSimplify, LCSSA, rotation, indvars/SCEV, safe LICM, unswitch/deletion, unroll, idiom formation.
5. **Vectorization (3-6 months):** loop vectorizer with runtime trip-count checks, remainder loops, alias versioning, cost model, then SLP.
6. **Codegen quality (parallel):** block placement/branch relaxation, regalloc constraints, scheduling, spill quality.

Rough effort: **12-18 engineer-months** for credible scalar `-O2`-like quality on common code; **2-3 engineer-years** for broad `-O2` parity, with O3/vector parity longer. This is not a weeks-scale cleanup.

### Stale or incorrect documentation

- `docs/optimization-landscape.md:70,77-79` still says `simd_vec` score 1 and “does no loop-level vectorization”; §6 says it was reworked to score 4, and the current code is a real loop vectorizer. The table/headline are stale.
- `optimization-landscape.md:194` says `branch_inversion` is wired L1-L3; L2 omits it. It is L1/L3 only.
- `optimization-landscape.md:201-205` says `jump_thread` does not check other predecessors; current code has the `npreds == 1` guard. The remaining phi/empty-target bugs are different.
- `optimization-landscape.md:311-316` and table line 67 still describe the old `stack_layout` overflow/double-parenting; G43 fixed that, but the current code has a new alloca-ordering bug.
- `optimization-landscape.md:164-167` says `lex_canon` leaves “stale use lists”; actual behavior is discarded/leaked rebuilt instructions, and `createInst` does not add users.
- `optimization-landscape.md:259-260` says LICM “builds/reuses preheaders”; `createPreheader` never reuses and always names the block `preheader`.
- `optimization-landscape.md:180-185` describes `select_to_branch` as CFG churn only; it misses the null-operand crash, `ops[3]` OOB, and successor-phi bugs.
- `optimization-landscape.md:304-310` says only SysV ABI lowering is imported and Win64 is referenced nowhere; `wallvm.crl:59` imports the Windows pass and `abiLowerPassFor` selects it. Only i386 remains unwired.
- The score table (`optimization-landscape.md:29-42`) overstates `sccp`, `dce`, `adce`, `inline`, and `validate`; `adce` is not ADCE, SCCP corrupts phis/CFG, inline is broken, and validate is a diagnostic that reports “changed.”
- `pipeline-gaps.md` is generally more accurate, but A13 “FIXED” covers only the specific nameless-block/multi-pred subclaims; `select_to_branch` is still broken and `jump_thread` still mishandles phis. G43 fixed the old overflow but does not mention the new ordering bug. Many line references are stale: `wallvm.crl:406/285/158/170/195/227/295/477`, `mem2reg.crl:494/506/517`, `validate.crl:286/247`, etc.

**Bottom line:** do not treat this as a usable `-O2` pipeline yet. Fix the P0s and make validation fatal first; then build CFG, loop, and IPA infrastructure in that order.

---

## Part 2 — x86_64 audit

### WallVM x86_64 audit — findings so far

#### Method

- Built temporary drivers `/tmp/wvm_driver.crl` and `/tmp/wvm_driver_o.crl` against the repo’s `dist/coralc`; the installed `~/.coral/lib/wallvm` files hash-identically to the repo, so the emitted assembly reflects current tree code.
- Ran targeted IR through `irCompileAsm`, plus a variant that manually runs `irOptimize(..., 1)` first. No repo files were modified.
- Reproduced several wrong-answer/invalid-assembly cases directly; remaining items are code-inspection findings with exact locations.

#### Bottom line

The backend is not correctness-clean. At least eight independent P0 classes exist: constant operands, `icmp x,0`, spilled address operands, div/rem, shifts, compare clobbers, integer widths, and GEP scaling/indexing. Performance work should wait until these are fixed and a differential test harness is in place.

#### Confirmed P0 defects

1. **Constants are not materialized**

`emitBinOp` (`x86_64_base.crl:2565`) passes constants through `getRegForValue`; `opFor` (`:2203`) treats `ConstInt.valData` as an LSRA register index. For `5`, `intRegNameFor(5)` is `r8`; for `42`, it falls back to `rax`.

Observed for `%x = add i64 %v, 5`:

```
movq rcx, rax
addq r8, rax
```

`ret i64 42` emits no `movq $42,%rax` at all; `opFor(Const42)` returns `rax`, so `emitRet` suppresses the move (`:1305-1311`). The same bug affects store, gep indices, compares, and any generic ALU operand. Constants only work in call arguments and a few special isel patterns.

2. **`icmp x, 0` is never materialized, yet branches use the undefined result**

`iselTryFoldCmpZero` (`:2041`) emits `testq src,src` and returns true without writing `dst`. `emitCondBr` (`:2885`) then emits a second `testq` on the `ICmp` destination.

Observed:

```
movq (rcx), rax
testq rax, rax    # from the ICmp, flags discarded
testq rcx, rcx    # tests the alloca address, not the comparison
jne .Lyes
```

This miscompiles both value uses (`zext`, `select`, etc.) and direct branch uses.

3. **A spilled pointer corrupts the instruction text**

`addrFor` (`:1670`) calls `opForReg`, which emits a reload line. `emitLoadWidth` (`:1677`) and `emitStoreWidth` (`:1723`) emit `\tmovq (` before calling it.

Observed under pressure:

```
movq (	movq -128(%rbp), r11
r11), r10
```

This is not assembler-valid. It occurs when an alloca/pointer result spills, which is common once pressure rises.

4. **div/rem clobber the divisor when it is allocated `rdx`**

`emitDiv` (`:2594`) and `emitRem` (`:2629`) only move the divisor out of `rax`. `cqo` then destroys `rdx`.

Observed:

```
movq rsi, rax
addq rdx, rax
movq rax, %rax
cqo
idivq rdx
```

The divisor in `rdx` is overwritten before `idivq`. Unrelated live values in `rax`/`rdx`/`rcx` are also unmodeled clobbers.

5. **Shift overwrites the count when the destination is `rcx`**

`emitShift` (`:2660`) writes `src1` into `work`, then moves the count into `%rcx` if it is elsewhere. If `work == rcx`, the count is destroyed.

Observed:

```
movq rdx, rcx    # count in rcx
movq rax, %rcx   # dst=rcx overwrites count
shlq %cl, rcx
```

This computes `z << (z & 63)`, not `z << r`. It also clobbers unrelated live `rcx`.

6. **ICmp/FCmp clobber `rax`/`rcx`**

`emitICmp` (`:2801`) unconditionally writes `setcc %al`; if `dst != rax`, any live `rax` is corrupted. `emitFCmp` (`:2823`) uses `%al` and `%cl`. LSRA reserves only `rsp`/`rbp`/`r10`/`r11`, so `rax`/`rcx` are freely allocatable. This is the same family as G22 but broader than the doc lists.

7. **Integer widths are ignored**

`emitBinOp` ignores its `lOp` argument and always emits `movq` plus the 64-bit op; `emitICmp` always emits `cmpq`. Observed for `i32`:

```
movl (rdx), edi
movl (rsi), eax
movq rdi, rcx
addq rax, rcx
testq rcx, rcx
```

An `i32` overflow into bit 32 changes subsequent 64-bit compares. `i8`/`i16` arithmetic has the same problem.

8. **GEP uses the pointer width as the scale and does not fold constant indices**

`emitGep` (`:2768`) derives scale from `ops[0]->type->width` (pointer width `64`), so scale is always `8`, even for `i32`/`i8` arrays. Constant indices go through `opFor` and become registers.

Observed for `alloca array i32 4; gep %p, 1`:

```
leaq -16(%rbp), rax
movq rax, r10
movq rcx, r11        # constant 1 interpreted as register rcx
leaq (r10, r11, 8), rcx   # should be scale 4
```

#### Top 10 by impact/effort

| # | Finding | Class | Impact | Effort | First fix |
|---:|---|---|---|---|---|
| 1 | Constants not materialized | Correctness | Wrong results on nearly all constant uses | M | `loadImm` helper + immediate ALU/store/ret forms |
| 2 | `icmp x,0` not materialized | Correctness | Wrong branches/values | S | Materialize `setcc`, or fuse predicate-aware compare+branch |
| 3 | Spilled address corrupts instruction | Correctness | Invalid asm in any spilling function | S | Make `addrFor` side-effect-free; reload before formatting |
| 4 | Div/rem `rdx` and fixed-reg clobbers | Correctness | Wrong answers/crashes | M | Fixed-reg constraints or save/restore |
| 5 | Shift `rcx` destination/count clobber | Correctness | Wrong answers | S | Handle `dst==rcx`; constrain count |
| 6 | ICmp/FCmp `%al/%cl` clobbers | Correctness | Wrong values | M | Fixed-reg constraints or use safe scratch |
| 7 | Width-ignorant ALU/compare/shift/div | Correctness | `i32` overflow, `i8`/`i16` wrong | L | Thread type width through isel |
| 8 | GEP scale/constant index | Correctness | Wrong addresses | M | Use pointee element width; const → displacement |
| 9 | Caller-save-only RA, no coalescing, graph no-op | Performance | Massive spills/copies | L | Callee-save allocation, splitting, coalescing; retire graph |
| 10 | ABI gaps: indirect calls, varargs, structs | Correctness/functionality | Missing/broken call forms | M | Indirect call `*reg`, `%al`, ABI classification |

#### Register allocation notes for #9

- `wallvm.crl:401` sets `useCalleeSave=false`; `lsra.crl:672` therefore makes every call-spanning value spill.
- `lsra.crl:777` coalescing only lengthens intervals; it does not assign shared registers.
- `graph.crl:314-355` runs LSRA, recolors intervals, then writes nothing back to `valData`; it is a no-op at O3.
- One 16-byte slot per vreg, no packing/remat/splitting; only `xmm2`-`xmm7` are allocatable, so `xmm8`-`xmm15` are unused.
- Alloca results are normal vregs and spill like any value; a pressure test produced a 384-byte frame and spilled alloca pointers.

#### Path to roughly `1.2x` gcc/clang `-O2`

**Phase 0 — correctness, 3-5 days.** Fix items 1-8. Without this, benchmark results are meaningless. Add one regression test per shape: constant ALU/ret/store, `icmp x,0` branch/value, spilled pointer load/store, divisor in `rdx`, shift dest in `rcx`, `i32` overflow compare, `i32[]` GEP.

**Phase 1 — register allocation, 1-2 weeks.** Enable callee-saved registers, split live ranges at calls, implement real copy coalescing, rematerialize constants/alloca addresses, pack spill slots by width, use `xmm8`-`xmm15`, and either repair or delete `graph.crl`. This is likely the largest single performance gain on call-heavy/spill-heavy code.

**Phase 2 — instruction selection, 1-2 weeks.** Immediate ALU forms, 32-bit mnemonics, GEP displacement folding, load-op/store-op memory operands, compare+branch fusion, `cmov` select, xor-zeroing, magic constant division. This closes most instruction-count gaps.

**Phase 3 — layout and ABI, about 1 week.** Block layout/fallthrough, branch inversion, broader tail calls, indirect calls, varargs `%al`, struct/vector returns, Win64 end-to-end validation.

**Measurement:** build a differential corpus (integer, pointer, branch, call, array/struct, divide) and compare assemble/link/run output against gcc/clang `-O2`; also track code size. The current backend is far from `1.2x`, but after Phase 0 + Phase 1 + Phase 2, `1.2x` on integer/pointer/control-flow code is plausible. Floating/vector code will likely need separate work.

#### Doc corrections

| Doc claim | Reality |
|---|---|
| `codegen-quality.md:147` — “immediates for ALU ops exist” | False for generic ALU; constants map to register indices. Only special isel patterns/call args work. |
| `codegen-quality.md:137` — “test vs cmp $0 good” | Not good: `iselTryFoldCmpZero` never writes `dst`; branches re-test the undefined result. |
| `codegen-quality.md:133` — GEP scale “derived from operand type” | `emitGep` uses pointer width → scale `8` always; non-8-byte elements wrong. |
| `codegen-quality.md:135` — store constant “copies constant into a register first” | It does not copy; `opFor(ConstInt)` treats the literal as a register index. |
| `codegen-quality.md:150` — “three-operand `imulq`” | Fallback is two-operand through `emitBinOp`; minor wording error. |
| `pipeline-gaps.md:327` — G21 spill contract “works end-to-end” | Frame/decode exists, but spilled address operands emit invalid nested instructions. |
| `pipeline-gaps.md:414-429` — G22 clobber half real | Correct, but incomplete: add divisor-in-`rdx` and shift-dest-in-`rcx` cases. |
| `pipeline-gaps.md:551` — `cond_br` is “naive” | Worse for `icmp x,0`: it is a miscompile, not just extra instructions. |
| `codegen-quality.md` tail-call row vs Section 3 item 9 | Contradiction: table says fixed; item 9 says regressed/removed. Code has `tailShapeOk`; fix is present but limited to frameless direct register-arg calls. |

Verified claims that do hold: G42 unsigned div/rem now selects `cqo` vs `xorl %edx,%edx` correctly; G44 two-phase parameter seeding is present; G34 tail-call logic is present; G22’s reserved-array off-by-one is fixed. Their line references have drifted.

#### Open items

- ABI end-to-end tests are not done. The text parser creates `IrValueKind::Arg` (`irParser.crl:2174`), while LSRA only harvests `Inst`-kind parameter values (`lsra.crl:342-370`), so parser-built functions with parameters do not get seeded; ABI tests need `irBuilder` or a temporary parser adjustment.
- Struct/vector returns likely need work: `emitRet` dereferences struct values as pointers (`:1268`), and 16-byte struct `Load` uses `movq` only. Verify against ABI-lowered IR.
- Indirect calls have no register form in `emitCall` (`:3398`); `%al` varargs count is only emitted for direct `Func` callees.
- Win64 register mapping (`X86_64_INT_REGS_WIN64`) looks consistent, but no Win64 assemble/link/run test has been performed.
- The generated text mixes bare register names (`rax`) with `%`-prefixed ones (`%rax`); confirm the intended assembler accepts both before treating assembly output as GNU-as compatible.

**Recommended immediate next patch order:** #1 constant materialization, #2 remove/fix cmp-zero flag-only path, #3 fix `addrFor`/load-store emission, then #4-#8.

---

## Part 3 — Maturity, Wasm/PE, and default-backend recommendation

WallVM is broad but not end-to-end. The strongest pieces are the assembler, linker, and wasm32 WAT emitter. The native x86_64 path still miscompiles basic IR, has no artifact path, and must not become the default yet.

### New evidence

- **wasm32 is semantically the best backend in these tests.** No-opt WAT is correct for `ret 42`, parameter passing, phi, `1+2`, constant stores, and `f64` constants. It emits parameters directly, materializes constants, and lowers phi via pc/select.
- **wasm32 is still WAT-only:** `irCompile` returns success but discards output. `compile2` on the phi fixture fails with `terminator reached the generic dispatcher`; `compile3` returns success/no artifact.
- **PE is now validated under Wine:**
  - PE executable with `mov $42,%eax; ret` exits `42`.
  - PE executable linked with a short import library calls `ExitProcess(42)` and exits `42`; the import directory is emitted correctly.
  - PE DLL exporting `get42` loads via `LoadLibraryA`/`GetProcAddress` and returns `42`.
- **PE import caveat:** short import libraries work (`llvm-dlltool`), but GNU/Wine-style `libkernel32.a` is treated as ordinary COFF objects, producing no import directory and a runtime fault.
- **Linker/assembler positives:** static ELF, shared ELF + dynamic executable, static archives, PE exe/DLL, COFF input, and short import libraries all work. ELF output still needs `chmod +x`; TLS is rejected; 32-bit PE is not exposed by `linktool`.
- **Native x86_64 blockers remain unchanged:** constants decoded as register indices, `IrValueKind::Arg` params never seeded, `lower_phis` alloca inserted after the terminator, duplicate epilogue, bare-register syntax against AT&T, data section never flushed, and silent success for unsupported targets.
- **Earlier segfault report is retracted:** no-opt main/float are not reproducibly crashing after the harness rebuild.

### Maturity snapshot

| Area | Assessment |
|---|---|
| Assembler |  |
| Linker |  |
| wasm32 |  |
| x86_64 |  |
| x86-32 / Win64 |  |
| IR/parser/passes |  |
| Integration |  |

*(The raw output supplied for this section contained only the area labels; the qualitative assessments are in the synthesized report.)*

### Must-fix before default

1. Add a real artifact/sink path and `buildModule`; stop discarding `irCompile` output.
2. Materialize `ConstInt` generally in `opFor`/store/binop/ret paths.
3. Fix parameter seeding to recognize `IrValueKind::Arg` or create the expected entry stores.
4. Emit exactly one epilogue and balance callee-save pushes/pops.
5. Fix `irLowerPhis` insertion and fail closed on unsupported opcodes/backends.
6. Emit valid AT&T syntax consistently and make target dispatch reject/conform correctly.
7. Flush the data section; add `.rodata`/constant-pool support.
8. Add golden IR/asm tests plus differential tests against the C backend.

### Adoption recommendation

Keep the C backend default. Add WallVM behind an opt-in flag and promote target-by-target: wasm32 first for semantic coverage, then x86_64 after the blockers above, with C-vs-WallVM differential testing, parser/pass fuzzing, and self-hosting only after correctness is stable. Preserve the linker/assembler and wasm emitter; do not preserve the native emitter’s current constant/parameter/epilogue behavior.

---

## Appendix — audit scope notes

- Root audited: `/home/cerie/Documents/coral/lib/wallvm`.
- No source/test/build files were modified.
- Canonical IR reference for parser/IR-creation work: `/home/cerie/Documents/Mu/Mu_docs/IR.md`.
- Linker and assembler findings are retained as evidence, but binary-generation work is outside the intended edit focus.

# WallVM Backend Audit — Pipeline, Codegen, and Default-Backend Readiness

**Date:** 2026-10-20  
**Root:** `/home/cerie/Documents/coral/lib/wallvm`  
**Status:** Initial audit was read-only. Remediation status is tracked in §1.1; P0 fixes below have since been applied to WallVM and targeted compiler fixes were made for literal typing and brace-initializer checking.  
**Canonical IR contract:** `/home/cerie/Documents/Mu/Mu_docs/IR.md`  
**Focus:** Upper optimization pipeline, IR creation/parsing, and native/Wasm backend readiness. Linker and assembler results are included for context only; they are not the target of this audit.

**Evidence labels used below:**

- **Source:** established by reading the current tree.
- **Reproduced:** observed by running targeted IR through a temporary driver.
- **Reported:** a subagent finding that still needs independent reproduction with the approved build.
- **Doc drift:** a claim in an older WallVM document that no longer matches current code.

---

## 1. Executive summary

WallVM is broad but not end-to-end production-ready. The strongest pieces are the assembler, the linker, and the wasm32 WAT emitter. The optimization pipeline contains real scalar passes, but the CFG, loop, and interprocedural layers are far below an `-O2`-class optimizer, and several P0 defects make even ordinary optimization levels unsafe. The native x86_64 path additionally miscompiles basic IR and is not ready to become the default backend.

At a glance:

| Area | Assessment |
|---|---|
| Pipeline correctness | Not production-safe at any optimization level. SCCP is in L0, so O0/O1 are already exposed to phi/CFG corruption. |
| `-O2` completeness | Roughly 30/100 as an `-O2`-class optimizer. Local scalar work exists; CFG, loop, IPA, and vector layers are substantially incomplete. |
| x86_64 correctness | Not correctness-clean. At least eight independent P0 classes: constants, `icmp x,0`, spilled addresses, div/rem, shifts, compare clobbers, integer widths, and GEP scaling/indexing. |
| x86_64 performance | Far from `1.2x` gcc/clang. The pipeline cannot be benchmarked meaningfully until the P0s are fixed; then register allocation is the largest single gap. |
| wasm32 | Semantically the best backend in the tested cases, but WAT-only: `irCompile` discards output and one phi path fails. |
| Assembler | Strong: raw clang GNU/MSVC asm, direct COFF objects, static ELF, and COFF output work. |
| Linker | Strong: static/shared ELF, dynamic executables, archives, PE exe/DLL, COFF, and short import libraries work, with known limits. |
| IR/parser/passes | Broad IR and pass inventory, but several passes are broken, unsafe, dead, or silently ineffective. Parser-created `Arg` values are not seeded by register allocation. |
| Default-backend readiness | Not ready. Keep the C backend as default and make WallVM opt-in, target by target. |
| Immediate priority | Fix memory-safety and wrong-code P0s; make validation fatal; add differential tests. Do not start performance work first. |

The one-line recommendation is: **fix correctness, then build CFG/scalar infrastructure, then IPA, then loops, then vectorization; keep the C backend default until the differential and ABI gates are green.**

### 1.1 Remediation status (updated 2026-10-20)

Legend: **Done** = fixed in the tree; **Verified** = exercised with the approved `compiler/build/coralc`; **Open** = not fixed.

| Milestone | Status | Evidence |
|---|---|---|
| X-P0-1 constants materialized | Done, Verified | Constant ALU/ret/store fixtures at O0. |
| X-P0-2 `icmp x, 0` | Done, Verified | `i32cmp`, `i32slt` fixtures. |
| X-P0-3 spilled pointer text | Done, Verified | Spill-pointer fixture at O0. |
| X-P0-4 div/rem self-clobber | Done, Verified | `div`, `divneg`, `udiv`, `sdivchk`, `divreg` fixtures. |
| X-P0-5 shift count clobber | Done, Verified | `lshr`, `ashr`, `shl` fixtures. |
| X-P0-6 ICmp/FCmp clobbers | Done, Verified | Compare/tail-call fixtures. |
| X-P0-7 integer widths | Done, Verified | i32 compare/overflow fixtures. |
| X-P0-8 GEP scale/index | Done, Verified | `gep2`, `gep3`. |
| Tail-call frame/comment bugs | Done, Verified | `emitRet` uses `emitComment`; tail calls are rejected when `spillFrameBytes > 0`. |
| Duplicate block labels | Done, Verified | `emitBlockLabel` emits function/block/block-id labels; inline and loop fixtures link. |
| Parser `Arg` / LSRA seeding | Done, Verified | Direct `func->args` vreg harvesting plus legacy entry-store harvesting. |
| O-P0-1 `mem2reg` UAF/double-free | Done | Loop-alloca promotion made all-or-nothing; no early free. |
| O-P0-2 `select_to_branch` | Done | Operand capacity, users, successor phis, preds/succs repaired. |
| O-P0-3 `inline` | Done, Verified | Args mapped from `IrFunc::args`, no skipped real instructions, unique block labels, return values captured before erasure. `/tmp/wvm_inline.ir` exits 42 at O0-O3. |
| O-P0-4 `stack_layout`/`lower_phis` | Done | Def-before-use ordering and terminator-safe alloca insertion. |
| O-P0-5 SCCP | Done | Phi pairs removed on folded edges; unreachable cleanup; no dangling dealloc. |
| O-P0-6 LICM/loopcse loads | Done | Load hoisting disabled until dereferenceability/exit-domination exists. |
| O-P0-7 `machine_opt`/GVN | Done | Dominance-aware store forwarding; atomics/fence/GC ops invalidate GVN. |
| O-P0-8 `jump_thread`/`tail_dup` | Done | Phi/pred/succ repair and dead-block compaction. |
| O-P0-9 `loop_distribute` | Done | Correct operand capacity and unique block names. |
| Compiler literal typing (`1ULL`, `1L`) | Done, Verified | Sema honors lexer long flag; C emission casts literals to their resolved integer type. `/tmp/masktest` prints `mask=4294967295`; suffix fixture exits 42. |
| Scalar brace initializer rejection | Done, Verified | `char c = { 'c', 'd' };` now fails with T0002; array/struct brace initializers still compile. |
| P1 `simd_vec` `Noret` cleanup | **Open** | Still deletes legitimate `Noret` terminators. |
| Vectorization / vector codegen | **Open** | Pass audit and lowering work not started. |
| Full O0-O3 regression rerun | **Open** | 22 fixtures passed at O0; inline passed at all levels; full rerun still required. |

---

## 2. Scope and method

This audit covers:

- the WallVM optimization driver and pass placement;
- pass correctness and completeness relative to clang/gcc `-O2` and `-O3`;
- native x86_64 instruction selection, register allocation, and ABI issues;
- wasm32, assembler/linker, and PE evidence needed to judge default-backend readiness;
- the IR/parser contract described by `/home/cerie/Documents/Mu/Mu_docs/IR.md`, including its intended use for inline IR and compiler-generated IR.

It does **not** modify WallVM, the compiler, tests, or build outputs. Linker and assembler are treated as existing infrastructure and are explicitly left alone in this phase.

### 2.1 Evidence base

- Source inspection of the current tree, including `wallvm.crl`, every wired pass named in this report, `target/x86_64/x86_64_base.crl`, `regalloc/lsra.crl`, `regalloc/graph.crl`, `text/irParser.crl`, and the target emitters.
- Temporary x86_64 drivers under `/tmp/wvm_driver.crl` and `/tmp/wvm_driver_o.crl` for targeted IR reproduction.
- The x86_64 harness was built against the then-installed `dist/coralc`; the installed `~/.coral/lib/wallvm` files hash-identically to the repository, so the emitted assembly reflects the current tree code. Reproductions should nevertheless be rerun with the approved `compiler/build/coralc` before patching.
- The x86_64 driver variant manually runs `irOptimize(..., 1)` before `irCompileAsm` where needed.
- No repository files were modified by the audit harness.

### 2.2 IR contract and parser

`/home/cerie/Documents/Mu/Mu_docs/IR.md` is the canonical description of the WallVM IR model and text format. It is the contract the parser and IR creation should follow, and it is the intended route for:

- inline IR;
- inspecting and testing optimization passes;
- caching or replaying compiler-generated IR;
- round-trip printer/parser workflows.

The text format is one instruction per line, with typed atoms and no infix expressions. The parser (`text/irParser.crl`) already implements a substantial one-pass parser with forward fixups, metadata, aggregate constants, and textual round-tripping. The main contract-related gap called out by this audit is not syntax breadth but semantic integration: parser-created function parameters are `IrValueKind::Arg` values, while LSRA currently harvests only `Inst`-kind parameter values, so parser-built functions with parameters are not seeded. See §6.4.

The intended scope split for follow-up work is:

- **Upper pipeline and IR creation:** driver, pass correctness, IR builder/parser, validation, test harness.
- **Binary-generation backend:** linker and assembler are out of scope for edits in this phase.
- **Native codegen:** fix correctness gate first; performance work only after the differential harness exists.

---

## 3. What the pipeline actually does

### 3.1 Driver behavior

`irOptimize` selects an optimization level and runs each function through `runOnFuncIterate`, then clears analysis caches. The iteration caps are:

| Level | Max iterations |
|---|---:|
| L0 | 1 |
| L1 | 2 |
| L2 | 5 |
| L3 | 8 |

Relevant driver locations:

- Level selection and iteration caps: `wallvm.crl:318`
- `runOnFuncIterate`: `wallvm.crl:130-170`
- `irStructureLane`: after optimization; contains `borrowcheck`, optional `unroll`, and `validate`
- `irCompile`: ignores the optimizer return value and does not check validation errors: `wallvm.crl:462-466`

The structure lane runs **after** optimization. `unroll` is opt-in, so its output is never reoptimized. `irCompileAsm` skips optimization but still runs the structure lane, so unroll can run twice if both entry points are used.

### 3.2 Actual pass lanes

```
L0 (1 iteration):
  validate -> simplify -> constfold -> sccp -> dce -> validate

L1 (2 iterations):
  validate -> abi_lower -> comm_canon -> simplify -> constfold ->
  involution -> sccp -> range -> range_br_elim -> branchprop ->
  branch_inv_flat -> cse -> cast_elim -> dse -> jump_thread ->
  idiom -> peephole -> dce -> validate

L2 (5 iterations):
  validate -> abi_lower -> mem2reg -> sroa -> comm_canon -> simplify ->
  constfold -> involution -> range -> range_br_elim -> branchprop ->
  sccp -> adce -> alias -> mssa -> licm -> gvn -> loopcse ->
  jump_thread -> inline -> cast_elim -> idiom -> peephole -> dse ->
  lowrphis -> validate

L3 (8 iterations):
  validate -> abi_lower -> mem2reg -> sroa -> stack_layout ->
  comm_canon -> lex_canon -> simplify -> constfold -> involution ->
  range -> range_br_elim -> branchprop -> branch_inv_flat ->
  branch_fact -> divmod -> sccp -> adce -> alias -> mssa -> licm ->
  gvn -> loopcse -> loop_interchange -> loop_distribute ->
  jump_thread -> tail_dup -> inline -> tco -> simd_vec -> idiom ->
  idempotent -> cast_elim -> macro_fusion -> peephole ->
  machine_opt -> sel2br -> dse -> lowrphis -> validate
```

### 3.3 Placement facts that matter

- `abi_lower` is at the **head** of L1-L3, not adjacent to code generation. `abiLowerPassFor` selects the Windows pass for Win64/SyscallWin64, otherwise SysV. i386 remains unwired (`wallvm.crl:191-198`).
- L2/L3 have **no ordinary DCE**. They run only `adce`, which is not real ADCE.
- L1 has CSE; L2/L3 do not.
- L2/L3 run `inline` near the end, after LICM/GVN/loopcse.
- `lower_phis` is the last optimizer pass in L2/L3.
- L0/L1 leave frontend phis unlowered. The x86_64 emitter has no `Phi` case, so those levels cannot be considered a complete native-code path for arbitrary frontend IR.
- `validate` returns true for valid IR (`validate.crl:253`, `validate.crl:291`). `runOnFuncIterate` therefore always reports "changed" and always exhausts `maxIters`. It also increments `analysisGeneration` every iteration (`wallvm.crl:130-170`).
- The structure lane runs after the optimizer, and `irCompileAsm` can run it without the optimizer, so unroll can execute twice across entry points.

---

## 4. Pipeline correctness findings

### 4.1 P0 — memory corruption, crash, or wrong-code

Severity definition used here: **P0** means memory corruption, a crash, or wrong code on ordinary input; **P1** means invalid IR, compile failure on less common shapes, or a major missed optimization; **P2** means dead code, leaks, or documentation drift.

| ID | Finding | Trigger and impact |
|---|---|---|
| O-P0-1 | `mem2reg` use-after-free and double-free | Any loop alloca. Heap corruption reachable at O2/O3. |
| O-P0-2 | `select_to_branch` null dereference, heap OOB, stale CFG/phi | Any select converted by the pass. Crash or invalid CFG. |
| O-P0-3 | `inline` maps wrong values, drops instructions, creates duplicate labels | Any inlined call; particularly callees with parameters. Wrong code or duplicate assembly labels. |
| O-P0-4 | `stack_layout` violates def-before-use at O3 | Entry loads/stores/GEPs that use an alloca after reordering. Wrong addresses or uninitialized pointers. |
| O-P0-5 | SCCP leaves invalid phi/CFG state and dangling values | Constant-folded conditional branches and unreachable blocks. Affects every optimization level because SCCP is in L0. |
| O-P0-6 | LICM/loopcse speculate possibly-trapping loads | Loop-invariant loads inside conditional or zero-trip loops. Can fault code that should not execute. |
| O-P0-7 | `machine_opt` forwards across non-dominating stores; GVN crosses atomics/fences | Memory forwarding and synchronization. Wrong values. |
| O-P0-8 | `jump_thread`/`tail_dup` move phis without repairing CFG/phi invariants | Multi-predecessor targets and duplicated phi destinations. Invalid IR. |
| O-P0-9 | `loop_distribute` writes operands with zero capacity | Loops with at least two loads/stores and an induction variable. Heap OOB and duplicate empty labels. |

#### O-P0-1 — `mem2reg` use-after-free and double-free

Locations: `passes/mem2reg.crl:495`, `:507`, `:515`, `:518`.

The pass deallocates `inLoop`, reads it twice in the `anyLoopAlloca` path, then deallocates it again. This is not merely a leak; it is heap corruption reachable at O2/O3. The fix must make loop-alloca promotion safe and all-or-nothing, and must not deallocate state that is still used by the promotion decision.

#### O-P0-2 — `select_to_branch` crash and invalid IR

Locations: `passes/select_to_branch.crl:43-48`, `:79-87`, `:129-138`.

- `createTerminator` allocates a bare `IrInst` with `ops == null`, then writes `ops[0..2]`.
- The original `Select` has `capOps == 3`; the pass sets `nops = 4` and writes `ops[3]`.
- It leaves the old condition as a stale user, duplicates users for the selected values, and does not rewrite successor phis when redirecting successors from `bb` to `mergeBB`.

The pass should either be repaired to allocate the terminator operands, respect `capOps`, rewrite users, successor phis, preds, and succs atomically, or be disabled.

#### O-P0-3 — `inline` maps the wrong values and creates duplicate labels

Locations: `passes/inline.crl:363-381`, `:335`, `:353`, `:427`; parameter creation at `text/irParser.crl:2174`.

- Function arguments are `IrValueKind::Arg` values, not entry instructions. `inlineCall` maps `oldEntry->insts[i]` for `i < nparams` to call arguments, then skips the first `nparams` cloned entry instructions. Real callee instructions can be dropped; `estimateFuncCost` makes the same wrong assumption.
- `after_inline` and `cont_inline` are fixed names. Cloned callee blocks reuse `ob->base.name`. The Linux emitter writes `.L` plus the block name (`target/x86_64/linux/linux.crl:42-43`), so multiple inlines or repeated callee names produce duplicate assembly labels.
- Continuation phi counts can mismatch void/mixed returns.
- Inline is not bottom-up and has no call-graph or SCC layer.

Fix direction: map `IrFunc::args`, not entry instructions; do not skip real instructions; construct continuation phis from actual return shapes; use globally unique block labels; add a call-graph layer.

#### O-P0-4 — `stack_layout` violates def-before-use

Locations: `passes/stack_layout.crl:178-205`; `passes/lower_phis.crl:60-73`.

`stack_layout` rebuilds the entry block as all non-alloca instructions first, then all allocas. Entry loads/stores/GEPs that use an alloca now execute before the alloca is defined. The emitter places `emitAlloca` at the instruction position and uses the alloca value as the pointer operand, so this can produce uninitialized pointer values or wrong addresses.

It also sets `changed = true` whenever there are at least two entry allocas, even when ordering is unchanged. `lower_phis` then starts insertion at `entry->ninsts` when the first instruction is not an alloca and appends new allocas after the terminator.

Fix direction: preserve def-before-use; only insert allocas at legal positions before uses; never append allocas after a terminator; add dominance validation.

#### O-P0-5 — SCCP leaves invalid phi/CFG state and dangling values

Locations: `passes/sccp.crl:1001-1008`, `:1048-1066`.

- Folding a constant conditional branch removes the not-taken predecessor but does not remove its phi incoming pair.
- It deallocates instructions in unreachable blocks without nulling uses in reachable phis, leaving dangling operands.
- Empty unreachable blocks remain in `func->blocks`; L2/L3 have no DCE to clean them up.
- Because SCCP is in L0, this affects every optimization level.

Fix direction: remove phi pairs when folding edges; recompute/clean unreachable blocks; never deallocate values used by live phis; add a CFG/phi cleanup utility.

#### O-P0-6 — LICM and loopcse speculate possibly-trapping loads

Locations: `passes/licm.crl:194-200`; `passes/loopcse.crl` shares the same hoisting helpers.

- Any `Load` is considered loop-invariant.
- There is no dereferenceability proof, no “dominates all exits” check, and no zero-trip guard.
- A load inside a conditional or a loop that never executes can be moved to the preheader and fault.
- `createPreheader` always creates a block named `preheader`; it never reuses an existing one. Multiple loops/functions produce duplicate `.Lpreheader` labels. `loopcse` can reuse `lp->preheader`, but does not fix the naming.

Fix direction: require dereferenceability and domination of all exits for speculative loads; add zero-trip guards where needed; reuse preheaders; make labels unique.

#### O-P0-7 — Unsafe memory forwarding and synchronization barriers

Locations: `passes/machine_opt.crl:232-259`; `passes/memory_ssa.crl`; `passes/gvn.crl:171-199`.

- `crossBlockLoadForward` scans predecessor candidates by array index `pi < bi`, not dominance. A later-indexed block can still lie on the path, or an earlier-indexed block can be unrelated.
- `memory_ssa.crl` uses linear block-order memory versioning, not CFG/dominance SSA, and returns false without publishing to `FunctionAnalysisCache`.
- GVN invalidates loads on `Store`, `Call`, and `InlineAsm`, but not `AtomicStore`, `AtomicRmw`, `AtomicCmpXchg`, `Fence`, or GC barriers. Normal loads can be CSE'd across synchronization.

Fix direction: make forwarding dominance-aware; use real MemorySSA or equivalent; invalidate on all memory/synchronization effects.

#### O-P0-8 — `jump_thread` and `tail_dup` violate phi/CFG invariants

Locations: `passes/jump_thread.crl:35-39`; `passes/tail_dup.crl:39-150`.

- `jump_thread` correctly guards multi-predecessor targets, but patterns 1 and 2 still move target phis into `bb`, rewrite incoming blocks to `bb`, and create self/duplicate incoming pairs in `finalTarget`/`taken`. The target is emptied but remains in `func->blocks`.
- `tail_dup` pattern 1 moves target phis into `bb` and rewrites destination phis to `bb`, creating duplicate `bb` incoming pairs while leaving some target-to-destination edges/preds stale. Pattern 2 does not rewrite destination phis at all.
- These produce invalid phi/pred state that `lower_phis` and the validator cannot repair.

Fix direction: update preds, succs, and phis atomically; remove empty blocks; add targeted CFG/phi tests.

#### O-P0-9 — `loop_distribute` zero-capacity operand writes

Locations: `passes/loop_distribute.crl:245`, `:255-277`.

The pass creates clones with `createInst(..., null, 0, 0, 0)`, then sets `clone->nops = inst->nops` and writes `clone->ops[oi]`. `capOps` is zero; for any clone with more than one operand this is an out-of-bounds write. New blocks use `createBlock(null)`; the emitter labels them `.L:`, producing duplicate empty labels. The pass is wired into L3 and can fire on loops with at least two loads/stores and an induction variable.

Fix direction: allocate operand storage with the correct capacity; use unique block names or reject unnamed blocks.

### 4.2 P1 — invalid IR, compile failure, or major missed optimization

- **`sroa` deletes legitimate `Noret` terminators** — `passes/sroa.crl:163-174`. It marks alloca/store/load as `Noret` and then compacts every `Noret` in the function. Real `noret` terminators disappear; blocks can lose their terminator. It also leaks removed instructions/users.
- **`simd_vec` deletes legitimate `Noret` terminators** — `passes/simd_vec.crl:1023-1052`. Its cleanup removes every `Noret`, including real source `noret` terminators, while using `Noret` as a transient marker for neutered scalar chains.
- **`dce` leaves stale predecessor edges and null phi operands** — `passes/dce.crl:50-132`. `removeUnreachableBlocks` compacts `func->blocks` but does not remove dead-block entries from live successors' `preds` arrays or repair phis. `irPassAdce` (`dce.crl:316`) is not real ADCE: no CFG liveness, no dead-branch removal.
- **`branch_inversion_flat` is dead** — `passes/branch_inversion.crl:25-26` requires the previous instruction to be `CondBr`, making the later `ICmp`/`FCmp` constant-fold arms unreachable. Even if reached, it changes `CondBr` to `Br` without removing CFG edges or preds.
- **`branch_factoring` is half-dead and incomplete** — `passes/branch_factoring.crl:180-181` requires an `ICmp` as the last instruction of a successor, impossible on valid IR. `collapseInversions` can fire but changes `CondBr` to `Br` without full pred/phi cleanup.
- **`idempotent` main patterns are dead** — `passes/idempotent.crl:64-80`, `:107-120`. Backward scans break at the first `Store` before reaching the earlier identical-store checks.
- **`lex_canon` rebuilds and discards chains** — `passes/lex_canon.crl:203-210`. `flattenSortChain` creates instructions that are never inserted or freed; only the two operands of the current instruction are sorted. The document claim about “stale use lists” is wrong: `createInst` does not add users.
- **`loop_detect` can leak/overflow** — `passes/loop_detect.crl:22`, `:92`. It allocates `n + 1` loop slots but can emit more than one loop per latch; `IrLoop` and block objects are leaked.
- **`validate` does not check dominance/def-before-use** — it checks terminator/phi/pred consistency and use-def user lists, but not whether an operand's definition dominates its use. It also discards errors instead of failing compilation.
- **`unroll`/`loop_distribute` create unnamed blocks** — `unroll.crl:456`, `loop_distribute.crl:245`. Duplicate `.L:` labels appear when enabled.
- **`ipa_cp` is a stub** — `passes/ipa_cp.crl` has a TODO/null-deref path and is wired nowhere.

---

## 5. Completeness versus clang/gcc `-O2`

The pipeline is roughly “O1-shaped scalar canonicalization plus a narrow O3 vectorizer.” It is not close to `-O2`.

| Area | Current state | Gap versus `-O2` |
|---|---|---|
| CFG | No simplifycfg, block merge, empty-block fold, branch-to-empty removal, or real ADCE. `branch_inversion` is dead; `branch_factoring` is half-dead. | Major. `-O2` relies heavily on simplifycfg/BDCE/ADCE and block placement. |
| Scalar | `mem2reg`/SROA limited and unsafe; no reassociation, PRE, early-cse, or real instcombine. CSE is local; GVN is dominance-scoped only. constfold/SCCP exist but have phi/CFG bugs. | Major. Local folding exists, but the core scalar fixpoint is missing and broken. |
| Loops | No loop-simplify, LCSSA, rotation, indvars, SCEV, unswitch, deletion, or strength reduction. LICM/loopcse speculate loads; unroll runs after optimization; interchange/distribute are unverified or crash. | Severe. The loop substrate is effectively absent. |
| Memory/alias | Object-based no-alias AA; `isMustAlias` only identical IDs. DSE is single-block and conservative. No memcpy/memset/memmove idiom formation or runtime alias versioning. | Major. Field/GEP-sensitive AA and memory optimization are missing. |
| IPA/module | No module pass stage, call graph, bottom-up inline, IPSCCP, globalopt, globaldce, argpromotion, or attribute inference. Inline is function-local and currently wrong. | Absent. This is the largest architectural gap. |
| Vectorization | Loop-only elementwise/reduction vectorization with static divisible trip counts; no SLP, runtime checks, remainder loops, cost model, or runtime alias checks. | Narrow. Not comparable to `-O2`/`-O3` vectorization. |
| Tail calls | Accumulator-recursion transform only; emitter has a local call; `ret -> jmp` peephole. | Limited; no general tailcallelim. |
| Codegen | Excluded from this audit’s scope, but stack ordering, duplicate labels, and regalloc constraints cap optimizer value. | Separate but release-blocking. |

---

## 6. Native x86_64 codegen and register allocation

### 6.1 Bottom line

The native backend is not correctness-clean. At least eight independent P0 classes exist: constant operands, `icmp x,0`, spilled address operands, div/rem, shifts, compare clobbers, integer widths, and GEP scaling/indexing. Performance work should wait until these are fixed and a differential test harness is in place.

The x86_64 harness built temporary drivers and ran targeted IR through `irCompileAsm`, plus a variant that manually runs `irOptimize(..., 1)` first. No repository files were modified. Several wrong-answer/invalid-assembly cases were reproduced directly; the remaining items are code-inspection findings with exact locations.

### 6.2 Confirmed P0 defects

#### X-P0-1 — Constants are not materialized

Locations: `target/x86_64/x86_64_base.crl:2565`, `:2203`, `:1305-1311`.

`emitBinOp` passes constants through `getRegForValue`; `opFor` treats `ConstInt.valData` as an LSRA register index. For `5`, `intRegNameFor(5)` is `r8`; for `42`, it falls back to `rax`.

Observed for `%x = add i64 %v, 5`:

```asm
movq rcx, rax
addq r8, rax
```

`ret i64 42` emits no `movq $42, %rax` at all; `opFor(Const42)` returns `rax`, so `emitRet` suppresses the move. The same bug affects store, GEP indices, compares, and any generic ALU operand. Constants only work in call arguments and a few special isel patterns.

#### X-P0-2 — `icmp x, 0` is never materialized, yet branches use the undefined result

Locations: `x86_64_base.crl:2041`, `:2885`.

`iselTryFoldCmpZero` emits `testq src, src` and returns true without writing `dst`. `emitCondBr` then emits a second `testq` on the `ICmp` destination.

Observed:

```asm
movq (rcx), rax
testq rax, rax    # from the ICmp, flags discarded
testq rcx, rcx    # tests the alloca address, not the comparison
jne .Lyes
```

This miscompiles both value uses (`zext`, `select`, etc.) and direct branch uses.

#### X-P0-3 — A spilled pointer corrupts the instruction text

Locations: `x86_64_base.crl:1670`, `:1677`, `:1723`.

`addrFor` calls `opForReg`, which emits a reload line. `emitLoadWidth` and `emitStoreWidth` emit `\tmovq (` before calling it.

Observed under pressure:

```asm
movq (	movq -128(%rbp), r11
r11), r10
```

This is not assembler-valid. It occurs when an alloca/pointer result spills, which is common once pressure rises.

#### X-P0-4 — Div/rem clobber the divisor when it is allocated `rdx`

Locations: `x86_64_base.crl:2594`, `:2629`.

`emitDiv` and `emitRem` only move the divisor out of `rax`. `cqo` then destroys `rdx`.

Observed:

```asm
movq rsi, rax
addq rdx, rax
movq rax, %rax
cqo
idivq rdx
```

The divisor in `rdx` is overwritten before `idivq`. Unrelated live values in `rax`/`rdx`/`rcx` are also unmodeled clobbers.

#### X-P0-5 — Shift overwrites the count when the destination is `rcx`

Location: `x86_64_base.crl:2660`.

`emitShift` writes `src1` into `work`, then moves the count into `%rcx` if it is elsewhere. If `work == rcx`, the count is destroyed.

Observed:

```asm
movq rdx, rcx    # count in rcx
movq rax, %rcx   # dst=rcx overwrites count
shlq %cl, rcx
```

This computes `z << (z & 63)`, not `z << r`. It also clobbers unrelated live `rcx`.

#### X-P0-6 — ICmp/FCmp clobber `rax`/`rcx`

Locations: `x86_64_base.crl:2801`, `:2823`.

`emitICmp` unconditionally writes `setcc %al`; if `dst != rax`, any live `rax` is corrupted. `emitFCmp` uses `%al` and `%cl`. LSRA reserves only `rsp`/`rbp`/`r10`/`r11`, so `rax`/`rcx` are freely allocatable. This is the same family as G22 but broader than the documentation lists.

#### X-P0-7 — Integer widths are ignored

Location: `x86_64_base.crl:2565` and the ICmp emitter.

`emitBinOp` ignores its `lOp` argument and always emits `movq` plus the 64-bit operation; `emitICmp` always emits `cmpq`.

Observed for `i32`:

```asm
movl (rdx), edi
movl (rsi), eax
movq rdi, rcx
addq rax, rcx
testq rcx, rcx
```

An `i32` overflow into bit 32 changes subsequent 64-bit compares. `i8`/`i16` arithmetic has the same problem.

#### X-P0-8 — GEP uses the pointer width as the scale and does not fold constant indices

Location: `x86_64_base.crl:2768`.

`emitGep` derives scale from `ops[0]->type->width` (pointer width `64`), so the scale is always `8`, even for `i32`/`i8` arrays. Constant indices go through `opFor` and become registers.

Observed for `alloca array i32 4; gep %p, 1`:

```asm
leaq -16(%rbp), rax
movq rax, r10
movq rcx, r11        # constant 1 interpreted as register rcx
leaq (r10, r11, 8), rcx   # should be scale 4
```

### 6.3 Top x86_64 issues by impact/effort

| # | Finding | Class | Impact | Effort | First fix |
|---:|---|---|---|---|---|
| 1 | Constants not materialized | Correctness | Wrong results on nearly all constant uses | M | `loadImm` helper plus immediate ALU/store/ret forms |
| 2 | `icmp x,0` not materialized | Correctness | Wrong branches/values | S | Materialize `setcc`, or fuse predicate-aware compare+branch |
| 3 | Spilled address corrupts instruction | Correctness | Invalid asm in any spilling function | S | Make `addrFor` side-effect-free; reload before formatting |
| 4 | Div/rem `rdx` and fixed-reg clobbers | Correctness | Wrong answers/crashes | M | Fixed-register constraints or save/restore |
| 5 | Shift `rcx` destination/count clobber | Correctness | Wrong answers | S | Handle `dst == rcx`; constrain count |
| 6 | ICmp/FCmp `%al`/`%cl` clobbers | Correctness | Wrong values | M | Fixed-register constraints or safe scratch |
| 7 | Width-ignorant ALU/compare/shift/div | Correctness | `i32` overflow, `i8`/`i16` wrong | L | Thread type width through isel |
| 8 | GEP scale/constant index | Correctness | Wrong addresses | M | Use pointee element width; constant becomes displacement |
| 9 | Caller-save-only RA, no coalescing, graph no-op | Performance | Massive spills/copies | L | Callee-save allocation, splitting, coalescing; retire graph |
| 10 | ABI gaps: indirect calls, varargs, structs | Correctness/functionality | Missing/broken call forms | M | Indirect call `*reg`, `%al`, ABI classification |

### 6.4 Register allocation notes

- `wallvm.crl:401` sets `useCalleeSave=false`; `lsra.crl:672` therefore makes every call-spanning value spill.
- `lsra.crl:777` coalescing only lengthens intervals; it does not assign shared registers.
- `graph.crl:314-355` runs LSRA, recolors intervals, then writes nothing back to `valData`; it is a no-op at O3.
- One 16-byte slot per vreg, no packing/remat/splitting; only `xmm2`-`xmm7` are allocatable, so `xmm8`-`xmm15` are unused.
- Alloca results are normal vregs and spill like any value; a pressure test produced a 384-byte frame and spilled alloca pointers.
- Parser-created functions use `IrValueKind::Arg` (`irParser.crl:2174`), while LSRA only harvests `Inst`-kind parameter values (`lsra.crl:342-370`). Parser-built functions with parameters are therefore not seeded. ABI tests need either the IR builder or a temporary parser adjustment.

### 6.5 Other open ABI/codegen items

- Struct/vector returns likely need work: `emitRet` dereferences struct values as pointers (`x86_64_base.crl:1268`), and 16-byte struct `Load` uses `movq` only.
- Indirect calls have no register form in `emitCall` (`x86_64_base.crl:3398`); `%al` varargs count is only emitted for direct `Func` callees.
- Win64 register mapping (`X86_64_INT_REGS_WIN64`) looks consistent, but no Win64 assemble/link/run test had been performed at audit time.
- Generated text mixes bare register names (`rax`) with `%`-prefixed registers (`%rax`). Confirmed: clang/GAS does not treat bare `rax` as a register; it assembles as a symbol/memory operand, so constant ALU output writes address 0 instead of `%rax`. Normalize register operands before treating output as AT&T assembly.
- Coral compiler diagnostic gap: indexing a `str` as `r[i]` instead of `r.ptr[i]` is accepted without a diagnostic. `str` indexing should be rejected or lowered correctly, since this silently bypasses the intended pointer/index form. `x86_64_base.crl`'s `toReg32` contained this mistake and was corrected manually.
- Verified claims that do hold: G42 unsigned div/rem now selects `cqo` versus `xorl %edx,%edx` correctly; G44 two-phase parameter seeding is present; G34 tail-call logic is present; G22’s reserved-array off-by-one is fixed. Their line references have drifted.

### 6.6 Path to roughly `1.2x` gcc/clang `-O2`

The current backend is far from `1.2x`. After the correctness gate and register-allocation/instruction-selection work, `1.2x` on integer/pointer/control-flow code is plausible. Floating/vector code will likely need separate work.

**Phase 0 — correctness, 3-5 days.** Fix X-P0-1 through X-P0-8. Without this, benchmark results are meaningless. Add one regression test per shape: constant ALU/ret/store, `icmp x,0` branch/value, spilled pointer load/store, divisor in `rdx`, shift destination in `rcx`, `i32` overflow compare, `i32[]` GEP.

**Phase 1 — register allocation, 1-2 weeks.** Enable callee-saved registers, split live ranges at calls, implement real copy coalescing, rematerialize constants and alloca addresses, pack spill slots by width, use `xmm8`-`xmm15`, and either repair or delete `graph.crl`. This is likely the largest single performance gain on call-heavy/spill-heavy code.

**Phase 2 — instruction selection, 1-2 weeks.** Immediate ALU forms, 32-bit mnemonics, GEP displacement folding, load-op/store-op memory operands, compare+branch fusion, `cmov` select, xor-zeroing, and magic constant division. This closes most instruction-count gaps.

**Phase 3 — layout and ABI, about 1 week.** Block layout/fallthrough, branch inversion, broader tail calls, indirect calls, varargs `%al`, struct/vector returns, and Win64 end-to-end validation.

**Measurement:** build a differential corpus covering integer, pointer, branch, call, array/struct, and divide code; compare assemble/link/run output against gcc/clang `-O2`; also track code size.

### 6.7 Recommended immediate x86_64 patch order

1. Constant materialization.
2. Remove or fix the flag-only `cmp x,0` path.
3. Fix `addrFor`/load-store emission.
4. Fix div/rem and shift fixed-register clobbers.
5. Fix ICmp/FCmp clobbers.
6. Make ALU/compare/shift/div width-aware.
7. Fix GEP scale and constant-index folding.
8. Then proceed to register allocation and instruction selection.

---

## 7. Severity, production safety, and top actions

### 7.1 Severity definitions

- **P0:** memory corruption, crash, or wrong-code on ordinary input.
- **P1:** invalid IR/compile failure on less common shapes, or a major missed optimization.
- **P2:** dead code, leaks, or documentation problems.

### 7.2 Safety by optimization level

- **L0/O0:** `validate -> simplify -> constfold -> sccp -> dce -> validate`; exposed to SCCP phi/CFG corruption.
- **L1/O1:** adds more scalar/CFG passes, but still exposed to SCCP and CFG/phi bugs; frontend phis remain unlowered for the x86_64 emitter.
- **L2/O2:** adds `mem2reg` use-after-free and broken inline.
- **L3/O3:** adds `stack_layout` use-before-def, `select_to_branch`, `loop_distribute`, and duplicate-label failures.

**No optimization level is production-safe today.** SCCP is in L0, so even O0/O1 are exposed to phi/CFG corruption. O2 adds the `mem2reg` UAF and inline bugs. O3 adds the stack-ordering, select-to-branch, loop-distribute, and duplicate-label failures.

### 7.3 Top optimizer actions, prioritized

1. **P0 — Fix `mem2reg` memory safety.** Remove the `inLoop` double-free/UAF and make loop promotion all-or-nothing.
2. **P0 — Fix `select_to_branch`.** Allocate terminator operands, enforce `capOps`, rewrite users, successor phis, preds, and succs; otherwise disable it.
3. **P0 — Fix `inline`.** Map `IrFunc::args` instead of entry instructions, stop skipping real instructions, make continuation phis correct, and use globally unique block labels.
4. **P0 — Fix `stack_layout` and `lower_phis`.** Preserve alloca def-before-use and never insert phi allocas after a terminator; add dominance checking to the validator.
5. **P0 — Fix SCCP.** Remove phi pairs when folding edges, recompute/clean unreachable blocks, and never deallocate values used by live phis.
6. **P0 — Fix or disable unsafe loop hoisting.** LICM/loopcse must require dereferenceability and domination of all exits for loads; fix preheader naming.
7. **P0 — Fix memory forwarding.** `machine_opt` must use dominance-aware MemorySSA; GVN must invalidate on atomics, fences, and GC barriers.
8. **P0 — Fix CFG/phi passes.** `jump_thread`, `tail_dup`, `branch_factoring`, and `sel2br` must update preds/succs/phis atomically; remove dead `branch_inversion_flat`.
9. **P0/P1 — Fix O3 crash/label paths.** `loop_distribute` zero-capacity operand writes, all `createBlock(null)` sites, and function-global label uniquing (`preheader`, `after_inline`, `cont_inline`, `acc_loop`, `sel2br`).
10. **P1/P2 — Build the missing infrastructure.** Hard-fail validation, true mutation flags, real DCE/ADCE, simplifycfg, safe mem2reg/SROA, reassociation/PRE, loop canonicalization/indvars/SCEV, then module/IPA and vectorization. Update docs/tests last.

The backend P0s in §6 must be treated as a parallel release gate: fixing the optimizer without fixing x86_64 constants, parameters, and spills still leaves ordinary programs miscompiled.

---

## 8. Wasm32, PE, assembler, and linker evidence

### 8.1 Wasm32

- wasm32 is semantically the best backend in these tests. No-opt WAT is correct for `ret 42`, parameter passing, phi, `1+2`, constant stores, and `f64` constants. It emits parameters directly, materializes constants, and lowers phi via pc/select.
- wasm32 is still WAT-only: `irCompile` returns success but discards output. `compile2` on the phi fixture fails with `terminator reached the generic dispatcher`; `compile3` returns success with no artifact.

### 8.2 PE

- PE is validated under Wine:
  - PE executable with `mov $42,%eax; ret` exits `42`.
  - PE executable linked with a short import library calls `ExitProcess(42)` and exits `42`; the import directory is emitted correctly.
  - PE DLL exporting `get42` loads via `LoadLibraryA`/`GetProcAddress` and returns `42`.
- PE import caveat: short import libraries work (`llvm-dlltool`), but GNU/Wine-style `libkernel32.a` is treated as ordinary COFF objects, producing no import directory and a runtime fault.

### 8.3 Assembler and linker positives and limits

- Static ELF, shared ELF plus dynamic executables, static archives, PE exe/DLL, COFF input, and short import libraries all work.
- ELF output still needs `chmod +x`.
- TLS is rejected.
- 32-bit PE is not exposed by `linktool`.
- Linker/assembler are the strongest production pieces and should be preserved; they are outside the edit scope of the upper-pipeline phase.

### 8.4 Native x86_64 blockers

Native x86_64 remains blocked by:

- constants decoded as register indices;
- `IrValueKind::Arg` parameters never seeded;
- `lower_phis` inserting an alloca after the terminator;
- duplicate epilogue;
- bare-register syntax against AT&T;
- data section never flushed;
- silent success for unsupported targets.

The earlier segfault report is retracted: no-opt main/float are not reproducibly crashing after the harness rebuild.

### 8.5 Maturity snapshot

| Area | Assessment |
|---|---|
| Assembler | Strong: GNU/MSVC asm, COFF, ELF/PE object paths; syntax tolerance is broad. |
| Linker | Strong: static/shared ELF, dynamic exe, archives, PE exe/DLL, COFF, short import libs. Limits: TLS, 32-bit PE exposure, executable bit. |
| wasm32 | Best semantic correctness in tested cases; WAT-only and missing an artifact sink. |
| x86_64 | Not correctness-clean; basic IR miscompiles; performance also limited by spills and ABI gaps. |
| x86-32 / Win64 | Incomplete/unwired; i386 ABI lowering is not wired; no Win64 end-to-end test. |
| IR/parser/passes | Broad inventory; parser/IR contract is substantial; multiple P0 pass bugs and dead/ineffective passes. |
| Integration | Incomplete: no end-to-end default path, no differential harness, no fatal validation. |

### 8.6 Must-fix before WallVM becomes the default

1. Add a real artifact/sink path and `buildModule`; stop discarding `irCompile` output.
2. Materialize `ConstInt` generally in `opFor`/store/binop/ret paths.
3. Fix parameter seeding to recognize `IrValueKind::Arg` or create the expected entry stores.
4. Emit exactly one epilogue and balance callee-save pushes/pops.
5. Fix `irLowerPhis` insertion and fail closed on unsupported opcodes/backends.
6. Emit valid AT&T syntax consistently and make target dispatch reject/conform correctly.
7. Flush the data section; add `.rodata`/constant-pool support.
8. Add golden IR/asm tests plus differential tests against the C backend.

### 8.7 Adoption recommendation

Keep the C backend default. Add WallVM behind an opt-in flag and promote target by target:

1. wasm32 first for semantic coverage;
2. x86_64 after the blockers above;
3. C-vs-WallVM differential testing, parser/pass fuzzing, and self-hosting only after correctness is stable.

Preserve the linker/assembler and the wasm emitter. Do not preserve the native emitter’s current constant/parameter/epilogue behavior.

---

## 9. Stale or incorrect documentation

Line references can drift; treat the listed locations as audit-time anchors.

### 9.1 `docs/optimization-landscape.md`

- `:70`, `:77-79` still say `simd_vec` score 1 and “does no loop-level vectorization”; §6 says it was reworked to score 4, and the current code is a real loop vectorizer. The table/headline are stale.
- `:194` says `branch_inversion` is wired L1-L3; L2 omits it. It is L1/L3 only.
- `:201-205` says `jump_thread` does not check other predecessors; current code has the `npreds == 1` guard. The remaining phi/empty-target bugs are different.
- `:311-316` and table line 67 still describe the old `stack_layout` overflow/double-parenting; G43 fixed that, but the current code has a new alloca-ordering bug.
- `:164-167` says `lex_canon` leaves “stale use lists”; actual behavior is discarded/leaked rebuilt instructions, and `createInst` does not add users.
- `:259-260` says LICM “builds/reuses preheaders”; `createPreheader` never reuses and always names the block `preheader`.
- `:180-185` describes `select_to_branch` as CFG churn only; it misses the null-operand crash, `ops[3]` OOB, and successor-phi bugs.
- `:304-310` says only SysV ABI lowering is imported and Win64 is referenced nowhere; `wallvm.crl:59` imports the Windows pass and `abiLowerPassFor` selects it. Only i386 remains unwired.
- The score table at `:29-42` overstates `sccp`, `dce`, `adce`, `inline`, and `validate`; `adce` is not ADCE, SCCP corrupts phis/CFG, inline is broken, and validate is a diagnostic that reports “changed.”

### 9.2 `docs/pipeline-gaps.md`

`pipeline-gaps.md` is generally more accurate, but:

- A13 “FIXED” covers only the specific nameless-block/multi-pred subclaims; `select_to_branch` is still broken and `jump_thread` still mishandles phis.
- G43 fixed the old overflow but does not mention the new ordering bug.
- Many line references are stale: `wallvm.crl:406/285/158/170/195/227/295/477`, `mem2reg.crl:494/506/517`, `validate.crl:286/247`, etc.
- `:327` says the G21 spill contract “works end-to-end”; frame/decode exists, but spilled address operands emit invalid nested instructions.
- `:414-429` G22 clobber is half real: correct, but incomplete. Add divisor-in-`rdx` and shift-dest-in-`rcx` cases.
- `:551` says `cond_br` is “naive”; for `icmp x,0` it is a miscompile, not just extra instructions.

### 9.3 `docs/codegen-quality.md`

- `:147` — “immediates for ALU ops exist” is false for generic ALU; constants map to register indices. Only special isel patterns/call args work.
- `:137` — “test vs cmp $0 good” is not good: `iselTryFoldCmpZero` never writes `dst`; branches re-test the undefined result.
- `:133` — GEP scale “derived from operand type” is false: `emitGep` uses pointer width, so scale is `8` always; non-8-byte elements are wrong.
- `:135` — store constant “copies constant into a register first” is false: it does not copy; `opFor(ConstInt)` treats the literal as a register index.
- `:150` — “three-operand `imulq`” is a minor wording error; the fallback is two-operand through `emitBinOp`.
- Tail-call row versus Section 3 item 9 is contradictory: the table says fixed, the item says regressed/removed. The code has `tailShapeOk`; the fix is present but limited to frameless direct register-arg calls.

Verified claims that still hold: G42 unsigned div/rem now selects `cqo` versus `xorl %edx,%edx` correctly; G44 two-phase parameter seeding is present; G34 tail-call logic is present; G22’s reserved-array off-by-one is fixed. Their line references have drifted.

---

## 10. Quality score and realistic path

### 10.1 Current score

**About 30/100 as an `-O2`-class optimizer.**

| Dimension | Rough score |
|---|---:|
| Scalar local simplification/canonicalization | 55-65/100 |
| CFG | 20-25/100 |
| Loop optimization | 20-25/100 |
| Interprocedural | 5-10/100 |
| Vectorization | 10-15/100 |
| Correctness/robustness | 10/100 |

The local scalar passes are real, but the CFG/loop/IPA layers are not production-grade, and several P0 bugs make benchmarking misleading.

### 10.2 Realistic staged path

1. **Correctness foundation, 2-4 weeks.** Fatal validator, true change tracking, unique block naming, CFG/pred/phi utilities, fix the P0 memory/CFG bugs. Goal: O0-O3 compile every function reliably. In parallel, fix the x86_64 P0 gate.
2. **Scalar O2 core, 2-4 months.** Safe mem2reg/SROA, simplifycfg, instcombine-like canonicalization, reassociation, real DCE/ADCE, dominance-aware GVN/PRE, jump threading/tail merging.
3. **Interprocedural layer, 2-3 months.** Correct inline with call graph/bottom-up ordering, IPSCCP, globalopt, globaldce, argpromotion, attribute inference.
4. **Loop infrastructure, 2-4 months.** LoopInfo, LoopSimplify, LCSSA, rotation, indvars/SCEV, safe LICM, unswitch/deletion, unroll, idiom formation.
5. **Vectorization, 3-6 months.** Loop vectorizer with runtime trip-count checks, remainder loops, alias versioning, cost model, then SLP.
6. **Codegen quality, parallel.** Block placement/branch relaxation, regalloc constraints, scheduling, spill quality.

**Rough effort:** 12-18 engineer-months for credible scalar `-O2`-like quality on common code; 2-3 engineer-years for broad `-O2` parity, with O3/vector parity longer. This is not a weeks-scale cleanup.

The ordering is deliberate: correctness/fatal validation first, then CFG and scalar fixpoint, then interprocedural, then loops, then vectorization. Building ILP/vector passes before fixing CFG and memory semantics would amplify wrong-code risk rather than improve performance.

---

## 11. Verification and immediate next steps

### 11.1 Mandatory regression coverage

Add targeted tests before or with each P0 fix:

- optimizer: loop alloca, folded conditional branch with phis, multi-predecessor jump threading, tail duplication, select-to-branch, stack layout with entry alloca uses, preheader labels, unnamed blocks, atomic/fence load CSE, trapping-load hoist;
- x86_64: constant ALU/ret/store, `icmp x,0` branch/value, spilled pointer load/store, divisor in `rdx`, shift destination in `rcx`, `i32` overflow compare, `i32[]` GEP;
- driver: validation failure must stop compilation, not be discarded;
- parser: round-trip inline/compiler-generated IR against `/home/cerie/Documents/Mu/Mu_docs/IR.md`, including parameters, phis, metadata, and aggregate GEPs;
- ABI/integration: direct/indirect calls, varargs, struct/vector returns, Linux SysV, Win64, wasm32.

### 11.2 Differential harness

Build a C-vs-WallVM differential corpus (integer, pointer, branch, call, array/struct, divide, floats/vectors where supported). Compare assemble/link/run behavior under sanitizers where possible, plus code size. Do not benchmark until the correctness gate is green.

### 11.3 Recommended program order

1. Fix optimizer memory-safety and wrong-code P0s; make validation fatal; add unique block naming and CFG/phi utilities.
2. Fix x86_64 P0s and add the per-shape regression tests.
3. Fix or disable `select_to_branch`, unsafe hoisting, and unsafe forwarding until their invariants are testable.
4. Add simplifycfg, real DCE/ADCE, safe mem2reg/SROA, reassociation/PRE.
5. Add the module/IPA layer and a bottom-up inline.
6. Add loop canonicalization/indvars/SCEV and safe loop transforms.
7. Add vectorization with real runtime checks and cost modeling.
8. Keep the C backend default behind an opt-in WallVM flag until differential, ABI, and fuzz gates pass.

The immediate x86_64 patch order remains: constants, `cmp x,0`, `addrFor`, div/rem/shift/compare constraints, widths, GEP.

---

## 12. Key source map

| Path | Role |
|---|---|
| `wallvm.crl` | Optimization driver, level/lane selection, iteration, structure lane, ABI pass selection, `irCompile`. |
| `passes/mem2reg.crl` | Alloca promotion; P0 UAF/double-free. |
| `passes/select_to_branch.crl` | Select-to-CFG lowering; P0 crash/OOB/phi issues. |
| `passes/inline.crl` | Function-local inliner; wrong argument/block mapping. |
| `passes/stack_layout.crl` | Entry alloca layout; def-before-use violation. |
| `passes/lower_phis.crl` | Phi lowering; allocas after terminators. |
| `passes/sccp.crl` | Sparse conditional constant propagation; phi/CFG corruption. |
| `passes/licm.crl`, `passes/loopcse.crl` | Loop hoisting; unsafe load speculation, preheader naming. |
| `passes/machine_opt.crl`, `passes/memory_ssa.crl`, `passes/gvn.crl` | Memory forwarding/CSE; dominance and barrier gaps. |
| `passes/jump_thread.crl`, `passes/tail_dup.crl` | CFG/phi rewrites; invariant violations. |
| `passes/loop_distribute.crl` | Loop distribution; zero-capacity operand writes, labels. |
| `passes/sroa.crl`, `passes/simd_vec.crl` | `Noret` misuse and cleanup risks. |
| `passes/dce.crl` | DCE/unreachable cleanup; stale preds/phis; `adce` is not real ADCE. |
| `passes/validate.crl` | Structural validator; no dominance check, true-changed contract. |
| `target/x86_64/x86_64_base.crl` | Native x86_64 isel/emission; P0 constant/width/GEP/fixed-register issues. |
| `target/x86_64/linux/linux.crl`, `target/x86_64/windows/windows.crl` | Target-specific emission and ABI lowering. |
| `regalloc/lsra.crl`, `regalloc/graph.crl` | Register allocation; caller-save-only, no-op graph path, Arg seeding gap. |
| `text/irParser.crl`, `text/irPrinter.crl` | IR text contract, parser fixups, printer; parser-created `Arg` integration. |
| `base/irBuilder.crl`, `base/irtypes.crl` | IR construction and type/value model. |
| `target/wasm/` | wasm32 WAT emitter; best semantics, missing artifact sink. |
| `assembly/x86/x86_64.crl` | Assembler; strong GNU/MSVC/COFF tolerance. |
| `linker/x86/` | Linker; strong ELF/PE/archive support, known limits. |
| `/home/cerie/Documents/Mu/Mu_docs/IR.md` | Canonical IR model and text format. |
| `/tmp/wvm_driver.crl`, `/tmp/wvm_driver_o.crl` | Temporary x86_64 audit drivers; not part of the repository. |

---

## 13. Bottom line

Do not treat this as a usable `-O2` pipeline yet. Fix the P0s and make validation fatal first; then build CFG, scalar, IPA, and loop infrastructure in that order. Keep the C backend as the default, preserve the assembler/linker and wasm emitter, and make WallVM opt-in target by target with differential, ABI, and fuzz gates. The local scalar work is worth keeping, but it is sitting on CFG, loop, and IPA layers that are not production-grade.

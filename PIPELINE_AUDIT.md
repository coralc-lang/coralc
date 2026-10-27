# Wallvm Upper-Pipeline & Vectorizer Audit — Issue Register

Consolidated from five parallel audits (branch/CFG, loop, SSA/canonical,
memory/analysis, transform/vectorizer) plus empirical repros (crafted .ir,
`WALLVM_PRINT_AFTER_PASS`, gdb, valgrind, ASAN). Every entry starts **OPEN**
and must be *verified against the actual code* before being fixed — an entry
is only marked FIXED after rebuild + `test/wallvm/run.sh` (target 88/88) is
green, or INVALID with a reason.

Status legend: `OPEN` → `VERIFIED` (issue confirmed real) → `FIXED` /
`INVALID` (not real, say why) / `DEFERRED` (real but parked, with reason).

## Already fixed earlier this session (regression baseline)

| ID | Issue | Where |
|----|-------|-------|
| P0-1 | mem2reg stale rename-stack entries → dangling phi values | mem2reg.crl (retarget across all stacks) |
| P0-2 | SCCP `handleTerminator` skipped on `Top` cells → edge viability lost | sccp.crl (~1007) |
| P0-3 | simd_vec block-scoped `aa` use-after-scope → heap corruption (`%missing`, segfault) | simd_vec.crl (aaOwned at fn scope) |
| P0-4 | tail_dup missing `dest->removePred(gutted)` ×3 → phi-vs-npreds validate errors | tail_dup.crl |
| P0-5 | Emitter never removed `jmp` to the next block / fallthrough cond_br edges | x86_64_base.crl (`blockFallsThrough`) |
| P0-6 | SCCP `getCell` returned meet-neutral `Bottom` for Arg/Global/aggregates → param-derived phi contributions silently dropped (`phi [0,entry],[x,backedge]` folded to 0) | sccp.crl (only Inst reads `cells[]`) |
| P0-7 | lsra liveness walks skipped `IrValueKind::Arg` uses → param interval `[0,0] uses=0`, never `spansCall`, assigned caller-saved reg → clobbered across calls (O0/O1 miscompile) | lsra.crl (3 walks allow Inst‖Arg; coalescing sites untouched) |
| P0-8 | `getRegName` rejected non-Inst → Args mapped to "" → `funcUsesReg("rbx")` missed param's callee-saved home → rbx never pushed, recursive calls clobber caller rbx | x86_64_base.crl (Inst‖Arg) |
| P0-9 | `valueIsSpill` rejected non-Inst → spilled **Arg** (lsra sets the spill bit on Arg valData) took the direct staging-commit path → `movq mem, mem` in the prologue → assembler error whenever an Arg spills | x86_64_base.crl (`valueIsSpill` Inst‖Arg) |

---

## A. Branch / CFG passes

| ID | Sev | Location | Issue | Status |
|----|-----|----------|-------|--------|
| A1 | Critical | branch_factoring.crl:67-94 | "collapse case 1" checks the wrong edge: `bb: cond_br d,A,B`, A tests `!d` ⇒ A always takes its *false* edge, but code checks A's *true* edge and rewrites `cond_br → br falseTgt` — straight miscompile. Asymmetric proof: false-target section (124-153) checks only `ftTrue==trueTgt`, and the correct case `ttFalse==falseTgt` exists at :96. | OPEN |
| A2 | Critical | branchprop.crl:85-98 | Region criterion `dominates(taken,b2) && !dominates(other,b2)` ≠ "v==cst on all paths": F side reaching T side poisons the region (counterexample: `entry: cond_br, T,F; T: br M; F: br T`). Rewrites value at :134/:152 and phi pairs at :125-137. Needs reachability, not dominance. | OPEN |
| A3 | Critical | range.crl:617-656 | Records *every* non-ownCond ICmp in a block as an unconditional range fact. `%c1=icmp sge v,100` need not be true; folds sibling `%c2` wrongly (guard also defeated by a `not()` wrapper around the icmp). | OPEN |
| A4 | High | range.crl:658-687 | "propagate ranges through dominators" — **unimplemented**: `blockRanges[bi]` only holds same-block icmps; `tryFoldByRange(func,bi)` params unused. Pass's stated purpose missing (and A3 makes what remains dangerous). | OPEN |
| A5 | High | branch_factoring.crl:88-90,112-114,145-147,219-221 | Deletes edges without `removePhiEdge` — target's phi keeps `(value,bb)` pair while preds shrink → validate phi-vs-npreds failure (same class as P0-4). | OPEN |
| A6 | Med-High | jump_thread.crl:100-106 | Pattern 1 moves target's phi into bb: (a) `replacePhiBlock` scans bb while phi still in target (no-op), (b) moved phi keeps pair naming bb itself (self-pred, invalid), (c) inserted after non-phis → invalid layout. Should RAUW the single-incoming phi instead. | OPEN |
| A7 | Medium | branch_inversion.crl:25-26,68,107 | Whole `branch_inv_flat` pass dead: requires two CondBr terminators in one block (invalid IR, validator-rejected), so ICmp/FCmp folds unreachable; FCmp switch also omits 6 `U*` predicates. Pipeline slot is a no-op. | OPEN |
| A8 | Medium | jump_thread.crl:147-166 | `cond_br c, X, X` → both succ entries skipped ⇒ nsuccs=2 under new `Br` (validate fail); two phi pairs naming bb not merged; `if (notTaken != taken)` skips phi cleanup entirely. | OPEN |
| A9 | Medium | branch_factoring.crl:158-231 | `factorCommonGuards` requires last inst of successors to be ICmp (non-terminator) → dead on valid IR; header comment advertises guard-extraction that doesn't exist. | OPEN |
| A10 | Low-Med | range.crl:922-1092,719-790 | Signed/unsigned bounds conflated in one i64 path; `(i64)valData` wraps u64 ≥ 2^63 → wrong folds near the top of the range. | OPEN |
| A11 | Low | jump_thread.crl:154 | `taken->base.addUser(term)` duplicates the existing user entry (operand slot kept, never removed). | OPEN |
| A12 | Low | jump_thread.crl:110-119 | Gutted target's dead `Br` never erased; still in `finalTarget` users; `target->insts` still points at moved instructions. | OPEN |
| A13 | Low | branchprop.crl:138-160 | One `removeUser`/`addUser` per instruction though the value may occur twice in ops (`add v,v`) → user-count imbalance. | OPEN |
| A14 | Low | range.crl:849-876,719 | `addConstraint` overwrites bounds instead of intersecting (`v<8` then `v<10` loses tight bound). | OPEN |
| A15 | Low | select_to_branch.crl:83-86 | `hasSideEffects(value)` gate doesn't do what comment claims — values are computed eagerly before select, conversion doesn't condition them. Transform itself sound. | OPEN |
| A16 | Low | jump_thread.crl:56-61,113 | `removeBlock(func,block,at)` helper dead+broken (`if (at < nblocks) return`); forward loop skips a block after `func->removeBlock` (missed opt only). | OPEN |
| A17 | Low | jump_thread.crl:5-7 | Header comment claims dead-block removal; Pattern 2 leaves orphaned `notTaken` block with npreds=0. | OPEN |

## B. Loop passes

| ID | Sev | Location | Issue | Status |
|----|-----|----------|-------|--------|
| B1a | Critical | loop_distribute.crl:361-369 | Header-erase loop erases non-phi non-terminator insts *including the ICmp feeding the header CondBr* (never seeded into partitions) — `erase` doesn't repair users ⇒ terminator operand dangles (UAF for validate/next pass). | OPEN |
| B1b | Critical | loop_distribute.crl:390-399,463-465 | Latch orphaned: header's in-loop arm retargeted to `newBlocks[0]`, partitions loop back to header; original latch never reached ⇒ induction phi never advances → infinite loop. | OPEN |
| B1c | Critical | loop_distribute.crl:414-460 | Header phis never rewritten for rewired entry edges (old pred pair stays, `newBlocks[n-1]` pred has no pair) → validate failure + wrong values. | OPEN |
| B1d | High | loop_distribute.crl:480,486-536 | `aa` parameter accepted, never read; partitioning = "one partition per store", no dependence check — aliasing stores sequentially reordered across a load (violates the file's own safety claim). | OPEN |
| B1e | High | loop_distribute.crl:382-399,437-452 | Both-arms-in-loop (or both-to-header) CondBr retargeted but `addSucc` once ⇒ nsuccs=1 behind a 2-target CondBr. | OPEN |
| B2a | Critical | loop_interchange.crl:301-324 | "Interchange" swaps the two increments' phi operands with **no CFG change** — inner backedge becomes `outer_iv+step` → infinite/zero-trip inner loop. **Empirically confirmed**: instrumentation showed `canInterchange=true` ×8 + `interchange DONE` ×2 on `cases/loop_swap.ir` (first CondBr-block ICmp is a param compare → ivdep check passes), producing validate errors + non-assembling output. | FIXED (`interchangeLoops` bails before any mutation; `cases/loop_swap.ir` expect 36) |
| B2b | Medium | loop_interchange.crl:277-299 | Initial-value swap dead: keyed on `IrLoop.preheader`, which detector inits null and this pass never creates. | INVALID — dead code (preheader always null); unreachable now that B2a disables the pass |
| B2c | Low | loop_interchange.crl:326-329 | "Header swap" mutates only analysis structs (freed at :108) — no IR effect. | INVALID — no IR effect by definition; unreachable now |
| B2d | Medium | loop_interchange.crl:113-122,181-194,215-234 | Naive legality: `findLoopCompare` = first compare in loop (not the exit test); dependence check only direct; `isLoopContained` header-only ⇒ multi-latch loops misread as nested. | OPEN |
| B3a | High | licm.crl:188-226,363 | Speculatively hoists potentially-trapping `SDiv/UDiv/SRem/URem` into preheader → executes on zero-trip loops; div-by-zero trap newly reachable. | OPEN |
| B3b | Medium | licm.crl:195,239-254,352-362,383-404 | Load hoisting is dead code (`isLoopInvariant` returns false for Load) — the entire alias-guard machinery below is unreachable. | OPEN |
| B3c | Low | licm.crl:248,394-400 | (Latent, in dead code) `AtomicStore` counted as write but `loadMayAliasLoopStore` misses `AtomicRmw/AtomicCmpXchg`. | OPEN |
| B3d | Medium | licm.crl:66-77,80-82,104-115 | `CondBr(cond, header, header)` double edge: both arms retargeted but one edge pair left; single-ext-pred phi path fixes only first matching pair. | OPEN |
| B4a | High | unroll.crl:673-690 | Teardown removes *other* blocks' entries but never decrements `b->npreds/nsuccs`, then gates `removeBlock` on those counts ⇒ originals never removed (dead code + validate inconsistency). | OPEN |
| B4b | High | unroll.crl:597-602,666-668 | Exit preds double-counted: clone edges auto-add preds via `addSucc`, then exit-phi maintenance adds all k clones again ⇒ npreds=2k vs k phi pairs. | OPEN |
| B4c | Info | wallvm.crl:79,380; drivers | Unroll wired but `gUnrollEnabled=false` everywhere; no CLI flag (`--funroll` parsed nowhere) — pass dead in production; B4a/B4b latent until enabled. | OPEN |
| B5 | Medium | loopcse.crl:79-83,103,36-37 | Pass is a no-op: `isHoistableLoad` always false ⇒ preheader never created ⇒ `dedupeBlock` gate (`lp->preheader != null`) never true. Occupies L2/L3 slot. | OPEN |
| B6a | Medium | loop_detect.crl:34-98; licm.crl:27,55,80-82 | Multi-latch loops emitted as separate overlapping `IrLoop`s (one per header/latch); licm treats sibling latch as external pred and rewires its backedge through the new preheader. Consumers never re-detect. | OPEN |
| B6b | Medium | loop_detect.crl:35 | Self-loops (`header==latch`) skipped — invisible to all consumers despite unroll comments claiming latch-test targets. | OPEN |
| B6c | Low | all loop consumers | `IrLoop` structs + `blocks` arrays leaked per run (only outer pointer array freed). | OPEN |

## C. SSA / canonicalization

| ID | Sev | Location | Issue | Status |
|----|-----|----------|-------|--------|
| C1 | Critical | involution.crl:116-129 | `fabs(fneg(x))` RAUWs with `x` — comment says `fabs(x)`; for x=-3 result -3 instead of 3. O1-O3 unconditional. | OPEN |
| C2 | Critical | involution.crl:153-170 | `fptrunc(fpext(x))` identity compares `outW == fpext-output-width` — whenever it fires, replacement operand is narrower than result → type-corrupt uses. (Correct form in constfold.crl:105-118.) | OPEN |
| C3 | Critical | cast_elim.crl:54-65 | Identity cast null-out without `replaceAllUses`/`removeUser` → users dangle at orphaned inst (never freed = leak + UAF). | OPEN |
| C4 | Critical | cast_elim.crl:74-89,139-153; constfold.crl:88-103 | fp↔int round-trip "identities" keep the *outer* opcode fed an operand of the wrong type (`sitofp(fptosi(f64))` type-inconsistent; `sitofp(fptosi(1.5))=1.0≠1.5`) — no fast-math gate exists anywhere. | OPEN |
| C5 | High | sccp.crl:960,1068,1202-1208 | Phase-2 `cells[inst->base.id]` — replacement `Br` created at :1068 has id > maxId ⇒ heap OOB read every cond_br fold. | OPEN |
| C6 | High | mem2reg.crl:451-454,510 | Pre-existing `Phi` users of the alloca treated as "placed by us" (check runs before placePhis) → alloca erased while phi operand still points at it (UAF). | OPEN |
| C7 | High | mem2reg.crl:372-384 | Phi update `break`s after first pair for `bb` — parallel edges (`cond_br c,X,X` / dup preds) leave second pair = const placeholder (wrong value). | OPEN |
| C8 | High | idempotent.crl:64-96,111-132 | Store patterns unreachable: walk `break`s on any Store *before* the store-matching code that can therefore never run — pass's primary purpose dead. | OPEN |
| C9 | Medium | idempotent.crl:136-149 | Bitcast-chain collapse has no type/width check → uses see inner source type instead of outer result type (contrast cast_elim Pattern 10 which rewires operand and keeps outer type). | OPEN |
| C10 | Medium | mem2reg.crl:521 | Returns `true` unconditionally when `nAllocas>0` even with zero promotions ⇒ every address-taken alloca forces all 8 fixpoint iterations. | OPEN |
| C11 | Medium | mem2reg.crl:352-361,494-511 | Unreachable blocks never renamed (domtree children only) but alloca erased anyway → surviving loads in unreachable blocks dangle. | OPEN |
| C12 | Medium | sccp.crl:1172-1199,1241-1244 | Drops unreachable blocks without `removePred` on surviving blocks' preds (phi pairs are removed) → stale preds feed next-iteration mem2reg/placePhis. | OPEN |
| C13 | Medium | idiom.crl:143-182 | `fadd(fmul)→fma` with no fast-math/contract gate (single vs double rounding) — unconditional O1+. | OPEN |
| C14 | Medium | lex_canon.crl:59-181,198-214 | `flattenSortChain` result discarded: builds a full sorted chain of new insts never inserted/wired/freed (leak), returns `changed=true` even when no swap happens (false fixpoint trigger); `ConstFloat` sort key constant → floats never ordered; only 2-op roots sorted. | OPEN |
| C15 | Medium | comm_canon.crl:71-82; irOps.crl:300-308; cse.crl:146 | `FAdd/FMul`, `VecAdd/VecMul/VecFAdd/VecFMul/VecMin/VecMax`, `ICmp Eq/Ne` missing from commutative sets → comm_canon float branch dead, CSE misses commuted forms. | OPEN |
| C16 | Low-Med | sccp.crl:1058 | Phase-2 uses raw `cells[term->ops[0]->id]` instead of `getCell` → literal `ConstInt` conditions never folded to `br`. | OPEN |
| C17 | Low-Med | sccp.crl:842,847,878,924,975-977 | Worklist silently truncates at `wlCap` (informal bound) — dropped entry = missed edge (the bug class P0-2). No assert/growth. | OPEN |
| C18 | Low | dce.crl:190-212,232-234 | ADCE has no control dependence (every terminator live) ⇒ degenerates to plain DCE; permanently clobbers `valData` as scratch. | OPEN |
| C19 | Low | cse.crl:35-126 | Intra-block O(n²); missing `Fma/Gep/ExtractValue/InsertValue/Vec*/commuted Eq-Ne`; invalidation on Call only. | OPEN |
| C20 | Low | constfold.crl:64-159,405-464 | No ICmp/FCmp const-const fold; `foldUnary` lacks Trunc/Zext/Sext; FDiv-by-0.0 inf inconsistent with SCCP's bail. | OPEN |
| C21 | Low | algebraic.crl:110-311 | Sparse b-const-only identities (missing `x+0`, `x-x`, `x^x`, `x|0`, `x*1`, `shl 0`, `sdiv -1`…); `lshr(shl)` rules dead (`outW>inW` never true in typed IR); duplicate `x*2` shadows pow2 rule. | OPEN |
| C22 | Low | idiom.crl:394-398 | `matchAbs` only `icmp ??(x,0)` — constant-in-ops[0] forms never match. | OPEN |
| C23 | Low | mem2reg.crl:110-152 | DF computation O(n³) with linear id lookups; missing id mid-walk keeps stale idom silently. | OPEN |
| C24 | Low | sroa.crl:26,84-90,121-148 | Not real SROA (single-store RVO), 16-load hard cap, O(n³) rewrites. | OPEN |

## D. Memory / analysis passes

| ID | Sev | Location | Issue | Status |
|----|-----|----------|-------|--------|
| D1 | Critical | memory_ssa.crl:258-319; machine_opt.crl:105-121,188-212,245-267 | MemorySSA versions chained by *block array order* not CFG edges; machine_opt Pass 1 forwards with **no dominance check** (`isStoreKilledBy` scans only killer's block) → forwards a value not on the load's path (loop + single-pred shape). Pass 3 scans only *dominating* blocks, misses non-dominating side-path stores (and ignores `AtomicStore`). | OPEN |
| D2 | Critical | dse.crl:101-127 | Kills a wider store with a narrower one: `store i64` erased by later `store i32` at same address — no `type->width` comparison anywhere (machine_opt's `isStoreDead` does compare). O1+. | OPEN |
| D3 | Critical | alias_analysis.crl:436-452 vs 292,302 | Multi-object phi caches the *first* incoming object → `phi(gepA,gepB)` permanently "A"; loads through real B answer NoAlias → gvn keeps stale load across store (miscompile). `walkAddr`'s own phi rule returns UNKNOWN on disagreement — cache poisons it. | OPEN |
| D4 | High | gvn.crl:266-268; machine_opt.crl:53-55; memory_ssa.crl:373-375; licm.crl:318-320; loop_distribute.crl:79-81; alias_analysis.crl:144-149,208-213 | Cache-hit shallow copy (`aa=*aaPtr`) shares 6 buffers; `walkAddr` on a query can *realloc* those buffers (atomic addresses never analyzed → query-time `createObject`) → cache entry poisoned → `destroyCachedAliasAnalysis` double-frees. Invariant "query never allocates" unenforced. | OPEN |
| D5 | High (dormant) | ipa_cp.crl:204-223,249-274,282-292 | Unwired. If wired: null-deref (`firstConst->id` when first site non-const) + unsound specialization (every entry-block alloca matched to every constant arg, loads RAUW'd module-wide, never erased; cloning steps unimplemented). | OPEN |
| D6 | Medium | alias_analysis.crl:31,370-375,478,489,507,543-573,618-653 | `defId 0 == OBJECT_UNKNOWN` sentinel collision (first def indistinguishable from "no def"); `objectCount=0` means both "none" and "all"; `blockEntryDef` never populated/read; most MemoryDef/Phi API dead; intra-block-only `currentDefId`; `MemoryPhi.incoming[16]` silent truncation. | OPEN |
| D7 | Medium | dse.crl:110-117; alias_analysis.crl:598-603 | `isMustAlias` is id-equality → AA branch in dse can never fire beyond the plain pointer compare; header claim ("across GEP offsets and bitcasts") false. | OPEN |
| D8 | Medium | memory_ssa.crl:190,222,287,359-388; wallvm.crl:270,307 | Phi versions have null def ⇒ `findNearestDefForLoad` stops at every join (cross-block forwarding structurally dead); 256-step cap; `irMemorySSA` builds then destroys — wired no-op. | OPEN |
| D9 | Low-Med | gvn.crl:131-145; irOps.crl:296-311 | Load CSE gated on id-equality (same as D7); commutativity set missing `FAdd/FMul`; no value-numbering for phi-merged/cast forms; O(n²)/O(n³) subtree scans. | OPEN |
| D10 | Low | dse.crl:71-82,90,129-134 | `MAX_TRACKED=128` silent truncation; any Load flushes all tracked stores (near-useless after mem2reg, though safe). | OPEN |
| D11 | Low | irtypes.crl:283; machine_opt.crl:76-83; alias_analysis.crl:373 | Raw `IrInst*` retained in MSSA/AA across passes that `erase()` (which frees) — safe only under an unstated shadowing invariant; `analyze()` re-run leaks `blockEntryDef`. | OPEN |

## E. Transform / vectorizer passes

| ID | Sev | Location | Issue | Status |
|----|-----|----------|-------|--------|
| E1 | Critical | tco.crl:317-329 | **GDB-confirmed compiler hang**: forward loop over `nb->ninsts` with `insertBefore(final, inst)` at each `Ret` shifts the anchor right, `ii` re-lands on the same Ret → rewrites forever (O3 only; suite green because no case matches the single-self-call `[call,comb,ret]` shape). | FIXED (backward `for ii=ninsts; ii>0; ii--` loop; `cases/tco_acc.ir` expect 15) |
| E2 | High | sccp.crl:1173-1197 | Unreachable blocks gutted (`ninsts=0`) but never `removeBlock`'d; phi pairs removed from survivors but preds kept → validated empirically: inline probes at O2/O3 produce ~380KB of phi-vs-npreds + predecessor/successor validate errors. | OPEN |
| E3 | High | inline.crl:98,612-615 | `MAX_INLINE_DEPTH = 4` never referenced — only `MAX_TOTAL_INLINED=500` bounds growth; cloned self-calls re-inline (block names show iteration 24) — multiplies E2 litter. | OPEN |
| E4 | High | peephole.crl:423-452 | br-chain redirect: (a) adds `[constInt(0), bb]` phi pair for an edge whose real value is unknown (correctness hazard when phi live), (b) raw `bb->succs[0]=finalTarget` assumes nsuccs==1, (c) intermediate chain blocks left in `func->blocks`. | OPEN — cycle-hang fixed (see E14); (a)(b)(c) remain |
| E5 | Medium | simd_vec.crl:189 | Return `vecOps > 0` vs local `changed` (peephole-cleanup mutations) — potential missed/stalled fixpoint step. | OPEN |
| E6 | Medium | simd_vec.crl (analyzeLoop) | Cross-candidate alias gap (two candidate loops/regions may alias each other — not checked between candidates); Noret-sweep hazard; OOB anchors at :882/:915. | OPEN |
| E7 | Medium | tco.crl:196-212,229,349-351 | Legacy-parameter representation issues: `argPhi` built from `func->args`, entry clone `start=0`, e-cleanup keeps only trailing `br acc_loop`, `remap`/`cloneInst` consult `valMap` for all kinds. | FIXED (Arg values, not entry insts) |
| E8 | Medium | tco.crl:263-281,349-351 | `cb==e` path discards terminator: tco output valid (non-terminating fn, no ret anywhere — matches original infinite recursion), but adce then guts it to a **pure 3-block br cycle** that made peephole's chain redirect ping-pong forever → O3 hang. | FIXED (peephole cycle-guard; `cases/tco_cbe.ir` expect 0) |
| E9 | Medium | tco.crl:333-347 | Removal loop index-shift bug vs shift-left `removeBlock` (pre-existing). | FIXED (`nblocks` captured pre-`createBlock`; two-phase unhook-then-free over snapshot of originals) |
| E10 | Medium | tail_dup.crl:76,122,159 | `ninsts=0` gutting leaves `insts` pointer at moved instructions (ownership confusion; P0-4 fixed preds only). | OPEN |
| E11 | Medium | inline.crl | alloca handling, vararg handling, `phiCount==1` hazards (pre-existing, documented). | OPEN |
| E12 | Info | x86_64_base.crl:3512-3530 | Opcode/emitter table: **no gaps** — all 14 vector IR opcodes have x86_64 emitters (verified by audit). | VERIFIED |
| E13 | Medium | loop passes × pipeline | Pipeline `validate` is non-fatal (returns false, callers ignore) — every CFG/phi inconsistency above flows into codegen and the next of up to 8 iterations. | OPEN |
| E14 | Critical | peephole.crl (br-chain redirect) | **Compiler hang (found via E8 repro)**: single-step chain redirect re-matched inside `while (blockChanged)` and ping-ponged forever on any br cycle (`bb→X→bb`); also the non-erasing `continue` skipped the sole `ii++`. Fixed by chasing the full chain in one rewrite with a `nblocks` cycle guard (bail on cycle / landing on `bb`), phi-pred check extended to every skipped block, fall-through to `ii++`. | FIXED (`cases/tco_cbe.ir` locks it) |

## F. Frontend safety (user-requested feature)

| ID | Sev | Location | Issue | Status |
|----|-----|----------|-------|--------|
| F1 | Feature | coral-frontend | Reject (or diagnose, like T0012) **address-of block-scoped local escaping its scope**: `self.field = &local` inside an `else` block — the exact P0-3 pattern. Copying struct values is fine; taking a local's address into a longer-lived pointer must be flagged at compile time. | OPEN |

---

## Fix order (severity-first, verify-before-fix)

1. ~~E1 (compiler hang)~~ ✓ · ~~B2a (unconditional O3 miscompile)~~ ✓ — done, plus E7/E8/E9 and P0-6/7/8/9. Next: B1a-e (UAF/infinite loop)
2. D2 (O1+ miscompile), D3 (unsound AA), D1 (unsound forwarding)
3. C1-C4 (critical folds), C5 (OOB), A1-A3 (miscompiles)
4. E2, E3, E4, C6-C8, A5-A6 (validate/CFG litter)
5. B3a, B4a/b, A7/A9 (dead/wrong passes), D4 (double-free hazard)
6. Remaining Medium/Low by area; F1 frontend diagnostic
7. After register is green: newer-pass adoption candidates (real ADCE, range propagation, loopcse enablement, unroll wiring, ipa_cp completion) and vectorizer extension testing (SSE/AVX feature inventory below).

## Vector-extension inventory (for vectorizer testing — fill during E-series)

Emitters/features referenced in x86 codegen (x86_64_base.crl, generic.crl, linux.crl, assembly/x86): SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2, AVX, AVX2, FMA, BMI1, BMI2, POPCNT, LZCNT (CpuFeatures in generic.crl:14-26); XMM/YMM register files; `.Lskip_xmm_` spill paths. Vector IR opcodes (14) ↔ emitters: verified present (E12). To test: vectorizer's *supported shapes* (contiguous i64 loops, widths, reductions) vs what SSE/AVX codegen could actually emit.

# Wallvm Upper-Pipeline & Vectorizer Audit — Issue Register

Consolidated from five parallel audits (branch/CFG, loop, SSA/canonical,
memory/analysis, transform/vectorizer) plus empirical repros (crafted .ir,
`WALLVM_PRINT_AFTER_PASS`, gdb, valgrind, ASAN). Every entry starts **OPEN**
and must be *verified against the actual code* before being fixed — an entry
is only marked FIXED after rebuild + `test/wallvm/run.sh` (target 116/116) is
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
| P0-10 | irParser table grow copied `valueNames` but never `values` (same for `blockNames`/`blocks`) → any function with >32 values or >16 blocks lost every pointer slot on realloc → `undefined value` / `unknown label` at the first use past the old capacity; nothing in the suite was large enough until `cases/dist_swap.ir` | irParser.crl `addValue`/`addBlockName` (copy both arrays) |
| P0-11 | loop_distribute clone loop called `addUser` only for `IrValueKind::Inst` operands → const operands never listed the clone → 16× use-def validate errors after distribution | loop_distribute.crl (addUser every non-null op) |
| P0-12 | stack_layout swapped `entry->insts` for an exact-`newCap` array but left `capInsts` at the old (larger) value → lower_phis' grow check passed and wrote off the end (heap-buffer-overflow, ASAN) | stack_layout.crl (`capInsts = newCap`) |
| P0-13 | tco teardown called `freeInst` (unhook+free per inst) in program order → consumers freed after producers `removeUser`'d already-freed operands (valgrind UAF on `tco_cbe`) | tco.crl (`unhookInst` phase over all doomed insts, then `destroyInst`) |
| P0-14 | lsra `allocate` freed `linearInsts`/`instVreg`/… at its tail, but `irGraphRegAlloc` calls `lsra.rewrite` a second time after recoloring → `parkUnallocatedResults` read freed arrays (ASAN); the `numVregs==0` early return leaked the same arrays | lsra.crl (scratch-array frees moved to `destroy()`) |
| P0-15 | sccp: (a) cond folds `createInst(Br)` whose id exceeds the entry scan's `maxId` → phase 1/2 `cells[]` read one past the heap; fixed with bounds guards (out-of-range ⇒ Top ⇒ skip/keep). (b) unreachable-block wipe unhooked+freed per inst → cross-block and producer-before-consumer references chased freed values; fixed with a full unhook pre-pass before any free (trigger: `tco_acc` O2) | sccp.crl (bounds guards + two-phase wipe) |
| P0-16 | mem2reg promoted allocas with mixed-width accesses: a narrow store REPLACED the wider slot's SSA value (i32 const handed to i64 users; constfold then legitimately folded `lshr i64` with the i32 bit width) → wrong results at O2/O3 (repro `cases/dse_wide.ir`: 0/5 instead of 170 before the fix) | mem2reg.crl (promotability: every load/store type must equal the slot's element type) |
| P0-17 | mem2reg's promotability check blanket-allowed `Phi` users ("placed by us") though `placePhis` runs *after* the check → an input-level address-escaping `phi %p` was promoted and the alloca freed under the phi (use-def errors, wrong exits). Same repro exposed `AliasAnalysis_walkAddr` with no cycle guard: phi self/mutual cycles recursed forever → stack overflow, irtool SEGV (O1/O2/O3, from dse→analyze→walkAddr) | mem2reg.crl (any phi user ⇒ not promotable) + alias_analysis.crl (`OBJECT_INPROGRESS` marker, self-edge skip, marker always cleared) |

## Also fixed this session — regalloc / IR text / codegen support

| ID | Issue | Where |
|----|-------|-------|
| PHI-1 | Phi elimination redesigned to **register form**: every phi home materialized into a register by `lsra.rewrite` via `materializePhis` (per-pred greedy ordering, `Trunc`/`Bitcast` copies carrying the home in valData, `divertEdge` spill-slot saves for deadlock, critical-edge `edgeSplit` blocks — split names `split<funcid>_<n>` because coral `char` is 4 bytes) | lsra.crl; default on (`gKeepPhisEnabled = true`), escape hatch `WALLVM_LOWER_PHIS` |
| PHI-2 | Interleaved per-function pipeline ran `inl` on already-lsra'd callees: cloned phis had detached valData → dangling `%N` refs → adce deleted the "dead" add → O3 `tco_acc` returned 88 instead of 15 | wallvm.crl (`irCompile`/`irCompileAsm` split into phase 1 = optimize+structure lane for all funcs, phase 2 = regalloc for all funcs) |
| T-1 | `parseTypeAfter("ptr")` read `peekIdent` without skipping whitespace → every `ptr T` type (globals, params, `ptr ptr` decls) leaked the pointee to the caller ("expected ';' after global declaration") | irParser.crl (`skipWs` before the pointee peek) |
| T-2 | gep parser rejected aggregate bases (`gep @msg, 1` on a string literal, struct-typed alloca) while `emitGep` decays them — first text-format coverage of strings/globals/structs could not even parse | irParser.crl (same decay as emitGep: pointer → pointee, aggregate → itself) |
| C-1 | `addrFor` returned a raw rip operand (`counter(%rip)`) that load/store emission wraps in `( … )` → `(counter(%rip))` assembler error; spill/intConst path shared `r11` with store's symbol source | x86_64_base.crl (materialize via `leaq …, %rdx` — reserved, never a value home) |
| C-2 | `emitGlobalInit` had no branch for symbol initializers → `global @alias: ptr i64 = @counter` emitted `.zero 8` (null-pointer deref at runtime); pointer-variable globals declared `ptr T` got pointee-sized storage | x86_64_base.crl (`.quad label` branch; declaration convention: one deref — a pointer variable is `ptr ptr T`) |
| C-3 | Emission-time ext-load fold (`iselTryFoldExtLoad`) re-read the *address* register at zext/sext time, but LSRA only keeps the address live until the load — its home may belong to another value (misread / fault) | x86_64_base.crl (fold disabled pending a pre-regalloc fold or RA fold-safe marking) |
| C-4 | `createStringConst` built its bytes in a scoped `String` whose storage was reclaimed before the caller could read `sc->data` → string pool emitted whatever reused the buffer (e.g. block-name bytes); exposed by the first `string @…` test cases | irtypes.crl (raw `alloc` + `copy` owned by the IrStringConst, same ownership as `irDupStr`) |
| G-1 | Coverage: `cases/globals.ir` (52), `cases/strings.ir` (96), `cases/structs.ir` (57) — symbol/const globals, pointer alias init, rodata pool bytes, gep decay, memory-loaded pointer byte access, struct field access across padding | gate: rebuild + run.sh = **116/116** (29 cases × O0-O3); ASAN 116/116, valgrind clean |
| P-1 | `gKeepPhisEnabled` had silently reverted to `false` → `lowrphis` demoted every register phi back to alloca form; O3 loops compiled to the memory-form (sum_loop O3 did a load/store round trip per iteration instead of a pure register loop) | wallvm.crl:83 (`true` default + `WALLVM_LOWER_PHIS` escape hatch re-landed with comment) |
| P-2 | icmp+condbr compiled as `movl $c; cmpq; setl; movzbq; testq; je` (6+ instructions per compare) instead of `cmp $c; jge` (gcc does the latter) | x86_64_base.crl: `JCC_INT_TRUE`/`JCC_INT_FALSE` tables, `emitCmpOperands` (imm second-operand fold), `iselFusedBranchPair` (adjacent icmp→br), `iselSkipFusedICmp` (single CondBr user skips standalone setcc), fused `emitCondBr` with fallthrough policy |
| P-3 | edge-split block names built in a `char[64]` — coral `char` is 4 bytes, so the name loop wrote one char per 4 bytes and `(cchar*)buf + pos` skipped `pos*4` bytes → corrupt labels like `.Lmain_m   .split0_50` → `unknown pseudo-op` at assembly in every phi-heavy case once P-1 re-enabled register phis (12 harness failures) | lsra.crl `edgeSplit` (`u8[64]` + byte-pointer offset; same lesson as PHI-1's split naming) |
| P-4 | Param-seeding prologue always reserved the full SysV bank bound `subq $176,%rsp` even for one integer arg, then staged `%rdi → 0(%rsp) → %rdi` — an identity round trip through a phantom frame (fib O3 prologue was 6 wasted instructions before the first compare; gcc emits none) | x86_64_base.crl: `planParamSeeds` classifies seeds once, skips stage+commit when the home already is the incoming register and no other seed's register home is that register, lays out slots over survivors, sizes the region exactly (0 ⇒ no region); stage/commit walks replay the plan |
| P-5 | Load/store to a constant address went through a lea round trip (`leaq counter(%rip),%rdx; movq (%rdx),%r8` = 2 instructions; gcc emits `movq counter(%rip),%r8`), and an immediate store materialized into r10 first (`movq $1,%r10; movq %r10,(%slot)`) | x86_64_base.crl: `addrFor` folded into `memOperandFor` — symbol/symbol+const-gep addresses come back as the bare rip operand (callers emit it verbatim, no `( … )` wrap), sub-word stores mask the immediate to the store width and64-bit stores take the direct path only when the value sign-extends from 32 bits |
| P-6 | Every scaled gep copied its index into the r11 scratch first (`movq %r9,%r11; leaq (%rsi,%r11,8),%r8`) — the SIB lea could have used the index's home register | x86_64_base.crl `emitGep`: first dynamic index stays in its own home when full-width (no ext), stride expressible by the final lea (no pre-lea imul), and the home collides with neither base, destination, nor rax; `idxReg` threaded through the extra-index fold, big-disp fold, and final lea (r11 remains the fallback every hardwired path expects) |
| P-7 | add with the constant in operand 0 materialized the constant, then did the two-address op (`movq $1,%rdi; addq %r9,%rdi` — 2 instructions; gcc emits `leaq 1(%r9),%rdi`) | x86_64_base.crl `emitBinOp`: `Add(const, reg)` with a displacement that fits signed-32 emits one lea from operand 1's register (spilled operand 1 reloads into r11 first; disp 0 degenerates to the move it would have been); other opcodes/const positions unchanged |
| P-8 | Enabling unroll at O3 exposed four bugs it had never hit while dead: (1) the clone-order topo sort deadlocked on the backedge (nothing ready → `nOrder=0` → every copy emitted empty — the "empty block chains" the driver comment warned about), (2) exit-block uses of loop values kept pointing at the originals that teardown freed (`%missing` in `done`), (3) a latent `CondBr` successor bug — the `addSucc` loop fed `ops[0]` (the condition inst) as a block and skipped the false target, (4) B4b's doubled exit preds | unroll.crl: two-pass cloning (pass 1 shells every non-terminator so `remapVal` resolves backward phi/latch reads in any block order, pass 2 fills operands, pass 3 installs terminators); unified exit-value rewrite — existing exit phis rebuilt to k per-iteration pairs plus one `retargetExitVal` pair (header phis take their backedge-pair value as if the final header entry ran), non-phi exit uses get a fresh phi with the same shape; teardown zeroes original counts (B4a); `CondBr` adds `ops[1]`/`ops[2]` as successors |
| P-9 | Spilled phi copies compiled to `movq -168(%rbp), -152(%rbp)` — x86 has no mem←mem encoding — and the widen mnemonics (`movzbl`/`movslq`/…) write a register only, so a spilled destination was equally invalid (assembler error, `loop_swap` O3) | x86_64_base.crl `emitCast`: when the destination renders as memory, stage the finished value in `r11` (`r11d` for `movd`) and store it once after the switch — a 32-bit write into r11 already zero/sign-extends the full 64 bits, so one `movq` covers every width |
| P-10 | `%p = alloca ptr` (a bare `ptr` as the last word of an instruction) failed with "extra tokens after instruction": `parseTypeAfter("ptr")` did `skipWs`, which crossed the newline and left the cursor on the next line | irParser.crl ptr branch now uses `skipSpaces` (horizontal only); the function-header `{` check crosses the newline itself so `func @f() ptr` + `{` on the next line still parses |
| P-11 | The borrow checker could never fire on text IR: params are plain `Arg` values (not entry allocas), so `storeCapIndex` found no evidence, `buildCaps` skipped functions with zero entry allocas, and `calleeWrites` was always false for internal callees; the escape rule also exempted *any* entry-block alloca, missing entry-local dangling returns; and nothing ever printed violations (no reporter was wired anywhere) | borrowcheck.crl: `storeCapIndex` accepts stores directly to `Arg`, `buildCaps` runs without entry allocas, escape exemption narrowed to the first-`nparams` entry allocas, new `irPassBorrowCheckPrint` + `borrowKindName`; irtool honors `WALLVM_BORROW_CHECK=1` (prints `borrow: Kind: func: msg`, exit 3 on violations); suite `test/wallvm/borrow/` (8 cases, exact-kind-set assertions) + `run_borrow.sh` — all documented in `lib/wallvm/docs/borrow-check.md` |
| P-12 | O1 was byte-identical to O0 across the harness (no promotion → L1's scalar passes had almost nothing to work on), which read as "the levels don't differ" | pipelineLevel1 runs `mem2reg` after `abi_lower` (clang -O1 promotes too): gcd O0 568 → O1 354 bytes, fib_iter 640 → 495; harness 116/116, ASAN 116/116 |

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
| B1a | Critical | loop_distribute.crl:361-369 | Header-erase loop erases non-phi non-terminator insts *including the ICmp feeding the header CondBr* (never seeded into partitions) — `erase` doesn't repair users ⇒ terminator operand dangles (UAF for validate/next pass). | FIXED (erase keeps terminator, phis, and any inst with `nusers != 0`) |
| B1b | Critical | loop_distribute.crl:390-399,463-465 | Latch orphaned: header's in-loop arm retargeted to `newBlocks[0]`, partitions loop back to header; original latch never reached ⇒ induction phi never advances → infinite loop. | FIXED (partitions chain to the header's old in-loop target; that block's phi pairs rewritten from `(v, header)` to `(v, last partition)`) |
| B1c | Critical | loop_distribute.crl:414-460 | Header phis never rewritten for rewired entry edges (old pred pair stays, `newBlocks[n-1]` pred has no pair) → validate failure + wrong values. | FIXED (entry edges and latch left untouched — only the single in-loop arm retargeted, so phi pairs stay valid) |
| B1d | High | loop_distribute.crl:480,486-536 | `aa` parameter accepted, never read; partitioning = "one partition per store", no dependence check — aliasing stores sequentially reordered across a load (violates the file's own safety claim). | FIXED (gate: header must have exactly one in-loop successor, and every partition's stores must be `isNoAlias` against all loads/stores elsewhere in the header, else the pass aborts) |
| B1e | High | loop_distribute.crl:382-399,437-452 | Both-arms-in-loop (or both-to-header) CondBr retargeted but `addSucc` once ⇒ nsuccs=1 behind a 2-target CondBr. | FIXED (`succs[k]` patched in place with matching `removePred`/`addPred` — validate requires positional succs, so `addSucc`/`removeSucc` would shuffle the order) |

B1 verification: repro `cases/dist_swap.ir` (expect 54) — loop1 rejected by the alias gate and runs normally, loop2 distributes (`loopdist` labels present at O3), exit 54 at all 4 levels, 0 validate errors, gcc assembles; ASAN + valgrind clean. The hunt also surfaced P0-10 (parser table grow) and P0-11 (clone `addUser`).
| B2a | Critical | loop_interchange.crl:301-324 | "Interchange" swaps the two increments' phi operands with **no CFG change** — inner backedge becomes `outer_iv+step` → infinite/zero-trip inner loop. **Empirically confirmed**: instrumentation showed `canInterchange=true` ×8 + `interchange DONE` ×2 on `cases/loop_swap.ir` (first CondBr-block ICmp is a param compare → ivdep check passes), producing validate errors + non-assembling output. | FIXED (`interchangeLoops` bails before any mutation; `cases/loop_swap.ir` expect 36) |
| B2b | Medium | loop_interchange.crl:277-299 | Initial-value swap dead: keyed on `IrLoop.preheader`, which detector inits null and this pass never creates. | INVALID — dead code (preheader always null); unreachable now that B2a disables the pass |
| B2c | Low | loop_interchange.crl:326-329 | "Header swap" mutates only analysis structs (freed at :108) — no IR effect. | INVALID — no IR effect by definition; unreachable now |
| B2d | Medium | loop_interchange.crl:113-122,181-194,215-234 | Naive legality: `findLoopCompare` = first compare in loop (not the exit test); dependence check only direct; `isLoopContained` header-only ⇒ multi-latch loops misread as nested. | OPEN |
| B3a | High | licm.crl:188-226,363 | Speculatively hoists potentially-trapping `SDiv/UDiv/SRem/URem` into preheader → executes on zero-trip loops; div-by-zero trap newly reachable. | OPEN |
| B3b | Medium | licm.crl:195,239-254,352-362,383-404 | Load hoisting is dead code (`isLoopInvariant` returns false for Load) — the entire alias-guard machinery below is unreachable. | OPEN |
| B3c | Low | licm.crl:248,394-400 | (Latent, in dead code) `AtomicStore` counted as write but `loadMayAliasLoopStore` misses `AtomicRmw/AtomicCmpXchg`. | OPEN |
| B3d | Medium | licm.crl:66-77,80-82,104-115 | `CondBr(cond, header, header)` double edge: both arms retargeted but one edge pair left; single-ext-pred phi path fixes only first matching pair. | OPEN |
| B4a | High | unroll.crl:673-690 | Teardown removes *other* blocks' entries but never decrements `b->npreds/nsuccs`, then gates `removeBlock` on those counts ⇒ originals never removed (dead code + validate inconsistency). | FIXED (teardown zeroes each original's npreds/nsuccs after the neighbor-side repair, so the removal gate passes and originals + insts are actually freed) |
| B4b | High | unroll.crl:597-602,666-668 | Exit preds double-counted: clone edges auto-add preds via `addSucc`, then exit-phi maintenance adds all k clones again ⇒ npreds=2k vs k phi pairs. | FIXED (the k-clone re-add loop dropped — clone terminators already registered the edges; the unified exit rewrite builds exactly k original-pred pairs plus the retargeted last-backedge pair, matching npreds) |
| B4c | Info | wallvm.crl:79,380; drivers | Unroll wired but `gUnrollEnabled=false` everywhere; no CLI flag (`--funroll` parsed nowhere) — pass dead in production; B4a/B4b latent until enabled. | FIXED (enabled at O3 only: `irtool.crl` `gUnrollEnabled = opt == 3`, `generateWallVm` `wvOptLevel(opt) == 3`; harness shakes every case at O3) |
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
| C5 | High | sccp.crl:960,1068,1202-1208 | Phase-2 `cells[inst->base.id]` — replacement `Br` created at :1068 has id > maxId ⇒ heap OOB read every cond_br fold. | FIXED (phase-2 cells reads bounds-guarded `inst->base.id <= maxId ? cells[...] : latticeTop()` at sccp.crl:1065,1227 — same fix as P0-15; row never closed) |
| C6 | High | mem2reg.crl:451-454,510 | Pre-existing `Phi` users of the alloca treated as "placed by us" (check runs before placePhis) → alloca erased while phi operand still points at it (UAF). | FIXED (mem2reg marks the alloca `promotable = false` for any non-Load/Store user incl. Phi — mem2reg.crl:461-467, repro `cases/addr_phi.ir`; same fix as P0-17; row never closed) |
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
| D2 | Critical | dse.crl:101-127 | Kills a wider store with a narrower one: `store i64` erased by later `store i32` at same address — no `type->width` comparison anywhere (machine_opt's `isStoreDead` does compare). O1+. | FIXED — both passes compared `store->base.type->width`, but store base.type is **void** (width 0), so machine_opt's check was vacuous `0 == 0` and dse had none: now both compare the *value* operand's width and only kill when a same-address store of >= width covers the earlier one (unknown width never kills). Chasing the repro surfaced P0-16 (mem2reg mixed-width promotion) and P0-17 (address phi + walkAddr stack overflow). `cases/dse_wide.ir`: 170 at all levels. |
| D3 | Critical | alias_analysis.crl:436-452 vs 292,302 | Multi-object phi caches the *first* incoming object → `phi(gepA,gepB)` permanently "A"; loads through real B answer NoAlias → gvn keeps stale load across store (miscompile). `walkAddr`'s own phi rule returns UNKNOWN on disagreement — cache poisons it. | FIXED — the phi arm merge now caches only when *every* incoming arm resolves to the same object; any disagreement/unknown caches nothing, so `walkAddr`'s phi rule answers UNKNOWN (conservative may-alias) at query time; self-edges skipped like walkAddr. Repro `cases/phi_alias.ir`: 50 at O2/O3. |
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

1. ~~E1 (compiler hang)~~ ✓ · ~~B2a (unconditional O3 miscompile)~~ ✓ · ~~E14 (peephole br-cycle hang)~~ ✓ — done, plus E7/E8/E9, B1a-e, P0-6…P0-17, ~~D2~~ ✓, ~~D3~~ ✓ (P0-16/P0-17 found while fixing D2). Next: D1
2. D1 (unsound forwarding) — D2, D3 done
3. C1-C4 (critical folds), A1-A3 (miscompiles)
4. E2, E3, E4, C7-C8, A5-A6 (validate/CFG litter)
5. B3a, ~~B4a/b~~ ✓, A7/A9 (dead/wrong passes), D4 (double-free hazard)
6. Remaining Medium/Low by area; F1 frontend diagnostic
7. After register is green: newer-pass adoption candidates (real ADCE, range propagation, loopcse enablement, ~~unroll wiring~~ ✓ (O3), ipa_cp completion) and vectorizer extension testing (SSE/AVX feature inventory below).

## Vector-extension inventory (for vectorizer testing — fill during E-series)

Emitters/features referenced in x86 codegen (x86_64_base.crl, generic.crl, linux.crl, assembly/x86): SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2, AVX, AVX2, FMA, BMI1, BMI2, POPCNT, LZCNT (CpuFeatures in generic.crl:14-26); XMM/YMM register files; `.Lskip_xmm_` spill paths. Vector IR opcodes (14) ↔ emitters: verified present (E12). To test: vectorizer's *supported shapes* (contiguous i64 loops, widths, reductions) vs what SSE/AVX codegen could actually emit.

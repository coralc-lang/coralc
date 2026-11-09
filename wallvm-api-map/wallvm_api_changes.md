I'm going only by this doc, not the code, so treat the specifics as things to check. Here's what in it affects your plan, in the order I'd hit it.

**Bounds checks**
- `irPassSafety` is gated to O0 and runs before the pipeline. Make the gate its own `SafetyMode` instead of tying it to the opt level, but keep it running *first*. Then your existing `range`, `range_br_elim`, `branchprop` and `gvn` passes remove provably redundant checks, so you get bounds-check elimination without writing a new pass.
- `isLeaf()` is "no `Call` anywhere," and graph regalloc needs a leaf. Every inserted `_trap` call then costs you graph coloring at O3. Emit traps as `noret` and make `isLeaf` ignore them. Also mark the trap blocks cold, or the check branches will pollute layout.
- Make it per function, via a metadata attribute, not the process-global `gSafetyChecks`. Then engine hot loops can opt out while scripts stay checked.
- Give `_trap` a code plus file and line. Without EH on x86-64, decide how a trap unwinds to the engine. With per-script heaps, "kill the script, destroy its heap" is the simplest answer.

**Allocation injection**
- Declare the `__Mu__intrinsic_*` functions as externs, but the optimizer has no notion of "allocator" or "free." Today `cse`, `gvn`, `dce` and `dse` treat them as ordinary calls. Add `allocfn`, `freefn` and `noalias-return` attributes to `irMetadata`.
- With those attributes, a **heap-to-stack pass** becomes easy. If the result of an alloc call doesn't escape (you have `alias_analysis`, plus `setNoCapture` metadata), turn it into an `alloca` and delete the matching free. It would also be useful to Coral itself.
- Extend `validate` or `borrowcheck` to check alloc/free pairing per path. `borrowcheck` already runs in the structure lane as a diagnostic.

**Things that will bite you early**
- **`constFloat` dedups ignoring type (§4.14).** That's a f32/f64 confusion bug in a language full of floats, and the fix is one comparison at `irtypes.crl:960-962`. Do this first. **[done 2026-11-09 — see map §4.14/§13-G-type4]**
- **`irTypeAlignOf(struct)` is hardcoded to 8.** Anything with 16-byte-aligned vec types will be wrong at the Coral/Mu extern boundary. Check that Coral's layout rules match `createStructType`. **[done 2026-11-09 — see map §4.11/§13-G-type3]**
- **The assembler caps at 512 symbols and 1024 relocs per object.** A big script module will hit that fast. I can't tell from the doc whether local labels count against the limit.
- **G10: IR is never freed.** If the compiler runs in-process for hot reload, every recompile leaks. Give each `IrContext` its own arena and destroy it wholesale after emitting.
- **There's no single IR-to-object entry (G5).** For fast hot reload, add a wrapper that skips the text round trip. `emitRaw(base)` plus `FMT_RAW` looks like most of the way to loading straight into executable memory.

**For debugging all of this:** print `debugLoc` (P6) and make value ids stable (P2). Without them you can't golden-file test the injected frees.

Which do you want to start with? I'd begin with the float fix, then decouple safety mode, since both are small.

Here's how I'd do each one, in the order I'd do them. I'm working from your doc only, so the code is pseudo-Coral that follows the doc's naming and the line numbers are its claims. Check them against the source.

**One correction first.** I told you to emit traps as `noret`. Your doc says `noret` lowers to a per-arch exit snippet (`noretTemplate`), so it's probably an exit-syscall terminator, not a plain "never returns." Use `unreachable` after the `_trap` call and confirm what `noret` does before touching it.

## Tier 1: small and independent

- **`constFloat` type confusion (`:960-962`).** Compare the type like `constInt` does: `if (c->base.type == ty && c->valData == bits) return c;`. Test by creating an f64 1.0 and then an f32 1.0, and assert the pointers differ. **[done 2026-11-09 — type+bits dedup at `irtypes.crl:987`; e2e case `test/wallvm/pending/const_float_type.ir` awaits the deferred `opFor` float-const materialization]**
- **`constInt` masking.** Mask to width on creation (`if (w < 64) v &= (1<<w)-1`). In the printer, sign-extend from the type's width before printing. That fixes P3 and P4's "u64 prints as -1" case without a signedness model. Check the parser reads negatives back. **[done 2026-11-09 — mask at `irtypes.crl:957-958`, printer sign-extend `irPrinter.crl:341-354`; parser negatives verified by suite]**
- **Struct alignment.** Add `alignment` to `IrType`, set it in `createStructType` to the max field alignment (1 for empty), and have `irTypeAlignOf(Struct)` return it. Then grep for callers that depended on the hardcoded 8 (the global-alignment fallbacks you cite). **[done 2026-11-09 — field `IrType.align` (`:51`), set at `:901`, returned at `:840-851` with derive-fallback; fallbacks refreshed in map §4.11 quirk 1]
- **`createFuncWithArgs(name, ret, params, argNames, n, isVararg)`.** Wrap your §4.13 loop and set `base.type` with the vararg flag in the same function. That keeps `args[]` and `paramTypes` in sync in one place.
- **`IrBuilder.insertValue`.** Copy `extractValue` and use `createInst(InsertValue, ...)`.
- **`.str` collisions.** Name them `.str`, then `.str.<n>` from a per-module counter. Make a builder-aware `getStringPointer` that respects the insert point.
- **`metadataInit`.** Call it from `irCtxCreate`, then test whether anything breaks. If it's idempotent, that settles it.

## Tier 2: structural

- **Per-function safety mode.** Replace `gSafetyChecks` and the O0-only gate with a module default plus a per-function override. Use `irMetadata` for the override. Run safety whenever mode is on, at any opt level. Your L2 `range`, `branchprop` and `gvn` passes then remove provably redundant checks, so debug-with-checks and release-with-checks are the same code path. Each failed check should branch to a block that calls `_trap(code, fileId, line)` and ends in `unreachable`. Set `setBranchWeights` so the check branch is unlikely. Mark `_trap` with the `NoReturn` attribute, which already exists, and make `isLeaf()` ignore calls to `NoReturn` callees. Otherwise every check kills graph regalloc at O3.
- **Trap unwinding.** I wouldn't implement EH (G9). Make `_trap` in your runtime `longjmp` to a context saved at script entry, then destroy that script's heap. The catch is engine frames between script and trap. If a script calls an extern that calls back into a script, a longjmp skips those engine frames. Rule: externs must not hold locks or resources across callbacks, or the trap is deferred to the extern's return.
- **Make `irCompile`/`irCodegen` honest (G1, G2).** Delete the bool variants, or make `irCompile` a thin wrapper over `irCompileAsm` that takes a destination. Replace the silent `else` fallback with an error naming the unsupported cc.
- **IR to object in one call (G5).** `irCompileObject(m, ctx, cc, opt, fmt, AsmBytes*, err)` that chains `irCompileAsm`, `assembleText`, and `emitElf`/`emitCoff`/`emitRaw`. Just your §3.3 as a function. Measure before you try to skip the text round trip, since optimization likely dominates.
- **Free IR wholesale (G10).** If wallvm allocates through mimalloc, you don't have to change the IR code:
  ```
  h = mi_heap_new();  prev = mi_heap_set_default(h);   // per thread
  ... parse / build / optimize / emit ...
  copy asm/object out to the normal heap
  mi_heap_set_default(prev);  mi_heap_destroy(h);
  ```
  Initialize any process-global state (metadata store, flags) before switching heaps, or it gets destroyed with the rest. This only works if Coral's `alloc` ends up in `mi_malloc`, which uses the thread default heap. Confirm that.
- **Assembler caps (G7).** Turn `syms[512]` and `relocs[1024]` into growable arrays with len/cap. Also check whether `asmFindSym` is a linear scan, and add a hash map if so, because it gets slow once the caps are gone.
- **Pointer size in layout (G-type2).** Add a `ptrBytes` field to `IrContext` and set it at creation from the target. Struct offsets are baked in at `createStructType`, so the target must be known before the first struct is made. That means a `irCtxCreateFor(cc)` constructor, not a setter.

## Tier 3: the payoff for your allocator

- **Allocation attributes.** Add `allocfn`, `freefn`, and `noalias-return` as func attributes via `irMetadata`. Teach `cse`, `gvn`, `dse`, and `dce` that a call to an `allocfn` is not a pure duplicate-able call, and that a `freefn` call kills the pointer.
- **Heap-to-stack pass.** For each call to an `allocfn` with a constant size under some threshold, walk the result's users. GEP, load, and store-to-it are fine. If it's stored as a value, returned, passed to a call without `NoCapture`, or fed into a phi that escapes, it escapes. If it doesn't escape and is not inside a loop (use `loop_detect`), replace it with an `alloca` in the entry block and delete the matching frees. Conditional frees are fine to delete, since stack memory needs none. Skip `realloc` at first and treat it as escaping.
- **Coroutines.** If you compile them to state machines, allocas that live across a yield must go into the coroutine frame. Run this pass before coroutine lowering, or make the lowering aware of it.
- **Module-level summaries (G8).** `irPassIPAConstProp` has no driver. Write one: build the call graph, find SCCs (Tarjan), and process callees first. Store a summary on each `IrFunc.metadata`: which params escape, whether the return aliases a param, and whether it allocates. Then make `alias_analysis` consult the summary at call sites. Without this, every call boundary forces a heap allocation. `irOptimize` ordering already requires all functions to be optimized before regalloc, so a module-level phase fits there.

## Tier 4: defer

- **EH, the rules-driven selector (G4), and ARM/RISC-V backends (G3).** These are large, and none of them blocks the engine on x86-64. The ABI tables are the cheap part, so an arm64 backend would still mean writing a new `target/` directory the size of `x86_64_base.crl`. Only do it when you have a platform that needs it.
- **Printer fixes.** Print `debugLoc` as a comment, renumber ids per function at print time instead of using context ids, add a `printBlocksInOrder` option, and print `extern` on extern globals. These are small, but they matter for golden-file tests of your injected frees, so move them up if you test that way.

If you want one thing first, do the `constFloat` fix, then the safety-mode change. I'll write either one out against real code if you paste the relevant functions.


some of this are actually for another project, but dependent on wallvm, so this was needed

I can only see file names and your API doc, not the pass code, so "strengthen" below means "likely weak, check it," not "I've seen that it's weak."

## Build first: correctness tooling
You have about 45 passes and the doc mentions known miscompiles. Each new pass adds miscompile surface, so I'd add these before more passes:
- **An IR interpreter.** Fuzz with random valid IR, run it at O0, then at O3 and after each pass, and compare results. This finds more bugs per hour than anything else here.
- **Pass bisecting.** A limit counter (`--opt-bisect=N`) so you can binary-search which pass invocation broke a test.
- **A stricter verifier.** Run `validate` after every pass in debug mode, and check pred/succ consistency, SSA dominance, and phi/pred matching. Your doc says edges are maintained by hand and `terminator()` ignores Switch, so that's a likely bug source.

## Missing, ordered by leverage
1. **Function attribute inference** (`readnone`, `readonly`, `nounwind`, `noreturn`, `nocapture`), computed bottom-up over call-graph SCCs. Right now your CSE, GVN, LICM and DCE probably treat every call as a barrier. This unlocks the most with the least code.
2. **A module-level pass phase.** Your `PassFn` takes one `IrFunc*`, which is why `ipa_cp` has no driver. Add a module pass manager first. After that, wire `ipa_cp` and add global DCE, dead-argument elimination, constant-global folding, and unused-function removal.
3. **Scalar evolution (SCEV-lite)** for induction variables and trip counts. It's the base for most loop work, and `range`, `simd_vec`, `loop_interchange` and `loop_distribute` are probably guessing without it.
4. **`simplifycfg`**: merge blocks, drop empty ones, fold same-target branches, remove unreachable code, and simplify switches. `jump_thread` and `branch_*` cover pieces, but I don't see a general cleanup.
5. **Loop canonicalization**: loop-simplify (preheader, single latch, dedicated exits), LCSSA, loop rotate.
6. **Loop passes on top of those**: induction-variable simplification, loop unswitching, loop deletion, loop idiom (turn loops into memset/memcpy), and bounds-check elimination from induction ranges. The last one matters most for your checks, since it lets you keep them on in release.
7. **`memcpyopt` and store merging**, plus forwarding through memory SSA.
8. **Reassociate**, which is different from `comm_canon`. Also strength reduction and known-bits/demanded-bits analysis, which would strengthen `cast_elim` and the mask handling.
9. **PRE and sinking.** `gvn` alone misses partial redundancies.
10. **Switch lowering** to jump tables or binary search, plus a lookup-table pass. Check that Switch is handled end to end.
11. **Backend-side**: block placement, copy coalescing, rematerialization, live-range splitting, and shrink-wrapping. After `lsra`, these are often a bigger win than another IR pass.

## Probably worth strengthening
- **`alias_analysis` and `memory_ssa`.** Your doc says memory SSA is never published, so `gvn`, `dse` and `licm` may be working from weaker information. Check GEP offset reasoning, noalias args, alloca-versus-global separation, and capture tracking.
- **`inline`.** Check the cost model, SCC ordering, and whether it honors `AlwaysInline` and `NoInline`. It's late in L2, after `gvn` and `licm`. Inlining early and then cleaning up with `sroa`, `mem2reg` and `gvn` usually does better, though your 5 to 8 pipeline iterations may hide that.
- **`dse`.** Is it cross-block? Does it use memory SSA?
- **`sroa`.** Does it handle memcpy-based aggregate copies and partial aliasing?
- **`range`.** Does it widen at loop phis, or only handle acyclic cases?
- **`loop_interchange`, `loop_distribute`, `simd_vec`.** These need dependence analysis and runtime alias checks to be correct, and vectorization needs remainder loops and a cost model. Run them against the fuzzer before trusting them.
- **`unroll`.** Does it support runtime trip counts with a remainder loop, or only constants?
- **`tco`.** `irPassAccumulate` handles accumulator recursion, but general sibling-call-to-jump needs backend support.
- **The pass manager.** `runOnFuncIterate` reruns the whole pipeline, and any mutation bumps one global analysis generation. Per-analysis preserved sets would cut compile time noticeably. That matters if you want fast hot reload.

If I had to pick three: the fuzzer, attribute inference with the module phase, then SCEV and the loop work. If you paste `alias_analysis.crl` or `inline.crl`, I can tell you much more specifically what's weak.

I'm going from your API doc and the pass list. I haven't seen how GEP encodes struct indices, so check that before relying on the layout section.

## Passes worth adding (beyond the earlier list)

- **Struct passes** (the layout section covers these): dead field elimination, field-constant propagation, struct peeling, hot/cold field splitting.
- **`assume` intrinsic and its consumers.** The frontend states facts ("`i < len`", "this variant is not `None`") and `range`, `sccp`, and `gvn` use them. It's cheap, and it's how Mu's type system feeds the optimizer.
- **Loop predication / check widening.** Instead of checking `a[i]` every iteration, check the first and last index once before the loop, and fall back to a slow loop if that fails. That's what keeps bounds checks affordable in release builds.
- **Argument promotion and return scalarization.** Pass small structs by their fields so `sroa` can finish the job across calls.
- **Identical function folding.** Merging structurally identical functions shrinks the code, and the content hash is useful for hot reload too.
- **Cold outlining and partial inlining.** Move trap and error paths out of line, which pairs well with your inserted checks.
- **Devirtualization.** If Mu has dynamic dispatch, resolve it when the type is known from the allocation site.

## Smarter algorithms

- **Replace the pile of ad-hoc rewrite passes with an e-graph.** `algebraic`, `peephole`, `idiom`, `involution`, `comm_canon`, `lex_canon`, `cast_elim`, `idempotent`, and `macro_fusion` are all rewrite rules, and an equality-saturation engine (egg-style) subsumes them and removes their ordering problems. Run it per block or region with a node limit, because compile time can blow up.
- **SSA-based register allocation.** SSA programs have chordal interference graphs, so coloring is optimal and polynomial. Spill first (Braun and Hack's SSA spilling), then color, then coalesce, and do SSA destruction properly (Boissinot et al.). The alternative, if you keep linear scan, is Wimmer and Franz's version with interval splitting.
- **Instruction selection with tree tiling** (iburg-style dynamic programming over patterns). That also gives your unused rule tables a real purpose.
- **Points-to analysis:** Steensgaard is near-linear, and Andersen is more precise. Either would beat per-function alias queries across calls.
- **Static branch prediction** (Wu-Larus) for block frequencies, then ext-TSP block placement.
- **Per-analysis preservation** in the pass manager, instead of one global generation counter.
- **Interval analysis with widening and narrowing** for `range`, plus known-bits.

## IR data representation

The main problem is that **layout is computed when the type is created and baked in as offsets**, and types are interned by shape. Reordering or packing later is hard under that design. I'd restructure it like this:

1. **Nominal struct types.** Identity by record, not shape. This also fixes P9 and the same-shape collapse.
2. **A separate `StructLayout`** computed by a layout pass: offsets, size, align, and field permutation. Struct GEPs index by *logical field number*, and nothing before the layout step should see byte offsets. Anything calling `irTypeSizeOf` early, such as `sroa`, `stack_layout`, or alias analysis, must go through a layout query. Simplest approach: decide layout once in a module pass before the function pipelines, then freeze it.
3. **Struct attributes:** `repr(auto | c | packed | transparent)`, `align(N)`, and `pinned` (extern, serialized, or reflected, so don't reorder). Per-field flags: hot, cold, never address-taken.
4. **A real `DataLayout` object** on the context (pointer size, per-type alignment, endianness), set before the first type is created. That fixes the wasm32 pointer issue.

**Reordering algorithm:**
- Sort by alignment descending, which gives zero internal padding for power-of-two sizes.
- Then cluster fields that are accessed together, and put hot fields in the first cache line and cold ones at the tail.
- Further savings: narrow fields using `range` results (a field only ever 0..100 becomes a u8), pack bools into bits, and use niche optimization for option-like types (invalid values encode "none").
- **Since Mu has no raw pointers, 32-bit handles or heap-relative offsets** can replace 8-byte pointers inside structs, which is a big memory and cache win.

**Cautions:**
- The closed world must be real. Anything crossing an extern, serialized, or reflected is pinned.
- **Hot reload needs layouts to be a pure function of the struct definition**, not of profile data, or live state migration breaks.
- Packed structs need `align` on loads and stores, which the doc says `IrInst` lacks. Add `align`, `volatile`, and `nontemporal`, plus a proper flags field for `nuw`, `nsw`, `exact`, `inbounds`, and fast-math, instead of reusing the `icmpPred` slot.
- AoS to SoA is worth offering later as a `#[soa]` annotation before attempting it as an automatic pass.
- Constants are a single u64, so wide integers need two words or arbitrary precision.

## Metadata

**Mechanism:**
- Interned, immutable metadata nodes. Register kinds by ID instead of string keys, and keep a small sorted `(kind, node)` array per instruction.
- **Every kind declares a merge policy** for when passes combine or clone instructions (drop, intersect, union, keep-first). This is the usual place metadata systems miscompile. Make `combineMetadata(a,b)` mandatory for any pass replacing an instruction, and drop unknown kinds by default.
- Split into four classes: semantic (wrong means miscompile: `range`, `noalias`, `nonnull`, `dereferenceable`), hints (hot, cold, branch weights), debug, and opaque frontend data.

**What the high-level language should supply:**
- **Borrow-checker output as `noalias`.** Unique borrows become noalias parameters, as in Rust. That's what lets `licm`, `gvn`, and `simd_vec` do their work without runtime checks.
- **Type-based alias tags.** In a language with no raw pointers, distinct struct types and field types can't alias.
- Value ranges from source types (enum with N variants gives `[0,N)`), `unreachable` from exhaustive matches, and the origin of each bounds check.
- ABI attributes: `zeroext`/`signext`, `byval`, `sret`. Signedness isn't in the type, so ABI lowering needs these.
- Function attributes: `allocfn`, `freefn`, `pure`, `willreturn`, `coroutine`, plus the usual `readnone` and friends.

**Debug info:** scopes and an `inlinedAt` chain (without it, inlined code loses its origin), and variable locations that use `valData` after regalloc.

**Back to user code:**
- **Emit the final layouts** (offsets, sizes, names) as a table or side file, so the engine, serializer, editor and debugger see what the compiler actually chose. Once you reorder, this is required.
- **Structured optimization remarks** ("allocation moved to stack," "bounds check removed," "inline failed: recursive"). It's the same mechanism as your `--explain-alloc` idea.
- Per-function stack depth bounds, which you need for coroutine frame sizing and overflow checks.
- A content hash per function, for caching and hot-reload diffing.

## Passing it to the assembly

**The structural fix is a machine IR (MIR)** between selection and printing: machine instructions with vregs and physregs, block structure, and metadata attached. Asm text becomes just one printer for it, and object emission can encode it directly and skip the text parse. Right now `machine_opt` and `macro_fusion` are IR passes doing machine-level work, and an MIR gives them and your post-RA passes (scheduling, coalescing, block placement) a proper home.

What to emit or carry through:
- `.file` and `.loc` for line tables, or your own line table directly, so traps and the debugger can map code back to Mu source.
- CFI directives, which give you backtraces for crash reports even without EH.
- Per-function and per-global sections, so the linker can drop dead code. You already have hot and cold sections in `AsmObject`.
- `.type`, `.size`, visibility and weak binding, alignment from metadata, and loop-header alignment.
- Safepoint and stack maps (return address to live root locations) for your `gc` ops and coroutines. These need the post-regalloc `valData` locations at each call site.
- Reflection tables and an ABI-version note as read-only data.
- Optional IR-as-comments in the asm, like `-fverbose-asm`. It's free and helps debugging.

## Order I'd do it in
1. Metadata infrastructure with merge policies, load/store flags, `assume`, and `noalias` from the borrow checker.
2. Nominal structs, `DataLayout`, and `StructLayout` with GEP-by-field. Reordering falls out of this.
3. MIR.
4. SSA regalloc and the e-graph, which are bigger rewrites.

I'd hold off on the struct-reordering pass until the layout is decoupled, since everything else in that section depends on it.

The way to avoid massive rewrites is to make replacement a per-component swap with a safety net, not a flag day. You need three things, in this order: shared infrastructure, a way to prove a replacement is equal or better, and a migration path per subsystem. I'm going from your API doc, so I don't know how your passes are structured inside.

## 1. Infrastructure first
- **Move the global flags into an options struct (G15).** Side-by-side runs with different settings in one process can't work with `gUnrollEnabled` and friends as globals. Do this before anything else.
- **Give passes metadata.** A `PassInfo {name, requires, preserves, version}` in place of the bare `PassFn`. Track analyses per analysis ID, not one global `analysisGeneration`, so a pass that preserves the domtree doesn't force a rebuild. In debug builds, verify the claim: after a pass says it preserves X, recompute X and compare.
- **Add a change journal.** Have `erase`, `replaceAllUses`, `addInst`, and `addSucc` push into a log the pass manager can read. Then passes can run incrementally on a dirty set, and old and new passes can hand each other "these instructions changed" without rescanning.
- **Key analysis caches by ID**, not fixed fields like `aliasAnalysis` and `memorySSA`. New passes register new analyses without touching `irtypes.crl`.

## 2. Flatten in two steps, not one
Jumping straight to an e-graph is the big rewrite. A cheaper intermediate step:
- **One worklist combiner with per-opcode visitors.** Change `algebraic`, `peephole`, `idiom`, `involution`, `comm_canon`, `cast_elim`, and `idempotent` from `bool pass(IrFunc*)` into `bool visit(IrInst*, Ctx*)`, and run them all from one driver that revisits users of any changed instruction. This only works if those passes are already local rewrites, so check each one. `lex_canon` should run last, and `macro_fusion` is machine-level, so leave both out.
- **Put simple rewrites in data** (`pattern -> replacement`) where you can. The legacy visitor driver and a later e-graph can both load the same table, so the rules survive the engine swap.
- The e-graph then replaces the combiner driver, not 9 separate files.

## 3. Running things side by side
- **Name your pipelines.** Keep `pipelineLevel3` as is and add `pipelineLevel3v2`, chosen by option, env var, or a per-function metadata attribute. That lets you migrate one module or function at a time.
- **Shadow mode.** Clone the function (your inliner already clones callee IR), run the old pipeline on one copy and the new on the other, then compare:
  - `validate` passes on both
  - interpreter outputs match on test inputs (this is where the IR interpreter pays off)
  - cost metrics: instruction count, final asm size, and later estimated cycles
  Log any function where the new result is worse or different. Shadow clones leak since IR is never freed (G10), so run shadow mode in a per-compile mimalloc heap and destroy it afterward.
- **Extend pass bisecting** to cover both pipelines, so a diff points at one pass invocation.

## 4. Communication between old and new
- **Facts as metadata with merge policies.** Ranges, known-bits, `noalias`, and `assume` are written by one pass and read by others. That's how old and new passes cooperate without knowing about each other.
- **Run sequentially, never concurrently, on the same function.** Passes mutate in place, so "side by side" means two copies or two phases, not two threads on one IR. For an e-graph, convert a region (block or loop body) to the graph, extract, and write back. Passes before and after still see ordinary IR. On extraction, carry `debugLoc` and metadata through using the merge rules, or you'll silently lose them.

## 5. Per-subsystem migration
- **Register allocation.** `lsra` and `graph` already share the signature `irXRegAlloc(func, userdata, abi, cfg)` and the driver picks one. Add the SSA allocator as a third behind the same signature, and select it by option.
- **MIR.** Build it as a new path next to `*Asm`, not a replacement. Lower to MIR and print through the existing emitters at first, then move selection logic into MIR gradually. Compare old and new by assembling both and running the same test programs.
- **Struct layout.** Keep `irTypeSizeOf` and `irTypeAlignOf` as thin wrappers that call the new layout query. Allow nominal and structural struct types to coexist (a flag on the type) while you migrate callers.
- **Retire an old pass** only when the new one has a clean fuzz run, matching tests, and no worse metrics on a benchmark set. Delete the old one in the same commit.

## Order
1. Options struct.
2. `PassInfo`, journal, and ID-keyed analyses.
3. Shadow harness and the interpreter.
4. Visitor combiner.
5. Then the big components (e-graph, SSA regalloc, MIR, layout), one at a time.

If you paste `peephole.crl` and `pipelineLevel3`, I can tell you how hard the visitor conversion would be.
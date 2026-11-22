# Coral Compiler TODO

## Modules & Imports
- [x] Fix qualified type paths `module::Type` — parser keeps full `a::b::C` name, sema resolves via module members, `bitset::Bitset` + `bitset::Bitset::new()` work end-to-end
- [x] Circular imports resolve (foo↔goo↔ioo test moved wrong/ → works/)
- [ ] Make IR backend work as actual modules (not single TU)
- [ ] More test files for module/import scenarios (sibling use, selective use, qualified paths, circular)

## References & Edge Cases
- [ ] Test reference-to-array-element binding (`i32& r = arr[1]`)
- [ ] Test array decay vs pointer-to-array (`&arr` vs `arr`)
- [ ] Test reference in conditional expressions
- [ ] Test reference in generic struct fields
- [ ] Test reference method calls on generic types

## IR Backend Audit
- [ ] Check CODEGEN_GAPS.md for documented gaps, implement in muvm codegen (skip C backend)
- [ ] Verify all error paths reach upper pipeline before codegen
- [ ] naked attribute constraints: only inline asm blocks, no args, no locals, not on methods
- [ ] Inline asm must hard-error on targets that cannot carry it (wasm32/wasm64)
- [ ] Give IR printer output more styling/formatting
- [ ] wasm32 gaps: ExtractValue/InsertValue, aggregate locals, SIMD v128 vs scalarize decision, Switch compare/select chains vs br_table
- [ ] arm64: emit .pdata/.xdata unwind info for Windows (currently SEH cannot unwind through fast-backend frames)
- [ ] arm64: >16-byte aggregate returns and call args (x8 indirect-result path)

## Optimizer (muvm)
- [x] Inlining policy: hints-only at O0/O1/Debug, cost model at O2/O3; simplifycfg flattens post-inline CFG; parallel-edge phi bug fixed
- [x] Ported: unroll, tco, sroa, select_to_branch, comm_canon, idempotent, involution, cast_elim, dse, macro_fusion, alias_analysis (points-to + escape marking, published to FunctionAnalysisCache), idiom (rotl/rotr/bswap/minmax/abs/fma), range (interval merge; branch-elim half of wallvm range was provably inert, skipped)
- [x] Rotate width fixes: x86_64 rol/ror suffix by operand width, arm64 w-regs + 32-bit modulus for <=32-bit (both were 64-bit-only, corrupting narrow rotates); runtime-verified x86/arm64/wasm
- [x] Test infra: muvm_tool --only <pass> single-pass isolation; run_aa.sh + run_pass.sh golden runners; cases_aa(17)/cases_dse(12)/cases_macro_fusion(8)/cases_fcmp_const(24) fixtures, runtime-verified on x86_64/arm64/wasm32
- [x] fcmp backend fixes: x86_64 (fcmpPred+PF mask ported from wallvm), arm64 (verified NZCV: Olt->mi, Ole/One combos, Uge->hs), wasm32 (Ueq/One were miscompiled — also wrong in wallvm)
- [x] Optimizer audit (physical, per-pass isolation vs --noopt baseline, diffs read): fixed fold same-arm select (check order), loop_cse was dead (reordered after licm + isSafeToSpeculate alloca/global-rooted pointers only + gVerbose gate), loop_detect now detects single-block (self-edge) loops — licm/loop_cse/unroll/loop_canon all benefit; new select_sidefx + involution fixtures (zero coverage before); verify-each 508 runs clean, run.sh 140/0
- [ ] Audit CFG-mutating passes for duplicate-predecessor/parallel-edge hazards (jump_thread, branchprop, licm, loop_cse, sccp, gvn, mem2reg, ipa_cp) — verify-each over full corpus
- [x] memory_ssa + machine_opt ported: store-to-load forwarding (must-alias + dominance + region scan) and AA-based dead-store elim at O2/O3 after dse; atomic loads excluded from forwarding (wallvm bug), 7 isolation fixtures + runtime verified, fires on dist_swap
- [ ] Port remaining wallvm passes: loop_distribute, loop_interchange
- [x] simd_vec ported: constant-trip-count vectorizer, O2 cheap tier (elementwise only, no reductions, vf*4 min iters) + O3 full (adds int sum/unsigned min/max reductions); unroll+tail_dup run at BOTH O2 and O3 (only unported passes stay O3-only); fixed wallvm bugs — icmp-last-inst check rejected all real loops, reduction phi pair order assumed, unclaimed in-loop load/store now rejected (widening changes dynamic counts — was a miscompile); x86_64/arm64 emitters gained per-lane vector Load/Store (was single scalar access — runtime-caught); 15 fixtures in cases_simd, runtime-verified x86_64 O0/O2/O3
- [x] slp_vec ported: SLP/straight-line vectorizer for unrolled scalar chains — packs consecutive-offset gep/load groups into vector loads, isomorphic ALU chains (operand lane-map or broadcast) into Vec* ops, and lane-aligned stores into vector stores; cheap tier (O2) skips broadcast-store packing; odd tails stay scalar; snapshot-based scanning (insertBefore mutates insts mid-scan), ADCE sweep after packing for orphaned geps, nextId bumped past numeric source names (printer %name/%id namespace collision → ambiguous reparse); extractelement inserted for surviving scalar uses; 3 fixtures in cases_slp + expected_slp_vec goldens; vec_add packs 16 elems → 8 vector groups at O2 AND O3, real coralc pipeline verified (vadd.crl exit 45)
- [ ] Vectorizer unlock roadmap (analysis-limited rejections, in order): signed min/max reductions (add VecSMin/VecSMax or per-lane select), constant-shift GEP a[i+k] (unit-stride + offset), runtime alias versioning (points-to fast path + runtime overlap check for UNKNOWN — biggest unlock), runtime trip-count + scalar epilogue, width-grouped vectorization for mixed elem widths
- [ ] Vectorizer rejections that stay fundamental: atomics/fences, early exits/side branches (needs if-conversion+masking), float reductions without fast-math, calls in loop (needs loop_distribute first)
- [ ] scalar_evolution pass (docs/scalar_evolution.md — LLVM IndVars/CR chains of recurrences): O3-only when ported; enables exit-value rewriting/loop deletion; watch overflow-widening rules
- [x] range: 12 golden fixtures + 54 runtime checks; fixed 3 wallvm bugs in port — u64-wrap gap check, || vs && unbounded sentinels (unsound union merges), insert-before-reject infinite loop
- [ ] Deliberately skipped as unsound: branch_inversion (CFG corruption), branch_factoring (incomplete CFG check), lex_canon (orphan chains; sort covered by comm_canon)
- [ ] Rejected: borrowcheck (diagnostic-only alias-violation reporter, not an optimization — declined)
- [ ] Port wallvm passes (backend-adjacent, decide fit for fast backend): lower_phis, stack_layout, peephole (only unique patterns x+x->shl, x*-1->neg — already added to algebraic), validate

## Attributes
- [x] Attribute args captured (align(N)/entry(addr)/deprecated("…") were silently dropped); entry requires address, once per program, chains with naked; naked = asm-only body contract; incompat pairs → T0068; bench/link/extern-attr/generate* removed; simd→muvm vector type; threadlocal/noalias/vectorise propagate or hard-error on muvm
- [ ] Audit which attributes exist vs are honored; add missing attributes and honor them through sema/IR/backend
- [x] vectorise attributes (docs/vectorize-attributes.md): [[vectorise]]/[[vectorise(N)]]/[[novector]] at fn level → !vectorize/!vectorize.width/N/!novector metadata; loop-level attrs on for/while heads → !vectorise.loop/!novector.loop on header terminator; simd_vec honors marks (marked-only at O0/O1, width cap, novector opt-out incl. inside vectorised fns); test/coral/should work/vec_attr_{fn,loop,runtime}.crl verified O0/O2/O3
- [ ] fastmath/reassoc attribute → unlocks float reductions in simd_vec (only legal with reassociation permission); attributes gate legality-relaxing transforms, never make illegal ones legal
- [ ] simd struct attribute → fixed-vector IrType element-wise lowering (explicit-SIMD escape hatch)

## Parser / diagnostics
- [x] `goto` + `ident:` labels → single P0030 unsupported-syntax error (was: parsed as decl, cascading errors)
- [ ] Patterns in muvm IR: wildcard/lit/const/ident/or/range/guard lowered; variant/tuple/struct/type patterns hard-error by name — variant layout itself is still an opaque blob (Phase 3), implement layout then patterns + bindings

## Build system / modules
- [x] `.crlb` `target` field honoured: translated to platform=/arch= flag pairs (native-<arch> = host OS, arch/os passthrough, bare arch + host OS); explicit pairs win; `bytecode` errors E1013; unrecognized flags warn W2001
- [ ] Module registry: lib-level .crlb manifest pointing to std modules, each std module with its own manifest + conditional platform config — replace truncated x86_64/linux probing and hardcoded std jumps
- [ ] Per-module `override` opt/flags are fingerprinted but never applied (single-TU compile) — decide: apply globally, error, or document
- [ ] `flags` honoured end-to-end audit: which crlb flags map to real compile options vs only the flag() table

## Prelude
- [ ] Shift default prelude to only str.crl, result.crl, option.crl

## Testing
- [ ] Generate lots of random invalid programs (use unfamiliar subagents to write them) — compile all, verify errors are formatted/reported properly
- [ ] Fix 'should work' tests that are failing
- [ ] Add tests for all discovered edge cases
- [ ] Test under different optimization levels

## Error Reporting (finish polish)
- [ ] Uninitialized-variable tracking: emit W0019/T0047 (groundwork in scope.crl)
- [ ] Fix remaining cascading errors (e.g. `return x.;` → T0030)
- [ ] Finish error-message polish across all error creation sites
- [ ] Ensure consistent error formatting across all diagnostic types
- [ ] Add source location context to all errors

## Build System
- [ ] Fix build system issues and docs coverage
- [ ] Polish frontend and args passing
- [ ] Run compiler under ASAN
- [ ] Check docs/markdown files for reported failing cases

## muvm backend bugs (verified 2026-11-22)
- [ ] `std::string::String` segfaults under `--muvm`: `String s; s.pushChar('a'); s.appendView(...); s.asView()` crashes — heap-growth path (push/append realloc) broken; consequently `std::fmt::format` (String sink) cannot run under muvm. C backend fine.
- [ ] muvm float/varargs bugs: `println("{}", 3.14159)` prints `9.53e-130` (garbage f64), `println("{}", 1.5f)` prints `0`, `{:f}` f64 prints `0.000000` (f32 works). f64 ABI/varargs lowering broken — unrelated to format impl.

## Language features
- [ ] `eq` trait design: types implementing it may use `==`/`!=` (and decide relational ops); replace the sema aggregate-comparison ban with trait-gated equality. Decide whether it subsumes the `(any toStr)` comptime arm in print/format — i.e. trait-based automatic conversion vs keeping comptime pattern matching. Needs design decision on scope first.
- [ ] Union/variant IR representation: variant stored like a C tagged union (`{i32 tag; union payload}`, tag = case ordinal); union = byte blob + bitcast field access. Design doc written: `docs/union-variant-ir.md` — no new IrTypeKind needed, all lowering lives in coral-ir.
- [ ] Per-module muvm codegen: compile projects as real modules, not one big translation unit.
- [ ] wasm target: muvm assembler pipeline instead of gcc for muvm-generated assembly; stream assembler errors from the text buffer to the user; add wasm target.

## Language Cleanup
- [x] Remove all compiler `cchar` hardcodes — `cchar` is a library `distinct` over `flag(arch)`; `C"..."` types as `const u8*` and binds to any integer pointer; bare module name in type position errors "is a module, not a type"; ~40 lib files now import `core::cchar { cchar }` explicitly
- [ ] Strip 'static' keyword; mark methods without self as static
- [ ] Remove remaining 'as' references if any
- [ ] Quality of life polishes

ref: ""test a lot more edge cases, even references as arguments during declaratiopn. then reference supports in the ir. then the parts of the ir backend of the compiler specifically said to not be supported, and search for things not even supported at all. make sure you run far too many tests. to catch secretly failing or unreported cases. error issues. beatify and structure the error report for all error cases, not some looking trashy and otehr lookig good and reported well. make sure errors are more understandable and less generic("expected an expression alwasy" kind of generic) and more. then the cascading error, then, the build system, there are many issus with it and parts of it's docs not covered. then after that. polishing of the fromtend and args passing. polishng of the args. then running the compiler under asan. also, you may look around the docs and other text or markdown files for things that are reported as failing cases. then also, making the ir backend for projects not work as a single transation unit, but in actual modules. also the test that are marked as hsould work but fail, make them work. then later on, strippig of the static keyword completely, and in it's use sites. we check if self is in a methid alreasdy, so methods with we can jsut mark methods that don't use self as static. and the ones that do as methods. then you'll be free to do any quality of life polishes. and other stuff. " add thses to a todo file and implement one by one, in order." 

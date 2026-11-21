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
- [x] Ported: unroll, tco, sroa, select_to_branch, comm_canon, idempotent, involution, cast_elim, dse, macro_fusion, alias_analysis (points-to + escape marking, published to FunctionAnalysisCache)
- [x] Test infra: muvm_tool --only <pass> single-pass isolation; run_aa.sh + run_pass.sh golden runners; cases_aa(17)/cases_dse(12)/cases_macro_fusion(8)/cases_fcmp_const(24) fixtures, runtime-verified on x86_64/arm64/wasm32
- [x] fcmp backend fixes: x86_64 (fcmpPred+PF mask ported from wallvm), arm64 (verified NZCV: Olt->mi, Ole/One combos, Uge->hs), wasm32 (Ueq/One were miscompiled — also wrong in wallvm)
- [ ] Audit CFG-mutating passes for duplicate-predecessor/parallel-edge hazards (jump_thread, branchprop, licm, loop_cse, sccp, gvn, mem2reg, ipa_cp) — verify-each over full corpus
- [ ] Port remaining wallvm passes: idiom (rotl/bswap/select->smin/smax/abs), range (interval analysis), memory_ssa + machine_opt (store-to-load forwarding via AA), loop_distribute, loop_interchange
- [ ] Deliberately skipped as unsound: branch_inversion (CFG corruption), branch_factoring (incomplete CFG check), lex_canon (orphan chains; sort covered by comm_canon), borrowcheck (diagnostic-only, not an optimization)
- [ ] Port wallvm passes (backend-adjacent, decide fit for fast backend): lower_phis, stack_layout, peephole (only unique patterns x+x->shl, x*-1->neg — already added to algebraic), simd_vec (deferred — vectors scalarized per earlier decision), validate

## Attributes
- [ ] Audit which attributes exist vs are honored; add missing attributes and honor them through sema/IR/backend

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

## Language Cleanup
- [x] Remove all compiler `cchar` hardcodes — `cchar` is a library `distinct` over `flag(arch)`; `C"..."` types as `const u8*` and binds to any integer pointer; bare module name in type position errors "is a module, not a type"; ~40 lib files now import `core::cchar { cchar }` explicitly
- [ ] Strip 'static' keyword; mark methods without self as static
- [ ] Remove remaining 'as' references if any
- [ ] Quality of life polishes

ref: ""test a lot more edge cases, even references as arguments during declaratiopn. then reference supports in the ir. then the parts of the ir backend of the compiler specifically said to not be supported, and search for things not even supported at all. make sure you run far too many tests. to catch secretly failing or unreported cases. error issues. beatify and structure the error report for all error cases, not some looking trashy and otehr lookig good and reported well. make sure errors are more understandable and less generic("expected an expression alwasy" kind of generic) and more. then the cascading error, then, the build system, there are many issus with it and parts of it's docs not covered. then after that. polishing of the fromtend and args passing. polishng of the args. then running the compiler under asan. also, you may look around the docs and other text or markdown files for things that are reported as failing cases. then also, making the ir backend for projects not work as a single transation unit, but in actual modules. also the test that are marked as hsould work but fail, make them work. then later on, strippig of the static keyword completely, and in it's use sites. we check if self is in a methid alreasdy, so methods with we can jsut mark methods that don't use self as static. and the ones that do as methods. then you'll be free to do any quality of life polishes. and other stuff. " add thses to a todo file and implement one by one, in order." 

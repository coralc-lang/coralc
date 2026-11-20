# Coral Compiler TODO

## Modules & Imports
- [ ] Fix qualified type paths `module::Type` (parser drops qualifier; `bitset::Bitset` fails) — do before other module work
- [ ] Circular imports should resolve rather than causing cascading errors
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
- [ ] Strip 'static' keyword; mark methods without self as static
- [ ] Remove remaining 'as' references if any
- [ ] Quality of life polishes

ref: ""test a lot more edge cases, even references as arguments during declaratiopn. then reference supports in the ir. then the parts of the ir backend of the compiler specifically said to not be supported, and search for things not even supported at all. make sure you run far too many tests. to catch secretly failing or unreported cases. error issues. beatify and structure the error report for all error cases, not some looking trashy and otehr lookig good and reported well. make sure errors are more understandable and less generic("expected an expression alwasy" kind of generic) and more. then the cascading error, then, the build system, there are many issus with it and parts of it's docs not covered. then after that. polishing of the fromtend and args passing. polishng of the args. then running the compiler under asan. also, you may look around the docs and other text or markdown files for things that are reported as failing cases. then also, making the ir backend for projects not work as a single transation unit, but in actual modules. also the test that are marked as hsould work but fail, make them work. then later on, strippig of the static keyword completely, and in it's use sites. we check if self is in a methid alreasdy, so methods with we can jsut mark methods that don't use self as static. and the ones that do as methods. then you'll be free to do any quality of life polishes. and other stuff. " add thses to a todo file and implement one by one, in order." 

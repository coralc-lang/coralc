# Coral Compiler TODO

## Reference & Edge Cases
- [ ] Test reference edge cases (args during declaration, nested refs, ref arrays, ref in generics)
- [ ] Verify reference support in IR lowering and backend
- [ ] Test reference-to-array-element binding (`i32& r = arr[1]`)
- [ ] Test array decay vs pointer-to-array (`&arr` vs `arr`)
- [ ] Test reference in conditional expressions
- [ ] Test reference in generic struct fields
- [ ] Test reference method calls on generic types

## IR Backend Audit
- [ ] Audit IR backend for explicitly unsupported constructs
- [ ] Search for constructs not supported at all (silent codegen failures)
- [ ] Check CODEGEN_GAPS.md for documented gaps, mark in the codegen gap doc and implement them in the muvm codegen for the compiler. you can skip implementation in the c backend.
- [ ] Verify all error paths reach upper pipeline before codegen.
- [ ] naked attribute should have constraints, the function can only have an inline asm block or a couple of them, no arguments, no local variables. it should also not be available on methods.
- [ ] Inline asm must be a hard compile error on targets that cannot carry it (wasm32/wasm64, and any future non-asm backend) — reject in the frontend/backend dispatch with a proper diagnostic, not a codegen-time failure.

## Testing
- [ ] Run extensive test suite to catch secretly failing cases
- [ ] Fix 'should work' tests that are failing
- [ ] Add tests for all discovered edge cases
- [ ] Test under different optimization levels

## Error Reporting
- [ ] Beautify and structure error reports for all error cases
- [ ] Make error messages more understandable and less generic
- [ ] Fix cascading error issue from error_issues.md
- [ ] Ensure consistent error formatting across all diagnostic types
- [ ] Add source location context to all errors

## Build System
- [ ] Fix build system issues and docs coverage
- [ ] Polish frontend and args passing
- [ ] Run compiler under ASAN
- [ ] Check docs/markdown files for reported failing cases
- [ ] Make IR backend work as actual modules (not single TU)

## Language Cleanup
- [ ] Strip 'static' keyword; mark methods without self as static
- [ ] Remove remaining 'as' references if any
- [ ] Quality of life polishes
- [ ] Other compiler improvements

ref: ""test a lot more edge cases, even references as arguments during declaratiopn. then reference supports in the ir. then the parts of the ir backend of the compiler specifically said to not be supported, and search for things not even supported at all. make sure you run far too many tests. to catch secretly failing or unreported cases. error issues. beatify and structure the error report for all error cases, not some looking trashy and otehr lookig good and reported well. make sure errors are more understandable and less generic("expected an expression alwasy" kind of generic) and more. then the cascading error, then, the build system, there are many issus with it and parts of it's docs not covered. then after that. polishing of the fromtend and args passing. polishng of the args. then running the compiler under asan. also, you may look around the docs and other text or markdown files for things that are reported as failing cases. then also, making the ir backend for projects not work as a single transation unit, but in actual modules. also the test that are marked as hsould work but fail, make them work. then later on, strippig of the static keyword completely, and in it's use sites. we check if self is in a methid alreasdy, so methods with we can jsut mark methods that don't use self as static. and the ones that do as methods. then you'll be free to do any quality of life polishes. and other stuff. " add thses to a todo file and implement one by one, in order." 

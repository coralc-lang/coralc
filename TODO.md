# Coral Compiler TODO

## Modules & Imports
- [x] Fix qualified type paths `module::Type` — parser keeps full `a::b::C` name, sema resolves via module members, `bitset::Bitset` + `bitset::Bitset::new()` work end-to-end
- [x] Circular imports resolve (foo↔goo↔ioo test moved wrong/ → works/)
- [ ] Make IR backend work as actual modules (not single TU)
- [ ] More test files for module/import scenarios (sibling use, selective use, qualified paths, circular)

## References & Edge Cases
- [x] Reference-to-array-element binding (`i32& r = arr[1]` mutates through) — verified
- [x] Array decay vs pointer-to-array: `i32* p = arr` decays; `i32[3]* pa = (i32[3]*)p` pointer-to-array view — verified
- [x] Reference in conditional expressions: `i32& r = c ? a : b` binds; `(c ? a : b) = v` assigns through (ternary lvalue: sema `isLvalueExpr` + backend pointer-select lowering)
- [x] Reference in generic struct fields: `Box<i32&>` literal `{ .v = r }`, read, and write-through all verified — `cgFindFieldTy` now zips the Named type's genericArgs with the decl's genericParams and runs mono `substituteType` on the field type
- [x] Reference method calls on generic types: `c.bump(i32&)` mutates arg, `i32& get()` returns assignable lvalue, `Wrap<T>::setV(T&)`/`refV()` verified

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
- [x] `std::string::String` segfaults under `--muvm` — FIXED (multiple root causes): (a) `(void)x` cast emitted a void bitcast whose "result" wrote slot 0 = saved %rbp; (b) aggregate alloca shared one region for pointer slot + pointee so field-0 stores clobbered the pointer; (c) aggregate globals sized `(width+7)/8` though width is already bytes — allocator globals were truncated; (d) reference args got values not addresses. Verified: pushChar/appendView growth to 5000+ chars, 20k alloc/dealloc cycles, `fmt::format` all run clean under --muvm.
- [x] muvm float/varargs bugs — FIXED, three independent causes: (a) extern C-ABI calls put float args in GP regs and read int returns only — x86_64 backend now splits int/xmm streams, sets AL for varargs, reads xmm0 float returns, and passes >6-arg calls on the stack (16-aligned); (b) internal calls silently DROPPED args past 6 registers — caller now pushes them and the callee prologue reads rbp+16+8j; (c) comptime eval dropped casts on runtime values (`(f64)f32val` emitted the raw f32) — Cast now re-roots but keeps the conversion; (d) `ios::println`-style qualified generic calls were never collected for monomorphization (collectCall only handled Ident callees) AND muvm's path resolver rejected generic module funcs — both fixed, `use std::ios; ios::println(...)` now works on both backends. Verified: sqrt/sqrtf/snprintf %.3f/%.*f/%d %f, println f32/f64/{:f}, 8/12-arg internal calls — muvm output identical to C backend.
- [x] mimalloc `_miRandomU64` overflow trap — LCG `state*C+A` overflows u64 and muvm's safety pass traps on checked add/sub (C backend wraps). Replaced with xorshift64 (XOR+shifts only) in linux+windows mimalloc.
- [x] `str`/`slice` → pointer cast returned the {ptr,len} struct address — muvm Cast arm now loads field 0 (the data pointer) for TypeKind::Str/Slice → Pointer/Rawptr targets. `(const u8*)"lit"` and `(const u8*)strVar` verified.
- [x] x86_64 sub-64-bit int ops emitted 64-bit forms (`cmpq`/`idivq`/`sarq`/`shrq`/`negq`) while slot values carry producer-dependent upper bits (consts/loads zero-extend, `neg`/arith sign-extend) — width-aware ICmp (cmpl/cmpw/cmpb), SDiv/UDiv/SRem/URem (cltd/cdq/cbw/cwtl setup + width idiv/div), Shl/Lshr/Ashr (shl/shr/sar suffix + %cl) now emitted; miscompiles were opt-level-dependent (`-7/2`, `-7>>1`, `a != -2`, u32 compares). Regression: `test/coral/should work/int_width_ops.crl` (i32/u32/i16/i8 div/rem/shift/cmp, O0–O3).
- [x] `(u64)V::Case` cast produced a pointer-truncated aggregate bitcast — `ExprKind::Path` always yields the tagged-struct form for variant cases; Cast now intercepts variant-case paths to integer targets and emits the ordinal const (C backend `cgVariantCaseIdx` parity). Found via `variant_ast_like.crl` check `score(outer2) == 3 + (u64)Node::Int`.

## coral-ir backend gaps (found via std::result/std::option [[noprelude]] test)
- [ ] `Option<T>::None` / `Result<T,E>::Ok` bare-path unit-case construction: `ExprKind::Path` with a generic type segment (`Option<T>`) isn't an `Ident`, so the V::Case ordinal path misses and it falls through to the last segment → "unresolved identifier". Used by `Option::take` (`self = Option<T>::None`) — blocks ANY use of Option<T>/Result<T,E> because all methods of a used generic variant get lowered, called or not.
- [ ] `Result<i32,i32>::Ok { .value = 40 }` as a local initializer → "unsupported assignment target" (muvAddrOf has no case for the variant-construction expr in decl-init position); return-position construction works.
- [ ] Path→ordinal const can't be assigned to a variant lvalue — `V::Case` in value position yields i32 tag ordinal (fine for `x.tag = V::Case` / compares), but `self = Option<T>::None` needs a real tagged-struct construction for unit cases.
- [x] plain `enum` member paths in expression position (`Color c = Color::Blue;`) — FIXED: `ExprKind::Path` resolves `Enum::Member` via `muvEnumMemberConst` (declaration-order running value, explicit `= N` incl. negative resets the counter, same rules as switch-pattern lowering); verified `enum` explicit/implicit/negative members at O0–O3 (`test/coral/should work/` probes + `int_width_ops.crl`)
- [ ] std::result/std::option noprelude fixture: `test/coral/should work/std_result_option_noprelude.crl` (unwrap/unwrapErr/isOk/isErr/unwrapOr paths compile once the above land; @assert/@assertOut resolve via core::error under noprelude, as it should only be blocked by freestanding, and not noprelude)
- [ ] float `%` on f32/f64 → "float modulo (needs fmod lowering, Phase 2)": sema lets it through, C backend emits invalid C `%` too — needs an `fmod` libm call lowering in coral-ir (std::math::fmod exists as extern)
- [ ] non-constant static/global initializer (`i32 h = g + 2;` at file scope) → "initializer of static storage must be a constant (Phase 3)": needs runtime init (ctor-style init fn or lazy init); C backend emits it and gcc rejects too — shared gap
- [ ] compound assign on aggregate (`p += q` where p is a struct) slips past sema's add-trait check (plain `p + q` is rejected) and hits "compound assign on aggregate (Phase 2)" — sema gap first, backend would need element-wise or trait dispatch anyway
- [ ] `[[threadlocal]]` globals → hard error in muvm (C backend compiles, probably incorrectly — no `__thread` emitted); unused in lib/ today
- [ ] tuple/struct/type patterns in switch/let → sema rejects bindings before backend ("undeclared identifier"), so PatKind::Tuple/Struct/Type hard-errors in stmt.crl are unreachable today; revisit if sema learns pattern bindings
- [ ] nested aggregate literals (`i64[2][2] m = { {1,2}, {3,4} }`, `struct(i32,i32)[2] = { {1,2}, {3,4} }`) → inner bare literal gets no `resolvedType` (sema `coerceArrayLit`→`findMemberByIndex` has no `TypeKind::Array`/`Tuple` element case) → backend "array/tuple literal needs an aggregate type". C backend handles it. Sema fix is one case; explicit `P { ... }` elements already work
- [x] aggregate ternary/if/switch expressions: were "(Phase 2)" hard-errors — now lowered via `muvAggSlot` + `muvArmStore` (element-wise `muvCopyAgg` per arm, slot address is the value); verified `test/coral/should work/agg_expr.crl` at O0–O3
- [x] dynamic-index gep typing: `irBuilder.gep` broke type descent on the first non-constant index, so `gep arr, i` stayed `ptr array` — chained field geps then added element size instead of field offset (`P[3] gs; gs[i].b` read `a[i+1]`). Array/vector indices now descend on const AND dynamic indices (matches irParser); struct/union still require const field index. Fixture: `array_struct_dynidx.crl`

## Language features
- [x] `eq`/`add` builtin traits: `extend T : eq` requires `eq`+`ne`, `extend T : add` requires `add`+`addAssign`; sema rewrites `==`/`!=`/`+`/`+=` to method calls (same-type operands only); aggregate ops rejected without the trait; builtin trait names reserved (no user trait named `eq`/`add`/`iter`/`drop`/`toStr`); `@name` spelling rejected by parser — builtin traits are bare names now
- [x] `toStr` implicit conversion: any `str` target (init/arg/return/ternary/assign) accepts a type with a `toStr` method — sema rewrites the expr node to `value.toStr()` via `tryToStrConvert` in `assignCompatible`; `(any toStr)` comptime arm in print/format stays for pack dispatch
- [x] Union/variant IR representation: `IrTypeKind::Union` first-class type (fields overlap at offset 0, size=max field, align=max field align, `[[align(N)]]` floor); variant = `{i32 tag; union payload}` lowered in coral-ir; union GEP = field-index selector at offset 0 on all backends (x86_64/arm64/wasm32 + parser/builder type descent); aggregate load/store/call/ret treat union like struct (shared existing gap, no worse)
- [ ] Per-module muvm codegen: compile projects as real modules, not one big translation unit.
- [ ] wasm target: muvm assembler pipeline instead of gcc for muvm-generated assembly; stream assembler errors from the text buffer to the user; add wasm target.

## Language Cleanup
- [x] Remove all compiler `cchar` hardcodes — `cchar` is a library `distinct` over `flag(arch)`; `C"..."` types as `const u8*` and binds to any integer pointer; bare module name in type position errors "is a module, not a type"; ~40 lib files now import `core::cchar { cchar }` explicitly
- [x] Strip 'static' keyword entirely — methods infer static vs instance from `self` usage (parser bit 32 + explicit-self-param, swept in `checkBodies` before any body check); keyword removed from lexer/parser/TokenKind; ~620 decl sites stripped across lib/, compiler/, ~/Documents/Mu; local `static` vars hoisted to file scope (mimalloc `_miRandomState`); dead `flags&4` var paths cleaned in sema/IR/C backend
- [ ] Remove remaining 'as' references if any
- [ ] Builtin `@name` vs bare-identifier namespacing: builtins require `@` (`@sizeof`, `@typeof`, …); a user function/variable named `sizeof` called without `@` must be treated as a NORMAL identifier (subject to normal lookup/shadowing penalties), not error with "sizeof is declared with @". `sizeof` and `@sizeof` are different things — audit every builtin-name collision path (decl + call sites).
- [ ] Quality of life polishes

ref: ""test a lot more edge cases, even references as arguments during declaratiopn. then reference supports in the ir. then the parts of the ir backend of the compiler specifically said to not be supported, and search for things not even supported at all. make sure you run far too many tests. to catch secretly failing or unreported cases. error issues. beatify and structure the error report for all error cases, not some looking trashy and otehr lookig good and reported well. make sure errors are more understandable and less generic("expected an expression alwasy" kind of generic) and more. then the cascading error, then, the build system, there are many issus with it and parts of it's docs not covered. then after that. polishing of the fromtend and args passing. polishng of the args. then running the compiler under asan. also, you may look around the docs and other text or markdown files for things that are reported as failing cases. then also, making the ir backend for projects not work as a single transation unit, but in actual modules. also the test that are marked as hsould work but fail, make them work. then later on, strippig of the static keyword completely, and in it's use sites. we check if self is in a methid alreasdy, so methods with we can jsut mark methods that don't use self as static. and the ones that do as methods. then you'll be free to do any quality of life polishes. and other stuff. " add thses to a todo file and implement one by one, in order." 
- [x] Generic-fn println picks wrong pack instance — FIXED: generic-pass collect of a generic body enqueued `println<str>` with `tailTypes=[TypeParam]` (T binds from the fmt literal = concrete str while the pack arg stays a type param); the instance-pass recollect's concrete `[i32]` tail was then discarded by `enqueueInstance`'s name+args+valueKey dedup, and codegen resolved the TypeParam tail through println's own T→str sub → `_coral_str _varg0`. Fix: `enqueueVal` now skips work items whose tailTypes aren't concrete (same deferred-recollect rule as arguments), and `isConcreteType` recurses through `Reference`. Verified: `dump<i32>`/`dump<i32&>`/`dump<str>`/`dump<f32>` all print correctly; 35/35 works tests pass.
- [ ] `println("rest={}", args)` — forwarding a whole comptime pack as a call arg gives G0002 "no unique mono instance" (pack splicing edge; `dump<T>(T v, ... args)` forwarding needs a look).

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
- [x] Sub-64-bit int op width fixes ported to arm64 + wasm32 (same bug class as the x86_64 cmpq/idivq fix): arm64 — sdiv/udiv/srem/urem/icmp/select-cond/cond_br/switch-cmp/minmax/abs/ctpop/ctlz/cttz/mulhi now use w-forms for <=32 and sxt*/uxt* canonicalization for <=16 (verified: `sdiv w9`,`sxth`,`sxtb`,`cmp w9`,`cbz w9`,`uxtw` in emitted asm, `aarch64-linux-gnu-as` clean); wasm32 — `emitNarrowExtend`/`emitBinOpNarrow` emit i32.extend8/16_s/u before div/rem/icmp/shr/minmax/ctpop/select/cond_br/switch for <=16-bit operands (verified in emitted WAT; i32/i64 untouched). x86_64 win64 mode covered by the same uncommitted x86_64.crl diff (nregs=4/WIN64 regs/stack args); TargetArch::X86 (win32) has no fast backend — `muvmTargetIsImplemented` excludes it.
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
- [x] scalar_evolution pass (safe subset of docs/scalar_evolution.md): canonical single-latch pure-arith loops, affine accumulators `s += A*i+B` (incl. quadratic via TC*(TC-1)/2 with even-factor halving — exact mod 2^w, no no-wrap proofs needed), `<`/`!=` exits with unit step, const-bound `<=`/strided exits, signed exits gated on NSW; exact trip counts via guard-select; exit values rebuilt in preheader + loop blocks deleted; O3 between loop_cse and unroll; verified on loops_scalar.crl
- [x] scalar_evolution extensions: plan algebraic identities (x+0/x*0/x*1 fold — unblocked invariant-coeff accumulators like `s += x*i`, f9); const-step phi substitution (`a+=b; b+=2` chained recurrences f13–f15, requires unit up-step IV); bare trip count for `i=0;i<n;i++` shape (select(0<n,n,0)≡n — lets inner loops emit affine-in-outer-IV exit values, enabling bottom-up nested elimination: f41→n*m, f43, f50); empty/dead loops (f24, f59)
- [x] muvm inbuilt intrinsics `__muvm_intrinsic_{memcpy,memmove,memset,memcmp,strcmp}` — real IR bodies in `lib/muvm/base/intrinsics.crl` (platform-agnostic loads/stores/branches, NO libc dependency — these are for any language/frontend targeting muvm, NOT coral-specific). Materialized by `irEnsureIntrinsics(ctx, mod)` from `muvmOptimizeModule` + `muvmEmitModuleAsmForTarget`; only fills DECLARED names (extern shells/bodyless funcs passing a signature gate), real definitions and undeclared names untouched. All five carry the `vectorize` func attr so simd_vec picks up the byte loops. Verified end-to-end at O0/O3 (memcpy/memset/memcmp, memmove fwd+bwd overlap, strcmp). Fixture: `lib/muvm/test/cases/intrinsics.ir`.
- [ ] REAL O3 BUG (masked by noinline): when __muvm_intrinsic_memcpy/memset are inlined, an O3 pass (unroll or scalar_evolution) miscompiles the chunk+tail two-loop shape — n=3 tail-only case produced wrong bytes. Same shape in user code likely affected. Repro: wt_enc.ir (memset+memcpy n=3) at O3 with intrinsics inlined → returns 101 not 111. Intrinsics now carry noinline+vectorize attrs.
- [x] word-at-a-time memcpy/memset bodies — DONE in lib/muvm/base/intrinsics.crl (u64 chunks via byte-offset geps + i8 tail; no ptr bitcasts). NOTE for future IR builders: insts emitted before the first IrBuilder.pos() are ORPHANED (self.block==null → never added to a block → getSlot MISS → 0(%rbp) reads). Always pos() before emitting. wasm `memory.copy`/`memory.fill` lowering for these bodies; `__muvm_intrinsic_iterator` if needed
- [ ] Port remaining unported passes: loop_distribute, loop_interchange (safe subsets)
- [ ] More muvm pipeline polish (O2/O3 ordering, cleanup rounds toward LLVM-tightness)
- [ ] Analysis work to unlock deferred patterns SAFELY: sum-of-squares/polynomial recurrences (sumsq term), nested loops with affine inner bounds, `<=`/strided symbolic-bound exits (needs range/no-wrap proofs), chained accumulators >1 level, memory idioms (dependence analysis), conditional updates (predication)
- [ ] Tighten IR to LLVM-level-or-better on optimization: audit gaps, add missing transforms
- [ ] Tiny graph regalloc, then the proper (non-fast) backends
- [ ] wasm is GENERIC, not fast/normal — it is not regalloc-constrained so the BackendKind::Fast/Primary distinction should not apply; remove wasm32/wasm64 from the fast tier (own kind or neutral classification)
- [ ] scalar_evolution deferred detail: see analysis notes above sum-of-squares/polynomial recurrences `s += i*i`, `(i+1)*(i+2)` (f11,f12,f16 — need sumsq(tc)=tc(tc-1)(2tc-1)/6 term, same wrapping caveat as tri); chained accumulators needing >1 substitution level or non-const-step intermediates; nested loops where inner bound is affine-but-not-the-IV (f44 `j<=i` Ule guard, f45 inner `s+=j` needs cubic, f46 `s+=i*j` needs invariant*IV product coeff through emitted exprs, f47 triple nesting, f48 partially — inner folds but outer update shape still rejected, f49 strided inner tc=ceil(i/2) non-affine); geometric/multiplicative recurrences ({a,*,b}); `!=` exits with |step|≠1 (needs divisibility/coprimality proof); `<=`/`>=`/strided exits with symbolic bound (bound+1/stride wrap can diverge — needs range/no-wrap proof, e.g. n < 2^w - step); signed exits without NSW; memory idioms (needs dependence analysis); conditional updates (needs predication/if-conversion); exit values used by non-header in-loop insts (needs full renaming, not just header rebuilds)
- [x] FIXED pre-existing unroll miscompile: exit-phi on retargeted last-backedge edge now uses the testBlock pair's value (was reusing an earlier in-loop pair → f11(2) folded to 0); added domtree feasibility pre-check (def must dominate every exit pred + latch for non-phi values) so unroll bails instead of emitting malformed phis; verified f11(2)==1 at O0–O3
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
- [x] x86_64 phi edge-copy parallel-copy bug — `emitPhiCopies` did sequential slot-to-slot copies, so swap/rotation phis (`p = phi [q], q = phi [p]`) clobbered the second source. Ported arm64's staging scheme: colliding sources are copied to a 64-byte phi-temp frame area first; vector phis still copy lane-by-lane. Verified: `cases/phi_swap.ir` + `test/coral/should work/phi_swap.crl` pass O0–O3.
- [x] x86_64 second wave of sub-64-bit width bugs (same producer-dependent-upper-bits class): Switch compare chain (`cmpq`→width cmp), Abs (32/64-bit idiom + <=16 canonicalization), CtPop/CtLz/CtTz (32-bit forms + zero-extend + CtLz bias 24/16), SMin/SMax/UMin/UMax (width cmp + cmovXXl, <=16 signed/unsigned canonicalization), MulHi/SMulHi (mull/imull for <=32, <=16 canonicalize first), Bswap (i8 identity, i16 rolw $8), Rotl/Rotr (rolb/rolw for <=8/<=16 + result canonicalization). Fixture: `cases/narrow_width_ops.ir`.

## coral-ir backend gaps (found via std::result/std::option [[noprelude]] test)
- [x] `Option<T>::None` / `Result<T,E>::Ok` bare-path unit-case construction — FIXED: `ExprKind::Path` on a variant-case path now yields the tagged-struct aggregate in value position (temp alloca + tag store) while `muvCompare`/`.tag` assign intercept it to the ordinal const; generic `Option<T>`/`Result<T,E>` segments resolve through instance substitutions (`muvSubstDeep` handles `Named "T"` args + Reference). Verified: `Option::take` (`self = Option<T>::None`) writes through correctly.
- [x] `Result<i32,i32>::Ok { .value = 40 }` as a local initializer — FIXED (variant-construction expr is an aggregate lvalue via `muvAddrOf`; decl-init copies fields into the local's slot). Verified by the noprelude fixture.
- [x] `self = X` on a pointer-typed `self` writes THROUGH the receiver — FIXED in `muvAssignCommon` (lvalue = pointee when the local's slot type is `ptr`); all `self = X` sites in lib/compiler/Mu migrated to explicit `*self = X`. Sema `assignTargetType` strips `Self*`→`Self` only for `self`, so mismatched types still error. Verified: `Option::take`, `distinct Celsius` `*self` ops.
- [x] plain `enum` member paths in expression position (`Color c = Color::Blue;`) — FIXED: `ExprKind::Path` resolves `Enum::Member` via `muvEnumMemberConst` (declaration-order running value, explicit `= N` incl. negative resets the counter, same rules as switch-pattern lowering); verified `enum` explicit/implicit/negative members at O0–O3 (`test/coral/should work/` probes + `int_width_ops.crl`)
- [x] std::result/std::option noprelude fixture — PASSES under `--muvm` (rc=0, deterministic across runs, matches C). Root cause was NOT variant logic: x86_64 aggregate `store`/`sret` memcpy rounded the byte count up to whole qwords — a 4-byte union payload field at offset 4 inside an 8-byte variant struct got an 8-byte store, clobbering the next alloca slot (layout-sensitive corruption of unrelated locals). Both copy paths now emit exact-size copies (qwords + movl/movw/movb tail). NOTE: arm64 `store union` stores the pointer itself and wasm32 emits `i32.store` of the address — aggregate-by-value copies are broken on those targets (pre-existing, untested).
- [x] float `%` on f32/f64 → BANNED in sema: `checkBinary`/`checkCompoundAssign` reject `%`/`%=` when either operand is float-typed (int literals adopt the float side, distinct-over-float unwraps) with T0033 "not defined for floating-point operands" — covers binary, compound, literal-adopting, and distinct cases on both backends. If fmod lowering is ever wanted it must be a real declared function (e.g. std::math::fmod route), not a synthesized extern — the IR layer now has a comment forbidding fabricated IrFuncs.
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

## muvm optimizer tightening (Devin work queue — ordered)

Done:
- [x] ifconv — diamond→select (O2/O3); v2 load speculation via alloca/global bounds proof
- [x] ivsr — phases A (mul/shl iv,K→recurrence) + B (affine a*iv+b fold) early; phase C pointer-IV (`gep base,iv`→ptr phi) LATE only (post-vectorizers — early placement killed SLP/unroll gep patterns)
- [x] loop_unswitch (O3) — invariant cond_br in loop → two specialized loops
- [x] div/rem by pow2 → shifts (algebraic.crl)
- [x] GVN cross-block load-cache miscompile fix; ifconv operand user-registration fix
- [x] AA constant-offset decomposition: decomposeAddr → (obj, byteOff); isMustAlias same-obj+same-offset; mayClobberSized range query
- [x] irPrinter: per-block `=` column alignment + func brace spacing

Pending (in order):
- [ ] Wire mayClobberSized into memory_ssa defMayAliasLoad/findNearestDefForLoad (needs load/store type sizes plumbed through)
- [x] Fold gaps: select c,x,x→x (fold.crl:395); icmp eq/ne x,x→const (821bcd0); mul x,-1→neg (algebraic.crl allOnes→Neg, pre-existing); gep base,0 (idempotent.crl Pattern 4) — ALL DONE
- [ ] AA depth: points-to SETS for phis (currently same-object-only merge → UNKNOWN on disagreement)
- [x] Function attributes — DONE: infer_memattrs pass (O1/O2/O3 head) computes readnone/readonly/writeonly/argmemonly via fixpoint; callMayWriteMemory/callMayReadMemory/funcIsArgMemOnly/mayCallClobber wired into gvn (surgical flush), memory_ssa, dse, loop_cse
- [x] Interprocedural points-to — DONE as infer_memattrs (read/write lattice + argmemonly lattice + callMayClobber/mayCallClobber queries wired into gvn/memory_ssa/dse/loop_cse)
- [ ] noalias/dereferenceable param attributes
- [ ] Printer: further stylization if wanted
- [x] loop_cse invariant-load "gap" — VERIFIED CORRECT: isSafeToSpeculate requires alloca/global-rooted addrs; arg-derived phi ptr can't be proven non-faulting on zero-trip (LLVM identical). Unblocks only with dereferenceable param attr (below)
- [ ] loop idiom: inner counted loop `sum += a[iv]` per outer iter → mul strength reduction (indvars territory)
- [ ] PER-PARAM ATTRS (deref/noalias) — syntax: `func @f(%p: ptr !dereferenceable(8), %q: ptr !noalias)` param-suffix form (NOT type qualifier — keeps IrType clean). Storage: per-arg metadata on IrFunc args (IrValue metadata slot or parallel argMeta array). Consumers: loop_cse isSafeToSpeculate + ifconv dereferenceability proof + vectorizer alignment + GVN forwarding; noalias per-param for memcpy-style mixed cases (func-level noalias already gives arg-arg pairs). IPA inference later (callers pass alloca/global → param dereferenceable). Unblocks verified-correct rejections like @nested_loop inner invariant load.
- [ ] counted-loop idiom: inner loop `sum += a[iv]` (invariant load + accumulator phi + provable trip count) → `sum += a[iv]*trip`. Needs SCEV-lite trip proof from ivsr affine recurrences; single-block inner loop; no side effects. No IR changes — pure mid-end transform.
- [ ] printer stylization round 2 (optional): phi-pair column alignment, aligned branch targets, section grouping — cosmetic only, goldens regen
- [ ] printer further stylization if wanted

# Current state — open issues (as of 2026-10-28)

Session work on strict symbol visibility / generic instantiation was moved to a
separate branch (not merged here). This doc records every issue found, its
status, and the fix direction so nothing is lost. Wallvm roadmap lives in
`.sisyphus/plans/wallvm-backend-wiring.md` (G-numbers below refer to it).
**Section G is the primary set: the issues notified directly during the
pipeline audit — symbols, typechecking, constructs wrong-but-still-parsed,
and constructs that failed codegen.**

## A. Visibility / generic instantiation (session branch)

- **[fixed on branch] `lookupAll` silently truncates at 16 candidates.**
  `ScopeStack.lookupAll(name, out, 16)` drops everything past #16. The merged
  self-build scope has ~40 `alloc`, ~76 `dealloc`, ~17 `realloc` symbols
  (one import binding per importing file), so `findGenericDeclaration`
  missed the only usable candidate → silent skip (collect.crl:331) →
  G0002 "call site was not collected" at codegen for
  `mman.crl:981`, `vec.crl:26/39/164/176/181/263` (all Vec method bodies
  for `JsonValue`/`JsonPair`/`ImportSymbol`/`Attribute`). Fix:
  `ScopeStack.lookupAllVisible(name, refFile, out, 64)` (visibility filter
  before the cap) used by `findGenericDeclaration`; `resolveQualifiedCallee`
  cap raised to 128.
- **[open] remaining raw 16-caps in sema** — same truncation class plus
  "picks invisible candidates": `typecheck.crl:579`, `typecheck.crl:768`
  (call arity disambiguation — mechanism candidate for issue1's
  `T0003 wrong number of arguments in call to 'read': expected 3, got 1`),
  `expr.crl:1421`, `decl.crl:495`, `decl.crl:528`, `decl.crl:780`.
- **[fixed on branch] `isConcreteType` used refFile-scoped lookup for
  instance ARGUMENTS.** Instance bodies re-collect from the defining file
  (refFile = vec.crl) where an argument type from another module
  (`JsonValue` in json.crl) is not bare-visible → `findDeclaration` = 0 →
  non-concrete → `enqueueVal` silently drops `alloc/realloc/dealloc<X>` →
  G0002. Small tests passed because their args were builtins (`i32`, `str`,
  `u8*`), never named types. Fix: fall back to permissive
  `scopes.lookup(name)` in the `Named` branch of `isConcreteType`; the
  type-bearing-decl guard (sha256 `const u32 K` case) still applies.
- **[fixed on branch] `collectCall` cannot infer type args through mirrored
  wrappers.** Pattern `T*` vs arg `u64*` (`read<comptime T>(T* out)` called
  bare as `read(&i)`): the named-param branch only unwraps
  Comptime/Const from the pattern, so a Pointer pattern never matches →
  `arguments[slot]` stays 0 → silent skip → G0002 at codegen. Fix: lockstep
  descent through Pointer/Slice/Array on pattern AND argument, binding the
  UNWRAPPED argument type (`u64`, not `u64*`).
- **[open] sema accepts bare calls to NON-comptime generics.**
  ```coral
  void rread<T>(i32 a) { a = 3; }
  i32 main(i32 x) { rread(3); return x; }   // passes sema, G0002 at codegen
  ```
  Rule: an inferred (no explicit `<...>`) generic call must only be legal
  when EVERY generic param of the callee is `comptime`
  (`GenericParam.flags bit 0`); otherwise sema must flag it (missing
  explicit type arguments) instead of dying in codegen. `read(&i)` is the
  sanctioned comptime-inference case and must keep working (needs the
  collectCall wrapper fix above).
- **[open] float literals without `f` suffix are pinned to f64 instead of
  being generic.** `f` suffix → f32, otherwise f64 unconditionally
  (`expr.crl:1249`). Repros:
  - `f32 a = 1.5 + 2.5;` → T0002 got f64, expected f32
  - `f32 a = c ? 1.5 : 2.5;` → T0002 (ternary types both branches f64)
  - `f32 e = c ? 1.5 : 3;` → T0002
  - already OK: `f32 a = 1.5;`, `takes(3.5)`, `f32 d = c ? 1.5 : 2.5f;`
  Fix direction: mirror `isConstIntExpr` (`expr.crl:995`) with
  `isConstFloatExpr` (FloatLit, IntLit, Neg, Add/Sub/Mul/Div, Ident→const,
  Ternary-of-const-float); add an adoption arm in `assignCompatible` after
  the const-int arm (`setExprType(value, targetTy)`); generalize the float
  binop arm's `isFloatLitNode` checks (`expr.crl:934`) to const-float
  exprs so `f32var + (c ? 1.5 : 2.5)` adopts f32.
- **[fixed on branch] `declare()` sites hardcoded fileId 0** (14 sites in
  stmt.crl/decl.crl) — latent under the old flat merge, wrong under strict
  lookup; now `self.fileOf(id)` (consistent with `declareAll`,
  decl.crl:138). Node index 0 keeps old behavior.
- **[fixed on branch] `coral-ast/types.crl` had ZERO imports** while
  declaring `Str name/sizeName`, `SourceLoc loc` fields → unresolved named
  types resolved silently → bogus `T0002 binary operand types: got 'Str',
  expected 'i32'` at use sites (the compiler's own multi-file source is
  full of such missing-import pairs). Class rule: a missing import for a
  FIELD type produces no diagnostic at the declaration — only wrong-type
  noise at uses. `import id { Str, SourceLoc };` added on branch.
- **[info] `Str` is an integer typedef (`pub typedef Str = u32`,
  coral-ast/id.crl:16).** Any `T0002 got 'Str', expected 'i32/u32'` means
  resolution failed, not an arithmetic rule issue — never loosen the
  int-literal rule to "fix" it.

## B. Issue fixtures (recreate under /tmp/opencode — wiped by restarts)

- `issue1_bare_read.crl` — bare `read(&i)` + `import(lib) std::time
  { sleepTimespec, Timespec };` (Timespec fields are `sec`/`nsec`;
  `sleepTimespec(c)` takes BY VALUE). Status: sema passes (prelude
  `ios::read`); codegen G0002 until the collectCall wrapper fix lands.
  The original libc leak (`T0003 … expected 3, got 1` for bare `read`)
  was observed inconsistently in an earlier run (one run showed no read
  error, the next T0003) — re-verify after the A-items land; expect
  resolution to prelude `ios::read` (1 arg), never libc's 3-arg.
- `issue2_qual_read.crl` — **[verified OK]** `libc::read(0, null, 0)`
  resolves qualified: emitted C has `int64_t read(int32_t, char*,
  uint64_t)` (libc extern), not ios's generic.
- `issue3_ifexpr.crl` — **[verified OK]** `i32 x = if (true) 1 else 2;`
  compiles.
- `issue4_type_call.crl` — **[verified OK]** `Foo(3)` (call a type) →
  `T0002 type 'Foo' is not callable` with the struct-literal hint.
- Vec/named-type regression tests: `vectest` (Vec\<i32\>), `vecstr`
  (Vec\<str\>), `vecptr` (Vec\<u8*\>), `veccap` (Vec\<u64\>::withCap),
  `namedvec` (Vec\<struct\> — the isConcreteType bug class),
  `jsonrepro` (struct field Vec + static-method `::new()`),
  `reallocrepro` (direct `realloc<T>`). All pass on the branch build.

## C. Wallvm backend (THE current task)

- **[active] 318 × `IR validation failed … block is missing a terminator`**
  on a full-prelude program through `--wallvm` (constbug; fixture needs
  recreation — `/tmp/opencode/constbug.crl` and `wv_out.txt` were wiped).
  Lowering (`compiler/coral-ir/stmt.crl`/`expr.crl`) emits some blocks that
  never receive br/ret/switch/unreachable. Also verify whether
  `irPassValidate` results actually gate the compile (roadmap G1: validate
  return ignored).
- **[known, deferred] termbug repro** needs struct field syntax `i32 v;`
  (old fixture used an initializer form the parser rejects).
- **[known, deferred] frame layout ignores pushed callee-saves** —
  `allocaSlotOf` (x86_64_base.crl:700) offsets measured from %rbp exclude
  `8 * numCalleeSaves`, so allocas land on top of saved registers; fib
  results wrong vs C backend. Fix sketch in roadmap; runtime results of
  any call-heavy function are untrustworthy until then.
- **[known] spill quality** — one 16-byte slot per vreg, xmm2–7 only; must
  reach clang/gcc -O2 level (no naive spills).
- Roadmap G-items still open (see plan doc): G29 data emission, G37 PIC,
  G40 inline asm dropped, G28 unhandled opcodes as comments, G1 validate
  gate ignored, G2 mem2reg↔lower_phis ping-pong, G10–G19 pipeline gaps.
  The full upper-pipeline/vectorizer issue register from the pipeline
  audit is section E below (canonical: `PIPELINE_AUDIT.md`).
- `extern("libname")` name is parsed then discarded (parser decl.crl:403);
  wallvm per-lib `-l` flags need an AST field (phase 3+).
- `#[[packed]]`/`#[[reorder]]` parsed, never honored (C or wallvm).

## D. Backend / sema backlog (unchanged)

- C backend emits prototypes for every decl of every collected file
  (unused-extern noise).
- `cgFindDeclFrom` with refFile 0 falls back to unfiltered decl scan
  (codegen.crl:871); Call arm still has a silent `root_member`
  unresolved-qualified fallback.
- Escape-check diagnostic (pending feature): `&local` assigned into a
  global/longer-lived pointer — error-style flag, compilation continues.
- C backend hard caps that must stay: 16 args; array/tuple literal caps
  of 16.
- Generic methods (phase 2), struct-by-value call ABI, type-only param
  erasure, dynamic global initializers — open.
- `expr.crl` `import stmt;` workaround — housekeeping.
- Pre-existing non-blocking warning: `lib/wallvm/passes/loop_interchange.crl:258`
  T0018 unreachable code.
- `duration.crl` parse fixes applied earlier (`d._normalize();`,
  `fromSecs` → `return Duration {...};`) — compile check pending.
- `docs/mangle_asm.md` needs the instance-leaf scheme
  (`name[_tys][_vkey]_<idx>`); `.sisyphus/plans/wallvm-backend-wiring.md`
  housekeeping.
- Sema: `typecheck.crl:579/768` ambiguity picks candidates that are not
  visible at the use site (same class as the lookupAll issue above).

## E. Pipeline audit — wallvm upper-pipeline & vectorizer

Canonical register: **`PIPELINE_AUDIT.md`** (repo root) — full locations,
evidence and fix notes; status flow `OPEN → VERIFIED → FIXED / INVALID /
DEFERRED`; gate = rebuild + `test/wallvm/run.sh` green (target 116/116).
All issues below are the ones notified during the pipeline audit.

**Baseline already fixed:** P0-1 mem2reg stale rename-stack dangle ·
P0-2 SCCP `handleTerminator` skipped on `Top` · P0-3 simd_vec
block-scoped `aa` use-after-scope · P0-4 tail_dup missing
`removePred` ×3 · P0-5 emitter never removed jmp/fallthrough edges ·
P0-6 SCCP `getCell` meet-neutral `Bottom` for Arg/Global · P0-7 lsra
liveness skips `IrValueKind::Arg` (param clobbered across calls) ·
P0-8 `getRegName` rejects non-Inst (rbx never pushed) · P0-9
`valueIsSpill` rejects spilled Arg (`movq mem,mem`) · P0-10 irParser
table grow dropped `values`/`blocks` arrays · P0-11 loop_distribute
clone `addUser` misses const operands · P0-12 stack_layout
`capInsts` stale after shrink (ASAN) · P0-13 tco teardown UAF order ·
P0-14 lsra scratch arrays freed then reused by second rewrite ·
P0-15 sccp cells OOB on new Br ids + two-phase unreachable wipe ·
P0-16 mem2reg mixed-width slot promotion · P0-17 mem2reg phi-user
promotion + AA `walkAddr` cycle guard.

**A. Branch/CFG (OPEN unless noted):** A1 branch_factoring "collapse
case 1" checks wrong edge — straight miscompile (Critical) · A2
branchprop region criterion dominance≠reachability (C) · A3 range
records every non-own ICmp as unconditional fact (C) · A4 range
dominator propagation unimplemented (H) · A5 branch_factoring deletes
edges without `removePhiEdge` (H) · A6 jump_thread Pattern 1 phi move
invalid (self-pred, layout) (MH) · A7 `branch_inv_flat` dead pass
(needs 2 terminators in one block) + missing 6 U* fcmp preds (M) · A8
jump_thread `cond_br c,X,X` leaves nsuccs=2 / unmerged phi pairs (M) ·
A9 `factorCommonGuards` dead on valid IR (M) · A10 signed/unsigned
bounds conflated, `(i64)` wrap of u64 ≥ 2^63 (LM) · A11 jump_thread
dup `addUser` · A12 gutted target's dead Br kept · A13 branchprop
single remove/addUser on repeated operand · A14 range `addConstraint`
overwrites instead of intersecting · A15 select_to_branch
`hasSideEffects` gate wrong (transform sound) · A16 `removeBlock`
helper dead+broken · A17 jump_thread Pattern 2 orphaned block.

**B. Loop:** B1a-e loop_distribute (header-erase UAF, latch orphan,
phi rewrite, `aa` never read / no dependence check, 2-arm `addSucc`
once) — all **FIXED** (repro `cases/dist_swap.ir` = 54) · B2a
loop_interchange no-CFG-change "swap" = infinite inner loop —
**FIXED** (`cases/loop_swap.ir` = 36); B2b/B2c **INVALID** (dead
code) · B2d naive legality (first-compare exit test, header-only
containment) OPEN · B3a licm speculates trapping div/rem into
preheader (H) · B3b licm load hoisting dead (`isLoopInvariant` false
for Load) · B3c atomic alias latent (dead code) · B3d `CondBr(cond,
header, header)` double edge · B4a unroll teardown never decrements
npreds/nsuccs (H) — **FIXED** (teardown zeroes the counts) · B4b
unroll exit preds double-counted (H) — **FIXED** (k+1 pairs, no
re-add) · B4c unroll wired but `gUnrollEnabled=false` — **FIXED**
(enabled at O3; two-pass cloning, exit-value phis, CondBr addSucc
and emitCast mem←mem staging landed with it; gates 116/116, ASAN
116/116, self-host, round-trip) · B5 loopcse
no-op (preheader never created) · B6a multi-latch loops emitted
overlapping, licm rewires sibling latch · B6b self-loops skipped ·
B6c IrLoop structs leaked.

**C. SSA/canonicalization:** C1 `fabs(fneg(x))→x` (Critical) · C2
`fptrunc(fpext)` identity keeps wrong-width operand (C) · C3
cast_elim null-out without RAUW/removeUser (C) · C4 fp↔int
round-trip "identities" wrong-type/wrong-value, no fast-math gate (C)
· C5 sccp phase-2 `cells[...]` OOB on new Br ids (H) — **FIXED**
(P0-15 bounds guard, row never closed) · C6 mem2reg
pre-existing phi users → UAF on erased alloca (H) — **FIXED** (P0-17
promotable gate, row never closed) · C7 phi update
breaks after first pair — parallel edges wrong value (H) · C8
idempotent store patterns unreachable — primary purpose dead (H) ·
C9 idempotent bitcast-chain collapse no type check · C10 mem2reg
returns true with zero promotions (forces 8 fixpoints) · C11
unreachable blocks never renamed but alloca erased (dangling loads) ·
C12 sccp drops unreachable blocks without `removePred` (stale preds) ·
C13 `fadd(fmul)→fma` no contract gate · C14 lex_canon
`flattenSortChain` result discarded (leak + false `changed`; float key
never sorts) · C15 commutative sets missing FAdd/FMul, Vec*, Eq/Ne
(comm_canon float dead, CSE misses) · C16 sccp phase-2 raw
`cells[term->ops[0]->id]` misses literal cond fold · C17 sccp
worklist silently truncates at `wlCap` · C18 ADCE has no control
dependence (degenerates to DCE) · C19 CSE O(n²), missing Fma/Gep/
Extract/Insert/Vec*/commuted Eq-Ne · C20 constfold no ICmp/FCmp
const-const, no trunc/zext/sext unary · C21 algebraic identities
sparse, `lshr(shl)` dead, `x*2` shadows pow2 · C22 `matchAbs` only
`icmp ??(x,0)` · C23 mem2reg DF O(n³) linear lookups · C24 "sroa" not
real (single-store RVO, 16-load cap, O(n³)).

**D. Memory/analysis:** D1 MemorySSA versions by block order not CFG
+ machine_opt Pass 1 forwards with no dominance check / Pass 3 misses
non-dominating stores (Critical) · D2 dse kills wider store with
narrower (no width compare) — O1+ miscompile (C) — **FIXED** · D3 AA
multi-object phi caches first incoming object → NoAlias through real B
(C) — **FIXED** (cache only unanimous phi arms) · D4 AA
cache-hit shallow copy shares 6 buffers, query-time realloc →
double-free hazard (H) · D5 ipa_cp unwired; if wired: null-deref +
unsound specialization (H dormant) · D6 AA `defId 0` sentinel
collision, `blockEntryDef` dead, `MemoryPhi.incoming[16]` truncation ·
D7 `isMustAlias` = id equality (AA branch in dse dead) · D8 MSSA phi
versions null def → cross-block forwarding dead; `irMemorySSA` built
then destroyed (wired no-op) · D9 gvn id-equality Load CSE, missing
commutativity, O(n²)/O(n³) scans · D10 dse `MAX_TRACKED=128`
truncation, any Load flushes all · D11 stale raw `IrInst*` in
MSSA/AA across freeing passes.

**E. Transform/vectorizer:** E1 tco forward-loop hang (GDB-confirmed,
O3) — **FIXED** (`cases/tco_acc.ir` = 15) · E2 sccp unreachable
blocks gutted not removed → ~380KB validate litter at O2/O3 (H) · E3
inline `MAX_INLINE_DEPTH=4` never referenced, cloned self-calls
re-inline (H) · E4 peephole br-chain redirect: fake `[0,bb]` phi pair,
raw `succs[0]` write, chain blocks left in `blocks` (a)(b)(c) remain —
cycle-hang part **FIXED** (E14) · E5 simd_vec returns `vecOps > 0`
instead of local `changed` · E6 simd_vec cross-candidate alias gap,
Noret sweep, OOB anchors · E7 tco legacy-param representation —
**FIXED** (Arg values) · E8 tco `cb==e` + adce/peephole O3 ping-pong
hang — **FIXED** (`cases/tco_cbe.ir` = 0; peephole cycle-guard) · E9
tco removal index-shift — **FIXED** · E10 tail_dup gutting leaves
`insts` pointer at moved instructions · E11 inline alloca/vararg/
`phiCount==1` hazards · E12 emitter table: **VERIFIED** no gaps (all
14 vector opcodes have x86_64 emitters) · E13 pipeline `validate`
non-fatal (returns false, callers ignore) — every CFG/phi inconsistency
flows into codegen across up to 8 iterations · E14 peephole br-chain
cycle hang (single-step redirect ping-pong) — **FIXED**.

**F. Frontend:** F1 = the escape-check feature in section D above —
flag `&local` assigned into a longer-lived pointer (exact P0-3
pattern) at compile time, diagnosis-style, compilation continues. OPEN.

**Audit fix order (severity-first):** 1) done (E1/B2a/E14 + E7-E9,
B1a-e, P0-6…P0-17, D2, D3; register-form phi elimination + two-phase
compile landed) → next **D1**; then C1-C4, A1-A3; then
E2/E3/E4, C7-C8, A5-A6; then B3a, ~~B4a/b~~ ✓, A7/A9, D4; then Medium/Low
by area + F1; finally newer-pass adoption (real ADCE, range
propagation, loopcse enablement, ~~unroll wiring~~ ✓ (O3), ipa_cp completion)
and vectorizer SSE/AVX inventory testing (E12 list in PIPELINE_AUDIT.md).

**This session:** borrow checker tested + reported for the first time
(`WALLVM_BORROW_CHECK=1`, `test/wallvm/run_borrow.sh` 8/8, doc
`lib/wallvm/docs/borrow-check.md`; fixed Arg write-caps, escape-rule
exemption, parser bare-`ptr` — PIPELINE_AUDIT P-10/P-11); O1 now runs
mem2reg (P-12, O0≡O1 was the "levels don't differ" symptom). Next O3
item: unrolled phi-chain spills (pipeline-gaps G24 evidence — fib_iter
O3: 62 vregs, 5 spills, 152 asm lines vs O2's 28).

## G. Frontend pipeline — issues notified directly (primary set)

The issues as notified (verbatim quotes, session order). Status:
`OPEN` / `FIXED (on branch)` / `VERIFY` (work happened around it —
re-check current behavior) / `RULE` (standing rule to honor).

### G-sym — symbols (visibility, resolution, collection, emission)

- **[OPEN] Private `_loc` file imported despite being private** — "the
  loc file thing being imported despite being private is another bug,
  write it in a document". Standing rules attached: "if it not public,
  it should not be in the import tree, and should not even be visible
  outside" (no elevated privileges for lib); unknown members "should
  stay as unknown member". Check the `_loc` module's import tree under
  strict visibility (branch state).
- **[OPEN] Codegen AND collector pull symbols never used** — "the bug
  is the codegen pulling/writing symbols that were not even remotely
  used in any way"; "not just the codegen, the collector too. it is
  pulling symbols that were not remotely used". Emission half =
  "C backend emits prototypes for every decl of every collected file"
  (section D); collection half = unresolved/indirect decls dragged in
  by the mono collector — verify each late.
- **[OPEN] libc symbols leak by default** — "libc is not preluded so
  all public symbols should not be available by default"; "ios does
  not even import libc read"; "the symbol was never explicitly pulled
  in, or even used with libc::read". Bare `read` must resolve to
  prelude `ios::read`, never libc's 3-arg extern (ties to section B
  issue1 and typecheck TYC2).
- **[FIXED (on branch)] `Str` typedef misuse** — "Str there is a
  typedef of i32, the fuck": `T0002 got 'Str', expected 'i32'` came
  from `coral-ast/types.crl` declaring `Str name`/`SourceLoc loc`
  fields with zero imports → unresolved named type. Class rule in
  section A. `Str` stays an integer typedef — never loosen typecheck
  to "fix" these; fix the declaration site's imports.
- **[VERIFY] `pub` flag bits per decl kind** — reported: isPub checks
  use bit 1 for Func/Struct/Variant but **bit 2 for Enum** (and
  whatever the switch pasted shows for others); globals: "for global
  variables, you could have a global i32 for example" — verify pub
  masking is right for every DeclKind incl. globals/typedef/distinct
  and that `pub` global variables resolve across files.
- **[RULE/VERIFY] extend + bare-import contract** — "if i import a
  type… `pub extend lexer { void fooo(); }` … `import base { lexer };
  import keyword;` … what we need and want, is a bare `import ident;`
  — the symbol ident extends is from base, and we have imported the
  types" — extended methods must be reachable via bare namespace
  import WITHOUT `import ident { lexer }` name collisions. Verify the
  pattern still works post-visibility changes (compiler itself relies
  on it).
- **[VERIFY] `self.fileOf(id)` as declare() fileId** — "that you added
  to stmt to replace 0, is that proper. it needs a u32, 0 is given, is
  that supposed to be an error". Answer: `fileOf` returns 0 only for
  the main file; all 14 declare sites pass it (section A). Re-verify
  on branch.
- **[FIXED] Build-file masking** — "you used a build file to gloss
  over the issue, rather than… fixing the elephant in the room";
  "note this in the bug doc". The single-file issue behind it was
  fixed ("the fix is now done"); never solve compile failures by
  introducing build files — surface the real defect.

### G-tyc — typechecking (checks that did not fire / fired wrong)

- **[VERIFY] Wrong argument type let through to codegen** — fixture:
  ```coral
  import(lib) std::time { sleepTimespec };
  import(lib) platform::libc;
  import(lib) core::cchar { cchar };
  void printt(str c) { libc::system((const cchar*)c.ptr); }
  pub void main() { sleepTimespec(10000u); printt("I ran after {}"); }
  ```
  "passing the wrong type to a function and the compiler did not flag
  it, and let it go like that to the codegen." (`sleepTimespec` takes
  `Timespec`, got `u64`.) Verify the call-site arg check still skips
  this (likely const/struct-literal arm interaction).
- **[OPEN → section B issue1] Out-of-scope symbol drives typecheck** —
  "the compiler will tell me wrong number of arguments, when the
  function it is using is not even in scope": bare `read(&i)` gets
  arity-checked against libc's 3-arg extern instead of resolving to
  in-scope prelude `ios::read`. Typecheck resolution order must match
  visibility.
- **[OPEN] Instance member call on a TYPE is not flagged** — "there is
  a `struct Scene {}` and i am seeing `MuScene = Scene.new(MuStorage,
  4096)` … calling a method via `.` or `->` has to be on an instance,
  or a pointer to an instance, not on the type itself. how did this
  thing get past the compiler?" Rule: `.`/`->` receiver must be an
  instance (or pointer-to-instance); type-level access uses `::`;
  static methods are only reachable via `::` (and instance methods not
  via `::`).
- **[OPEN] `::` vs `.` static/instance diagnostics wrong** — observed
  `[T0002]: method 'new' on type 'IrBuilder' is not static; it needs
  a receiver` on `IrBuilder::new(w.ir)`; "not just there, in math".
  The message/case selection for method-call form vs static-ness is
  inverted or mistargeted — verify against `Scene.new` (TYC3): both
  directions must be caught with the right message.
- **[FIXED (on branch)] stricter literal rules — fix code, not rules** —
  "the compiler had a little bit of added stricter rules, and some old
  code is in violation. int lit → enum intlit → bool directly. or
  pointer. that is what was changed"; "the codebase relying on that
  does not mean it is right… don't go and change my rules". Source
  call sites were fixed instead of loosening typecheck. RULE: never
  loosen the int-literal rule.
- **[OPEN → section A Issue A] bare call to non-comptime generic** —
  "the semantics doesn't flag `void rread<T>(i32 a)`… `rread(3)` … a
  normal generic and the codegen would fail here."
- **[OPEN → section A Issue B] floats without `f` suffix pinned f64** —
  "floats without f suffix are forcefully evaluated to f64. instead of
  generic"; "no, try it in a ternary expression."

### G-par — constructs wrong but still parsed

- **[VERIFY] Incomplete struct literal accepted** — fixture uses
  `const c = Timespec { 0, };` (one field of two + trailing comma).
  Verify missing-field / arity checks on positional struct literals
  actually fire (it must not reach codegen).
- **[OPEN] Parser+sema accept what codegen rejects** — "the current
  codegen, many times will error with 'construct not supported in the
  codegen', or codegen error, for something the semantics and parser
  will allow"; "you may even need to deploy agents to try and get
  things that are seemingly supported by the parser and semantics but
  the codegen does not." Three read-only inventories were dispatched
  (parser surface map / C-backend gap map / semantics acceptance map)
  — their outputs must be turned into a concrete missing-construct
  list here (see G-cg1).
- **[OPEN] Function-pointer declarators with custom-type pointers** —
  "function pointers returning a pointer, for the integral types was
  fixed, but… `foo*(isize, usize) goo;` are flagged as errors, then
  passing of addresses as params is not supported." Verify
  `T*(params) name;` declarator parsing/typing for custom `T`.
- **[OPEN] fn-pointer struct fields** — `struct foo { pub const
  MethodInfo*(ScriptData, u32*) ScriptGetMethodList; }` — same class:
  const-qualified function-pointer field declarator must parse+check.
- **[VERIFY] Realistic binding files fail to parse** — the Godot
  GDExtension translation (many `pub typedef X = i64;`, `pub distinct Y
  = rawptr;`, large `pub enum` blocks, `import core::cchar { cchar };`)
  failed with a parse error whose trigger "is not the space" — find
  and fix the actual trigger; binding-header code must parse.
- **[OPEN] Parser diagnostics wrong/incomplete** — expected `,` but
  reports `}` ("the real issue is that what is expected is a comma but
  it is reporting for a }"); "incomplete message. it just says
  expected a , it did not say what it got" (found-token missing);
  LSP: "malformed LSP header; the server is crashing".
- **[OPEN] Stale docs** — "a lot of docs are either stale or
  unimplemented"; grammar.md stale; array syntax `T name[N]` is stale
  (now `T[N] name`); `{:.6}`/`{:N}` documented but rejected as T0014;
  `{:f}` parses then dies G0002 (see documentation_issues.md).
- **[RULE] Fixture/syntax traps** — no `fn` keyword; std is flattened
  (there is no `std::text`, it is `std::item`); no `import(common)`;
  the correct nested form is `import(lib) std { math { F64 } };` —
  test fixtures must not invent syntax.

### G-cg — parsed + checked, failed codegen

- **[OPEN] C-backend missing-construct inventory** — per G-par #2:
  catalog every construct the parser+sema accept that `codegen.crl`
  errors on ("construct not supported" / G0002 class), as the working
  list for backend parity (wallvm must inherit the list, not the
  C-backend hacks).
- **[RULE/OPEN] `_loc_` must not be hardcoded** — "loc is literally a
  placeholder for locations in the module tree, not for `_loc_` to be
  written there. fix that in the wallvm codegen."
- **[OPEN] Drop resolution naive/incomplete** — "proper drop
  resolution in the codegen… the current codegen's drop is naive and
  incomplete. if wallvm has an issue, fix it, like the memoization
  issue you just noticed."
- **[VERIFY] Compound assignment parity** — "how compound assignment
  enters the ir. should be perfect, then, you patched something for
  linux, you did not patch for windows."
- **[OPEN] `{:f}` → G0002** — placeholder parses, sema passes, codegen
  fails ("no monomorphized instance in std/.../ios.crl") —
  documentation_issues.md.
- **[OPEN → section B issue1] bare `read(&i)` → G0002** — sema passes,
  mono never enqueues `read<u64>` (section A collectCall wrapper fix).
- **[RULE] `typeof` must never reach IR** — "typeof is a mono thing
  and should not end up in the actual ir… only used in comptime
  blocks" (StmtKind::Comptime skipped in lowering — keep verifying).
- **[RULE] No memcpy/memset struct equality in the new backend** — "an
  agent hardcoded the use of memcpy for equality in structs, in the
  codegen. do not adopt that in the wallvm codegen" — field-wise
  struct `==`, content `str ==`, `.tag` for variants.
- **[OPEN → section C] wallvm lowering gaps** — "all the supported
  constructs in the compiler should be lowered properly to ir…
  the ones that are now parsed but the current [wallvm] codegen fails,
  the missing ones" — the 305/318 missing-terminator class + coverage
  (section C).

### G-misc

- **[OPEN] Transient OOM bug** — "even when there is enough system
  memory it could error like that… 5 gb of ram free still, and it'll
  happen"; suspicion history: began around the mimalloc swap (since
  fixed under gdb/rr/asan/valgrind; default allocator is libc). Not
  yet root-caused — if it recurs, capture under asan/rr.
- **[OPEN → section C] extern lib name discarded; `#[[packed]]`/
  `#[[reorder]]` never honoured** — "add these to the docs" (done:
  plan doc "Known wallvm gaps"; tracked in section C).

## H. Queued after the backend (feature requests)

- **[DONE — landed 2026-11-03 as wallvm O0 safety instrumentation] Debug
  runtime / safety checks with real backtraces** — "the std itself
  (much preferably, the compiler itself), needs a way, or a specific
  tiny runtime it should link to, it could even be a core module, that
  would provide bounds checking and other things rust or zig would
  provide that, on debug mode, runtime crashes are called out
  correctly. it should just be able to work. the compiler itself
  should be able to add such debug symbols and items."
  Sketch: a tiny link-time runtime (core module) the compiler emits
  debug-mode instrumentation into (array/slice bounds, null/deref
  checks, overflows), plus compiler-emitted debug symbols/metadata so
  a runtime violation prints a proper diagnostic (kind, source loc,
  backtrace) instead of a raw SIGSEGV.
  **Implementation (wallvm, O0/debug only):** `lib/wallvm/passes/
  safety.crl` (`irPassSafety`, called from `irOptimize` before the L0
  pipeline) inserts a plain `call void @_trap(kind, a, b, file, line)`
  before every array-gep bounds test (constant in-range indexes
  skipped; a zero-length array type is a dynamic-buffer decay target,
  not instrumented), load/store through a pointer not provably
  non-null, non-literal div/rem, and integer `add`/`sub` whose
  branchless flag chain lands *after* the arithmetic — kinds 0 bounds /
  1 null / 2 divzero / 3 overflow (signed sign-mask, aux-tagged
  unsigned carry/borrow; `mul` reserved for a guarded-div CFG split);
  4 badvariant reserved. Insertion is further collapsed by
  dominance-based dedup (an equivalent check that already runs strictly
  earlier — same block position or dominating block — is dropped; sound
  because the call is unconditional and `_trap` returns only when the
  property holds). No new opcodes, no emitter changes; O1+ and wasm
  never instrument; `WALLVM_CHECKS=0` is the with/without kill-switch.
  `_trap` + `write_stdout` live in all four platform `error.crl`
  (pub-symbol parity) and print kind, a/b, `file:line` (`?:0` when the
  IR has no debugLoc) + backtrace, then abort; the harness links
  `test/wallvm/trap_stub.c` (exit 70) instead.
  **Docs:** `lib/wallvm/docs/safety-checks.md` (system),
  `lib/wallvm/docs/overflow-checks.md` (kind-3 contract + mul design).
  **Gates:** `run_checks.sh` 30/30 over 9 cases (all four implemented
  kinds fire, dedup pins exactly one call, kill-switch), `run.sh`
  116/116 (O0-O3), `run_borrow.sh` 8/8, ASAN irtool 30+116+8,
  self-host (`coralc -f coral.crlb --force`) rebuilds and runs.
  **OPEN:** driver must link error.crl's `_trap` for user builds with
  checks on (coralc TODO); badvariant (kind 4) and mul overflow not
  inserted yet (designs above).

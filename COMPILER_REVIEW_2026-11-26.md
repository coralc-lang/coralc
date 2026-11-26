# Coral Compiler Review — 2026-11-26

Fresh pass over the current tree, scoped to: `coral-build` (builder), `coral-lexer`,
`coral-parser`, `coral-semantics`, `coral-mono` (comptime/collect/instantiate),
`coral-ir` (the MuVM backend), `coral-context`, `coral-frontend` I/O. `coral-backend/codegen.crl`
(C emitter) is **out of scope** per request.

This supersedes the still-open items in `COMPILER_PERFORMANCE_REVIEW.md` (that doc's
parts 2–9 were never implementation-checked; several have since landed).

## Already fixed since the old review (verified, do not re-report)

- `AstContext.intern` is hash-indexed (FNV-1a open addressing, `context.crl:900+`).
- Lexer `IdentifierTable` grows geometrically at 75% load (`lexer/table.crl`).
- `prescanConstInts` walks the lex-once token array — no re-lex (`parser/type.crl:291`).
- `Parser.save/restore` are token-index rewinds (`Parser.toks`), not source-cursor rewinds.
- Scope lookup has a per-scope 64-bucket name hash (`semantics/scope.crl:43-53, 399-423`).
- Type singletons + `namedType` dedup go through `tyIdxFind`/`namedFirst` hash indexes
  (`semantics/typecheck.crl:42-57, 233-244`; `context.crl` `tyIdx*`, `namedScanTail`).
- `bFingerprint` is stat-based (size+mtime), no content reads (`build/builder.crl:1871-1946`).
- `reportExpected`/error paths early-out on `isSpeculating()` (`parser/recovery.crl:45-81`).
- IR `muvTy` is memoized per `Ty` (`ir/types.crl:994-1028`); fn/global/type-decl maps are
  open-addressed (`ir/lower.crl:734+`).

---

## P0 — algorithmic (quadratic / O(n·m) on real inputs)

### R1. IR: method-owner resolution is O(instances × decls) per call site, unmemoized
`coral-ir/expr.crl:300-411` (`muvFindMethodDeclOwner`). For every method call it:
- scans **all** `mono->instances` and calls `muvTypeInstanceName` per TypeInstance —
  that rebuilds the mangle buffer **and interns a fresh string** per comparison;
- for each matching instance, scans **all** `file->decls` for `Extend`/`ExtendTrait`
  and runs `muvSelfTyMatches` (which itself does `sameType` per arg).

Called per method-call site at `expr.crl:530, 569, 2469, 3975`. The C backend solved
this exact problem with a 256-slot `(owner, method) → NodeId` memo (`moOwner` in
codegen); the IR backend has no equivalent. Fix: same memo keyed by `(Str owner, Str method)`,
plus precompute `TypeInstance name → index` once instead of re-interning per probe.

### R2. IR: generic type-instance lookup scans all instances and interns per candidate
`coral-ir/types.crl:956-987` (`muvTypeInstanceTy`) and `types.crl:740-768`
(`muvPushTySubs`). Both walk `mono->instancesLen` and call `muvTypeInstanceName` inside
the loop — a buffer build + `ctx->intern` **per candidate instance**.

Worse, `muvm.crl:649-657` calls `muvTypeInstanceTy` once per TypeInstance up front →
**O(I²) name-building/interning at startup** before any body is lowered. Fix: key the
scan by `(name, argumentsLen)` first (integer compares), only build the name string for
survivors; or precompute a `TypeInstance (name,args) → index` hash once in `muvm`.

### R3. IR: per-TU capacity pre-pass is O(instances × decls)
`coral-ir/muvm.crl:767-804` — for every TypeInstance, scans every file decl calling
`muvSelfTyMatches` just to *estimate* `instMethodCap` (over-count is explicitly safe).
Same pattern again at `muvm.crl:1018` during collection. Fix: over-estimate cheaply —
sum all Extend/ExtendTrait methods once, or cap at `file->declsLen`-derived bound;
the queue already bounds-checks.

### R4. IR: generic call resolution scans all instances per call site
`coral-ir/expr.crl:607-680` (`muvPickInstanceForDecl`) and `expr.crl:687-819`
(`muvResolveGenericCall`): O(instances × sameType) per call, up to two full scans, plus
`alloc<Ty>`/`alloc<IrValue*>`/`gbuf` heap churn per site. Fix: build
`Hash<(declId|name, valueKey) → instanceIdx>` once after mono collection (same shape as
the C backend's instance index); reuse a scratch buffer for `want`/`gargs`.

### R5. Semantics: `libResolveSegs` reads whole files to test existence; manifests re-parsed per resolve
`coral-semantics/analyze.crl:771-876`.
- `n == 1` branch (784-801): `libRead`s each candidate file fully, then `dealloc`s —
  pure existence probe paying full file I/O, then the loader re-reads it for real.
  Fix: `stat`/`fileExists` (builder already has `statPath`/`bFileExists`).
- `n > 1` branch (805-873): every resolve of a `std::…`/`core::…` path re-reads **and
  re-parses** each intermediate `lib.crl` manifest into the shared `AstContext`
  (growing nodes/interns), retains the buffer in `L->bufs`, and `alloc`s a fresh
  `LibSeg` array per `ModReexport` probe. No memoization of `dir → manifest File*`
  or `import-string → resolved path`. With ~100 `import(lib)` sites this is the
  dominant loader cost. Fix: memoize manifests per `LibLoader` and resolved paths
  per import string; skip re-parse when the same manifest was already loaded
  (`libHas` check happens *after* resolve at the call site — move dedup earlier).

### R6. Parser: statement decl-vs-expr still pays a full speculative `parseType` + re-parse
`coral-parser/stmt.crl:788-819` (`parseExprOrDecl` general arm). For every
`isTypeStart()` statement (i.e. nearly every expression statement):
`save → parseType → maybe expectName → restore → parseType again` on the decl path.
The var arm (`stmt.crl:747-781`) at least commits via `endSpeculation`, but still
speculatively parses `var x = …`'s name as a type first.

Token buffering already landed, so `restore` no longer re-lexes — but the speculative
parse still allocates type entries, interns names, and (on decl success) parses the
type **twice**. Fixes, in order: (a) commit-on-success like the var arm — keep
`typeNode`/`name` instead of `restore`+re-parse (needs the buffered-diagnostics or
error-suppression story for the committed window); (b) a cheap token-shape gate
(`typeish+ Ident [= ; [ ]`) over `self.toks` before attempting `parseType` — kills the
whole speculation for `foo(bar);`, `x = 5;`, `obj.f = 1;` shapes.

### R7. Parser: `parseGenericArguments` speculates on every `<` after an identifier
`coral-parser/type.crl:397-447`, called from `expr.crl:627`. `a < b` in expression
position pays: save, `TyListBuilder` heap alloc, `parseType` of the RHS, `consumeGreater`
failure, dealloc, restore. Fix: balanced-`>` token prescan over `self.toks` (no parse,
no alloc) before committing; or require turbofish `::<>` in expression position.

### R8. Comptime: `resolvePatBase` does up to two full linear scans of the type table per pattern name
`coral-mono/comptime.crl:473-480` and `510-517` — `while (i < typesLen)` scans for a
bare `Named` entry even though `namedFirst`/`tyIdxFindNamed` already answer this in
O(1) two lines earlier in the same function. Type-switch-heavy comptime code
(`@typeof` dispatch, ios `_fprintOne`-style arms) pays O(types) per arm. Fix: call
`tyIdxFindNamed(bn, bareOnly=true)`; keep the scan only as fallback if the index can
miss entries (verify `namedScanTail` covers parser-created Named entries — it scans
`typesLen` tail, so it should).

---

## P1 — hot-path allocations & constant factors

### R9. Parser: every `Ident` primary allocates a `TypeEntry` it usually discards
`coral-parser/expr.crl:620-635` — `makeNamedArgs` (`type.crl:380-389`) →
`allocTypeKind` unconditionally, *before* knowing whether the ident is a `TypeRef`,
struct literal, or plain `Ident`. Plain variable references are the most common
primary; each mints a fresh `Named` type entry (parser types are **not** deduped —
dedup only exists sema-side via `namedFirst`). This inflates `typesLen`, lengthening
every `tyIdx`/`named` fallback scan and every `sameType` table walk. Fix: build
`namedType` lazily — only when `hasGenericArgs` or `LBrace` follows (3-line change,
same as old review #3; still unfixed).

### R10. IR: local-variable lookup is a linear reverse scan, twice per ident
`coral-ir/lower.crl:626-651` — `muvFindLocal` and `muvLocalTy` each walk `locNames`
backwards per identifier; expr.crl calls both on the same name in several arms
(e.g. `expr.crl:2220-2297`). `locLen` is scope-mark restored so it's bounded by max
simultaneous locals, but a 500-local function makes every ident O(500). Fix: small
open-addressed `Str → (slot,ty)` map per function, or at minimum fuse find+ty into
one scan (`muvFindLocalTy` returning both).

### R11. IR: `muvSubstDeep` heap-allocates per compound type node and mints undeduped TypeEntries
`coral-ir/lower.crl:430-562`. For `Named`/`FnPtr`/`Tuple` it `alloc`s a fresh arg array
*before* checking whether anything changed (alloc+dealloc on the no-change path), and
`allocType` on change creates a brand-new `TypeEntry` every time — no uniquing, so
`Vec<f64>` substituted in N places yields N distinct `Ty`s, which then defeats
`sameType`'s `a == b` fast path downstream. Fix: check-then-alloc (substitute into a
stack/scratch buffer first), and route rebuilt kinds through the `tyIdx` constructors
(`slicePtrType`-style) where one exists.

### R12. IR: `muvPushLocal` growth does 3 allocs + 3 copies + 3 deallocs per doubling
`coral-ir/lower.crl:582-597`. Three parallel arrays (`locNames`/`locSlots`/`locTys`)
grown independently. Fix: one `alloc` of a struct `{Str; IrValue*; Ty}[]` — single
copy, single free, better locality for the R10 scan too.

### R13. IR: switch lowering duplicate-value check is O(nvals²)
`coral-ir/stmt.crl:390-401` — nested loop over collected case values. A 1000-case
switch pays ~500k compares. Fix: sort `vals`/`valArm` together (they're already
arena scratch) or a small open-addressed seen-set; sorting also makes the emitted
`switchInst` table deterministic.

### R14. Semantics: `findMethod` re-scans all `extend` blocks per call; per-decl `intern()` constants
`coral-semantics/member.crl:486+` — after the own-methods scan it walks
`self.extendsLen` running `sameTypePattern` per candidate, on *every* call:
per `VarDecl` drop check (`stmt.crl:152`), per for-loop (`stmt.crl:308-332`), per
method call, per `implementsTraitMarker` probe (`member.crl:145-175`). The
`intern("drop")`/`intern("iter")`/`intern("toStr")` calls in these paths are now
hashed so individually cheap, but the structural scan is not memoized. Fix:
(a) cache `(receiver Ty, name Str) → MemberInfo` in a small map on `Sema`;
(b) better, precompute per-type method tables at `declareAll` time (the old
review's #3 — still open); (c) hoist the string constants to fields interned once.

### R15. Parser `pattern.crl`: heap scratch + triplicated 25-term kind chains
`coral-parser/pattern.crl:53,107` — `alloc<u8>(256)` + `dealloc` per type-prefix
pattern (twice per pattern site), plus the same ~25-term `kk == …` chain copy-pasted
at `:60-72` and `:115-125`. Fix: one `u8 patBuf[256]` field on `Parser` (or a
parser-scoped scratch), a `TYPE_PREFIX_SET[TokenKind::Count]` byte table, and one
shared `collectTypePrefixText()` helper. (Also: the comment at `:88`/`:136` —
*"was buf previousle deallocated? let me not casue a bug"* — should be resolved;
the `dealloc` is correct since `intern` copies, but the comment is noise.)

### R16. `AstContext.intern` byte-copy loop + separate `::` prescan
`coral-context/context.crl` (~940-965 in `intern`): after the hash probe it does a
first pass over the bytes hunting `::` for the `psep` flag, then a second byte-at-a-time
copy loop. Fix: fuse both into one pass, or `memcpy` the copy and derive `psep` during
the probe's `streq`-style compare (the flag only matters on insert — could compute
`psep` lazily on first `interns`-table scan that needs it, or keep a per-entry flag
set by a single fused loop). Minor but it's the single most-executed function in the
compiler; every interned identifier pays it.

### R17. `frontend/io.crl readFile`: blind 64KB growth, no `fstat` pre-size
`coral-frontend/io.crl:8-42` — starts at 64KB and doubles via `realloc` regardless of
file size: ~log2(size/64K) reallocs+copies per file, and every source file in the
compile closure goes through it (also `libRead` in analyze wraps this). Fix:
`fstat` the fd for exact size (one syscall), single alloc + read loop; keep the
NUL-termination the lexer relies on. `sliceCStr` also byte-copies — `memcpy`.

### R18. `mono/collect.crl` per-call-site heap arrays
`coral-mono/collect.crl:84-100, 266-349, 610-633` — `alloc<Symbol*>(16)` for
`lookupAll`, plus `ttypes`/`tnodes`/`lnames`/`lnodes`/`subst` alloc+dealloc per
generic call collected. These run once per generic call site during collection —
not huge, but trivially movable to a reusable scratch or the mono arena
(`muvArr`-style bump alloc already exists in the IR side; mono could use the
AstContext arena for same-lifetime data).

### R19. `lookupConstInt` linear scan
`coral-parser/type.crl:232-245` — per array-size ident in a declarator. Const tables
are small so impact is minor, but it's a `Str` id compare loop that could be a
`u32 → u64` open-addressed map built once in `prescanConstInts` (names are already
interned ids). Only worth it if const-heavy code shows up in profiles.

---

## P2 — polish / hygiene

- `coral-semantics/expr.crl:1783-1785` — `Ident` arm calls `checkIdent` (which does
  `lookupAt` internally at `:198`) **then `lookupAt` again** on the same name.
  `checkIdent` should return the `Symbol*` (or set a field) so the arm reuses it.
  ~2× scope lookups on the most common expression node.
- `coral-semantics/expr.crl:110-135` (`truthyCondMsg`) — builds diagnostic strings
  byte-by-byte through raw `alloc`/`dealloc` instead of `String`/`memcpy`. Diagnostic
  path only, but it's ~40 lines of manual copying; `String::new()` + `pushView`
  does the same thing safely.
- `coral-mono/comptime.crl:337-368` — `bind`/`lookup`/`hasDeclName` are linear scans;
  fine at current binding counts, but `bind` is O(n) per bind making block-scoped
  comptime O(n²) in pathological cases. A `Str → idx` map is cheap insurance.
- `coral-mono/comptime.crl:949,953` — string values `alloc`+byte-copy per eval;
  consider arena ownership for `CtVal.sptr` (values live as long as the eval).
- `coral-ir/expr.crl:894` — `while (i < sv.len) { bp[i] = sv.ptr[i]; i++; }` byte-copy;
  `memcpy`/`copy` is already imported in that file.
- `coral-ir/muvm.crl:662-737` — three full `file->declsLen` walks for TU partitioning
  could fold into one pass (count Func/Constant/owner-methods per file in a single
  sweep; the owner-method count needs `muvOwnerMethodCount` per decl anyway, so the
  first and third walks can merge).
- `coral-parser/stmt.crl` asm-clause loops (`:660-721`) and the block/switch/comptime
  loops duplicate the same "advance + progress-guard" shape ~6 times — factor into
  one `advanceGuarded()` helper (old review #11 table, still valid).
- `coral-frontend/io.crl:44-55` `sliceCStr` — byte loop → `memcpy` (it's on every
  diagnostic/print path).

## Suggested order

1. **R5** (loader probes/manifests) — biggest I/O win, well-localized.
2. **R1+R2+R3** (IR instance/method lookups) — one memoization pass over
   `coral-ir` mirrors what the C backend already has; kills the O(I×D) startup
   pre-pass and per-call-site scans together.
3. **R6+R7** (parser speculation gates) — commit-on-success + token-shape prescan;
   both are local to `stmt.crl`/`type.crl`/`expr.crl`.
4. **R8** (comptime `tyIdxFindNamed`) — 5-line fix.
5. **R9** (lazy `makeNamedArgs`) — 3-line fix, shrinks type-table growth.
6. **R4, R10-R15** — IR/mono/sema memoization and scratch-buffer cleanups.
7. P2 polish batch.

## Measurement suggestion

Add a `--stats` flag printing: `intern` calls/probes, `parseType` calls from
`parseExprOrDecl`, `save/restore` counts, `allocTypeSlot`/`allocTypeKind` counts,
`muvTypeInstanceName` calls, `muvFindMethodDeclOwner` calls + inner iterations,
`libRead` calls + bytes, `libResolveSegs` manifest parses. Every finding above has
a direct counter; an afternoon of instrumentation beats guessing on the self-host
build.

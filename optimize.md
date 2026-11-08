No naive hacks — here's the full plan, grounded in the measurements, the actual source structures (all verified above), and prior art (rustc's codegen-units). Pending items from earlier still stand: your sudo callgraph run, and the perf numbers will be recorded.
Coral Compiler Optimization Plan
Baseline (measured)
- Full forced build 28.75s · no-op 0.041s · 1 stale module 27.43s (one closure → one TU → one gcc; fingerprints only gate early-return)
- Split: coralc 38.8% · cc1 55.8% · as 7.5% · ld 0.3% (perf flat, 5371 samples)
- coralc hot: lookupFrom 5.4, namedType 4.8, cgMangleExempt 4.6, IdentifierTable_get 2.6, tyStr 2.5, slEqU8 1.7, declAt 1.6, growStable 1.6, declarationName 1.3, cgMethodRecvKind 1.2, cgFindMethodDeclOwner 1.0, cgFindDecl* 1.1+
- Confirmed bug: --force skips bFingerprint (builder.crl:1976) but bWriteAllFps runs (coralc.crl:408) → writes FNV-basis fps (builder.crl:824) → next non-force build is spuriously all-stale
- Confirmed missing feature: lexer IdentifierTable is fixed 256 slots, never resizes (table.crl:4-7) — saturated after ~256 words, so every later ident lookup runs the full 256-slot probe + falls back to degraded path
Phase 1 — coralc hot paths (targets ~25–30% off coralc's 38.8%)
1. growStable byte-loop → memcpy (context.crl:434) — 1.6%, trivial, zero risk.
2. IdentifierTable resize (missing feature): geometric grow + rehash, store FNV hash in entry (reject on hash before byte-compare), keep the documented degradation only as a safety net — 2.6% + removes silent saturation.
3. Scope hash: Scope gets an intrusive head/chain (append-only symbolsLen, leave() frees whole scope — verified safe), lookup/lookupFrom O(1), lookupAll walks same-name chain, declare's dup-check becomes a chain walk instead of full scan — 5.4% + declare.
4. FileDeclIndex (lazy, per-file, snapshot declsLen + incremental): one name→decl index powers cgMangleExempt 4.6%, cgFindDecl/From (kills the 32-slot linear cache), cgFindTypeDecl, cgFindMethodDeclOwner 1.2% (plus precompute owner-spelling groups once), and tyStr's alias/fn-ptr-const scans part of 2.5%.
5. Type-arena hash index (the namedType/internKind/accessor-family scans, typecheck.crl:39–250 + parser internKind + mono kindSingleton): hash-cons over the append-only type arena with the exact rewind-safety design worked out:
- per-kind keys (pure kinds key = tag only — payloads are uninitialized in callers like internKind, current code compares tag only; Named = name; Pointer = base; …)
- probe = verify range (idx < typesLen) + full structural match, take min live, continue past dead entries; miss → existing linear scan → insert (so direct-allocating creators stay correct without modification)
- intrusive chains in a parallel u32[] grown with types; dead entries bounded by total allocations — this is FoldingSet-style uniquing, correct under typesLen rewinds (parser.crl:202 etc.)
- plus cache interned literal Str ids ("cchar", "str", …) so hot slEqU8(cgIntern(...), lit) → u32 compare — namedType 4.8% + below-threshold family (every literal/expression type) + slEqU8 subset
6. Scope malloc pool (enter/leave churn) — mimalloc_free ~1%.
7. Re-profile after 1–3 and after 4–5; only chase declAt/nodeAt/declarationName if still hot (structure read first — no blind micro-tweaks).
Phase 2 — pipeline (the structurally missing pieces; biggest UX win)
1. Fix --force fp poison: always run bFingerprint; force only forces stale = true (builder.crl:1972–1997). Validated by the exact observed sequence.
2. Multi-TU backend — debug profile only (release stays single-TU; at -O0 a TU split has zero code-quality cost, which is exactly rustc's codegen-units policy: split at low opt, unity at -O2):
- Output already has sections preamble | fwd | typedefs | tdecl | globals | protos | bodies (codegen.crl:7729) and a global protos pass — so: prelude = all decl-only text (incl. fn protos, instance protos, global externs — verify/add during impl) written to every TU; bodies split by locFile ownership (decls are one merged list; origin = locFile); mono instances → dedicated TU; main in entry TU.
- static (flags&4) fns keep file locality because split is by file (non-pub can't be referenced cross-file — assert this with a dev checker over the emitted text); _coral_streq/_coral_strtruth promoted non-static or preamble-TU.
- gcc: write per-TU .c to .coral/obj/, compile 4 workers in parallel (nproc=4), link .os.
- Incremental: .o reused by module fingerprint → 1-stale-module build ≈ front-end + 1 TU + link ≈ ~10s instead of 27.4s; full build ≈ ~15–16s.
- Progress output (your complaint): print Compiling <module> when that TU actually finishes gcc — honest per-unit lines, not a plan-time dump.
- wallvm asAsm path untouched (stays single).
3. Optional follow-up (only if front-end becomes the bottleneck): per-module front-end caching; content-hash C cache (largely redundant once .o reuse exists).
Phase 3 — cc1/as volume (after .c files land on disk)
Sample real output for bloat (redundant casts, re-spelled instance names, init glue) and cut emitted bytes (cc1+as scale with volume). Also measure, not assume: -g1 and -gsplit-dwarf as documented options (dwarf is a known ~20%+ compile cost per kernel data) — proposed only with numbers, default behavior unchanged unless you approve.
Comparison vs production compilers (deliverable)
- Same generated C through gcc vs clang vs tcc (-O0 -g) → backend cost table.
- Front-end: coralc (parse+sema+codegen of 48k lines) vs clang -cc1 -fsyntax-only on comparable input.
- Everything lands in a dated perf write-up (baseline profile, your sudo callgraph, before/after tables, methodology).
Validation gate (each step)
Triple self-host (old→new→new), stage2/stage3 compare, test/coral + test/object + wallvm 64/64, --force sequence test, no-op still ~0.04s, perf re-record + timing table (full/no-op/1-stale). No step merges if any number regresses.
Explicitly avoided as naive/unsafe: dropping -g silently, threads inside sema, blind O(1) hacks without verify-on-probe (breaks under type rewind), splitting TUs without ownership analysis (statics/instances/globals), caching keyed loosely, redoing the already-landed intern hashing (COMPILER_PERFORMANCE_REVIEW F1).
Two questions before I start writing code:
1. Phase 2 multi-TU for debug builds only (release stays unity) — agree?
2. Want me to measure -g1/-gsplit-dwarf as opt-in options, or leave gcc flags alone entirely?

Option A — conservative (kill the fat, zero semantic change):
- buckets 64 → 4096 (power-of-two mask), mirrored in both files
- entry slab pool (freelist of recycled entries, one mmap'd slab) → removes per-entry mmap/munmap entirely
- _miPageFind: power-of-2 alignment fast path (offset & (blockSize-1) for 8/16/32/64/… size classes) so the div only remains for non-pow2 classes
- Expected: 3.8% → ~1.8–2.2%. Risk: low.
Option B — proper-mimalloc-grade O(1) (recommended end-state, after A validates):
- Each 64MiB arena gets a slice directory (MiPage**, one slot per 64KiB slice, carved from the arena header next to its bitmap — no new allocations) + a global arena list (published under the existing _miMapLockWord, lock-free readers — same concurrency model as today)
- _miPageFind = walk the few arenas (2 range compares each) → sliceIdx = (p-arena)>>16 → page* → range + alignment check. Register the page across its full reserved extent at _miPageAlloc (reserved never changes post-create — guaranteed by existing code)
- Huge pages + arena-full direct-mmap segments stay on the existing hash map as fallback (tiny chains there) — minimal blast radius
- Kills pageFind's hash/div and all map syscalls on the hot path; allocator semantics untouched: free-list encoding, retirement, cross-thread/delayed frees, huge-page owner logic — all unchanged (this is exactly the address→page index that upstream mimalloc itself has swapped designs for)
- Expected: family → ~1%. Risk: medium (arena-list publishing + directory registration) → gated by full validation.
- Windows file gets the mirrored edit (same code, mmap intrinsic is the platform shim). 
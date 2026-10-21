# Coral Compiler Performance Review — Consolidated Agent Report

Date: 2026-10-21
Method: 8 parallel review agents (parser ×3, semantics ×3, frontend ×1, codegen ×1), each performing static analysis plus callgrind/perf profiling of a self-host build, with web-search comparison against clang / rustc / GCC. An error-message-quality agent was requested but not yet run (see end).

**Universal headline finding (every agent independently confirmed):** `AstContext.intern` (`coral-context/context.crl:452-496`) is a linear scan with byte-compare (`streq`) over the entire interned-string table. It is **45–63.5% of all instructions** in a self-host build and is O(program-size²). Fixing it (hash map, reusing the lexer's own FNV-1a table at `coral-lexer/table.crl:34-85`) is the single highest-leverage change, worth roughly **2–3× whole-compile speedup** on its own. Everything else shrinks relative to it after it lands.

**Second universal finding:** statement/declaration disambiguation does a full speculative `parseType()` + `save()/restore()` (which rewinds the *source cursor*, forcing a re-lex) + a second real parse — doubling type-parse + intern work on the majority of statements and 100% of struct/union members and `const` decls. **Third:** `prescanConstInts` re-lexes the entire file once before parsing (47.6% of all lexing). **Fourth:** no token buffer, so every `save()/restore()` re-lexes. **Fifth:** the compiler is built with `opt = "debug"`, paying every constant factor at -O0.

## Implementation status (2026-10-21)

Landed in commit `8508d68` (`compiler: optimize interning, declaration parsing, and doc lookup`).

| Item | Status | Notes |
|---|---|---|
| F1 | **DONE** | FNV-1a open-addressed intern index. Measured ~1.27× full self-host speedup (21.6/23.2s → 16.8/18.4s), not the 2–3× headline above. |
| F2 | **DONE** | Struct/union members parse their type once via `parseFuncDeclTail`; benchmark impact inconclusive. |
| F3 | **DONE** | Single-pass `parseConstDecl` / `finishConstDecl`. |
| F6 | **DONE** | `ParserMark.nodesLen` saved and restored. |
| F7 | **DONE** | Attribute checks now hit the hashed interner; edit-distance table uses stack storage and length early-out. |
| F8 | **DONE** | Doc table kept sorted by `(fileId, declLine)` with binary-search insert/lookup. |
| F9 | **DONE** | One `rebindTypeParams` walk handles local and outer generics. |
| F10a | **DONE** | `scanDocsAbove` frees its temporary `String`. |
| F4, F5 | **NOT STARTED** | Token-buffer / single-lex redesign; largest remaining parser work. |
| F10b–F10f | **NOT STARTED** | Minor/hygiene items. |
| Parts 2–9 | **NOT REVIEWED** | Only Part 1 has been implementation-checked so far. |

Validation at that commit: two self-host builds, `opttest` rc 5, `sigtest` rc 0, generic fixtures matched, Mu rebuilt and ran.

---

# PART 1 — Parser: Declaration Layer & Core
*(Agent ses_ea2771785ffegwGmrixXgL7RYa — scope: decl.crl, base.crl, lib.crl, file.crl)*

## Coral Parser Performance Review — Declaration Layer & Core

Scope reviewed: `coral-parser/decl.crl` (1711 lines), `base.crl`, `lib.crl`, `file.crl`, plus the core machinery they depend on (`parser.crl` save/restore, `context.crl` intern/arena, `type.crl` prescan, lexer). All read-only; no files modified.

**Note on `lib.crl` / `base.crl`:** `lib.crl` is pure re-exports and `base.crl` only defines structs — no hot code. All findings below live in `decl.crl`, `file.crl`, and the core they call. Findings are ranked by expected impact; F1 is unambiguous, F2–F5 order depends on your workload profile (they compound — see end).

---

### F1. `AstContext.intern` is a linear scan with string compares — O(n) per call, O(n²) per compile

**Status: DONE (`8508d68`).** Replaced the linear scan with a FNV-1a open-addressed index. Measured whole-compile improvement is ~1.27×, so the 2–3× headline is overstated; the O(n²) mechanism was real.

**Location:** `coral-context/context.crl:452-496` (the `streq` loop at 458-467), invoked from **69 call sites in `decl.crl` alone** (e.g. `decl.crl:272, 594, 697, 817, 877, 915, 1041, 1130, 1481, 1534`) and 169 across the compiler.

**What it does / why it's slow:**
```coral
u32 intern(str s) {
    u32 i = 1;
    while (i < self.internsLen) {           // walks EVERY entry...
        if (self.streq(...e..., s)) return e.id;   // ...with a byte-by-byte compare
        i++;
    }
    ...
}
```
Every declaration name, field name, param name, type path segment, attribute name, and expression identifier pays a scan whose length grows with the number of distinct strings interned *so far*. Lookup of a string already interned at position p costs p comparisons; on average that's N/2. Since the parser interns on nearly every stored identifier, total cost ≈ `intern_calls × distinct_strings / 2` — quadratic in program size. The code even flags it: *"linear scan over distinct strings; O(n) per call, fine until a profile says otherwise"* (`context.crl:450-451`). This is the profile.

Worse, it **multiplies with every other finding below**: each speculative re-parse of a type re-interns the same idents (F2/F3), `isKnownAttr` calls `intern("literal")` up to 18× per attribute (F7), the prescan interns const-head idents (F4).

**Concrete fix:** add an open-addressed hash index over `interns` — FNV-1a, exactly the table you already ship in the lexer (`coral-lexer/table.crl:34-85`):

```coral
pub struct InternEntry { u8* ptr; u32 len; u32 id; u32 hash; }  // + precomputed hash
// AstContext gains: u32* internIdx; u32 internIdxCap;  // power-of-two, 0 = empty

u32 intern(str s) {
    if (s.len == 0 || s.ptr == null) return 0;
    if (!self.ensureInterns() || !self.ensureInternIdx()) return 0;
    u32 h = fnv1a(s);
    usize mask = self.internIdxCap - 1;
    usize p = h & mask;
    while (self.internIdx[p] != 0) {
        u32 id = self.internIdx[p] - 1;
        InternEntry* e = self.interns + id;
        if (e->hash == h && e->len == s.len && streq(*e, s)) return id;  // hash+len reject first
        p = (p + 1) & mask;
    }
    // miss → append entry as today, then claim slot: internIdx[p] = e.id + 1;
    // grow & rehash when internsLen*4 > internIdxCap*3
}
```
`Str` ids stay monotone so nothing downstream changes. Phase-2 (bigger win): the lexer already hashes every identifier at lex time (`table.crl` `IdentifierTable.get`) — stash the FNV hash (or even the final `Str` id) in `IdentifierInfo` and give the parser an `internFast(s, h)` so hot-path stores never re-hash.

**Speedup rationale / how others do it:** this turns the dominant O(N·M) into O(M) amortized. rustc's interner is `HashMap<String,u32> + Vec<String>`; switching it to `FxHashMap` alone cut whole-compile time up to 5% on rustc-perf (rust-lang/rust#50174). matklad's "Fast and Simple Rust Interner" describes exactly the map+vec shape. Clang (`IdentifierTable`/`StringMap`, hashed `DeclarationName`) and GCC (`htab_t` identifier tables) never scan string tables linearly. Coral already has the right data structure in `lexer/table.crl` — it just isn't used for the AST-level interner.

---

### F2. Struct/union members parse every type **twice** (field-vs-method lookahead re-parses from scratch)

**Status: DONE (`8508d68`).** Added `parseFuncDeclTail` and made struct/union members commit after one type parse. No confirmed speedup yet; benchmark noise was too high to attribute a gain.

**Location:** `decl.crl:854-869` (struct), `decl.crl:1077-1090` (union).

**What it does / why it's slow:**
```coral
ParserMark mark = self.save();
self.parseType();                       // PARSE #1 — allocates TypeEntry(s),
self.expect(TokenKind::Ident);          //   interns every path segment (linear, F1),
bool isMethod = current == LParen || current == Less;   //   may alloc/malloc generic-arg lists
self.restore(mark);                     // rewinds lexer cursor → those bytes re-lex too

if (isMethod) { ... parseFuncDeclFlags(...) }   // → parseFuncOrVarDecl → parseType()  PARSE #2
else          { Ty fieldType = self.parseType(); ... }  // PARSE #2
```
Both branches re-parse — this is **guaranteed 2× type-parsing work for 100% of struct/union members** (the speculative `parseType` always *succeeds*; only what follows the name decides field vs method). Each discarded pass also:
- re-interns the type's idents (doubles F1's cost inside every struct body),
- re-lexes the whole member prefix (restore rewinds `lexer.cur`, F5),
- leaks type-table entries (rewound via `typesLen` — OK) **and node-arena slots** (never rewound — F6),
- leaves `tyListFinish`-tracked generic-arg arrays reachable only as garbage until deinit.

Note this lookahead doesn't even need to *fail* — there's nothing speculative about the type itself.

**Concrete fix:** parse once and branch on the token *after* the name. Refactor `parseFuncOrVarDecl` (`decl.crl:587`) into a front half (`parseType` + optional `match(Const)` + `expectName`, lines 589-593) and a finisher that accepts `(Ty retType, Token nameTok)`:

```coral
// inside the struct/union member loop, replacing lines 854-891:
Ty memberTy = self.parseType();
if (self.current.kind == TokenKind::Ident)
{
    Token nameTok = self.advance();
    if (self.current.kind == TokenKind::LParen || self.current.kind == TokenKind::Less)
    {
        NodeId method = self.finishFuncOrVarDecl(memberTy, nameTok,
            fieldFlags == 1, mIsExtern, mIsStatic, isConstAttr);
        // docs: scanDocsAbove() already ran / run it here; attach as today
        if (!self.ctx.nodeListAppend(&methods, method)) self.reportAllocFailed();
        self.match(TokenKind::Semicolon);
        continue;
    }
    // field path: memberTy IS the field type — continue with declarator suffixes
    Ty declType = self.parseDeclaratorArray(memberTy);
    ... exactly the existing lines 876-890 ...
}
else { /* expect(Ident) failure: report once, recover */ }
```
Semantics are preserved: diagnostics still emit exactly once (the old code suppressed the lookahead's errors via `specDepth` and re-emitted on the real pass; a committed single pass emits them once at the same locations).

**Speedup rationale / how others do it:** this is precisely the bug class clang documents in `TryAnnotateTypeOrScopeToken` (`clang/include/clang/Parse/Parser.h`): token annotation exists so *"getTypeName will not be called twice, once to check whether it is a declaration specifier, and another one to get the actual type inside ParseDeclarationSpecifiers."* Clang resolves field-vs-method-style ambiguities with **1–2 token lookups and cached annotations**, not by parsing a prefix and discarding it; full `TentativeParsingAction` backtracking is reserved for rare/error cases (`ParseTentative.cpp`). Expected win: ~2× reduction in type-parse + intern work in every struct/union body — usually the largest code mass in a file — and half the re-lexing/churn once F5 is addressed.

---

### F3. `const` declarations parse the type twice (backtracking disambiguation)

**Status: DONE (`8508d68`).** Replaced the speculative const head with one forward parse through `parseConstDecl` / `finishConstDecl`.

**Location:** `decl.crl:410-425` (`parseDeclBody`, `TokenKind::Const` case), followed by re-parse in `parseConstDecl` (`decl.crl:1258-1296`) or `parseFuncOrVarDecl` (`decl.crl:589`).

**What it does / why it's slow:**
```coral
TokenKind::Const => {
    ParserMark m = self.save();
    self.advance();
    self.parseType();                    // full type parse #1 (alloc + intern + possible re-lex later)
    bool fnAfterConst = false;
    if (self.current.kind == TokenKind::Ident) { self.advance();
        fnAfterConst = self.current.kind == TokenKind::LParen; }
    self.restore(m);                     // rewind bytes → re-lex
    if (fnAfterConst) return self.parseFuncOrVarDecl(...);  // parseType AGAIN (line 589)
    return self.parseConstDecl(isPub);                     // parseType AGAIN (line 1261)
},
```
Every `const` in the file pays 2× `parseType`, 2× interning of its type, a `save/restore`, and a re-lex of the const head. `const Foo<Bar> N = …` doubles generic-arg list allocations too.

**Concrete fix (two options, both cheap):**

*Option A — commit-style, mirroring the pattern your parser already gets right in `parseVarDecl` (`decl.crl:1307-1320` does exactly this: speculative `parseType`, `endSpeculation()` on success):*
```coral
TokenKind::Const => {
    self.advance();                          // consume `const`
    Ty t = self.parseType();
    if (self.current.kind == TokenKind::Equal)          // untyped: t was the name
        return self.finishConstDecl(0, nameFromNamed(t), ...);
    Token nameTok = self.expectName();
    if (self.current.kind == TokenKind::LParen)
        return self.finishFuncOrVarDecl(t, nameTok, ...);   // const-returning fn
    return self.finishConstDecl(t, nameTok, ...);
}
```
Zero backtracking: the three shapes (`const NAME =`, `const T NAME`, `const T NAME(`) are distinguishable by one forward pass — `parseConstDecl` already contains the "type was actually the name" logic (lines 1265-1279), you just need it to accept a pre-parsed `(Ty, nameTok)` instead of re-lexing.

*Option B — if you keep save/restore, make the peek token-level:* after `const`, scan tokens while `isConstHeadToken`-style (ident/`::`/type keyword/`*`/balanced `<…>`/`[…]`), then check for `Ident (`. No `parseType`, no allocations, no interning in the discarded pass.

**Speedup rationale:** halves const-decl parse work; Option A additionally removes a restore+re-lex. Grounded in clang/rustc practice: both decide declaration shapes with a *single* forward pass and commit — `parseVarDecl` in this very codebase proves the pattern works. GCC's `c_parser_next_tokens_start_declaration` answers "is this a declaration?" purely from peeked token kinds, never by parsing.

---

### F4. `prescanConstInts` re-lexes the entire file before parsing

**Location:** called from `file.crl:25` (`parseFile` → `self.prescanConstInts()`); implementation `type.crl:215-276`.

**What it does / why it's slow:** a full dry run over **every token in the file** — `skipWsCmts` (including all doc-comment bytes) + token classification + `Token` materialization + parser `advance()` bookkeeping — through a state machine, wrapped in `save()/restore()` and a diag-pointer swap, so declarator array sizes (`u8 buf[N]`) can resolve forward consts. Then the real parse lexes everything again from the rewound cursor. Net: **≥2× lexer work per file**, and doc comments get scanned 3× (prescan + parse + `scanDocsAbove`'s raw walk). It also calls `ctx.intern` on every ident in a const head (line 243) — F1 cost, paid even for `const`-returning functions whose heads never match.

**Concrete fix (preferred, subsumes F5):** lex each file **once** into a token array and run both passes over indices:

```coral
// parseFile:
Token* toks = self.lexer.lexAll(&n);        // one pass, arena-allocated, freed at file end
self.prescanConstIntsFrom(toks, n);         // state machine over toks[i].kind — no lexer, no save/restore
self.parseFileFrom(toks, n);                // advance() = pos++, current = toks[pos]
```
The prescan state machine then costs only kind comparisons over a flat array (likely 20-50× cheaper than today), and it no longer needs `save()/restore` or diag muting beyond skipping `addConstInt` interning until the pattern matches.

**Standalone fallback** (if full pre-lex isn't wanted yet): make the prescan a raw byte scanner that skips strings/comments while hunting for `const` and then hand-verifies `head = int ;` — still two byte passes but no `Token` construction or parser plumbing. Note it *must* skip string/comment bytes to stay correct.

**Speedup rationale / how others do it:** GCC's `c_parser` explicitly supports *"...or more if parsing from pre-lexed tokens"* with `c_parser_peek_nth_token` over a token vector; rustc lexes the whole file into a `TokenStream` up front (`rustc_parse::lexer::lex_token_trees`) so the parser never re-lexes; clang's preprocessor caches lookahead tokens (`PP.LookAhead(N)`) precisely so peeking/backtracking never returns to source bytes. Coral's design does the opposite: the lexer cursor *is* the parser's undo buffer.

---

### F5. No token buffer: every `save()/restore` rewinds source bytes → backtracking re-lexes

**Location:** `parser.crl:123-152` (`save` captures `lexer.getCur()/getLineStart()/getLine`, `restore` sets them back); `base.crl:9-24` (`ParserMark`); `lexer/base.crl:51-59` (cursor pokes).

**What it does / why it's slow:** `restore()` doesn't restore *tokens* — it restores a byte cursor, so **every token consumed between `save()` and `restore()` is re-lexed** when the region is re-parsed. There are 9 `save()` sites in `decl.crl`, 1 in `file.crl`, plus 5 in `expr.crl`, 4 in `stmt.crl`, 3 in `type.crl`. Most are 1-token peeks (`decl.crl:398` struct tuple check, `742` const-self, `1488/1545` `::` peeks — cheap but each still re-lexes ≥1 token plus `ParserMark`/specDepth bookkeeping), but the heavy ones re-lex whole speculative regions: F2's member prefixes, F3's const heads, `parseGenericArguments` (`type.crl:324`) which fires on **every `<` after an identifier in expression position** (`expr.crl:570` — i.e., every `i < n` loop bound in every function body speculatively type-parses the RHS prefix, fails `consumeGreater`, restores, and re-lexes), and the cast lookahead at `expr.crl:635-648`.

**Concrete fix:** the token array from F4. `ParserMark` collapses to an index:

```coral
pub struct ParserMark { u32 pos; Token current; Token previous;
                        u32 panicMode; u32 specDepth; bool pendingGreater;
                        u32 typesLen; u32 nodesLen; }   // see F6
ParserMark save() { ... m.pos = self.pos; self.beginSpeculation(); return m; }
void restore(ParserMark m) { self.pos = m.pos; self.current = toks[m.pos];
                             self.previous = ...; ... }   // zero lexer involvement
```
Lookahead at any depth becomes O(1) with no re-lexing, and `lexer.setCur/setLine/setLineStart/setToken` plumbing can eventually go away.

**Minimum viable variant** (no full pre-lex): keep a small ring of already-lexed tokens (GCC's `tokens_buf[4]` + `tokens_avail`) so 1–2-token peeks — the majority of sites — never re-lex. But the full array makes F4 free at the same time.

**Speedup rationale / how others do it:** GCC `c_parser` (`gcc/c/c-parser.cc`): "A parser structure... Includes lexer information with up to two tokens of look-ahead" — `c_parser_peek_token` returns a *buffered* token; lexing happens once per token, ever. Clang: `GetLookAheadToken(N)` → `PP.LookAhead(N)` reads from the preprocessor's cached token queue. rustc: `TokenCursor` snapshots (cursor offsets into a lexed `TokenStream`) make backtracking a pointer copy — and `LazyAttrTokenStreamInner::Pending` exists exactly to avoid re-materializing streams. Coral is the outlier: source-position backtracking.

---

### F6. Speculation leaks node-arena slots — `restore()` rewinds `typesLen` but not `nodesLen`

**Status: DONE (`8508d68`).** `ParserMark` now records `nodesLen`; `restore()` rewinds it alongside `typesLen`.

**Location:** `parser.crl:117-122` (comment admits it: *"restore() rewinds everything except the node arena; nodes the discarded pass allocated stay behind"*); `base.crl:9-24` (`ParserMark` has `typesLen`, no `nodesLen`); `restore()` at `parser.crl:140-152`; allocation at `context.crl:820-834`.

**What it does / why it's slow:** every discarded `parseType` (array-size exprs via `parseTypeSuffix` → `parseExpr`, `type.crl:76`), discarded member/const/var lookahead, failed `parseGenericArguments`, and failed cast parse permanently consumes node-arena slots. Consequences: (a) `ctx.nodes` grows well beyond the real AST — wasted memory and cache footprint; (b) `growNodes` arena copies trigger more often; (c) any pass iterating `0..nodesLen` pays for ghosts — the LSP alone has **six** such full scans (`lsp/server.crl:1398, 1492, 1653, 1841, 2161, 2249`); (d) it *amplifies* F2: struct-heavy files inflate `nodesLen` by roughly the speculative member type-expr count. The `typesLen` rewind exists precisely because unrewound speculative entries broke sema (`base.crl:19-23`) — nodes are the same problem without the fix.

**Concrete fix:** treat `nodesLen` exactly like `typesLen`:

```coral
// base.crl ParserMark: add `u32 nodesLen;`
// parser.crl save():    .nodesLen = self.ctx.nodesLen
// parser.crl restore(): self.ctx.nodesLen = m.nodesLen;
```
Safety invariant (matches the one already relied on for types): nothing reachable survives a `restore()` — live structures are `ctx.types` (rewound), committed decl payloads (written only after `endSpeculation()`), and local variables (discarded). I traced `parseDecl`/`attachDoc` call sites: `parseDecl` only runs committed (`file.crl:81`, `decl.crl:1707` inside `parseComptimeDecl`, which itself only runs from committed `parseDeclBody`), so the `docs` table is never written under speculation. The one extra audit: any `track()`ed list finished inside a discarded pass stays owned until deinit (harmless garbage, no dangling ids) — optionally also record `ownedLen` in the mark if you want those buffers reclaimed (free entries beyond the mark on restore).

**Speedup rationale:** clang deliberately structures tentative parsing so it produces **no AST and no Sema actions** (`TentativeParsingAction`/`Revert` in `ParseTentative.cpp`; the well-known LLVM-discourse objection to backtracking is that `ActOn*` results "will be instantiated... and if you backtrack you have to deal with both the Expr objects and the diagnostics" — clang's answer is to not create them). Coral already adopted that for types; finish the job for nodes. All ASTs live in bump arenas (`BumpPtrAllocator` in clang) where "allocation is cheap but *count* matters for later traversals" — same here.

---

### F7. Attribute handling: up to 18 linear-scan `intern()` calls per name check + heap allocs in edit distance

**Status: DONE (`8508d68`).** The linear `intern()` cost disappeared with F1; `attrNameDistance` now uses stack arrays and an `abs(lenA-lenB)` early-out. The 18 candidate checks remain but are integer-only hashed lookups.

**Location:** `isKnownAttr` `decl.crl:132-153`; `attrNameDistance` `decl.crl:158-199`; `closestAttrName` `decl.crl:202-234`; called from `parseAttrListTo` `decl.crl:276` — which runs for **every** attribute on every decl, member, and statement (`parseAttrListTo` also interns the name at line 272 even when `outAttrs == null`).

**What it does / why it's slow:**
- `isKnownAttr("packed")` executes `self.ctx.intern("const")`, `intern("condassign")`, … until match — each an F1 linear scan with string compares. An unknown attribute runs **all 18**, each a full-length scan (not found), *on top of* the scan for its own name.
- `closestAttrName` then does 18 *more* `intern(literal)` calls and 18 × `attrNameDistance`, each allocating **two heap buffers** (`alloc<usize>(41)` ×2 at lines 166-167) — up to 36 mallocs per candidate pair, ~72 per misspelled attribute, with no `|lenA − lenB| ≥ bestD` early-out before the DP.
- `parseAttrListTo` on a `#[[packed]]` therefore costs ~13 full/partial interner scans *plus* a `String` build — in a hot per-declaration path.

**Concrete fix:**
```coral
// Parser init (or ctx init): intern each known attribute ONCE into a sorted id table
u32 knownAttrIds[18];   // Str ids, sorted ascending after build

bool isKnownAttr(Str name) {
    u32 lo = 0, hi = 18;
    while (lo < hi) { u32 mid = (lo + hi) / 2; u32 v = knownAttrIds[mid];
        if (v == name) return true;
        if (v < name) lo = mid + 1; else hi = mid; }
    return false;                          // pure integer compares, zero string work
}
```
`closestAttrName` iterates the same table (no re-intern). In `attrNameDistance`: use stack arrays `usize prev[41], cur[41];` and bail when `abs(lenA − lenB) >= bestD` (length alone rules out most candidates before any DP).

**Speedup rationale / how others do it:** production compilers answer "is this a known attribute/keyword?" with **enum or integer compares after a one-time hash classification** — clang checks `tok::kind` post-`IdentifierInfo` classification, GCC uses `C_IS_RESERVED_WORD`/RID codes. String work in a per-declaration path is the anti-pattern; the interner call *is* the string comparison here, just hidden behind F1.

---

### F8. `attachDoc` → `addDocBlock` linear scan: O(D²) doc table per file

**Status: DONE (`8508d68`).** Doc entries are kept sorted by `(fileId, declLine)`; insert and lookup are binary searches.

**Location:** `decl.crl:93-99` (`attachDoc`) → `context.crl:501-526` (`addDocBlock`, linear scan at 503-513); lookup twin `docFor` `context.crl:530-540`.

**What it does / why it's slow:** every documented declaration scans all doc entries collected so far comparing `(fileId, declLine)`. A file with D documented decls does ≈ D²/2 iterations (e.g. D=5000 → ~12M compares — plus the same quadratic again in any consumer calling `docFor` repeatedly). `scanDocsAbove` is invoked per decl/member (`decl.crl:368, 723, 846, 1070, 1155, 1234`), so this runs at full decl throughput.

**Concrete fix:** keep entries sorted by `(fileId, declLine)` and binary-search (insert is normally append — decls arrive in increasing line order per file), or hash on `(fileId << 32) | declLine`. Cheap change confined to `context.crl`.

**Speedup rationale:** clang stores raw comments offset-sorted in `ASTContext::RawCommentList` and resolves a decl's comment with `lower_bound` (`getRawCommentForDeclNoCache`) — O(log n), never a scan.

---

### F9. `rebindTypeParams` walks each type tree twice per declaration

**Status: DONE (`8508d68`).** Local and outer generic lists are now passed through a single recursive walk.

**Location:** `decl.crl:485-580` (function), invoked at `decl.crl:602-603` (return type ×2 lists) and `decl.crl:655-656` (per param ×2 lists).

**What it does / why it's slow:** each call recurses the *entire* composite type (nested generic args, pointers, tuples, fn-ptr params…) doing a linear name scan over `genericValues`. Inside struct/union/trait/extend methods **both** lists are non-empty, so every param type is fully walked twice; a method with P params does 2 + 2P full-tree walks. (Top-level functions are fine — `genericCount == 0` early-outs the `outerGenerics` call.)

**Concrete fix:** one walk with both binding lists:
```coral
void rebindTypeParams(Ty ty, NodeId* a, u32 la, NodeId* b, u32 lb)
// Named case: scan a, then b; recurse once per child passing (a,la,b,lb)
```
Alternatively build a tiny `name → (listIdx, paramIdx)` table once per decl (18-ish entries max) and let the walk do O(1) lookups instead of per-node linear scans.

**Speedup rationale:** standard "don't walk shared structure N times for N symbol tables" — clang's `Sema` resolves template args against a single `TemplateParameterList` scope in one pass rather than re-walking per scope layer. Moderate impact: rebind is cheaper than parse/intern, but it's pure waste and scales with type size × param count.

---

### F10. Minor / hygiene findings

**Status: PARTIAL (`8508d68`).** (a) is fixed; (b)–(f) remain.

| # | Location | Issue | Fix |
|---|---|---|---|
| a | `decl.crl:76-88` | **DONE (`8508d68`).** `scanDocsAbove` builds `String out`, interns it, and **never calls `out.free()`** — leaks one heap buffer per doc block (contrast `strListJoin` at `decl.crl:1467` which frees). Memory pressure, not CPU. | `Str r = self.ctx.intern(out.asView()); out.free(); return r;` |
| b | `decl.crl:39-89` | `scanDocsAbove` runs unconditionally for every decl/member: ≥1 backward line-walk even when no comment exists. Bounded (64 lines) — acceptable, but after F1-F5 it may be visible in profiles. | Keep, but only after F1-F5; if it still shows up, record `///`-run line numbers in the lexer (it already walks comment bytes) into a side vector and have the parser binary-search by line — same trick as F8. |
| c | `coral-lexer/base.crl:75-81` | `reportErrorCode` recomputes the line by scanning **from `bufStart` to `errPtr`** — O(file) per lexer diagnostic → O(n²) if a file has many bad bytes. `makeToken` already tracks `self.line`. | Track line delta incrementally or scan backward from `self.line`'s position; error path only, but trivially fixable. |
| d | `context.crl:561-596` + all list builders | Every params/fields/generic/variant list starts at cap 4 → per-declaration small-malloc sequences (`nodeListInit` → grow 4→8→16 + `track`). Not quadratic (amortized doubling), but high allocation *count*. | SmallVec-style inline capacity (`u32 inlineBuf[4]` in the builder, heap only on overflow) or a bump arena for per-decl scratch lists freed at scope end — clang's `SmallVector`/factory pattern; rustc `ThinVec`/`SmallVec`. |
| e | `type.crl:155-168` | `lookupConstInt` linear over the per-file const table — fine while tables are tiny; hash it if files accumulate many consts. | Same open-addressing table as F1 (names are already interned ids → integer keys). |
| f | `file.crl:31-57` | Leading-attribute peek does save/intern/restore then re-consumes via 5 `expect`s — re-lexes ~6 tokens. | Becomes free under F5 (index restore); alternatively compare `intern("no_drop_all")` result from a pre-interned id (F7 pattern). |

**Already good (don't "fix"):**
- **Dispatch is token-kind switches everywhere** (`parseDeclBody` `decl.crl:393`, `isTypeStart` 447, `expectName` `pattern.crl:235` using `token.info.isKeyword`) — no string compares in dispatch paths. Keep it that way (this is why F7's `intern("literal")` chains stand out).
- **`parseVarDecl`'s commit pattern** (`decl.crl:1307-1320`) — the right way to disambiguate; use it as the template for F2/F3.
- **Arena allocation** for nodes/types (`allocNodeSlot`/`allocTypeSlot`, `context.crl:804-834`) — O(1) bump with capacity checks; good foundation (clang `BumpPtrAllocator` analogue). The issue is slot *count* under speculation (F6), not the allocator.
- **`internKind` primitive dedup** (`type.crl:459-468`) — early-exits at low indices; effectively O(1).
- **`parseFile` progress/error guard** (`file.crl:78-94`) — cheap pointer/kind compares; prevents infinite loops correctly.
- **Recursion depth**: `parseType`/`parseExpr`/`parseDeclaratorArray`/`parseSymbolList` recurse only to source nesting depth — no unbounded or non-tail recursion found at the decl layer; this matches clang/rustc recursive-descent practice. Not a target.

---

### Interactions & suggested order of work

The findings **compound multiplicatively**, so sequence matters:

1. **Instrument first** (cheap, decisive): counters for `intern` calls + total scanned entries, `nextToken` calls, `save`/`restore` count, `parseType` invocations, final `nodesLen` vs. real AST size — print per file behind a flag. This ranks F1-F5 on *your* corpus instead of my priors.
2. **F1 (hashed interner)** — expected single largest win; everything below gets cheaper too. Reuse `lexer/table.crl`'s FNV-1a code.
3. **F2 + F3 (parse-once member/const)** — second-largest, entirely inside `decl.crl`; requires the `finishFuncOrVarDecl(Ty, Token)` refactor. Halves type-parse/intern/re-lex work in the most type-dense code.
4. **F5 + F4 together (lex-once token array)** — one change eliminates the prescan's extra full pass *and* all backtracking re-lexing *and* makes every one of the 22 `save()` sites O(1). GCC pre-lexed tokens / rustc `TokenStream` model.
5. **F6 (`nodesLen` rewind)** — one-line-in-three change, removes arena bloat and ghost-node scans.
6. **F7, F8, F9, F10** — bounded, localized wins (attr path, doc table, rebind walks, leaks).

Estimated qualitative effect: F1+F2+F3 are each plausibly 10-40% of parse-phase time on large inputs (intern is likely dominant *now*; once hashed, F2/F4/F5 rise in the profile — hence "measure between steps"). Grounding summary: **clang** — annotation/1-token lookahead instead of reparse (`Parser.h TryAnnotateTypeOrScopeToken`), tentative parsing creates no AST, `PP.LookAhead` never re-lexes, `BumpPtrAllocator`, sorted raw-comment binary search; **rustc** — whole-file `TokenStream` + cursor snapshots, `HashMap` interner (FxHash = up to 5% whole-compile); **GCC** — `c_parser` token buffer / pre-lexed token vectors, RID-code keyword checks, `htab` identifier tables. Coral's missing pieces relative to that set are: a hash interner, a token stream, parse-once disambiguation, and full speculative-arena rewinding.

---

# PART 2 — Parser: expr / stmt / pattern
*(Agent ses_ea276f495ffep4AGYiiGU8IjJh — scope: expr.crl, stmt.crl, pattern.crl)*

## Coral Parser Performance Review — expr / stmt / pattern

**Scope reviewed (read-only):** `coral-parser/expr.crl` (43KB), `coral-parser/stmt.crl` (31KB), `coral-parser/pattern.crl` (14KB), plus the machinery they call every line: `parser.crl`, `recovery.crl`, `type.crl`, `base.crl`, `coral-context/context.crl`, `coral-lexer/{lexer,table,ident}.crl`.

### Architecture verdict first

The expression core **is already a correct clang-style precedence climber**. `parseExpr → parseBinaryExpr(minPrec) → parseUnaryExpr → parsePostfixExpr → parsePrimaryExpr` (expr.crl:201-248) is structurally identical to clang's `ParseAssignmentExpression → ParseRHSOfBinaryExpression(LHS, MinPrec)` loop (`clang/lib/Parse/ParseExpr.cpp:313+`: "If this token has a lower precedence than we are allowed to parse… then we are done", recurse with `ThisPrec + !isRightAssoc`). There is **no per-operator backtracking** — the operator loop consumes each token once. That part is fine; don't rewrite it.

The slowness comes from *outside* the operator loop: **(a) an O(n²) string interner hit on every identifier, (b) statement-level speculative `parseType` that re-lexes and re-parses most statements, (c) per-identifier type-arena garbage, (d) speculation-triggered heap allocs (String/TyList) even when the result is discarded, (e) malloc-per-list instead of bump allocation.**

Ranked findings, highest impact first:

---

### #1 — `AstContext.intern` is a linear scan: O(distinct × occurrences) interning

**Location:** `coral-context/context.crl:452-496` (the scan, 458-467), reached from the hottest lines in scope: `expr.crl:364, 381, 422, 502, 507, 565, 583, 605, 786, 807/810`, `stmt.crl:58-61, 230, 242, 693`, `pattern.crl:43, 87, 99, 135, 143, 154, 174`.

**What it does / why slow:**
```coral
u32 intern(str s) {
    u32 i = 1;
    while (i < self.internsLen) {           // linear over EVERY distinct string
        InternEntry* e = self.interns + i;
        if (self.streq(str{.ptr = e.ptr, .len = e.len}, s)) return e.id;
        i++;
    }
    ... alloc copy + track ...
}
```
Every `Ident` primary, field name, method name, attribute name, pattern name does this scan. On the self-host corpus (~1.45MB of `.crl` in `compiler/`, ~3MB tree), that's on the order of 10⁵–10⁶ lookups × an average table position growing toward 10⁴ entries = **10⁸–10⁹ `streq` probes**, each a `self.streq(...)` method call building two `str` temporaries — and the compiler builds itself with `opt = "debug"` (coral.crlb), so this is un-inlined, un-vectorized generated C. This is textbook O(n²) and is almost certainly the single largest line-item.

Note the lexer **already solved this exact problem**: `coral-lexer/table.crl:34-85` is an FNV-1a open-addressing table, and every ident token carries `Token.info: IdentifierInfo*` (token.crl:168, ident.crl:213-217). The parser then re-does the same lookup with a worse algorithm.

**Fix (two layers):**
```coral
// context.crl — replace the scan with the lexer's own algorithm
InternEntry* hash;   // open-addressed, power-of-2 capacity, FNV-1a
u32 intern(str s) {
    usize h = fnv1a(s) & (self.internCap - 1);
    while (occupied) { if (streq(entry, s)) return id; h = (h+1) & mask; }
    ...insert...
}
// AND: piggyback on the lexer's identifier table for the hot 95%
// common/token.crl:  IdentifierInfo { ... u32 strId; }   // 0 = not yet interned
// expr.crl Ident case:
Str name;
if (nameTok.info != null) {
    if (nameTok.info.strId == 0) nameTok.info.strId = self.ctx.intern(nameTok.data.asStr());
    name = nameTok.info.strId;
} else name = self.ctx.intern(nameTok.data.asStr());
```
The `IdentifierInfo` route also skips the byte-copy+`track()` on repeat identifiers, because the lexer table already owns one entry per distinct word.

**How others do it:** clang's `IdentifierTable` is a `llvm::StringMap<IdentifierInfo*, BumpPtrAllocator>` keyed by xxHash — its own docs call it *"an extremely performance-critical piece of the code, as each occurrence of every identifier goes through here when lexed"* (`IdentifierTable.h:694`). rustc's `Interner` is an `FxHashMap<Symbol, u32>` + `Span` interner. Nobody linear-scans. **Expected impact: removes what is likely 30–60% of parse time on large files; the win grows quadratically with corpus size.**

---

### #2 — Statement decl-vs-expr disambiguation: full speculative `parseType`, then rewind + **re-lex** + re-parse

**Location:** `stmt.crl:719-747` (general path), `stmt.crl:670-713` (var/const/static path, 679-690), `stmt.crl:282-300` (typed `for` header); enabled by `parser.crl:140-152` (`restore()` calls `lexer.setCur(m.cur)`).

**What it does / why slow:**
```coral
// stmt.crl:719 — runs for EVERY statement starting with a type-ish token,
// which includes every Ident-leading expression statement (~60-70% of stmts)
if (self.isTypeStart() && self.current.kind != TokenKind::LParen) {
    ParserMark mark = self.save();
    Ty typeNode = self.parseType();          // (1) full type parse, allocates + interns
    bool isDecl = false;
    if (self.current.kind == TokenKind::Ident) {
        Token name = self.expectName();      // may fail -> String alloc (see #5)
        isDecl = current is = / ; / [ ;
    }
    self.restore(mark);                      // (2) ALWAYS rewinds the lexer cursor
    if (isDecl) {
        typeNode = self.parseType();         // (3) parsed a SECOND time for decls
        Token name = self.expectName();      // name re-read, re-lexed
        ...
```
Three distinct costs:
1. **`restore()` rewinds the raw byte cursor** (`parser.crl:142`), so every token the speculation consumed gets **lexed a second time** when the real parse runs. For `foo(bar, baz);`, `parseType` walks *the entire call* — `fnTypeAhead()` (type.crl:28-36) sees `(`, then `bar`/`baz` parse as parameter types — and then all of `bar, baz)` is re-lexed.
2. **Double parse of the same text**: for real declarations the type is parsed twice (line 722 speculative, line 732 real); for expression statements the type-shaped prefix is parsed as types *and* as expressions (`x = 5;` → `x` parsed by `parseBaseType` (intern + `makeNamedArgs` alloc) *then* by `parsePrimaryExpr`; `foo(bar)` → entire arg list parsed twice).
3. `parseType` during speculation also runs `parseGenericArguments`, `fnTypeAhead` (nested save/restore), array-suffix `parseExpr` (node leaks — see #8) — all discarded.

The var path (679-690) does it too: `var x = 5;` speculatively parses the *variable name* as a type, fails, restores, re-lexes. The `for` path (282-299) additionally calls `expectName()` unconditionally, so classic `for (i = 0; …)` pays a failed `expect()` (String alloc) and a bogus `advance()` past `=` before restoring.

**Fix (three parts, in order of effort/payoff):**

(a) **Don't re-parse the success path.** Commit what you already parsed:
```coral
ParserMark mark = self.save();
Ty typeNode = self.parseType();
if (self.current.kind == TokenKind::Ident) {
    Token name = self.advance();                 // no expect() needed, it IS an ident
    bool isDecl = self.current.kind == TokenKind::Equal ||
                  self.current.kind == TokenKind::Semicolon ||
                  self.current.kind == TokenKind::LBracket;
    if (isDecl) {
        self.endSpeculation();                   // keep cursor + typeNode + name
        ... typeNode = self.parseDeclaratorArray(typeNode); ... // no restore, no 2nd parseType
        return ...;
    }
}
self.restore(mark);                              // expr path: unavoidable, but see (b)/(c)
```

(b) **Shape-test before parsing anything** (the GCC move). Only run `parseType` when a token-shape scan says `typeish+ Ident ( = | ; | [ )` could follow:
```coral
// pure advance/restore over raw tokens; no parse, no intern, no alloc
bool declShapeAhead() {
    ParserMark m = self.save();
    u32 depth = 0; bool sawType = false, sawName = false;
    while (!self.atEnd()) {
        TokenKind k = self.current.kind;
        if (k == Less || k == LParen || k == LBracket) depth++;
        else if (k == Greater || k == RParen || k == RBracket) { if (depth == 0) break; depth--; }
        else if (depth == 0) {
            if (k == Semicolon || k == Equal) { sawName = ...; break; }   // decide
            if (k == ColonColon || k == Star || k == Ampersand) { /* type continues */ }
            else if (k == Ident) { if (sawType) { sawName = true; ... } else sawType = true; }
            else break;                            // `.`, `(`, operator => expression
        }
        self.advance();
    }
    self.restore(m);
    return decided;
}
```
This kills the *entire* speculation (and its `intern` + type alloc + re-lex) for the common expression shapes: `foo(bar);` bails at token 2 (`(` after a name in type position ⇒ expression), `x = 5;` bails at token 2, `obj.f = 1;` bails at `.`.

(c) **Buffer tokens so `restore()` never re-lexes** (see #4's mechanism — it also fixes #4/#6). `advance()` pulls from a growable token vector; `save/restore` become index arithmetic.

**How others do it:** GCC's C parser keeps `c_token tokens[2]` in the parser struct — `c_parser_peek_2nd_token()` + `c_parser_next_tokens_start_declaration()` decide decl-vs-expr by *token shape only* (`gcc/c/c-parser.h:33`: "Includes lexer information with up to two tokens of look-ahead; more are not needed for C"; `c_token_starts_typename` literally tests `peek is NAME && peek_2nd is (NAME or MULT)`). clang uses `Parser::GetLookAheadToken(N)` first and only falls back to `TentativeParsingAction` for hard cases; from the LLVM discourse on this exact tradeoff: *"Lookahead is more efficient than tentative parsing. Typically do lookahead if possible to catch all of the common cases. Then fall back to tentative parsing if it's a tricky case"* — and crucially *"there's not much difference in efficiency, they use the same preprocessor cache"*, i.e. tentative re-reads are cheap there **because the token stream is cached** (GCC's C++ front end lexes the whole file into `lexer->buffer` upfront). **Expected impact: second-largest win; eliminates ~1 full type-parse + all re-lexing on the majority of statements.**

---

### #3 — Every identifier expression allocates a `TypeEntry` that is never used

**Location:** `expr.crl:563-579`, specifically **line 571**:
```coral
Token nameTok = self.advance();
Str name = self.ctx.intern(nameTok.data.asStr());
Ty* genericArgs = null;  u32 genericArgsLen = 0;
bool hasGenericArgs = self.parseGenericArguments((rawptr*)&genericArgs, &genericArgsLen);
Ty namedType = self.makeNamedArgs(name, genericArgs, genericArgsLen);  // <-- ALWAYS
if (self.current.kind == TokenKind::LBrace) return self.parseLiteralFields(namedType, 0);
if (hasGenericArgs) return self.storeExpr(ExprKind::TypeRef{ ... });
return self.storeExpr(ExprKind::Ident{ .name = name });   // namedType dropped on the floor
```
**Why slow:** `makeNamedArgs` → `allocTypeKind` → `ctx.allocTypeSlot()` + a `te.loc` write (type.crl:307-317). Plain variable references — the most common primary node there is — allocate a full `TypeEntry` (a fat union payload) that nobody reads. On a 500k-token file that's hundreds of thousands of junk type entries, which (i) burn an arena slot, (ii) trigger extra `growStable` doublings — each a full copy, see #8 — and (iii) inflate `typesLen` forever (restore only rewinds *speculative* growth), lengthening `internKind`'s tag scan (type.crl:459-468).

**Fix:**
```coral
bool hasGenericArgs = self.parseGenericArguments((rawptr*)&genericArgs, &genericArgsLen);
if (self.current.kind == TokenKind::LBrace) {
    Ty namedType = self.makeNamedArgs(name, genericArgs, genericArgsLen);
    return self.parseLiteralFields(namedType, 0);
}
if (hasGenericArgs)
    return self.storeExpr(ExprKind::TypeRef{ .name = name,
        .typeNode = self.makeNamedArgs(name, genericArgs, genericArgsLen) });
return self.storeExpr(ExprKind::Ident{ .name = name });
```
**How others do it:** clang builds a `TypeRef`/`TemplateSpecializationType` node only after the parser *saw* `<…>` or a brace; a bare `DeclRefExpr` never touches the type table. **Expected impact: removes ~1 type-arena allocation per identifier; also shrinks arena growth/copies (see #8).**

---

### #4 — Every `<` after an identifier runs a full speculative generic-argument parse

**Location:** `expr.crl:570` → `type.crl:324-374` (`parseGenericArguments`).

**What it does / why slow:** In expression position, after *any* identifier, `current.kind == Less` triggers:
```coral
if (self.current.kind != TokenKind::Less) return false;
ParserMark mark = self.save();
self.advance();
TyListBuilder args; self.ctx.tyListInit(&args);   // grow() from cap 0 → malloc(4 * sizeof(Ty))
... arg = self.parseType();                       // intern + type allocs for the RHS
... ok = self.consumeGreater();                   // fails on `a < b ;`
if (!ok) { dealloc<Ty>(args.data); self.restore(mark); return false; }   // free + re-lex
```
So **`if (i < n)`** — the most common comparison in real code — costs: save/restore, a heap alloc + free of the arg array, `parseType` of `n` (intern linear-scan from #1 + type alloc), and re-lexing of the RHS. Multiply by every relational operator in the corpus.

**Fix (pick by ambition):**
1. **Cheap balanced-`>` prescan, no allocation, no parse** — from the `<`, walk tokens (plain `advance`) with a `<`/`>` depth counter and abort on any token that cannot appear inside a type-argument list (`;` `)` `]` `}` `&&` `||` operators at depth 0). `a < b;` aborts at `;` in one pass; only text that genuinely looks like `Foo<i32>` pays for a real parse.
2. **Required `::<>` turbofish in expression position** (rustc's answer): `Vec<i32>` in *type* position only; expressions use `Vec::<i32>` — the ambiguity disappears entirely and `parseGenericArguments` is only called when `ColonColon Less` is present. Zero-cost check.
3. **Known-type gate**: only attempt when the identifier is known to be a type/template name (clang tracks this on `IdentifierInfo` via `Sema::isTemplateName` / annotation tokens and only tentatively parses `Foo<` when the name is registered as a template).

**How others do it:** rustc sidesteps the ambiguity with turbofish (no speculation at all); clang's tentative `TryParseTemplateId` re-reads are free-ish because they hit the preprocessor's token cache and because `IdentifierInfo` knows whether the name is a template before any parsing starts. **Expected impact: medium-high in comparison-heavy code; also removes malloc/free traffic from the hot path.**

---

### #5 — `reportExpected` heap-builds a diagnostic `String` even while speculating

**Location:** `recovery.crl:109-134`.
```coral
void reportExpected(TokenKind kind) {
    if (self.current.kind == TokenKind::Eof) { ...; return; }
    str base = self.expectedTokenText(kind);
    ...
    String sb = String::from(base);      // String::from → withCap → malloc (lib/std/.../string.crl:34-41)
    sb.pushView(", found '"); ...
    self.reportError(..., sb.asView());  // reportError THEN checks isSpeculating() and drops it
}
```
**Why slow:** `recovery.crl:44` (`reportError`) is where speculation is checked — but by then the message is already built. Every failed `expect()` inside a speculative pass (the `for (i = 0; …)` type speculation, generic-arg failures, cast/decl lookaheads from #2/#4/#6) does a malloc + 3 buffer pushes + free for a message that is immediately discarded.

**Fix:** one line at the top of `reportExpected`:
```coral
void reportExpected(TokenKind kind) {
    if (self.isSpeculating()) return;   // nothing below can be observed
    ...
```
(same idea can guard `expectedTokenText`, though that one is just returns of literals).

**How others do it:** clang's `TentativeParsingAction` suppresses diagnostics at the *entry* of the tentative path, and rustc's `unexpected()`/lookahead paths return `Expected` tokens without formatting until commit. **Expected impact: small per hit, but hits are frequent wherever #2/#4/#6 speculation fails.**

---

### #6 — Paren-expression cast lookahead re-parses `(ident < …)` / `(ident::…)` / `(x)` shapes

**Location:** `expr.crl:608-649`.

**What it does / why slow:** after `(`, if the next token is an `Ident` and the token *after it* is one of `*` `)` `<` `::` (lines 620-632), `castable = true` and the parser runs a full `parseType()` (line 636) — which for `<` runs the generic machinery from #4, for `::` runs path parsing — then rewinds (line 648) and re-parses the whole parenthesized expression, re-lexing everything in between. The common victim is a parenthesized comparison: `(a < b) && (c > d)` does two failed `parseType` runs (each with an inner generic-arg speculation + TyList malloc/free) plus double-lex.

**Fix:** add a 3-token shape gate before committing to `parseType`, GCC-style: a cast's `)` must be followed by a token that can start a unary expression (not `;` `,` `)` `}` `&&` `||` `==` …), and for the `<` case reuse #4's balanced-`>` prescan. Concretely:
```coral
// before the parseType at expr.crl:635:
if (!self.unaryMayFollowAfterCastClose()) { /* skip speculation: it's (expr) */ }
```
Combined with token buffering (#2c), the residual cost of a wrong guess drops to index arithmetic.

**How others do it:** clang's `isCXXTypeId` / `ParseCastExpression` first tries cheap token checks (`isTypeSpecifier`, known-type-name bit on `IdentifierInfo`) and only then falls back to `TentativeParsingAction`; GCC's C parser never parses at all here — it peeks 2 tokens (`c_token_starts_typename` + `c_parser_peek_2nd_token`). **Expected impact: medium; scales with parenthesized-comparison density.**

---

### #7 — One heap allocation (×log) per argument list / tuple / block / literal — no arena, no inline capacity

**Location:** `context.crl:561-596` (`nodeListInit/Append/Finish`, likewise `strList*`, `switchList*`, `tyList*`), `grow()` at `context.crl:251-279` (starts `nextCap = 4`); call sites all over the hot paths: `expr.crl:345-351` (call args), `expr.crl:654-669` (paren tuples), `expr.crl:678-709` (block expr), `expr.crl:843-895` (struct literals), `stmt.crl:434-452` (blocks), `stmt.crl:560-653` (asm lists), `pattern.crl` (alternatives/tuples/fields).

**Why slow:** every `parseCallArgs` starts at `cap=0`, so a 1-arg call does `realloc(null, 4*8)` → a live heap block, then `nodeListFinish` → `ctx.track()` appends it to the `owned` vector until `deinit`. A big function body generates dozens-to-hundreds of small heap blocks + equal `owned[]` churn. This is allocator traffic and cache fragmentation on *the* hottest structural path, and the `owned` bookkeeping is pure overhead given every list has identical compile-long lifetime.

**Fix (either):**
- **Bump arena for AST lists** — the codebase already has one: `coral-build/arena.crl` (`Arena::alloc` with block chaining). Point `nodeListAppend`'s growth at a parser-scoped bump arena (or make `grow` call an arena alloc when `oldCap==0`), and drop `track()` for these. Lifetimes already match: `owned` is only freed at `deinit` anyway.
- **Inline capacity (SmallVec style):** put `NodeId inlineData[4]` inside `NodeListBuilder`; spill to heap only past 4 elements, and have `Finish` copy the inline buffer into one arena block. Covers the overwhelming majority (call args ≤ 4) with **zero** mallocs.

**How others do it:** clang parses into `SmallVector<Expr*, 4>` / `StmtVector` (Parser.h) with a `BumpPtrAllocator` backing everything; rustc uses `SmallVec`/`ThinVec` + the arena-allocated `ast::Node`. Nobody mallocs once per list. **Expected impact: medium (constant-factor); large win on allocation-profiled builds.**

---

### #8 — Node/type arena growth: byte-by-byte copy loop, no pre-sizing, and speculation leaks nodes

**Location:** `context.crl:398-447` (`growStable`), copy loop at **424-437**:
```coral
u8* src = (u8*)data; u8* dst = (u8*)result;
usize k = 0;
while (k < oldBytes) { dst[k] = src[k]; k++; }   // byte-at-a-time, whole arena
```
plus `parser.crl:117-122` (save/restore deliberately does **not** rewind `nodesLen`), and initial caps `ctx.init(4096, 4096, 4096)` (`semantics/analyze.crl:1423, 1718`).

**Why slow:** every doubling of the `nodes`/`types` arrays copies the old payload byte-by-byte through what is, in a `opt = "debug"` self-host build, an unoptimized scalar loop — and #3's junk type entries plus #2's unreclaimed speculative nodes make the arrays bigger than they need to be, causing *more* doublings. (Keeping the old block alive for stale-pointer safety is a fine invariant; the copy itself is the cost.)

**Fix:**
- `memcpy(dst, src, oldBytes)` (or a `usize`-strided loop) — trivially available (`codegen.crl:74` already uses `memcpy`).
- **Pre-size from source length** instead of growing: node count is bounded by ~`srcLen/4`; `AstContext.init(internCap, typeCap, nodeCap)` with `nodeCap = srcLen/2` (×1.3 headroom for speculative garbage) removes *all* doublings for a single-file parse — one alloc, one memset.
- Optionally rewind `nodesLen` on `restore()` for nodes allocated above the mark when no committed parse can reference them (needs an audit of which paths store nodes speculatively; the comment at `parser.crl:120` says it's intentional today — at minimum, reclaim nodes in the pure-lookahead paths like `fnTypeAhead`/`declShapeAhead`).

**How others do it:** clang's `BumpPtrAllocator` grows in large slabs (no full-array copies at all) and the AST is append-only during parsing; rustc's arena is a linked slab allocator. Pre-sizing is the cheap local fix here. **Expected impact: low-medium now, grows with file size (it's O(total AST bytes) over doublings).**

---

### #9 — Dead code and table-shaped dispatch on the operator/statement hot path

**Locations & fixes** (each small; they matter because everything is compiled `opt="debug"` with no inlining):

1. **`expr.crl:237` — `isAssignOp(op.kind)` + the `p-1` branch inside `parseBinaryExpr` is dead.** Assignment ops have `prec == 1` and the loop guard `p < minPrec` breaks them before the body runs (`minPrec ≥ 2` everywhere: entry at `parseExpr:203` passes 2, recursion only does `p+1`, and `p-1` is reachable only via `rightAssoc`, which needs `p==1`). So each binary operator pays a 12-way `||` chain (expr.crl:77-91) for nothing. Delete the `rightAssoc` branch (or assert) — assignment is handled solely in `parseExpr:211-218`.
2. **`prec()` (expr.crl:38-74) — switch → static table.** `TokenKind` is a dense enum up to `Unknown` (~145 values, token.crl:12-159), so:
   ```coral
   // file-scope
   const i32 PREC_TABLE[160] = ...;  // built from the current switch
   i32 prec(TokenKind kind) { return PREC_TABLE[(u32)kind]; }
   ```
   And `isAssignOp(kind)` ≡ `prec(kind) == 1` — one load replaces the 12 comparisons, which also simplifies `parseExpr:211` and `checkCondAssign`.
3. **`parseUnaryExpr` (expr.crl:291-330) — 8 sequential `if (current.kind == X)` → one `switch`.** Same for **`parseStmtBody` (stmt.crl:73-110)**: it's an if-chain where the two *most common* outcomes (`Var`/`Const`/`Static`/plain-expr → `parseExprOrDecl`) are reached only after 12 failed comparisons; a `switch` compiles to a jump table.
4. **`makeBinOp` (expr.crl:250-288)** is already a token-kind switch — correct; no change.

**How others do it:** clang has `getBinOpPrecedence(tok::TokenKind, …)` as a pure switch called once per loop iteration (`ParseExpr.cpp:315`), and `Tok.isOneOf(...)` groups for unary/statement dispatch; rustc maps `AssocOp::from_token` once and carries `Precedence` in a loop variable rather than re-querying per level. **Expected impact: a few percent — but these are free wins.**

---

### #10 — `pattern.crl`: per-pattern heap buffer + 25-way `||` kind chains

**Locations & why:**
- `pattern.crl:53` and `pattern.crl:107`: `u8* buf = alloc<u8>(256)` + `dealloc` per type-prefix pattern (`const T*`, `T*`, `T<…>` shapes). Two heap ops per such pattern for text that fits on the stack.
- `pattern.crl:60-72` and `pattern.crl:115-125`: ~25-term `kk == A || kk == B || …` evaluated *per token* while scanning those prefixes.

**Fix:**
```coral
u8 buf[256];                       // or a parser-scoped scratch field; no alloc
// and for the kind set — TokenKind is dense, so index a table:
bool takesTypePrefixTok(TokenKind k) { return TYPE_PREFIX_SET[(u32)k]; }
// static u8 TYPE_PREFIX_SET[160] built once (ident, void..rawptr, * & ( ) [ ] < > :: ,)
```
Same treatment for `isDeclarationStart` (pattern.crl:247-264) — it's already a `switch`, fine.

**How others do it:** this is exactly clang's `TokenKind` → `static const` tables / `StringSwitch`, and GCC's `c_token_starts_typename` switch over token types. **Expected impact: low (patterns are a minority path), but it's a 10-minute fix.**

---

### #11 — Minor / worth noting

| Location | Issue | Fix |
|---|---|---|
| `stmt.crl:58-61` | Per attributed statement, 4 linear `intern("condassign"/"fallthrough"/…)` calls (O(table) each, per #1). | Compare against pre-interned `Parser` fields created once in `init`, or hash-intern (#1) makes it moot. |
| `expr.crl:378-389` | `::` path builds a fresh 2-element `NodeListBuilder` (malloc + track) per segment, nesting `Path(Path(a,b),c)` — O(k) allocs, recursive `pathHeadType`. | Accumulate segments in one builder across the `::` run, emit one `Path` node. |
| `type.crl:215-276` + `file.crl:25` | `prescanConstInts` re-lexes the **entire file** once before parsing (a full extra lex pass; `save/restore` doesn't re-lex the scan itself, but the scan's own lexing is 100% overhead when the file has no const-int array sizes). *Outside the 3 scope files, but it taxes every parse.* | Cheap raw-byte prefilter (`memchr` for `const` and `[`) or fold the const scan into the main parse with a small post-pass. |
| `stmt.crl:436-447`, `expr.crl:681-704` | Per-statement progress guard copies a whole `Token` (~64B) + `getCur()` — fine, but repeated in 4 near-identical loops (`parseBlock`, `parseSwitchStmt`, `parseComptimeStmt`, file loop). | Not a perf problem; just factor it into one `advanceGuarded()` helper. |
| `expr.crl:417-470`, `stmt.crl:460-524` | Flag lookup is a linear scan over `ctx->flagsLen` per arm — tiny (flags are few), but each arm also interns its key. | Fine after #1; no action. |
| `coral.crlb` | **The compiler is built with `opt = "debug"`.** Every constant-factor above (byte-copy loops, `streq`, switch chains, method calls) is paid at -O0 in the emitted C. | Build `coralc` itself with `opt = "release"` — likely the single biggest *zero-code-change* win for the whole pipeline. |

---

### What is already good (don't "fix" these)

- `parseBinaryExpr`'s precedence-climbing loop: single pass, no backtracking — matches clang's `ParseRHSOfBinaryExpression` exactly.
- `storeExpr`/`storeStmt` go through a contiguous index-addressed node arena (`allocNodeSlot`, context.crl:820-834) — **no per-node malloc**.
- `save()`/`restore()` are O(1) struct copies of the mark (parser.crl:123-152); the *only* expensive part is the re-lex they force (#2) and the discarded allocations inside the speculative region (#3/#4/#5).
- `expect()`'s recovery-boundary logic (parser.crl:51-68) avoids the classic "swallow the closer" desync; error-free compiles never touch it.
- `nodeList*` growth is geometric (amortized O(1)); the issue is *which* allocator, not the doubling (#7).

---

### Suggested order of attack

1. **#1 intern → hash + `IdentifierInfo.strId` cache** — quadratic → linear; biggest single win, self-contained in `context.crl` + a one-field addition.
2. **#2 statement speculation** — shape-gate (`declShapeAhead`) + commit-on-success; then **token buffering** so `restore()` never re-lexes (this also makes #4/#6 cheap to keep).
3. **#3 lazy `makeNamedArgs`** — 3-line change, removes per-identifier type garbage (also shrinks #8).
4. **#5 one-line `isSpeculating()` early return** — free.
5. **#4/#6 lookahead gates**, **#7 arena/SmallVec lists**, **#8 memcpy+presize**, **#9 dispatch tables**, **#10 pattern scratch**, then the build-config change (`opt = "release"`).

Before/after measurement suggestion: add counters (intern probe count, `save()` calls, `restore()` calls, bytes re-lexed = `getCur()` rewinds, `allocTypeSlot` calls, mallocs from `grow`) printed under a `--stats` flag — every bottleneck above has a direct counter, so the ranking can be confirmed empirically on the self-host build in an afternoon.

---

# PART 3 — Parser: type / recovery / driver
*(Agent ses_ea276c6a6ffe4IH7Rds3vyzfxX — scope: type.crl, recovery.crl, parser.crl, file.crl — MEASURED via callgrind)*

Analysis complete — original tree untouched (all instrumentation was in a `/tmp` copy; the `git status` changes are pre-existing local edits to other files). Here is the report.

## Coral parser performance review — findings

**Method.** Static analysis of the four target files + their driver/lexer/context dependencies, then *measured* on a self-host build (15 modules, 777 `parseFile` calls) of a `/tmp` copy: Callgrind full-build profile (33.0 G instructions total) plus token/rewind counters added to the copy's lexer/parser. Every percentage below is measured, not guessed.

**Big picture.** The parse phase (`parseFile` inclusive) is **19.6 G Ir = 59.4%** of the entire build. Inside it:

| Component | Ir | Share of build |
|---|---|---|
| `AstContext_intern` + `streq` (from all phases) | 20.95 G | **63.5%** |
| — of which driven by parser call sites | ~16.4 G | ~50% |
| Lexing (`Lexer_nextToken`, 854,326 calls) | 2.17 G | 6.6% |
| — of which the const-prescan re-lex | ~1.10 G | 3.3% |
| `parseType` (29,526 calls, 93% of it interning) | 2.95 G | 8.9% |
| Error recovery (`synchronize*`) | **0** | 0% (clean build) |

The parser driver itself (`parser.crl` advance/match/expect) is thin and clean: 853,550 `advance` calls map ~1:1 to `nextToken` calls — no redundant token fetching. The slowness is (1) a quadratic interning service the parser hammers per-token, (2) full-type speculative re-parsing for statement/decl disambiguation, and (3) a whole extra lex pass per file.

---

### Rank 1 — `AstContext.intern` is a linear scan; 63.5% of ALL compile time

**Location.** `coral-context/context.crl:452-505` (the scan at :456-465, with the comment at :450-451 literally saying *"O(n) per call, fine until a profile says otherwise"*). Primary callers in scope: `type.crl:476,478,504,511` (every type name / `"any"` / `"self"`), `pattern.crl:43,87,99,135,143,154,174,183-187` (every pattern name, field name, and the scratch-buffer text), plus every ident in `expr.crl`/`decl.crl` (`parsePrimaryExpr`: 50,516 calls; `parseBaseType`: 18,247; `parsePostfixExpr`: 35,658; …).

**What it does / why it's slow.** Every `intern()` walks the whole `InternEntry` array with `streq` until a match. Measured: **235,594 calls, avg ~89,000 instructions per call** (11.6 G self in `intern` + 9.3 G in `streq`). Cost grows with the number of distinct strings in the program, so compile time is **O(tokens × distinct-idents)** — quadratic in project size. It also makes speculation worse: restored parses re-intern the same strings (the intern table is *not* rewound by `restore()`), paying full scan costs twice per guessed span.

**Fix (Coral sketch).** Mirror the hash table the *lexer* already has (`coral-lexer/table.crl` uses FNV-1a open addressing — reuse its `hash()`):

```crl
// context.crl: keep the linear array as the id→str backing store,
// add a bucket table: index into interns, 0 = empty
u32* internBuckets;   // power-of-two capacity, load factor 0.7
u32 internBucketCap;

u32 intern(str s)
{
    if (s.len == 0 || s.ptr == null) return 0;
    u32 mask = self.internBucketCap - 1;
    u32 h = fnv1a(s) & mask;
    while (true) {
        u32 slot = self.internBuckets[h];
        if (slot == 0) break;
        InternEntry* e = self.interns + slot;
        if (e->len == s.len && bytesEq(e->ptr, s.ptr, s.len)) return e->id;
        h = (h + 1) & mask;                 // linear probe
    }
    ... existing copy/append path → id = self.internsLen;
    self.internBuckets[h] = id;
    if (++self.internsLen * 10 >= self.internBucketCap * 7) rehash();
    return id;
}
```

**Rationale / how clang does it.** Clang's `IdentifierTable` docs call it *"an extremely performance-critical piece of the code, as each occurrence of every identifier goes through here when lexed"* — it is a `StringMap` (FNV/xxHash-keyed, open addressing), never a linear scan. rustc's `Interner` is likewise a hash map (`FxHashMap`) with ids as indices. This single fix should take the build from **33.0 G → ~13 G Ir (~2.3-2.5× faster)** and the parse phase from 19.6 G → ~3.5 G. It is the one change to make first; everything else's relative size shrinks after it.

---

### Rank 2 — Statement/decl disambiguation does a *full speculative `parseType` + restore + re-parse*

**Locations.**
- `stmt.crl:715-730` (`parseExprOrDecl` general arm — the hot one)
- `stmt.crl:676-688` (var/const/static arm), `stmt.crl:284-299` (for-loop binders)
- `decl.crl:854-859` and `decl.crl:1077-1082` (struct members / union arms: `save; parseType; expect(Ident); isMethod = (…); restore` — every field's type is **always parsed twice**, even when it is a field)
- `decl.crl:413-422` (`const` decl: full `parseType` inside a guess), `decl.crl:1309-1319` (`parseVarDecl`), `decl.crl:742-745` (`const self` peek), `expr.crl:622-650` (cast guess)

**What it does / why it's slow.** `parseExprOrDecl` is the statement dispatcher (16,108 calls, **10.4 G Ir inclusive = 31.5% of the build**). For *every* statement starting with a type-start token — `isTypeStart()` includes `Ident` (`decl.crl:447-474`), i.e. essentially every expression statement `foo(x);`, `a = b;` — it does `save(); parseType(); … restore(mark);` and then parses for real. Measured consequences:

- **19,465 of all 29,526 `parseType` calls (66%) come from `parseExprOrDecl` alone** (2.31 G Ir). The guess often walks deep: `foo(a, b);` parses `foo(a, b)` as an *fn-pointer type over two param types* before the `current == Ident` test fails and it rewinds.
- Successful guesses (`i32 x = …`) are then **thrown away and re-parsed** — `restore(mark)` at :729 discards the already-parsed type+name even when `isDecl` is true, then :731-732 re-runs `parseType` + `expectName`.
- Every rewind also discards diagnostics (specDepth), so the re-parse is the only one that reports — that's *why* the code re-parses, but it doubles type-parsing and interning work for all typed locals, fields, consts, and for-loop binders.
- Discarded guesses also leak node slots (`restore()` only rewinds `ctx.typesLen` — `parser.crl:120-122`) and permanently grow the intern table with re-scanned strings.

**Fix — two parts.**

(a) *Commit instead of re-parse when the guess succeeds.* The var/const arm already does this correctly (`stmt.crl:680-686`: `endSpeculation()` and keep `candidate`). Do the same in the general arm — but you must stop dropping diagnostics from the committed window. Buffer them per speculation depth:

```crl
// base.crl
DiagBuf* specDiags; u32 specDiagsLen;   // ring of (code, token, msg-id)

// recovery.crl reportError
if (self.isSpeculating()) { self.bufferDiag(code, token, msg); return; }

// parser.crl — commit: replay buffered diags, keep parse results
void commitSpeculation(ParserMark m)
{
    self.endSpeculation();
    self.replayDiagsSince(m.diagLen);   // errors from the committed span now emit
}
// stmt.crl:715 arm becomes:
ParserMark mark = self.save();
Ty typeNode = self.parseType();
bool isDecl = false;
if (self.current.kind == TokenKind::Ident) {
    Token name = self.expectName();
    isDecl = self.current.kind == TokenKind::Equal || TokenKind::Semicolon || TokenKind::LBracket;
}
if (isDecl) self.commitSpeculation(mark); else self.restore(mark);
if (isDecl) { /* continue from current position; NO second parseType/expectName */ }
```

Applied to the struct-member loops (:854, :1077), this also halves field-type parsing in every struct — those sites can commit on `!isMethod` and only re-parse (rare) methods.

(b) *For the failure path, decide with a bounded token peek, not a full parse.* The guess only needs to verify the shape `type-ish… Ident [= ; [ ]`. With a token buffer (Rank 4), scan forward at most N tokens to the disambiguator and rewind the index — no type entries, no interning, no AST.

**How clang does it.** `Parser::isCXXDeclarationStatement` → `isCXXSimpleDeclaration` (`ParseTentative.cpp`) is exactly this statement ambiguity. Clang first answers with *pure token lookahead* (`isCXXDeclarationSpecifier` returning `TPResult::True/False/Ambiguous`), and only in the genuinely ambiguous case runs `TryParseSimpleDeclaration` inside a `RevertingTentativeParsingAction` — a bounded tentative parse that (i) never re-lexes (tokens are cached, see Rank 4), (ii) never builds real AST or runs Sema, and (iii) records results in *annotation tokens* so a backtracked reparse "does not need to redo semantic analysis". Coral's commit-on-success + buffered-diagnostics is the lightweight equivalent of annotation tokens.

**Expected impact.** Removes ~2/3 of `parseType` volume (2.95 G → ~1.0 G before interning savings; the eliminated duplicates are mostly intern calls, so it compounds with Rank 1), plus ~9% of parse-phase lexing (the 41.5 k re-lexed tokens measured in Rank 4 come overwhelmingly from these restores) and a large amount of type-table/node arena churn.

---

### Rank 3 — `prescanConstInts` re-lexes the entire file before parsing

**Location.** `type.crl:215-276`, called unconditionally from `file.crl:25` at the top of every `parseFile`.

**What it does / why it's slow.** A full dry-run token pass over every file (with diag muted) to collect `const T NAME = <int literal>;` for forward-referenced array sizes. Measured: **406,243 of 854,022 `nextToken` calls (47.6% of all lexing in the build)** and ~1.1 G Ir (3.3% of the build). It duplicates every cost of lexing: whitespace/comment skipping, identifier/number/operator classification, `Token` construction — plus `intern()` calls for head identifiers (another ~tens of thousands of Rank-1 scans).

**Fix.** Single-pass with deferred resolution — the parser already has the machinery for this pattern: `makeArrayParam` (`type.crl:414-423`) defers name-sized array dims to sema. Do the same for const ints:

```crl
// file.crl parseFile: drop prescanConstInts().
// decl.crl parseConstDecl: after parsing `const T N = <int lit>;`, call
self.addConstInt(name, intValue);          // table now built in the ONE real pass
// type.crl parseDeclaratorArray: when the size ident is not yet in the
// table, emit makeArrayParam(base, name, loc) and record a fixup
// (declFile, declLine, arrayTyId, name); after the decl loop, resolve
// fixups against the now-complete table (and report unknowns).
```

If true forward references must resolve mid-parse and fixups are undesirable, the cheaper fallback is to make the prescan a *byte scanner*: reuse `skipWsCmts` + a minimal classifier that never constructs `Token`s, never interns, and never runs the number-suffix machinery — that removes most of the 1.1 G while keeping the current architecture. Clang and rustc both parse strictly single-pass; nothing re-lexes a whole file for forward facts.

---

### Rank 4 — No token cache: `save()/restore()` rewind the *source cursor*, re-lexing speculative spans

**Locations.** `parser.crl:123-152` (`save`/`restore` poke `lexer.cur/line/lineStart` — the accessors exist solely for this, `coral-lexer/base.crl:51-59`); all 20 call sites listed above depend on it.

**What it does / why it's slow.** There is exactly one buffered token (`Parser.current`); `restore()` rewinds the raw byte cursor, so *every* token consumed between `save()` and `restore()` is lexed again on the next `advance()`. Measured on the clean self-build: **28,786 saves, 22,778 restores, 2.32 MB of source rewound** ≈ 41.5 k re-lexed tokens ≈ **9% of parse-phase lexing** (~0.1-0.2 G). Modest on clean builds because most spans are short (avg ~102 B ≈ 15-25 tokens) — but this is the structural enabler for Rank 2's proper fix (bounded peek + tentative parse), and it scales badly with error-prone/LSP-reparse workloads where spans get long.

**Fix.** Give the parser a small token ring buffer and make `save()/restore()` buffer-index moves:

```crl
// base.crl
Token* tokBuf; u32 tokLen, tokCap, tokPos;   // window around `current`
// parser.crl
Token peek(u32 n) { fillTo(tokPos + n); return tokBuf[tokPos + n]; }
ParserMark save()  { ... .bufPos = self.tokPos, ... }   // no lexer state copies
void restore(ParserMark m) { self.tokPos = m.bufPos; self.current = tokBuf[m.bufPos]; ... }
```

**How clang does it.** Clang's preprocessor has precisely this: `Preprocessor::EnableBacktrackAtThisPos()` / `Backtrack()` / `CommitBacktrackedTokens()` (PPCaching.cpp) — *"the Preprocessor keeps track of the lexed tokens so that a subsequent Backtrack() call"* replays them from `CachedTokens` via `CachingLex()` instead of re-lexing, with **nested** backtracks supported (coral's `specDepth` already models nesting; only the token storage is missing). rustc pre-tokenizes the whole file into a `Vec` and backtracks by restoring an index — zero re-lex, also giving free `LookAhead(n)` for Rank 2(a)/(b).

---

### Rank 5 — Pattern parsing: per-pattern heap scratch + duplicated 30-branch token-kind tests

**Location.** `pattern.crl:48-90` (`const T*` prefix), `:104-138` (`T*` / `T<…>` prefix), membership tests at :60-72, :91-96, :115-125; measured `parseSwitchPattern` inclusive **391 M Ir (1.2%)**, ~320 kIr per call.

**What it does / why it's slow.** Each type-prefix pattern does `alloc<u8>(256)` / `dealloc` (heap churn, mimalloc page traffic — `mimalloc___miPageFind` shows at 37 M in the profile), then interns a *unique* scratch string into the ever-growing linear intern table (rank-1 cost, never rewound), and tests each token against a 20-30-deep `if (kk == … || kk == …)` chain copied in three near-identical variants (i-cache bloat + branch mispredicts).

**Fix.** Parser-owned scratch buffer (one `u8 patBuf[256]` field reused across patterns — no malloc), a `bool typePatTok[TokenKind::Count]` lookup table built once in `init`, and one shared `collectTypePrefixText()` helper replacing the three copies. Also consider structuring prefix patterns as real `parseType()` results instead of re-spelling source text (the current design forces sema to re-parse text — outside this review's scope, but it's the reason the scratch exists). Clang keeps no per-node heap scratch anywhere in the parser; token spans (`SourceRange`) + stack `SmallVector` are the norm.

---

### Rank 6 — `reportExpected` builds a heap `String` before any cheap guard

**Location.** `recovery.crl:109-134`. `String::from` + up to 3 `push*` (heap) run *before* `reportError` can decide to drop the diagnostic.

**What it does / why it's slow.** Costless on the clean self-build (365 calls, 1.3 M Ir) — but in two common situations it does dead work: (1) during speculation, `reportError` (:44) discards the message *after* it was built; (2) beyond the error limit (`errorLimit = 20`, `engine.crl:118-120`), `emitError` stops *rendering* but `reportExpected` still allocates for every subsequent failed `expect` — an error storm pays one heap build + hash-free string churn per failed expect for the whole file.

**Fix.**

```crl
void reportExpected(TokenKind kind)
{
    if (self.isSpeculating()) return;                 // dropped anyway
    if (self.lexer != null && self.lexer.diag != null &&
        self.lexer.diag.tooManyErrors()) { self.addError(); return; }
    u8 buf[96];                                        // no heap at all
    ... snprintf into buf, then reportError(...)
}
```

**How clang does it.** `Parser::ExpectAndConsume` / diagnostics are lazy: `Diag(...)` builds the diagnostic object only when the engine will actually emit it (checked via `getDiagnosticLimit`/client state first), and messages format into preallocated `Diagnostic` storage, not per-error heap strings.

---

### Rank 7 — Error recovery: *correct and cheap* — the one thing to tune is the stop set

**Location.** `recovery.crl:151-244` (`synchronize`, `synchronizeStatement/Expression/Case`), stop-set `isDeclarationStart` at `pattern.crl:247-264`, progress guards at `file.crl:84-93`, `stmt.crl:438-447`.

**Assessment (measured + by inspection).** **No O(n²), no spin, no re-scan of large spans.** All skip loops advance monotonically, are depth-tracked (parens/brackets/braces), stop before closers so enclosing constructs stay in sync, and every enclosing loop has a cursor-progress guard that force-advances one token — so worst case is linear with ≤1 diagnostic per token. On the clean build: **0 `synchronize` calls, 0 cost**. This is essentially the same design as clang's `Parser::SkipUntil` (nesting-aware skip with `StopAtSemi`, spurious closers consumed only when no enclosing construct claims them) — validated.

Two small notes:
- `isDeclarationStart()` accepts a bare fresh-line `Ident` and `LParen`, so under error storms recovery resyncs at nearly any line, producing cascading diagnostics rather than skipping to the next real decl. Tightening the set (decl keywords + `pub`/`extern`, not bare `Ident`) improves diagnostic locality — a quality win, not a speed one.
- `expect()` failure at file scope after every errored decl triggers `synchronize()` even when the decl already consumed through `;` (`file.crl:93`) — harmless (the skip exits immediately at the closer), just redundant.

---

### Explicitly checked and *not* significant (so you don't chase them)

- **`internKind` linear scan** (`type.crl:459-468`): early-exits at the *first* entry with the tag, and primitives get committed entries early → measured only 39.7 M Ir (0.12%), 3.4 kIr/call. Fine as-is (a 24-slot `Ty primByTag[]` cache is a 5-line optional cleanup).
- **`fnTypeAhead`** (`type.crl:28-36`): 51,575 calls but returns immediately when `current != LParen` — 11.6 M Ir total. Not a problem.
- **`parseGenericArguments`** (`type.crl:324-374`): 62,047 calls, 218 M Ir (0.66%) — cheap on the common path; its failed-attempt re-lex is already counted in Rank 4.
- **Driver plumbing** (`parser.crl`): `advance`/`match`/`expect` are 1:1 with lexing, `ParserMark` copies are ~100 B, `file.crl` progress checks call `getCur()` twice per decl — all noise. Token-by-value passing (`Slice_from` 57 M, `makeToken` 40 M) is negligible.
- **`scanDocsAbove`** (`decl.crl:39-84`): bounded to 64 lines, stops at first non-doc line — 285 M (0.9%); `addDocBlock`'s linear doc search (context.crl, 55 M) is a minor follow-up.

---

### Recommended order

1. **Hash the intern table** (Rank 1) — ~2.3-2.5× whole-build speedup, ~5.5× on the parse phase, ~30 lines in `context.crl`.
2. **Commit-on-success + buffered speculation diagnostics in `parseExprOrDecl`/struct-member/const/var paths** (Rank 2a) — eliminates the double `parseType`+intern of every typed local and field.
3. **Drop `prescanConstInts` for single-pass + deferred array-size fixups** (Rank 3) — removes 47.6% of lexing.
4. **Token ring buffer** (Rank 4) — makes all 20+ `save()/restore()` sites O(1) and unlocks clang-style bounded token-peek disambiguation (Rank 2b).
5. Pattern scratch/type-token-table (Rank 5) and `reportExpected` guards (Rank 6) as quick cleanups; recovery stop-set tightening (Rank 7) for diagnostic quality.

---

# PART 4 — Semantics: expr.crl
*(Agent ses_ea2769a09ffe4o9pwvs4jEAppF — scope: expr.crl semantics + typecheck/scope/member/stmt/context deps — MEASURED via callgrind)*

All facts verified. Writing the findings report now — that's the deliverable.

## Coral Semantic-Analysis Performance Review — Findings Report

**Scope:** `expr.crl` semantic analysis and its direct dependencies (`typecheck.crl`, `scope.crl`, `member.crl`, `stmt.crl`, `context.crl`).
**Method:** static review + callgrind profile of a clean self-host build (`coralc` compiling itself, `opt=debug`, no `-s`). Total: **33.0 B Ir**. Repo untouched; profiling ran on a copy under `/tmp/opencode`.

### 1. `AstContext_intern` — linear O(N) table scan — **63.5% of the entire build**

**Where:** `coral-context/context.crl:452–496` (scan loop `458–467`; byte-compare via `streq` at `210`, called at `462`).

**What it does / why it's slow:** Every `intern()` walks the *entire* interned-string table comparing bytes. Profile: **20.95 B Ir inclusive (63.5%)**, 235,594 calls, **~89k Ir/call** — inner self-cost splits into `intern` 11.6 B + `streq` 9.3 B ≈ **~40k string compares per call** (the table holds ~40–80k strings by end of build). This is O(N) per lookup, O(N²) per build. Everything below is partially a victim of this number.

**Fix:** add an open-addressing hash index over interned ids:

```
u32* internHash;   // power-of-two slot count, 0 = empty, else id+1
u32 internHashLen;

u32 intern(str s) {
    u64 h = fnv1a(s);                    // already have a hash in the lexer
    u32 mask = self.internHashLen - 1;
    for (u32 slot = h & mask; ; slot = (slot + 1) & mask) {
        u32 v = self.internHash[slot];
        if (v == 0) break;               // miss → allocate below
        InternEntry* e = self.interns + (v - 1);
        if (e.hash == h && e.len == s.len && memcmp(e.ptr, s.ptr, s.len) == 0)
            return e.id;                 // hash pre-checked → one compare, not 40k
        // rehash-on-grow: reindex by re-hashing existing entries
    }
    // ... existing alloc/copy path, then store e.hash and internHash[slot] = id+1
}
```

Store the `u64` hash in `InternEntry` so the probe does a hash compare before touching bytes; grow the slot array at 0.75 load, reindexing from stored hashes (no string rescans). Optionally reuse the lexer's `IdentifierTable_hash` so hash+intern share one pass.

**How others do it:** clang's `IdentifierTable` is a `StringMap` (hash-bucketed); rustc interns every symbol/name in `CtxtInterners` with `FxHashMap`; LLVM's `StringMap` is exactly the open-addressing + precomputed-hash design above.

**Expected gain:** 20.95 B → ~0.4 B Ir. Whole build ~33 B → **~12–13 B Ir (≈2.5–3× wall)** from this fix alone. Everything else in this report gets cheaper too (fewer stalls under the scanner).

---

### 2. No type uniquing — linear scans + deep structural `sameType` — **~3–5% direct, systemic feedback**

**Where:**
- `typecheck.crl:23` `allocType` — always appends a fresh slot, never dedups.
- `typecheck.crl:39–242` primitive singletons (`boolType`, `i32Type`, …) — each scans `types[]` linearly; the comment admits it.
- `typecheck.crl:266+` `namedType` — scans the whole type table *and* re-interns the name every call. Profile: **1.05 B Ir (3.13%), 2,619 calls from `checkPath` — ~400k Ir/call** (table has ~40k entries).
- `typecheck.crl:309+` `sameType` — has an `a == b` fast path, but it almost never hits because types aren't unique, so it falls into the recursive structural compare; called twice per binary/assign (`expr.crl:808–809`, `828–829`, `886`, `538–544`).
- Fresh types minted per expression: `AddressOf` (`expr.crl:1730–1734`), `ptrArithType` (`expr.crl:1086–1091`), TupleExpr (`expr.crl:2304–2320`), `substituteFieldTy` (`typecheck.crl:879–901`), `checkFunction`'s self `*const` (`stmt.crl:724`).

**Why it's slow:** unbounded `typesLen` growth makes every singleton lookup, `namedType`, and `dependentType` scan slower — an O(n²) feedback loop that also feeds finding #1 (bigger table = more intern pressure is separate, but bigger type table = slower linear scans). `sameType` then does deep compares because pointer equality can't be trusted.

**Fix (canonical types, exactly the GCC/clang design):**
1. **Uniqued constructors:** maintain a small hash on `(TypeKind, childTyIds…)` → existing `Ty`. `pointerType(base)`, `constType(t)`, `tupleType(ids)`, `namedType(name)` all check the map before `allocType`. One-time cache fields for the hot singletons (`boolTy`, `i32Ty`, `usizeTy`, `strPtrTy`, …) so `boolType()` is a field read.
2. **Fix the broken dedup scans:** `strPtrType` (`typecheck.crl:125`) and `ccharPtrType` (`:144`) scan comparing `Pointer.base == u8Type()` but store `Pointer(Const(u8))` — the scan **never matches**, so they allocate 2 fresh entries per call forever. Fix the comparison (or, better, replace with the uniquing map and delete the scans).
3. **`sameType` becomes `a == b`**: with uniquing, canonical-pointer equality is sound, structural recursion survives only for non-uniqued edges (decl-identity aliases). Thread `u32` type-ids as the hash key.

**How others do it:** GCC documents `TYPE_CANONICAL` precisely for this — `same_type_p` compares canonical pointers first and only falls back to structural comparison when `TYPE_STRUCTURAL_EQUALITY_P`; clang's `ASTContext::getPointerType()` etc. uniquing in the `BumpPtrAllocator`; rustc interns `TyKind` so `Ty` equality *is* pointer equality.

**Expected gain:** removes ~1.05 B `namedType` + singleton-scan costs, converts all `sameType` deep compares to O(1), and — critically — **caps `typesLen`**, which stabilizes every other linear scan. Direct ~1.5–2 B Ir; multiplicative effect on findings 3–5.

---

### 3. Scope lookup: linear scan per scope, string-compare keys — **5.75%**

**Where:** `scope.crl:224` `lookupFrom` (self **1.90 B Ir**); driven by `Sema_lookupAt` 100,258 calls + `Sema_lookupType` 55,478 calls (`member.crl` `findMember` 20,450; `isVariantNamedTy` 7,947; `resolveScalarAlias` 6,564; `checkType` 6,132).

**What it does / why it's slow:** each scope's symbol list is a linked/array walk with string equality on interned names. Every identifier, member access, and qualified path pays it — file scopes and module scopes hold hundreds of symbols, and the walk runs per scope-level hop. Additionally `lookupAll` allocates `Symbol*(16)` per qualified-name walk (`expr.crl:1338` area), and `modulePathPrefix` (`expr.crl:399–415`) does `alloc + intern("a::b::c")` **per qualified-call resolution**.

**Fix:**
- Per-scope `Str-id → Symbol*` open-addressing map, keyed by the **u32 intern id** (integer compare, no `streq`). Rebuild-free: scopes are append-mostly; grow the slot array on insert.
- For small scopes (<8 symbols) keep the linear list — hybrid, like hash-table-below-threshold designs.
- Kill the `lookupAll` heap alloc (stack buffer / fixed array) and the per-call `modulePathPrefix` intern: return `(u32 modulePathId, u32 nameId)` pair or pre-intern the concatenation once per module.
- Bonus: cache the resolved `TypeEntry*`/`Decl*` in the `Symbol` so `x.f` field access doesn't re-enter `lookupType` per access (feeds off #2's uniquing: member lookup returns canonical `Ty`).

**How others do it:** rustc's `Resolver` stores symbols in per-scope hash maps keyed by `Symbol` (interned, so `u32`-comparable); clang's `LookupResult` builds hash maps (`StoredDeclsMap`) per `DeclContext`.

**Expected gain:** ~1.5–1.9 B Ir → ~0.1 B. After #1 lands this becomes the #1 or #2 hotspot, so fix in the same pass.

---

### 4. Redundant walks in the expression checker — **~1–2% + alloc churn**

**Where:**
- **Double lookup, Ident arm:** `checkIdent` (`expr.crl:89–92`) does `lookupAt` internally, then the `Ident` arm of `checkExpr` (`expr.crl:1190–1191`) does `lookupAt` **again** on the same name — two full scope walks per identifier (100k `lookupAt` vs 42.6k idents ⇒ confirms).
- **Qualified calls (`fs::read(...)`):** ~4–6 walks per call — callee resolution (`expr.crl:1205`), then `lookupAt` at `1302`, `1323`, `1352`, then `checkCall` → `lookupAt` again (`expr.crl:257`), plus `modulePathPrefix` intern (finding #3).
- **`checkExpr` (`expr.crl:1128`) has no memo guard** — a `resolvedType != 0 → return true` short-circuit (the pattern already exists at `expr.crl:119` in one helper).

**Fix:** `checkIdent` returns `Symbol*`; the `Ident` arm uses it instead of re-looking-up. Resolve a qualified callee once and thread the result into `checkCall` (pass `Symbol*`, not the name). Add the `resolvedType` idempotence guard on `checkExpr` — cheap insurance for any node reached twice (const folding, tuple destructuring, etc.).

**Expected gain:** removes ~50–60k redundant walks (~0.5–1 B Ir pre-#3, less after; still worth it — it's pure waste).

---

### 5. Sema-side intern callers with constant strings — **~2.5 B Ir incl.**

**Where / counts:**
- `stmt.crl:89/95/101/108` — `intern("no_drop")`, `intern("drop")`, `intern("maybe_unused")` per VarDecl/Block; `checkStmt` made **15,601 intern calls (2.05 B Ir incl.)**.
- `member.crl:89–96, 137–143` — `intern("len"/"ptr"/"tag"/"payload"/"str")` in `findMember`/`findMethod`: **9,118 calls, 0.51 B**.
- `expr.crl:691/693` `isPayloadAccessNode` — `intern("payload")` per field access: **15,235 calls**.
- `modulePathPrefix` (`expr.crl:413`) — allocates + interns a fresh `"a::b"` per qualified path (see #3).

**Why it's slow:** even with a hashed `intern` (#1), each of these is a hash + probe + call overhead where it could be a field read. Today each is ~90–130k Ir.

**Fix:** intern these **once** at context/Sema init into cached fields:

```
// Sema fields, set in init after ctx is ready:
u32 idDrop, idNoDrop, idMaybeUnused, idPayload, idLen, idPtr, idTag, idStr;
```

Alternatively static `Str` constants handed to a tiny `internConst` that's memoized on first call. The attribute checks in `stmt.crl` and the member probes then become integer compares against pre-fetched ids.

**How others do it:** clang pre-creates known attribute/identifier identifiers in `IdentifierTable`'s constructor (`get()` for every keyword/known ident); rustc's `Symbols` struct holds `Symbol` constants for all lang items.

**Expected gain:** 2.5 B → ~0.05 B Ir. (Most of this cost is #1's linear scan; this makes it free even after #1.)

---

### 6. `growStable` byte-at-a-time copy — **1.14%**

**Where:** `coral-context/context.crl:424–438` — `while (k < oldBytes) dst[k] = src[k]`.

**What it does / why it's slow:** arena growth (interns/types/nodes — three separate arenas) copies byte-by-byte. **376 M Ir self.** Runs O(log n) times per arena but each copy is the full old table; the intern arena's growth is the big one (finding #1's table is what's being copied).

**Fix:** `memcpy(dst, src, oldBytes)` — the code already imports from `std.mman`; use `lib::string`/raw copy intrinsic. Same for the `alloc<u8>(s.len+1)` byte loop in `intern` (`context.crl:482–483`) — `memcpy`/`strcpy`. (This is a self-host limitation moment: if Coral's `memcpy` call overhead dominates for tiny strings, keep the loop under ~32 bytes, else call.)

**Expected gain:** ~0.3 B Ir, trivial change.

---

### 7. Out-of-scope observations (notes, not fixes in this pass)

- **Lexer `IdentifierTable_get`: 1.60 B self (4.85%)** — the lexer already hashes (`IdentifierTable_hash`) but the table walk/chaining is hot. Bigger win: the **parser then re-interns the same strings** — `parsePrimaryExpr` 50,516 intern calls (6.31 B), `parsePostfixExpr` 24,459 (2.76 B), `parseBaseType` 18,247 (2.46 B). If AST nodes stored the lexer's ident-table id directly instead of a `Str` re-passed to `ctx.intern`, ~93 B→small of parser cost and much of finding #1's call volume disappear. Worth a follow-up ticket; it's a frontend data-model change.
- **`runGcc` (`coral-frontend/compile.crl:38`) passes `-s`** — strips every produced binary, which is why profiling required a wrapper. Consider dropping `-s` for debug profiles.
- **Demoted from initial concern** (measured negligible, keep for hygiene): `markLocalUsed` (`stmt.crl:650`, 12 M Ir / 0.04%), `isConstIntExprD` (0.56 M), `assignCompatible` (1.0 M), `substituteFieldTy` (2.7 M), `ptrArithType` (0.13 M). The `strPtrType`/`ccharPtrType` broken-dedup is small in absolute Ir (0.65 M/1.3 M) but **must still be fixed as part of #2** — it's a type-table leak that degrades every linear scan.
- Backend `cgEmitSwitchChain` etc. not profiled in depth — separate pass if desired.

---

### Suggested landing order & expected cumulative effect

| Step | Change | Cumulative build Ir | ~Speedup |
|---|---|---|---|
| — | baseline | 33.0 B | 1.0× |
| 1 | hashed `intern` (finding 1) | ~12–13 B | ~2.6× |
| 2 | type uniquing + singleton cache + fix `strPtrType` (2) | ~8–9 B | ~3.7× |
| 3 | scope hash maps + kill redundant walks + pre-intern constants (3, 4, 5) | ~5–6 B | ~5.5× |
| 4 | `memcpy` in `growStable` (6) | ~5 B | ~6× |

The big three (#1 intern, #2 type uniquing, #3 scope maps) are also the clang/rustc/GCC-validated core: **intern everything, uniquing types so equality is pointer equality, hash the scopes.** All three are context/infrastructure fixes that `expr.crl` benefits from without changing its checking logic; the expr-local fixes (#4, #5) are small and safe on top.

Happy to start implementing — #1 (`context.crl` intern hash index) is the natural first patch if you want to proceed.

---

# PART 5 — Semantics: typecheck / analyze
*(Agent ses_ea276765affe0nIqPHOJJBUBtL — scope: typecheck.crl, analyze.crl — MEASURED via callgrind)*

Here's where we stand on the Coral compiler performance analysis (read-only; nothing in the repo was touched — all scratch work in `/tmp/opencode`):

**Setup & method**
- Built a symbolized `-O0 -g` copy of the compiler outside the repo (`/tmp/opencode/coralc-syms`) because `build/coralc` is stripped (`-s` in coral-frontend/compile.crl:38) and generated C hangs at `-O2/-O3` (real builds are `-O0` anyway).
- Generated scaling benchmarks (`/tmp/opencode/coralbench/` empty/b50/b100/b200/b400) and collected `perf` + callgrind profiles (`/tmp/opencode/cg.out`). perf call-graphs are unavailable (perf_event_paranoid=2); callgrind fills that gap. Parsed the callgrind file directly (it uses compressed `*`/`+N` position lines) — my numbers now match `callgrind_annotate` exactly (2.039B instructions, b100 workload).

**Measured findings (ranked, b100)**
1. `AstContext_intern` (context.crl:452) — **45.9%** self (intern 25.1% + streq 20.8%); only 33k calls but 15.5M `streq`s (avg ~468-entry linear scan per call). No hash table.
2. Type-table linear scans — **~14.4%**: primitive getters `boolType()` etc. (typecheck.crl:39–242; boolType alone 5.7% — first `Bool` entry lands at a late index because the singleton is created during Sema after ~10k parse-time entries, so every call rescans the whole table) + `Parser_internKind` (parser/type.crl:459, 6.4%, 4,147 calls × ~31k Ir each).
3. Import-path probing by full file reads (`libResolveSegs` analyze.crl:296–400 reads then frees candidate files just to test existence) — **~22%** inclusive; plus `libReexportDeclares` 1.3%.
4. `ScopeStack_lookupFrom` linear scans — 2.1%; `Sema_lookupType` — 1.1%.
5. `compatible()`/`resolveScalarAlias` chains — currently cheap (~0.03–0.04%) thanks to the `left==right` fast path, but fragile; becomes the next hotspot once 1–3 shrink the base.
6. No hash-consing of composite types (makeNamedArgs 8,979 fresh entries per spelling) — inflates the type table that findings 2 scan; synergy fix.
7. `substituteFieldTy`/`structParamName` — ~0.5%; lexer `IdentifierTable_get` — 9.1% (out of focus files).
- Scaling: marginal cost per function grows 1.36→3.18ms (b50→b400) — O(n²) signature consistent with intern/type-table scans; ~40% of an empty build is fixed prelude cost.

**Module self-costs**: context (intern) 48.7%, lexer 13.2%, semantics 11.1%, parser 8.1%, backend 7.6%, mono 4.8%.

All data is in hand — next step is writing the final ranked report with fix sketches (hash-map interner like clang's StringMap / rustc's interner; cached primitive singletons; stat()-based module probing; per-scope hash maps; composite-type uniquing). Want me to write it out now?

---

# PART 6 — Semantics: scope / member / decl / stmt
*(Agent ses_ea27652f8ffel26tCwmNP5phSy — scope: decl.crl, stmt.crl, member.crl, scope.crl, sema.crl, pointer.crl — MEASURED via callgrind)*

All research and profiling are complete. Here is the full recap + final report.

## What we did so far (recap)

1. **Read-only survey** of `coral-semantics/{decl,stmt,member,scope,sema,pointer}.crl` + supporting files (`context.crl`, `analyze.crl`, `expr.crl`, `typecheck.crl`, lexer `table.crl`).
2. **Wall-clock baselines**: `coralc test/object/linktool.crl` ≈ 11.7s; `--dry-run` (skips gcc) = 2.96s → frontend ≈ 2–3s on a 194-line file; the rest is gcc `-O0 -g` via `-x -` pipe (`coral-frontend/compile.crl:runGcc`).
3. **Symbolized callgrind profile** (perf was blocked by `perf_event_paranoid`; built `dist/coralc-linux.c` → `/tmp/opencode/coralc-sym`, ran valgrind → `/tmp/opencode/cg-sym.out`, caller tree → `/tmp/opencode/cg-caller.txt`). 6.65B Ir total.
4. **Attribution completed** for every in-scope function (intern callers, lookupFrom callers, findMember/findMethod/lookupAt/lookupType/declareAll costs).
5. **Web research** on clang/rustc/gcc name-lookup and interning (results cited per finding below).

---

## Ranked performance findings

### #1 — `AstContext_intern` linear scan: 46.4% of all instructions
**Where:** `coral-context/context.crl:452-467` (comment at 449-451 literally says *"linear scan … fine until a profile says otherwise"*).

**Why it's slow:** full linear scan of `interns[]` on every call, comparing with `streq` (self 25.7% + `streq` 20.7%). 64,431 intern calls → 51.6M `streq` calls ≈ **800 entries scanned per call**, and cost grows linearly with the table — late calls (sema, codegen) are ~2× the average. In-scope callers: `stmt.crl:89,101,108` (`intern("no_drop"/"maybe_unused")` per local), `stmt.crl:95,207,208,231` (`"drop"/"at"/"count"/"range"`), `stmt.crl:434,721` (`"self"`), `expr.crl:691,693` (`"payload"` — 120 calls cost 19.6M Ir = **163k Ir/call**, worst per-call offender in sema), `expr.crl:752,1471`, `member.crl:55,89,90,95,137,143,258,316`. Sema-side total ≈ 414M (6.2%); parser + codegen account for the other ~2.7B.

**Fix (Coral sketch):**
```coral
struct InternEntry { str s; u32 id; u32 hash; }   // store FNV-1a hash
struct AstContext { InternEntry* interns; u32* buckets; u32 bucketsCap; ... }

u32 intern(str s) {
    u32 h = fnv1a(s);
    for (u32 i = bucketProbe(buckets, h, bucketsCap); ; i = (i+1) & (bucketsCap-1)) {
        u32 idx = buckets[i];
        if (idx == 0) break;                                  // empty → insert
        if (interns[idx].hash == h && streq(interns[idx].s, s)) return interns[idx].id;
    }
    ... append entry, rehash at load factor 0.75 ...
}
```
Plus: hoist hot ids (`id_drop`, `id_self`, `id_payload`, `id_range`, `id_no_drop`, `id_maybe_unused`) into lazily-initialized context fields — one intern each, then plain integer compares.

**Prior art:** rustc interns every identifier to a `Symbol: u32` via `FxHashMap` (O(1)); clang's `IdentifierTable`/`DeclarationNameTable` hash-cons names to stable `IdentifierInfo*`; gcc hash-conses `IDENTIFIER_NODE`s (`IDENTIFIER_HASH_VALUE`, stringpool). All three make `intern` effectively O(1) — Coral is the only one scanning.

**Expected gain:** removes up to ~46% of Ir → **~1.9× whole-compile** on this benchmark; sema share alone ~6%, and the win *grows* with program size because the scan cost grows with the table.

---

### #2 — `ScopeStack` linear scope scans + merged mega-root scope: 6.58%
**Where:** `scope.crl:205-219` (`lookup`), `224-244` (`lookupFrom`), `250-269` (`lookupAll`), `148-203` (`declare` — dup scan at 159-179). Structural cause: `analyze.crl:1621-1633` merges the entire prelude (`core::str`, `std::io::ios`, `std::text::string`, `option`, `result`, `vec`, `arr`) plus all imports into **one flat scope**.

**Why it's slow:** `lookupFrom` = 437.8M Ir, 54,655 calls ≈ **8k Ir/call (~200+ symbol probes)** — and it cannot early-return on a name hit unless `fileId` matches, so it scans the *entire* root scope on misses and cross-file hits. Sema-side ~166M (`lookupType` 6,110× + `lookupAt` 27,146×); codegen-side ~270M (`cgFindTypeDecl` 17,495×). Also `declare()`'s dup scan makes `declareAll` **O(D²)** — only 0.61% on tiny linktool, but quadratic in real programs.

**Fix:**
```coral
struct Scope {
    Symbol* symbols; u32 symbolsLen, symbolsCap; Scope* parent;
    u32* map;      // open-addressed: key = name Str id (u32), value = index+1
    u32 mapCap;    // built lazily at 16 symbols, then maintained by declare()
}
Symbol* lookupFrom(Str name, u32 fileId) {
    for (Scope* sc = self.current(); sc != null; sc = sc->parent) {
        Symbol* hit = scopeFind(sc, name);          // O(1) via map, null-safe
        if (hit != null && hit->fileId == fileId) return hit;
        if (hit != null) return hit;                // shadowing semantics preserved
    }
    return null;
}
```
Better still (structural): give each imported file its own child scope in `analyze.crl` instead of flattening, so `fileId` disambiguation becomes natural parent-chain shadowing and `lookupFrom` collapses to `lookup`.

**Prior art:** clang never scans a scope array — lexical lookup walks `IdentifierResolver` **per-name** decl chains, and namespace/`DeclContext` lookup is `llvm::DenseMap<DeclarationName, StoredDeclsList>`. rustc's module resolution is `FxIndexMap<BindingKey{ident,ns}, NameResolution>` per module. gcc cp keeps `IDENTIFIER_BINDING(name)` chains and namespace slots via `find_slot_with_hash` (`cp/name-lookup.cc:119-124`). None linearly scans all names in a scope.

**Expected gain:** 8k → ~100 Ir/lookup; lookupFrom 6.6% → <1%; O(1) scaling; kills the quadratic `declareAll`.

---

### #3 — Per-decl `findMethod("drop")` + uncached extends scan: small now, O(E×compare) scaling
**Where:** `stmt.crl:95` (drop resolution for every `VarDecl`), `stmt.crl:207-231` (`at`/`count`/`range` per for-loop), `member.crl:381,387,65` (`sameTypePattern` per extend in `findMethod`/`implementsIter`).

**Why it's slow:** every local declaration re-runs `findMethod`, which linearly walks **all** extends/ExtendTraits and runs a recursive structural type compare (`typecheck.crl:781+ sameTypePattern`) per candidate. Types with no `drop` pay the full failed scan — on every declaration. 21.2M Ir / ~0.32% on linktool, but grows with extends count × decl count.

**Fix:** memoize method resolution — a hash map keyed by `(receiver Ty, name Str) → MemberInfo`, invalidated per file pass; or better, precompute at `declareAll` time a per-type method table (extends owner → methods indexed by receiver type), like building vtables once. Also a per-type capability bitset (`hasDrop`, `hasIter`, …) so the common "no drop" case is a bit test.

**Prior art:** clang caches inline-method lookup sets per `CXXRecordDecl`; rustc memoizes trait-in-scope lists per module (`ModuleData.traits`) and indexes impls by self type; gcc stores method lists on the class type (`lang_type`) rather than rescanning.

**Expected gain:** per-decl O(E) → amortized O(1); becomes a top-3 item on extends-heavy codebases.

---

### #4 — `expr.crl` double lookup + per-access `intern("payload")`
**Where:** `expr.crl:92` (`checkIdent` → `lookupAt`) then `expr.crl:1187` (Ident arm → `lookupAt` **again** on the same name); `expr.crl:691,693` (`isPayloadAccessNode` interns `"payload"` twice per node — 19.6M Ir on 120 calls); `expr.crl:752` (`"self"`), `expr.crl:1471` (`"range"`).

**Fix:** `checkIdent` already resolves the symbol — pass `Symbol*` through to the Ident arm instead of re-looking-up; pre-intern payload/self/range once into context fields (see #1).

**Expected gain:** eliminates ~100% of redundant lookups in the ident path + the worst per-call intern cost in sema; compounds with #1/#2.

---

### #5 — `member.crl` builtin-member intern compares
**Where:** `member.crl:89-143, 258, 316` — each `str`-builtin field access does ~5 `intern("str"/"len"/"ptr"/"tag"/"payload")` calls to build comparison keys.

**Fix:** cached ids (`id_str`, `id_len`, …) — one-line each once #1 lands; alternatively precompute a small static dispatch table for str-builtin members keyed by the already-interned field name at parse time.

---

### #6 (adjacent, flagged) — `IdentifierTable_get`: 7.24% — fixed 256-slot table
**Where:** `coral-lexer/table.crl:5` ("*never resizes: once full, get() starts…*"), `:48-57`. 481.9M Ir, 132,607 calls ≈ 3.6k Ir/call (near-full linear probe chains). This is lexer, not semantics, but it's the **#1 non-intern frontend cost** and sits directly on the declaration-parsing path (`lexIdentifier` 562M / 8.45%).

**Fix:** growable table, rehash at load factor ≤ 0.75 (mirror the intern fix — same pattern, same file family).

---

### Noted but out of scope
- **`pointer.crl`**: comment-only parking lot — no code, nothing to optimize.
- **Codegen** 33.1% (`generateC` 2.20B, `cgStmt` 2.65B, `cgMangleS`/`cgMangleExempt` ~8%) — separate workstream.
- **Comptime/mono** `CtEval_evalStmt'2` 27.2% — huge, worth its own profile.
- **gcc pipe cost**: `runGcc` with debug `-O0 -g` + `-x -` + strip dominates wall time on tiny files; caching std artifacts or reusing object files beats any sema fix for *wall clock* on trivial inputs.

---

### Recommended implementation order
1. **#1 intern hash** (self-contained in `context.crl`, benefits every phase, biggest single lever).
2. **#2 scope hash maps** (+ optionally per-file child scopes in `analyze.crl`).
3. **#4/#5 cached ids + kill double lookup** (hours of work, compounds with 1-2).
4. **#3 method-table memoization** (matters when extends grow).
5. **#7 lexer table growth** if frontend is still hot after 1-4.

**Verification plan:** after the staged `expr/sema/stmt` edits settle, self-host, rebuild the symbolized binary, rerun callgrind on linktool + a larger real crate; targets: `intern` < 5% of Ir, `lookupFrom` < 1%, `declareAll` linear.

---

# PART 7 — Frontend driver / orchestration
*(Agent ses_ea2762a16ffegUEaDdOwoh65aL — scope: coralc/compile/args/map/init/tasks/io + builder/map/prelude loading — MEASURED via callgrind)*

# Coral Frontend Driver — Performance Findings (Read-Only Analysis)

**Scope reviewed:** `coral-frontend/{coralc,compile,args,map,init,tasks,io}.crl`, plus the code they orchestrate (`coral-build/builder.crl`, `coral-semantics/analyze.crl` loader) where the driver triggers the cost. No files were modified.

**Shape of the pipeline** (`coralc.crl:243` → `builderRunEx` → `coralc.crl:322` → `compileUnitTo` → `analyzeForCompile` → `generateC` → `runGcc`): everything is a single-threaded, all-or-nothing sequence — discover → fingerprint (reads *every* source) → parse build file → parse entry → read+parse prelude+import closure → sema → mono → codegen → one `gcc` process. There is no caching layer between runs and no parallelism anywhere except the `poll()` drain of gcc's pipes.

Measured context for this repo: **81 `.crl` files / 1.53 MB** in `compiler/`, **300 `.crl` files** in `lib/` (520 KB in `std/x86_64/linux` alone), **103 `import(lib)` sites** in the compiler tree, plus a fixed 7-module prelude.

---

## Rank 1 — Prelude + std closure is re-read, re-lexed, re-parsed on EVERY compile (no PCH/PCM cache)

**Location:** `compile.crl:165` (`analyzeForCompile(...)`) → `analyze.crl:1619–1633` (prelude load list) and the recursive loader `analyze.crl:575–632`, `821–1278`, `649–733`.

**What it does / why it's slow:** Every `compileUnitTo` (and every `--emit-hir`, and every LSP open) constructs a fresh `AstContext`, then unconditionally pulls the fixed prelude — `core::str`, `std::io::ios`, `std::text::string`, `std::option`, `std::result`, `std::vec`, `std::collections::arr` — and recursively every `import(lib)` they declare (`std::mman`, `std::error`, `core::cchar`, `core::char_util`, `core::limits`, `platform::libc`, …). Each of those files is fully read, lexed, parsed into the shared context, then `libMerge` copies all decls into the entry file. For this tree that closure plus the ~103 `import(lib)` sites means on the order of **tens of std files and several hundred KB parsed per compile, every compile, even when only one user file changed**. None of it is reused across runs.

**Concrete fix:** a prelude/module cache keyed by the fingerprints the builder already computes:
```coral
// analyze.crl, inside analyzeForCompile, replacing the prelude block at 1619-1631
u64 key = preludeKey(libFiles);            // stat/mtime+size of the ~20 closure files, XOR flags
if (!cacheLoad(".coral/cache/prelude.pcm", key, ctx, &idents, engine))
{
    libLoadModulePath(&loader, "core::str");   // ... existing 7 loads + recursive closure
    cacheStore(".coral/cache/prelude.pcm", key, ctx, preludeDeclRange);
}
// then only libLoadImports(&loader, file) for the user closure
```
Even a cheap intermediate step helps: memoize `path → File*` inside `LibLoader` for one run so manifests/files are never parsed twice (see Rank 5).

**How others do it:** Clang's PCH docs state the design is "entirely driven by performance concerns": bundle common headers, serialize once, "load the PCH file first… which acts as a stand-in for that bundle" — loading must be cheaper than reparsing (clang.llvm.org/docs/PCHInternals.html). Clang Modules persist one PCM per module in the module cache so "a module's headers will only be parsed once per language configuration, rather than once per translation unit" (clang.llvm.org/docs/Modules.html). Real-world magnitude: clangd with implicit-module preamble caching took document-open from **120+ s → ~3 s on a 2 MLOC file** (LLVM Dev Mtg 2023 slides). This is the single highest-leverage fix for Coral because the prelude is *invariant* across builds.

---

## Rank 2 — All-or-nothing rebuild: no incremental/parse cache even though per-module fingerprints + topo order already exist

**Location:** `coralc.crl:289–307` (only two states: everything fresh, or recompile the entire unit), `coralc.crl:322`; builder already computes `b.mods[m].fingerprint`, `bCheckFp`, `b.topoOrder` (`builder.crl:1321–1361`, `1594–1629`, `1407–1428`).

**What it does / why it's slow:** Staleness is computed *per module*, but the compile decision is binary: if any module is stale (`b.anyStale`), the driver re-runs the full pipeline — entry + entire import closure + prelude + sema + mono + codegen + gcc — for **everything**. Editing a comment in one leaf module re-parses and re-typechecks all 81 files and re-emits/re-compiles the whole monolith. The per-module fingerprints are thrown away after a yes/no check.

**Concrete fix:** persist the parsed surface per module keyed by the fingerprint that already exists, and only rebuild in reverse-dependency order along `topoOrder`:
```coral
// coralc.crl, before compileUnitTo:
u32 changed = collectStale(&b);              // b.mods[i].stale from bCheckFp
// loader consults .coral/cache/<mod>.fp + <mod>.decls: fresh module => deserialize decls,
// skip read+lex+parse; stale module + dependents => reparse
```
Additionally, a red-green style "did the output actually change?" check before invoking gcc (Rank 3's code hash) converts most edit-rebuild cycles into a codegen-only cost.

**How others do it:** Cargo stores a per-unit `Fingerprint` in `target/.../.fingerprint/` and marks units dirty/fresh, propagating dirtiness through dependency fingerprints — "the Fingerprint also tracks the fingerprints of all its dependencies, so a change in a dependency will propagate" (docs.rs/cargo fingerprint module). rustc's red-green incremental algorithm: "if all the inputs to query Q are colored green, then the query Q must result in the same value as last time and hence need not be re-executed" (rustc-dev-guide incremental-compilation). Coral has the same ingredients (per-module fp, dep edges via `.coral/graph`, topo order) but only uses them for a boolean.

---

## Rank 3 — One monolithic, single-threaded `gcc` job over the whole generated C; frontend and backend never overlap

**Location:** `compile.crl:183` (`generateC` into one buffer), `compile.crl:214–215` (`codeHasMain` + `runGcc`), `compile.crl:38–126` (spawns **one** `gcc`, streams the entire C through stdin pipe).

**What it does / why it's slow:** The whole program becomes a single translation unit; a single `gcc` process lexes/parses/optimizes it sequentially. On any nontrivial program this dominates wall time — and coralc sits idle waiting (`waitFor` at `compile.crl:123`). The debug default adds `-O0 -g` (`compile.crl:59–61`); full `-g` DWARF emission on a giant TU is a well-known multi-x cost. There is no overlap: map/graph writes and fingerprinting finish before gcc starts; fingerprinting could at least start (or run in background) concurrently.

**Concrete fix (two parts):**
```coral
// 1) split codegen by module (backend already emits per-File sections) and run jobs in parallel
import(lib) std::concurrent::threadpool { ThreadPool };
ThreadPool pool; pool.init(nproc());
for (Chunk* c in cg.chunks) pool.submit(gccCompileOne, c);   // gcc -c -x c - -o chunk.o
pool.deinit();
runGccLink(outPath, objects);                                 // single link step

// 2) skip gcc entirely when the generated C is byte-identical to last run (ccache-style)
u64 ch = fnv64(cg.cCode);
if (!opts.force && objExists(outPath, ch)) return 0;
```
Also worth switching debug default to `-g1` or `-gsplit-dwarf` (cheaper debug info) and `-pipe`-equivalent behavior (already effectively piping).

**How others do it:** Ninja/meson run independent compile jobs in parallel by default — "Builds are always run in parallel, based by default on the number of CPUs" (ninja-build.org/manual); Meson limits link concurrency with ninja pools precisely because link/compile overlap matters (meson PR #13937). rustc "can split the compilation into multiple codegen units using threads" and regulates this via the make jobserver (ninja PR #2506 discussion; gcc `-flto=jobserver`). Clang's two-phase module build exists "because the two-phase compilation model can be compiled faster due to higher parallelism" (StandardCPlusPlusModules docs). First structural step for Coral: emit per-module C chunks + object reuse; second: a threadpool over them.

---

## Rank 4 — `bFingerprint` reads + double-copies EVERY source file on EVERY build; map/graph rewritten unconditionally (no-op builds do full I/O)

**Location:** driver entry `coralc.crl:243` → `builderRunEx` (`builder.crl:1672` → `bFingerprint` `builder.crl:1321–1361`, reads every file at `1341` via `bReadFile` `builder.crl:119–161`, heap→arena copy at `156`), plus `bWriteMap` at `builder.crl:1655` and `bWriteGraph` at `builder.crl:1675`, plus `bBuildModuleTable`/`bScanReexports` re-reading every module's `lib.crl` (`builder.crl:1096`, `918`), plus per-module `createDirRecursive` ×2 in `bWriteFp` (`builder.crl:1565–1566`, called per module via `bWriteAllFps` from `coralc.crl:328`).

**What it does / why it's slow:** Even when the result is `coralc: up to date`, the driver has already: walked all dirs, opened and **content-read all 81 files (1.53 MB)**, copied each into the arena (an extra full memcpy per file in `bReadFile`), FNV-hashed them, line-scanned all 15 `lib.crl` files for re-exports (their second read — fingerprint gives a third), loaded `.coral/graph`, written `modules.map` and `.coral/graph`/`.coral/graph.dot` again, and after a successful compile written 15×2 fingerprint files with 2 `mkdir` calls each. A no-op build should be ~`stat()`-sized.

**Concrete fix:** stat-first fingerprints; hash content only when stat changed; stop rewriting outputs whose content didn't change; drop the `bReadFile` double copy (hash from the read buffer directly, or mmap):
```coral
// builder.crl bFingerprint — hash (path, mtime, size, inode) as the fast path
FileStat st = fileStat(files[f]);
u64 fast = bFnv(bFnv(fp, files[f].ptr, files[f].len), (u8*)&st, @sizeof(st));
// .coral/cache/<mod>.fp stores (fast, contentHash): fast match => done (no read at all);
// fast mismatch => re-read, re-hash content, compare contentHash => false-stale suppression
```
Same for `.coral/modules.map` / `.coral/graph`: build into a buffer, compare with the existing file, write only on diff (map.crl already has this "line splice, no reserialize" philosophy).

**How others do it:** Cargo: "The mtime of a Unit's source files is compared to the mtime of its dep-info file… If any input files are missing, or are newer than the dep-info, then the unit is dirty" — content hashing is explicitly opted *out* by default for speed ("hashing file contents… would ensure more reliable… builds at the cost of being complex, slow"). ccache's whole design is a stat fast path (`file_stat_matches`: "consider a file as matching its cached version if the mtimes and ctimes match") with content hashing only as the fallback tier. Ninja stats inputs/outputs and does no content reads for freshness.

---

## Rank 5 — Loader existence probes read entire candidate files; directory manifests are re-read AND re-parsed on every resolve

**Location:** `analyze.crl:296–401` (`libResolveSegs`): probe at `309` and `320` does `libRead` (full `readFile`) and immediately `dealloc`s — the comment at `303–304` even says *"existence probe only; the file is re-read by the loader later"*. For `n>1`, `337` reads the directory manifest `lib/std/lib.crl` etc. and `354` **parses it into the shared context again** on every call — no dedup against `libHas`. Additional full-read probes: bare-module probe `analyze.crl:882`, `libReexportDeclares` at `analyze.crl:813` (re-resolves **and re-reads** the target once per alias, driven from the loop at `1206`), and `libSourceDeclares` (`773–795`) re-scans the file line × line for each requested symbol.

**What it does / why it's slow:** With ~103 `import(lib)` sites plus the prelude, each resolve of a `std::…`/`core::…` path (i.e., every path that is *not* in the builder's `modKeys`) walks up to 4 roots and: reads candidate target files fully just to test existence (each is then read a second time for real loading at `599`/`1105`), and re-reads + re-lexes + re-parses every intermediate manifest (`<root>/std/lib.crl`, `<root>/std/<sub>/lib.crl`, …) each time — each parse also grows `AstContext` nodes/interns and pushes another copy of the manifest buffer into `L->bufs` (`343–350`) that is retained until `freeUnit`. This is pure redundant I/O + redundant parsing multiplied by import count.

**Concrete fix:** probe with `stat`/`fileExists` (the builder already has `bFileExists`), and memoize manifests:
```coral
// analyze.crl libResolveSegs n==1 branch
if (fileExists(cand)) return cand;        // stat, not readFile+dealloc

// LibLoader gains: u8** mfPaths; File** mfFiles;   // memo: dir-manifest path -> parsed File*
usize mi = indexOfManifest(L, mpath);
if (mi >= 0) { /* use L->mfFiles[mi], skip libRead+libParse */ }
```
Similarly cache `resolved-path → path` per import string so `libResolve` is called once per distinct import (it currently resolves *before* the `libHas` dedup check at `1068` → `1094`), and memoize `libReexportDeclares` results per (target, alias).

**How others do it:** Clang's header search tests candidates with `stat` via `FileSystemStatCache` — a cfe-dev thread reports "Implementing FileSystemStatCache gave the next visible speedup" precisely because probing must not read files. LLVM's `MemoryBuffer::getFile` only ever reads when it intends to keep the buffer, and sizes via `fstat` first. Clang modules keep a validated on-disk PCM per module so a header path is never re-read to answer "does this exist / what's in it".

---

## Rank 6 — Linear module-table lookups, per-resolve heap copies, and repeated platform/env/path resolution

**Location:**
- `analyze.crl:410–457` — `libResolve` linearly byte-compares the import against **every** `modKeys` entry (first pass), then does a *second* full scan for the bare-name fallback; each hit `alloc`s a fresh copy of the value path (`418–423`, `448–452`).
- `analyze.crl:531–541` — `libHas` linear scan over all loaded paths.
- `analyze.crl:470`, `488` — every resolve allocates `libDir(inputPath)` and calls `libGlobalRoot()` (getenv + alloc).
- `analyze.crl:1542–1598` + `segsFromPlatformFlag` `1328–1399` — the platform root (flag → `CORAL_PLATFORM` → `hostArch/hostOs`) is recomputed from scratch per `analyzeForCompile`, while the builder computes the same thing independently in `bPlatformRoot` (`builder.crl:727–791`).
- `builder.crl:813–822` — `bModTableHas` also linear (`bRegisterExport` calls it per export → O(exports²) byte compares during module-table build).

**Why it's slow:** import count × table size with byte-wise compares and a `malloc` per hit; for this tree the table has 15 modules + aliases + all `pub mod` re-exports (hundreds of keys) × ~800 import decls in the closure. It's not the dominant cost, but it's pure overhead, and the repeated getenv/host/platform work + path-buffer churn add up in a driver that already does heavy I/O.

**Concrete fix:** hash map keyed by interned `Str` (the context already interns every import path — an interned key makes lookup a `u32` compare), plus a resolve memo:
```coral
// LibLoader / Builder: open-addressed table, key = interned Str (or FNV of bytes)
u32 slot = (hash(nsPtr, nsLen) & (modCap-1));
while (modPresent[slot] && !eq(modKeys[slot], ns)) slot = (slot+1) & (modCap-1);
```
Compute the platform root once in `coralc.crl` main and pass it into both `builderRunEx` and `analyzeForCompile` instead of getenv twice.

**How others do it:** clang/meson/cargo all key caches by a precomputed hash of the context (clang "module context hash" — LLVM Dev Mtg 2024 "ClangModules at Scale": "the subset of the command line forms the module context hash"; cargo's `Fingerprint` is a u64 compared after one hash computation). Lookups are O(1) via interned/hashed keys; environment is captured once per process.

---

## Rank 7 — `--emit-hir` runs a second full analysis pass; `compileFile` re-reads and re-parses the build file

**Location:** `compile.crl:308–322` — after a successful compile it `readFile`s the input again (`311`) and calls `analyzeForCompile` a **second time** (`314`), re-parsing prelude + closure from scratch; `compile.crl:237–302` — when `-f` is set, reads (`240`) and fully lex/parses the manifest (`246–247`) into a private 256 KB arena just to extract the `flags = [...]` list, without include/extends expansion (so it also misses flags from included crlb files).

**Why it's slow:** 2× frontend cost for a debug flag; manifest parse duplicates work the main driver path already does.

**Fix:** restructure so HIR is built from the unit *before* `freeUnit`:
```coral
CompileUnit unit = analyzeForCompile(...);
...
if (rc == 0 && opts->emitHir) {
    HirModule* hir = build(unit.ctx, unit.file, unit.mono, unit.ctx.intern(opts->input.asStr()));
    printHir(unit.ctx, hir);            // no second read, no second analyze
}
freeUnit(&unit);
```
For flags: do the cheap raw-text scan for `flags = [` (the builder already has line-scanning precedent in `bScanReexports`, `builder.crl:915–1051`) or, better, share one parsed manifest between `parseArgs`/builder/compileFile.

**Analogy:** clangd/preamble caching exists for exactly this class of "second full parse for a consumer" cost (documented ~3× median speedup before module caching, ~20× P50 with it).

---

## Rank 8 — `codeHasMain` scans the entire generated C twice, byte-at-a-time

**Location:** `compile.crl:128–151` (`codeHasSlice` nested loop), called at `compile.crl:214` with two patterns (`"int32_t main("`, `"void main("`).

**Why it's slow:** O(len × pattern) with a per-byte inner loop over a buffer that can be megabytes; done on every build; naive substring search that can't use `memmem`/SIMD.

**Fix:** the frontend already knows whether a main exists — `sema`/`mono` resolved `main` during analysis. Add `bool hasMain` to `CompileUnit` (set when the entry decl `main` is declared/found in `analyzeForCompile`) and pass it to `runGcc`. If that's awkward short-term, one `memmem()` over `cg.cCode` (GNU) replaces both scans.

**Analogy:** compilers carry semantic facts forward instead of re-scanning outputs; this is the same "don't re-derive from text what you already know structurally" principle as ccache skipping the preprocessor via its manifest.

---

## Rank 9 — `runTask` re-executes shared task dependencies (diamond → repeated `system()`)

**Location:** `tasks.crl:12–69`; the `after` loop at `27–37` recurses with no "already executed" marker; `system()` at `61`.

**Why it's slow:** with `after = ["build"]` shared across tasks (as in `coral.crlb:53–56`) or any diamond (`test` and `run` both after `lint`), each path re-spawns a shell. Task graphs make this exponential in pathological cases (depth cap 8 bounds but doesn't prevent duplicates).

**Fix:**
```coral
// Builder gains: u8* taskDone; (alloc tasksLen bytes in bInit, zeroed)
pub i32 runTask(Builder* b, str name, u32 depth) {
    i32 idx = bTaskIndex(b, name);
    if (idx < 0) return 2;
    if (b->taskDone[idx] != 0) return 0;      // memo: run each task at most once
    b->taskDone[idx] = 1;
    ...
```
**Analogy:** ninja/make evaluate each node in the build graph exactly once and memoize; cargo's `JobQueue` marks units visited in the same run.

---

## Rank 10 — Build-file include/extends: re-reads, no memoization, and an 8× wasted re-read loop

**Location:** `coralc.crl:94–148` (include expansion; path-separator re-scanned per include at `105–111`; source buffer `isrc` from `readFile` at `121` retained per include), `coralc.crl:150–233` (extends merge; `readFile` at `181`, parse at `186–190`).

**Why it's slow (concrete bug):** in the extends loop, `anyExt = true` is set at `161` *before* the `if (ebuild == null) { continue; }` check at `198`. If a build block extends a file that has **no** `build` block, `hasExtends` stays true, so the outer `edepth < 8` loop repeats the whole scan — **re-reading and re-parsing the same target file up to 8 times**. Separately, two blocks extending the same base file each read+parse it independently (no `path → root` memo), and nested includes re-scan the base path for `/` each time.

**Fix:** memoize and clear the flag on the failure path:
```coral
// 1) after readFile+parse of extends target, always: c->hasExtends = false;  (even if ebuild==null)
// 2) small memo for the build-file phase:
//    struct { Slice path; CrlbNode* root; } extCache[8]; usize extCacheLen;
//    root = lookupExt(joined) ?: (parse & store)
```
Build files are small so absolute cost is low, but this is a correctness-adjacent latency bug on the hot startup path (it runs before *every* build).

---

## Rank 11 — I/O hygiene: `readFile` grows blindly, no `fstat`/mmap; extra copies; leaked-but-kept buffers

**Location:** `io.crl:8–42` (starts at 64 KB regardless of file size, doubles via `realloc`, multiple `read()` syscalls for larger files, no `fstat` pre-size, no mmap); `io.crl:44–55` (`sliceCStr` copies every path passed to `printf`); `compile.crl:181–182` / `coralc.crl:83–84` (4 MB arenas; `Arena.freeAll` at `compile.crl:226` immediately allocates another 4 MB block per `arena.crl:76`); `compile.crl:158` `src` never released (as with `fsrc` `240`, `hsrc` `311`) — buffers are retained because interned strings/parse nodes point into them (same ownership rule as `L->bufs`, `analyze.crl:340–342`).

**Why it's slow:** for the 1.5 MB tree, reads are 4+ realloc copies each (64K→128K→…→2M) per file, ~3× per file per build counting Rank 4/5 duplication. The tiny build file still costs a 64 KB allocation. Path copies are trivial individually but appear on every diagnostic/print.

**Fix:**
```coral
pub Slice readFile(str path, usize* outLen) {
    FileHandle fh = fileOpen(path, "rb").unwrapOr((FileHandle)0);
    usize sz = fileLen(fh);                       // fstat(fd): one syscall for exact size
    u8* buf = alloc<u8>(sz + 1);                  // single alloc, single read loop
    // or: mmap PROT_READ MAP_PRIVATE when sz >= 16KB — caller munmaps in freeUnit
```
Keep the NUL-termination guarantee the lexer relies on (LLVM does the same: `RequiresNullTerminator`).

**How others do it:** LLVM `MemoryBuffer::getFile` does `fstat` for size ("fstat on an open file descriptor is cheaper than stat on a random path") and mmaps files ≥ 16 KB (`FileSize >= 4096*4`), falling back to one exactly-sized alloc + read loop; clang-scan-deps measured ~**50% peak-memory reduction** from not copying mmap'd file contents (LLVM D115043). Also consider a shared `readFile` between `io.crl` and `bReadFile` — today the builder's variant does heap-read → arena-copy → free (`builder.crl:126–158`), i.e., a guaranteed extra memcpy per file.

---

## Rank 12 — `map.crl` discovery walk: O(n²) membership checks, insertion sort, double-copy splice

**Location:** `map.crl:190–224` (`mWalk`: per-directory `bFileExists` probes at `214`, `bJoinStr` arena allocs per entry), `map.crl:172–188` (`mListed` scans the *entire* `modules = [...]` text for each found module → O(found × entries × len)), `map.crl:237–252` (`mSort` insertion sort → O(n²) swaps on up to 512 entries), `map.crl:276–317` (`mSplice` allocates `raw.len + 4096` insert buffer + a second full-size output buffer → two full copies of the build file).

**Why it's slow:** only on `coralc map`, so impact is low in absolute terms, but it's the same quadratic patterns as elsewhere; with 512-entry caps it's ~260K comparisons worst case plus two build-file copies.

**Fix:** sort found modules *first*, then do one merge-style pass against the sorted listed set (or intern names into a small open-addressed set — Coral already needs one for Rank 6); use `qsort`-equivalent (`std::collections::sort` exists in lib); build the spliced output with `pwrite`-style append into a single buffer sized `raw.len + computedInsertLen` instead of a separate insert buffer.

**Analogy:** ninja/meson keep discovery linear with hashed sets; anything quadratic in the driver shows up immediately at `-j` scale.

---

## What's already good (don't "fix")

- `args.crl` — flag classification is a length-switch (`args.crl:126–154`), arg parsing is a single pass over `/proc/self/cmdline`; startup cost here is negligible. `init.crl` is one-shot scaffolding; fine.
- GCC stdout/stderr are drained concurrently with a `poll()` loop (`compile.crl:90–119`) so gcc can never block on diagnostics — good; the SIGPIPE ignore at `coralc.crl:33` avoids a classic pipe hazard.
- The builder's module table is consulted **before** filesystem probing (`analyze.crl:406–410`, "map-first") and `.coral/modules.map` is a debug dump, not an input — the right design; the remaining waste is that *std/core/platform* imports (not in the table) fall through to the probing path (Rank 5).
- The up-to-date short-circuit exists (`coralc.crl:289`); it just sits behind a full discovery+fingerprint pass (Rank 4).
- Feeding gcc via pipe avoids writing a `.c` file (`compile.crl:35–37`) — keep that when parallelizing.

---

## Suggested implementation order (by expected impact ÷ effort)

1. **Stat-probe instead of full-read in `libResolveSegs` + manifest/path memo** (Rank 5) — localized, removes the worst redundant I/O and duplicate parses immediately.
2. **Prelude/PCM cache keyed by fingerprint** (Rank 1) — biggest fixed per-compile cost; makes every subsequent build's frontend proportional to *changed* code.
3. **`hasMain` from sema instead of scanning generated C; ccache-style generated-C hash to skip gcc** (Ranks 3/8) — turns "rebuild with no semantic change" into near-zero.
4. **Stat-first fingerprints + write-on-diff map/graph** (Rank 4) — makes no-op builds ~`stat()` cost (cargo/ccache behavior).
5. **Per-module incremental reparse along existing `topoOrder`** (Rank 2) — the architectural payoff once 1–4 are in.
6. **Parallel codegen-unit gcc jobs via `std::concurrent::threadpool`** (Rank 3) — scales with cores, mirrors ninja/meson/rustc.
7. Quick wins: task memo (Rank 9), extends-loop clear + memo (Rank 10), emit-HIR reuse (Rank 7), `fstat`-sized reads (Rank 11), map.crl sets/sort (Rank 12).

**Instrumentation note:** `analyze.crl:1088` already gates load tracing behind `CORAL_TRACE_LOAD` — extending that to a `CORAL_TIME=1` mode that prints per-phase ms (fingerprint / build-file parse / prelude load / closure parse / sema / mono / codegen / gcc) would validate these rankings against real numbers before/after each change.

---

# PART 8 — Codegen (C emission)
*(Agent ses_ea2761057ffe7tAfohDTpPfhb5 — scope: coral-backend/codegen.crl — patterns-to-avoid for backend rewrite)*

# Codegen Performance Review: `coral-backend/codegen.crl`

**Scope:** C-emission backend (7142 lines). Since this backend will be replaced, findings are framed as **patterns to avoid in the rewrite**, ranked by expected impact. All line numbers verified against the current file.

---

## P0 — O(n²) output assembly via append-only scratch streams

### 1. `ebuf` never truncates; every parent re-appends its children's text

**Location:** `cgExpr` entry `codegen.crl:2460` (`usize es = cg.ebuf.len`); re-append arms throughout `2715–2737` (Neg/BitNot/Not/Deref), `2834–2841` (Cast), `2917–2923` (all 16 binary ops), `2930–2936` (And/Or), `3170–3175` (Call), plus `cgLvalue`, `cgPatTest:4100`, etc. **Verified: zero `stTrunc(&cg.ebuf, …)` calls exist in the file** (only `4830`, `4898` truncate `cg.body`).

**What it does / why it's slow:** every `cgExpr` node writes its *entire subtree's* text into the shared `ebuf` stream; the parent then `stPS`-copies the child's returned slice *again* as part of building its own wrapper text. The child's original bytes `[es, rs)` are dead but never reclaimed. Consequences:

- Total bytes written = Σ over nodes of (subtree text size) → **O(n²) for expression chains** (`a+b+c+…`, nested calls). A chain of depth d over leaf size 1 costs Θ(d²) memcpy bytes.
- `ebuf` grows monotonically for the **whole translation unit** (never reset between statements *or functions*), so its final size is several times the real output, and every capacity doubling memcpy's the garbage.
- 334 write sites feed this stream; it's the hot path of the entire backend.

**Fix (pattern):** don't hand out interior pointers into a shared scratch buffer. Either
(a) emit directly into a target stream with a recursive `cgExprTo(Stream* out, NodeId)` (children emit into `out` *before* the parent writes its wrapper around them — order of writes replaces the need to re-append), or
(b) keep the slice-returning API but **truncate `ebuf` back to `es` after each `stPS` copy** (one `stTrunc(&cg.ebuf, es)` per parent arm), or
(c) return arena-owned strings built in a fresh short-lived buffer with a stack of reusable buffers (Coral sketch):

```
Slice cgExpr(Codegen* cg, NodeId id) {
    usize es = cg.ebuf.len;          // mark
    ... emit child into ebuf ...
    Slice c = stTail(&cg.ebuf, childStart);
    usize rs = cg.ebuf.len;
    stP(&cg.ebuf, "(-("); stPS(&cg.ebuf, c); stP(&cg.ebuf, "))");
    Slice res = stTail(&cg.ebuf, rs);
    // copy res down to es, then truncate: O(len) once, no quadratic residue
    ...
}
```

**Speedup rationale:** this is the difference between O(output × depth) and O(output). Clang never re-appends: `ExprEmitter` writes directly into a buffered `raw_ostream` (`raw_ostream.h` — single buffer with `OutBufCur`/`OutBufEnd`, slow path only on overflow), and the only "scratch" is small stack `SmallString`s for subexpressions that must be reordered. The recent LLVM TableGen PR #123353 (stringvec_ostream) exists precisely because re-copying a growing output buffer is the classic C-emission bottleneck — don't recreate it.

### 2. `tybuf` has the identical disease (type spellings + mangled names)

**Location:** `tyStr` `codegen.crl:1725–1837`, `tyStrPut:1719`, `cgInstanceName:597–609`, `cgMangleTy:564`, `cgTempName:326`, `cgEmitMethodSet:6742`, `cgEmitInstMethodList:6797`. Never truncated.

**Why slow:** `tyStr` for `Named` composes `cgMangle(cg, td, name, 0)` which internally writes the whole path-mangled name into a *fresh* stream, then `tyStrPut` **appends it into `tybuf` again**. Nested pointer/array types append child spellings then re-append. `tybuf` accumulates every type spelling and every temp name for the whole file, doubling repeatedly with all prior contents dead. Same O(output × nesting) growth as `ebuf`, on a second axis.

**Fix:** same as #1; additionally cache (see #3) so the common case (leaf/primitive/named type) is a lookup, not an append. A `tybuf` used as a *scratch* must be save/restore-truncated around each top-level composition.

---

## P0 — Missing memoization / interning (recomputation of identical text)

### 3. No `Ty → C spelling` cache: `tyStr` recomputes mangled names on every use

**Location:** `tyStr` `codegen.crl:1725`; Named arm `1755–1794` — every spelling does: linear alias scan over all file decls (`1770–1787`), then `cgFindTypeDecl` (scope lookup + another full decl scan, `887–936`), then `cgMangle` → `cgMangleS` path rebuild.

**Why slow:** `tyStr` is called from temp declarations, every cast, every binary-op wrap, every struct field, every param — hundreds of times per identical type. Each call redoes path maging (segment sanitize loops, `/lib/` scanning, fresh 96-byte arena stream at `764`). For a file with T type spellings of average length L, this is O(T·L·decls) instead of O(T).

**Fix:** a direct-indexed cache `Slice* tyStrCache` in `AstContext` keyed by `Ty` id (types are already interned numeric ids; entries grow with the type table, invalidated only if substitutions rewrite — inside an instance either cache under a substituted key or bypass). Clang equivalent: `TypePrinter` results are effectively cached per `QualType` in ASTContext-style side tables, and `ItaniumMangleContext` caches mangled names per decl — a mangled name is computed **once per decl**, then referenced.

```
Slice tyStr(Codegen* cg, Ty t) {
    if (t < cg.tyCacheLen && cg.tyCache[t].ptr != null) return cg.tyCache[t];
    ... existing computation ...
    cg.tyCache[t] = result;  // store arena-owned slice
    return result;
}
```

### 4. `cgMangleS` rebuilds the file path per call; `cgMangleExempt` double-called and O(decls)

**Location:** `cgMangleS:741–849` (fresh `stNew(cg.arena, 96)` at `764`, full path scan `769–837`); `cgMangle:852–857` calls `cgMangleExempt` then `cgMangleS:743` calls it **again**; `cgMangleExempt:717–731` scans **all file decls** looking for an extern("C") twin of any Func; `cgEmitFwd:5776+5778` mangles the **same decl twice back-to-back**; the proto pass (`6905`) and body pass (`6968`) each re-mangle every function; every *reference site* (Ident `2634`, calls `1502`, `1659`, methods `3233`) re-mangles again.

**Why slow:** the mangled name of a decl is a pure function of (decl file path, alias, name) — computed O(uses + passes) times, each with a decl scan and an arena alloc. With K decls and R references this is O((K+R)·K) byte work plus arena fragmentation from one abandoned stream per call.

**Fix:** one memo table `Hash<declId, alias> → Slice` populated on first mangle; `cgMangleExempt` precomputed into a per-decl flag bit (or a `HashSet<Str>` of extern names built once in `generateC`). Fold the double `cgMangleExempt` call. In the rewrite: **mangle each symbol exactly once during a declaration-collection pass**; all later phases just carry the `Slice` (this is how clang works — `CodeGenModule` records `getCGName` per decl in `MangledDeclMap`-like structures and never re-derives it).

### 5. All "lookup tables" are linear scans over interned `Str` IDs

**Locations (all in codegen unless noted):**

| Structure | Line | Shape |
|---|---|---|
| `cgFindDecl` cache | 1310–1325 | 32-slot linear; miss = full decl scan `1326–1359` |
| `cgRegHas` (typedef registry) | 1844–1862 | linear + per-char compare |
| `cgFnSeen` (proto/body dedup) | 1874–1887 | linear per mono instance → O(instances²) |
| `cgIsLocalName` / `cgAddLocal` | 1007, 986 | linear per ident reference |
| `cgFindMethodDeclOwner` | 1162–1263 | decls×methods scan; mono branch nests decls×instances×decls |
| `cgMethodRecvKind` | 2346–2409+ | full decl scan per method call |
| `cgHasField` | 2310–2340 | find-decl + field scan per call |
| `cgFindTypeDecl` alias scan in tyStr | 1770–1787 | full decl scan per type spelling |
| **`AstContext.intern`** | `context.crl:452–467` | **linear scan over ALL interned strings** |

**Why slow:** `Str` is already a **u32 interned id** — equality is integer compare — but every membership test still walks arrays, and `intern()` itself (called from `cgMoveDisposeRecv:479` for `"dispose"`/`"free"` on *every method call*, and `cgAddLocal:5663` for `"self"`) scans the entire intern table with byte-compare. The intern table has one entry per distinct string in the whole program (tens of thousands); this alone can dominate small-compilation times. Clang counterpart: `IdentifierTable`/`KeywordHash` — keywords are hashed once at startup, lookup is O(1); `StringMap`/`DenseMap` for every registry here.

**Fixes:**
- **Hash the intern table** (open addressing on the string bytes → id). This is cross-cutting and benefits lexer/parser too — highest leverage single change outside this file.
- Codegen registries: since keys are `Str` u32s, use direct-indexed bit/pointer tables (`Slice* byStrId` sized to `internsLen`, or a small open-addressed `u32→u32` map). `cgFindDecl`: prebuild `Hash<(name,tag)→NodeId>` once in `generateC` (O(decls)) instead of a 32-slot cache.
- `cgRegName`/`cgFnSeen`: hash set keyed by the name's first 8 bytes + len, or by a precomputed u64 hash of the slice.

### 6. `cgIdent`: ~40 sequential string compares per identifier; `cgIsCrtFn` same pattern

**Location:** `cgIdent:2177–2226`; `cgIsCrtFn:2228–2260` (called from `cgMangleExempt:705`, i.e., every mangle).

**Why slow:** every local/ident emission and every mangle does up to 40+ length-checks-and-memcmps. Constant factor, but on the hottest path (every `Ident`, every name).

**Fix:** intern the keyword set **once** into `Str` ids at startup; `cgIdent` becomes `if (isKeyword[name]) append '_'` — a single u32 array index (keywords are ids ≥ 1; a bitset or byte table indexed by id is O(1)). Same for the CRT name set. This is exactly clang's model (`tok::kw_*` in a hashed `IdentifierTable`).

---

## P1 — Per-node allocation and repeated resolution work

### 7. Call resolution: heap alloc + full mono-instance scan per call site (×2 scans)

**Location:** `cgCallFromDecl:1444–1486` (`alloc<Ty>` per call, `callValueKeyTyped` walk, `inferCallArgs` walk, then linear scan of **all** mono instances with `sameType` per candidate); `cgResolveGenericCall:1585–1703` — up to **two** full instance scans (decl-keyed at `1631`, name-keyed fallback at `1668`) plus `alloc`/`dealloc` of `gbuf` per call.

**Why slow:** O(call-sites × instances × args) with two heap alloc/free pairs on the path. Generic-heavy code (the mono system exists for this) makes instances numerous exactly when this matters.

**Fix:** build once in `generateC` (or better, in mono): `Hash<(declId, valueKey) → instanceIdx>` and `Hash<(name, valueKey) → instanceIdx>`. Scratch `Ty` arrays come from a reusable arena bump buffer (save/restore length), never `alloc`/`dealloc` per node. Clang analogue: `CodeGenTypes`/`CXXGen` cache instantiations by canonical template args; nothing is re-inferred at emission.

### 8. Loop conditions emitted twice (probe + real)

**Location:** `StmtKind::While:4812–4848`; `StmtKind::For:4862–4898`.

**Why slow:** the cond/post are emitted once purely to *detect* whether they produced side statements (`cg.body.len > b0`), then `stTrunc(&cg.body, b0)` throws the text away and `cgExpr` runs **again** for the real emission. All resolution work (mangle, instance scan, method lookup, intern) runs twice per complex loop condition — and the first pass's `ebuf` garbage also stays (see #1).

**Fix:** either (a) make the probe a *pure query* (`bool exprHasSideStmts(NodeId)` walking the AST for Call/Assign/etc. — cheap, no emission), or (b) emit once into `body`, and if side-stmts were produced, keep that emission and only restructure the surrounding `while(1){…}` scaffolding around the already-emitted text. Never re-run the emitter.

### 9. Multi-pass decl walking with per-pass recomputation

**Location:** passes over `file.decls` in `generateC:7094–7109`: `cgEmitFwd` (5761), `cgEmitAliasBridges` (5828), `cgEmitTypeDefs` (6486 — sweeps 1, 2, 2b, 3, 5), `cgEmitProtos` (6869), `cgEmitGlobals` (6419), `cgEmitBodies` (6953). `cgEmitMethodSet` runs **twice** per type (proto pass `6912`, body pass `6976`) recomputing every method's `owner_method` name (`6742–6746`). `cgEmitProtos` extern-dedup `6886–6901` is an O(i) inner scan → O(n²) over extern decls.

**Why slow:** 6–8 full walks, each re-deriving mangled names and re-checking generic-ness. The extern dedup is quadratic in the number of extern decls (libc-heavy units have many).

**Fix:** one collection pass that produces a `DeclRecord[]` (kind, mangled name, flags, methods list, instance list) consumed by thin emit passes — names computed once (#4). Extern dedup via a `HashSet<Str name>` seen-set during that pass. This mirrors clang's `CodeGenModule::EmitTopLevelDecl` dispatch over a precomputed symbol table rather than re-scanning the AST per phase.

---

## P2 — Constant-factor stream inefficiencies

### 10. `stPut` does full machinery (bounds check, `memcpy`, NUL-write) per byte

**Location:** `stPut:65–81`; `stCh:95`, `stU64:100–112` (one `stCh` per digit → per digit: bounds check + `memcpy(1)` + NUL store), `stNL:143–150` (one `stP` per 4-space indent unit), `cgWriteHex:613`, string-literal escape loops `2522–2559` (per char). 334 such write sites in `cgExpr` alone.

**Why slow:** ~3–4× constant overhead vs. a buffered char push; the per-write NUL terminator (`s.p[s.len] = 0` at `codegen.crl:80`) exists so `stTail` slices pass as C strings — a correctness convenience costing a store per byte written.

**Fix:** expose a fast path: `if (s.len < s.cap) { s.p[s.len++] = c; } else stPutSlow(...)` for chars; numbers formatted into a 20-byte stack buffer then one `stPut`; indent via a precomputed `"    \n…"` or a `memset`. Reserve the NUL only when a `Slice` is actually handed out (or drop the invariant and NUL-terminate once at the end — slices carry explicit lengths anyway). This is exactly what `raw_ostream` does: inline buffered `operator<<` with a single `OutBufCur < OutBufEnd` compare, slow path only on overflow.

### 11. Arena-growth streams leak every intermediate buffer

**Location:** `stPut:68–77` — growth allocates a doubled buffer from the **arena** and abandons the old one (arena can't free). `ebuf` (8KB start, `7036`) and `tybuf` (16KB) reaching MBs leave every prior generation (8K+16K+32K+…+final) permanently live; `stNew(cg.arena, 96)` per mangled name (`764`) similarly fragments the arena.

**Why slow:** not just memory — the peak working set balloons (page faults, cache/TLB pressure) precisely while the emitter is in its hottest loop; doubles also mean each byte is memcpy'd ~2× even without the O(n²) issue.

**Fix:** scratch streams (`ebuf`, `tybuf`, per-call `abuf` at `3133/3240/3338`, `pbuf:4361`) should use a **heap buffer with real `realloc`**, or a chunked segment list that never copies (the stringvec_ostream pattern from LLVM PR #123353: append-only vector of fixed-capacity chunks, concatenated once at the end). Output streams (`bodies`, `protos`, …) are fine on the arena since they're written once — but pre-reserve (`stReserve`) from an estimated size to avoid doublings.

### 12. Per-call-site `stNew` scratch streams for arg lists / switch tests

**Location:** `3133` (Call args), `3240` (MethodCall args), `3338`, `3441/3489/3511`, `4174`, `4361` (switch patterns) — each allocates a fresh 64-byte arena Stream, grows it with doublings, never frees.

**Fix:** one reusable `abuf` on the `Codegen` struct with save/restore of `len` (a stack discipline, same as `stTrunc` already used for `body` at `4830`). Zero allocations in steady state.

---

## Summary ranking (expected impact on compile time)

| Rank | Bottleneck | Complexity class | One-line fix |
|---|---|---|---|
| 1 | `ebuf` re-append + no truncation (`2460`+) | O(output × depth), whole-TU growth | emit-into-target or mark/truncate after each copy |
| 2 | `intern()` linear scan (`context.crl:452`) | O(calls × strings) | hash the interner (helps all phases) |
| 3 | No `Ty→C-name` / `declId→mangled` cache (`tyStr:1725`, `cgMangleS:741`) | O(uses × decls × len) | memoize once per decl/type |
| 4 | Linear-scan registries + `cgIdent`/`cgIsCrtFn` chains (`1310`, `1844`, `1874`, `2177`) | O(n²) in decls/instances | u32-keyed hash/direct-index tables |
| 5 | Call-resolution instance scans + per-site heap alloc (`1424`, `1585`) | O(calls × instances) | instance index by (decl, valueKey); arena scratch |
| 6 | `tybuf` same re-append disease (`1725`) | O(types × depth) | cache + truncate |
| 7 | Loop cond double-emission (`4812`, `4862`) | 2× on loop-heavy code | pure query instead of probe-emit |
| 8 | 6–8 decl passes re-mangling (`5761–7016`), O(n²) extern dedup (`6886`) | O(passes × decls) | single record-building pass |
| 9 | Per-byte `stPut` + NUL per write (`65–112`) | ~3× constant | inline buffered char push |
| 10 | Arena-leaked stream doublings (`68–77`) | memory/fault churn | realloc scratch or chunked segments |

**The three patterns to carry into the new backend:** (1) single-pass, write-directly emission — never assemble text by re-appending child strings into a growing scratch buffer; (2) compute every name (mangled symbol, type spelling) exactly once per entity and store it — AST/IR nodes carry `Slice`/id handles thereafter; (3) every "table" is a hash or direct-index array keyed by interned `Str`/`Ty` ids — no linear scans, no per-node heap allocation in the emitter.

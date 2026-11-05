# `pub` is parsed but never enforced on imports (sema visibility hole)

## Summary

`pub` is parsed and stored on every declaration (flags bit 0 = isPub in
`compiler/coral-ast/decl.crl`), but sema never consults a declaration's
own `pub` flag when an import binds a symbol. Non-pub items are freely
importable across file boundaries — including through the flat merge the
compiler itself is built with. `pub` currently only means something in
one place: the re-export symbol list of a `pub mod x = import …`
declaration.

## Incident

`compiler/coral-ast/id.crl` declared `locFile`/`locLine`/`locCol`
without `pub`; six compiler modules imported them anyway
(`coral-backend/codegen.crl`, `coral-semantics/sema.crl`,
`coral-diagnostics/engine.crl`, `coral-lsp/server.crl`, and via the
`ast { id { … } }` form elsewhere) and the `--strict` self-build stayed
green. The working tree patches those three to `pub` with inline
comments recording the incident.

The fix also makes `makeLoc` (`id.crl:24`) `pub` (it was non-pub and
imported by `coral-lexer/base.crl:16` and `coral-parser/parser.crl:12`).

## Root cause

- Import binding for flat-merged files: `checkImportDecl`
  (`coral-semantics/decl.crl:~748`) — when the first path segment is not
  a bound module symbol, it takes the "sibling file import" branch and
  calls `bindImportSymbols` (`decl.crl:606`), which resolves each name in
  the merged scope and declares it in the importing file. No isPub check
  anywhere on that path.
- `moduleExportsContain` (`decl.crl:442`) — used by the
  "symbol not exported by module" diagnostics (`decl.crl:790,809`,
  `expr.crl:528,1371`) — only validates the symbol list of a
  `ModReexport` declaration and returns `true` for any other decl kind.
  The member's own `pub` flag is never read.
- Sema has no other site that inspects decl-level isPub (grep for
  `flags & 1` in `coral-semantics/` only hits import/param/symbol flags,
  not decl isPub).

## Why the compiler self-builds anyway

The builder flat-merges the whole compiler tree into one compile unit;
`import ast::id { … }` resolves via the sibling-file path above, which
skips export checks entirely. `--strict` is unrelated (it gates
unknown build-file fields, not visibility).

## Impact

- Language: module privacy is unenforceable; `pub` is decorative for
  free functions and types in multi-file projects, and `import(lib)`
  flat-merged std/lib internals marked non-pub are still importable by
  user code.
- Bootstrap hazard: enforcing the check breaks the compiler's own
  imports (`makeLoc` in lexer+parser today; sweep for others in the
  same change).

## Fix sketch

1. In `bindImportSymbols`: for each named symbol, read the resolved
   declaration; if its kind carries isPub (flags bit 0) and the flag is
   clear, report `SemaUnknownMember` — same code as the existing
   export diagnostics, message adjusted ("`X` is not `pub`" /
   "symbol not exported by module").
2. At the qualified-access call sites (`expr.crl:528,1371`), also
   consult the member decl's isPub, not just the mod re-export list.
3. Clean the tree first or simultaneously: `pub` on `makeLoc`, plus a
   sweep for other cross-module imports of non-pub items (e.g.
   `stPut`/`stP`/`stCh`/`stU64` in `codegen.crl` are non-pub but
   currently only used in-file).
4. Tests: two-file project importing a non-pub fn → error, pub → ok;
   `import(lib)` of a non-pub std symbol → error; `mod::member` access
   to a non-pub member → error; same-file use of non-pub → still fine.

## Fix applied (done)

Implemented per the sketch, with two additional bugs found and fixed
during the bootstrap sweep:

- `declIsPub` / `moduleMemberIsPub` helpers in `decl.crl`; non-pub
  rejection in `bindImportSymbols`; `moduleMemberIsPub` consulted at
  both qualified-access sites in `expr.crl`.
- **Parser bug (second root cause):** `parseTypedefDecl` and
  `parseDistinctDecl` hardcoded `.flags = 0`, discarding `pub` on
  `pub typedef` / `pub distinct`. Both now take `isPub` and store it
  (flags bit 0). This is why `Str`, `Ty`, `cchar`, `FileHandle`, `Dir`
  etc. all looked non-pub on the first enforcing build.
- **Loader bug (pre-existing, exposed by the sweep):** a bare entry
  filename (`coralc main.crl`, no directory separator) made `libDir`
  return null, so `libLoadSiblingImports` skipped loading siblings
  entirely — the sibling-import path in `checkImportDecl` then failed
  with `T0001 symbol not found`. `libLoadSiblingImports` now falls back
  to `.` (or `/` for a root path) when `libDir` is null.
- Tree cleaned: `pub` on `makeLoc`, `codeStr`, and `analyzeForCompile`;
  the enforcing compiler now self-builds clean.

### Verified

- Bare `coralc main.crl` importing a sibling's `pub` fn → builds, runs.
- Bare `coralc main.crl` importing a sibling's non-pub fn → `T0006
  symbol is not pub`.

# String literal convention — handoff

Status: requirement agreed; lexer support for `C"..."` ALREADY EXISTS (the
lexer lexes it). What remains is enforcement in the parser plus bringing the
library code into convention.

## Requirements (from the user)

1. Every string literal must be specified with its type.
2. C-style strings (nul-terminated, no length) use the `C"..."` literal form —
   the lexer already lexes it.
3. Any other string literal must have a length attached to it.
4. The compiler will be made to enforce all of this — enforcement lives in the
   parser; the library code is being brought into convention ahead of it.

## Rules for `str::fromCstr` (from the user)

- `str::fromCstr` is ONLY for runtime C-string VARIABLES — the result of a
  libc output (`getenv`, `argv[i]`, `strerror`, a `char*` field) where the
  length is unknown; it computes the len via `strlen`.
- String literals are str by default (len-carrying). Wrapping a literal —
  `str::fromCstr("lit")` or `str::fromCstr(C"lit")` — defeats the purpose;
  write the bare literal instead (`ent.equals("apos")`).
- `C"..."` stays only where the callee genuinely consumes a raw C string
  (printf/snprintf format arguments, libc prototypes taking `const cchar*`,
  file-mode/path arguments handed straight to C).

## Work items

### Compiler (deferred — out of scope for library agents, `compiler/` stays untouched)

- Parser: enforce the convention — `C"..."` is the C-string form (nul-terminated,
  no len); every other literal must carry its type and an attached length; reject
  untyped or len-less non-C literals. The lexer needs no new tokens.

### Library sweep (done as a first pass — see below)

- Areas: `lib/std/`, `lib/core/`, `lib/platform/`, `lib/wallvm/` (excluding
  directories owned by concurrent agents: `wallvm/passes/`, `wallvm/regalloc/`,
  `wallvm/rules/`, `wallvm/target/wasm/`).
- First pass completed: 125 clearly C-style sites across 27 files converted to
  `C"..."` (report: /tmp/opencode/string_literals_report.md — tmp, so re-derive
  from git history if lost; conversion = `C` prefix only, literal bodies
  unchanged).
- Left alone and still open: `_writeCSI` style `str` parameters, `println`
  format literals (len machinery reads `f.len`), `@compileError` /
  `@assertOut` builtins, 28 `asm volatile { "template" : ... }` blocks (IR
  stores these as `str` in irtypes — ambiguous), `pub str* NAME[] = { ... }`
  initializer arrays (user style, never fought), IR-domain string handling
  (`irOps` name tables, `irTypeStr`, `irPrinter`, `irParser` errors).
- Ambiguity policy stands: convert only clearly C-style sites; report the rest.

### Verification

- `python3 /tmp/opencode/check_crl.py <edited files>` (recreate the checker in
  tmp if wiped) must PASS after edits.
- Converted files will not parse until the parser enforcement lands — sequence
  parser work first or together.

## Open questions

- Exact spelling/shape of the type annotation and the attached length on
  non-C literals (TBD by the parser work).
- Whether pointer-array initializers (`pub str* NAME[] = { ... }`) count as
  C-style or len-style (they look C-ish; likely C, confirm with the user).
- The `asm volatile` template strings: C-style or len-style?

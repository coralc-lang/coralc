# PORTING_RULES — lib_old → lib, old syntax → new coral syntax

(These live in coral-docs/ because /tmp gets wiped between sessions.)

## §0 — never fight the user's content
The user's stylistic edits are authoritative. If a destination file already exists and
contains user content, do not rewrite it to your preference; keep their style (for
example `pub str* NAME[] = { ... }` array initializers, existing comment wording, naming
choices). Report discrepancies instead of "fixing" user style. Add a first-person comment
only where you made a genuine judgment call.

## §0.5 — scope (hard boundary)
- READ only: your assigned old sources, this file, coral-docs/check_crl.py, and the
  target trees lib/wallvm/, lib/std/, lib/core/, lib/platform/ (plus the repo's
  coral-docs/ for reference). NEVER read anything under compiler/ — other agents were
  caught snooping there. Also /home/cerie/Documents/Mu/IR.md when the task says so.
- WRITE only the destination files your prompt assigns. Never edit module tables
  (lib.crl files) or manifests unless the prompt says so. Never run compilers, builds,
  or git. Note: a second opencode instance may be working in this tree concurrently —
  re-read a file immediately before editing it, and never revert foreign content.

## §1 — faithful port
Port the logic exactly: same functions, same algorithm, same control flow, same
side effects, same comments (converted per §5). Do NOT fix suspected bugs — list them
in your report under "suspected bugs". Do NOT add guards, asserts, TODOs, fallbacks or
features that were not there. If something is ambiguous, port it as-is and flag it.

## §2 — syntax mapping
- Pointers: `->` for pointer receivers/fields; `.` for `self` and value locals.
- Null: `== null` / `!= null`; never bare truthiness on pointers; `!p` becomes `p == null`.
- Conditions must be bool: integer truthiness `if (v & m)` → `if ((v & m) != 0)`.
- Switch: `case A: ... break;` → `A => { ... },`; `default:` → `else =>`; drop switch
  `break`s (keep mid-case logic — a C fall-through becomes sequential statements or
  if/else); grouped labels become one `|` arm.
- Enum/constructor access: `::` (e.g. `IrOpcode::Store`, `CSEPass::new(ctx)`).
- Umbrella imports die: `mod wallvm = import(lib) wallvm;` → explicit
  `import(lib) wallvm::irtypes { ... }` + `import(lib) wallvm::irOps { ... }` with only
  the symbols actually referenced; `mod std = import(lib) std;` →
  `import(lib) std::mman { alloc, dealloc }` etc. (bare calls after import), dropped
  entirely when unused.
- `wallvm::ir_types::X` → `wallvm::irtypes`. Any `import file::X` cross-pass import →
  `import(lib) wallvm::passes::X { symbols }` (or `wallvm::domtree`, `wallvm::rules::
  asm_rules` where applicable).
- Strings in imports (`import "path";`) are stale — remove.
- `new` methods (user style rule): return a struct literal directly —
  `return (T) { .f = x, ... };` — never declare a local, assign fields, then
  return it. Keep the build-up form only when fields are conditionally assigned,
  later fields depend on earlier ones, or the ctor heap-allocates (report those).
- Keep `static` helpers, non-pub types, zero-init compound literals `(IrBlock) {}` when
  the old file had them (flag if you find no precedent).
- `float` → `f32`, `double` → `f64` if the dialect demands it; keep `__builtin_*` when
  no coral equivalent exists (flag it).

## §3 — imports procedure
1. Delete old umbrella `mod` lines.
2. Collect every referenced symbol from the old file's qualifiers.
3. Emit explicit import lines per §2 with symbol lists; verify each symbol is `pub`
   at its destination; drop unused imports.
4. Cross-pass: see §2 (`import(lib) wallvm::passes::X { ... }`).
5. Every kept import must be referenced at least once beyond the import line.

## §4 — no new guards
(see §1) no new null checks, bounds checks, assertions, or defensive rewrites beyond
what the syntax mapping forces (e.g. explicit `!= null` is a mapping, not a guard).

## §5 — comment style
- Prose colons → commas or em-dashes ("Pattern 1:" → "Pattern 1,").
- Sprinkle first-person where you made a judgment call; never restate the code the
  comment sits above; preserve old comments otherwise (even factually wrong ones —
  report them instead of editing).

## §6 — verification (before you report)
1. `python3 coral-docs/check_crl.py <your files>` (run from the repo root
   /home/cerie/Documents/coralc) must print PASS for each.
2. Stale-syntax greps over your files, comment-stripped: `mod X = import`,
   `import file::`, `import "`, `case `, `default:`, `wallvm::ir_types::`,
   `wallvm::irOps::`, `std::mman::`, `self->`, `strvuct` — zero code hits (loop
   `break;` is fine, English prose in comments is fine).
3. Pub coverage: every `pub` symbol in the old file exists in the new file; no `pub`
   added or dropped.
4. Report: files + line counts (old → new), checker output, import decisions, suspected
   bugs (with old line numbers), assumptions/judgment calls.

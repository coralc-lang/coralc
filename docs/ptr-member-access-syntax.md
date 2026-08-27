# Pointer Member Access: `*.` vs `->`

## Current Syntax

```coral
self->foo();    // pointer member access
self.foo();     // direct member access
```

## Proposed Alternative

```coral
self*.foo();    // pointer member access (asterisk-dot)
self.foo();     // direct member access (unchanged)
```

## Analysis

### Why `*.` is Clean

Both `->` and `*.` are **two-character sequences** that cannot be misinterpreted:

| Sequence | Could mean... | But actually means... |
|----------|---------------|----------------------|
| `->` | subtraction (`-`) then greater-than (`>`) | pointer member access |
| `*.` | multiply (`*`) then dot (`.`) | pointer member access |

**Why `->` can't be subtraction + greater-than:**
- `a->b` — the `-` has no left operand if we split. In `a - >b`, the `>` would be a unary prefix on `b`, but `>` is not a prefix operator.
- The lexer sees `->` as a single token. No ambiguity.

**Why `*.` can't be multiply + dot:**
- `a*.b` — the `*` has no right operand if we split. In `a * .b`, `.b` is not a valid expression (dot is postfix, not prefix).
- The lexer sees `*` then `.` — but `.` after `*` can only mean pointer member access.
- Even without a dedicated token: the parser can treat `* .` (star, dot) as a two-token pointer access operator.

### No Ambiguity in Any Position

```
expr *.ident    → always pointer member access (postfix position)
expr * expr     → multiply (binary)
*expr           → dereference (prefix)
```

In postfix position, `*` followed by `.` is unambiguous because:
1. `*` as multiply is binary — needs right operand
2. `*` as dereference is prefix — followed by expression, not `.`
3. `.` after `*` has no meaning other than pointer member access

### Lexer Implementation

**Option A: Single token `PTR_DOT`**
- Lexer emits `PTR_DOT` for `*.` (like `ARROW` for `->`)
- Parser treats `PTR_DOT` identically to `ARROW`
- Cleanest: token is context-free

**Option B: Two tokens, parser fusion**
- Lexer emits `STAR` + `DOT` separately
- Parser fuses them in postfix loop: `if (STAR + DOT) → EX_ARROW`
- No lexer change, but two-token lookahead

**Recommendation:** Option A — matches existing `ARROW` pattern, keeps tokenization simple.

### Semantic Impact

None. `EX_ARROW` already handles pointer dereference + member access in:
- Typecheck: resolves through pointer types
- Codegen: dereferences pointer before field access
- Backend: identical codegen to current `->`

### Changes Required

| Component | Change |
|-----------|--------|
| **Lexer** | Add `PTR_DOT` token kind; emit for `*.` sequence |
| **Token table** | Add `PTR_DOT` = some id |
| **Parser** | In postfix loop: treat `PTR_DOT` like `ARROW` → produce `EX_ARROW` |
| **AST** | No change (already has `EX_ARROW`) |
| **Typecheck** | No change |
| **Codegen** | No change |

### Comparison: Other Languages

| Language | Syntax | Notes |
|----------|--------|-------|
| C, C++, Rust | `->` | Current Coral |
| Zig | `.field` | Auto-dereferences Optional/Pointer |
| Python | `.attr` | References are transparent |
| Go | `.` | Pointers auto-dereferenced |
| Java, C# | `.` | No pointers (references) |

The `*.` syntax is **unique to Coral** — no major language uses it. This is a design choice, not a convention.

### Trade-offs

| Factor | `->` | `*. ` |
|--------|------|-------|
| Precedent | C, C++, Rust, Go | None (unique) |
| Typing ease | Shift+dot (2 keys) | Shift+8, dot (2 keys) |
| Visual clarity |箭头 metaphor (dereference) | Asterisk metaphor (dereference) |
| Lexer complexity | Single token `ARROW` | Single token `PTR_DOT` (same) |
| Ambiguity | None | None |

### Conclusion

The swap is **clean** — no lexer ambiguity, no parser ambiguity, no semantic changes. The only difference is syntactic preference.

`*.` emphasizes the dereference (`*`). `->` emphasizes the arrow (pointer to member).

Both are valid. The choice is purely stylistic.

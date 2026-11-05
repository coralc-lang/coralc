# Coral error explanations over LSP

**Status: proposal. Nothing implemented.**

`coralc --explain P0006` already prints the right thing:

```
P0006 — unexpected end of file

why:  input ended while a construct was still open.
fix:  close every '{', '(' and '['; the file is most likely truncated.
```

That output is text, and it is good. The work is to send **that same text**
over the wire so a user can click an error and read it, rather than inventing a
second structured format that can drift from the CLI.

---

## The one rule

**The LSP must call the same renderer the CLI uses.**

`--explain` already has a function that turns a code into that block. Both
`coralc --explain` and the LSP handler call it. There is no second
implementation, no JSON schema to keep in sync, and no way for the terminal and
the editor to disagree.

If a structured form is ever wanted, the renderer grows one behind the text —
never the reverse.

---

## 1. `coral/explain`

### Request

```jsonc
{"method": "coral/explain", "params": {"code": "P0006"}}
```

### Result

`MarkupContent`, reusing the CLI's exact rendering:

```jsonc
{"contents": {"kind": "markdown", "value":
  "**P0006** — unexpected end of file\n\nwhy:  input ended while a construct was still open.\nfix:  close every '{', '(' and '['; the file is most likely truncated."}}
```

- `kind` is `markdown` so the bold code renders; `plaintext` if the client
  advertised only `hover.contentFormat: ["plaintext"]`.
- The value is the CLI text with the terminal escape stripped. ANSI bold on the
  code becomes markdown bold.
- Empty string for a code the compiler does not know about, rather than an
  error — "no explanation" is a legitimate answer, not a failure.

### Errors

- Missing `params.code` → `-32602`.
- Unknown code → **empty result**, not an error.

---

## 2. Making it clickable

Three layers. Each is useful alone; together they cover every editor.

### 2a. `codeDescription` on the diagnostic — standard LSP

```jsonc
{"code": "P0006",
 "codeDescription": {"href": "coral://explain/P0006"}}
```

VS Code renders this as a clickable link in the Problems panel today, with no
client work. Zed supports `Diagnostic.codeDescription` — **verify before
relying on it**.

The scheme is opaque: `coral://explain/<code>`. No client resolves it to a file.
A client that does not know the scheme renders the diagnostic normally.

### 2b. A code action

```jsonc
{"title": "Explain P0006",
 "kind": "coral.diagnosis.explain",
 "diagnostics": [{…}],
 "data": {"code": "P0006"}}
```

- **No `edit`.** Informational only. An action with no edit still appears in
  the lightbulb menu; a client that tries to apply it gets a no-op.
- `data.code` is what the client passes back to `coral/explain`.

### 2c. The client asks and renders

```js
const { code } = action.data;
const info = await client.request('coral/explain', { code });
// info.contents.value  ->  side panel, quick pick, or scratch buffer
```

---

## 3. Hover, brought up to clangd / rust-analyzer

Not about clickable explanations — about hover being as structured as the
reference implementations.

### What they do

**clangd** keeps a struct (`HoverInfo`: `Name`, `Provider`, `Documentation`,
`Type`, `ReturnType`, `Parameters` with per-param type/name/default,
`TemplateParameters`, `Size`/`Offset`/`Align`) and renders it. A recent change
(llvm/llvm-project#152918) split the rendering into **own sections** — brief,
notes, warnings, then **parameter docs**, then **return docs** — because a wall
of prose was unreadable.

**rust-analyzer** returns `HoverResult { markup, actions }`: a fenced code
block with the signature, a bullet list stating the resolved `Value:`, the doc
comment as markdown, then **clickable actions**.

Common shape: **signature in a code block → resolved type stated explicitly →
where it came from → docs as markdown → per-parameter/return sections →
clickable links.** Both restructured toward sections rather than prose.

### Where Coral is

Today:

````markdown
```coral
// In Arr
T data[0]
```

Type: T[0]
Declared in std/x86_64/linux/collections/arr.crl:3
````

Signature, type and provenance are there. Missing are the last three items:
doc comment, per-parameter/return sections, and links.

### Target

````markdown
```coral
T at(usize i)
```

**In `Arr`** · `std/x86_64/linux/collections/arr.crl:11`

**Type** `T`

**Parameters**

| name | type | meaning |
| --- | --- | --- |
| `i` | `usize` | index into the backing array |

**Returns** `T`

Array element access. Returns `self.data[i]`.

[Full documentation](coral://doc/Arr.at)
````

| Addition | Effort |
| --- | --- |
| Doc comment as markdown | small |
| **Parameters** and **Returns** sections | medium |
| `In <Type>` as a section, not a `//` comment inside the code block | small |
| **Overrides** — trait methods and `extend` members satisfied | medium |
| Link to full docs | small |

Hover stays `Hover | null`. Start sending `range` so both editors can highlight
the token under the cursor.

---

## 3b. Doc comments — `///`

The other piece of "hover should feel like clangd": hovering an std item shows
the comment written above its declaration.

### Today: there is no doc-comment concept

Coral lexes `///` as an ordinary `//` comment. The tree-sitter grammar has no
`doc_comment` node, so a documentation comment and an incidental one are the
same token and the compiler cannot tell them apart.

That matters because **290 of 619 `.crl` files** already put a plain `//`
directly above a declaration — and some are commented-out code rather than
prose:

```coral
// // trait @drop { // drop trait impl.
// //     void drop(); // it be embeded in the compiler
// }
```

Treating plain `//` as documentation would surface that as an item's
description. Worse than showing nothing.

### Adopt `///`

Rust's marker, which clang also recognises. It separates intent from
commentary, and the convention is already unclaimed in Coral.

```coral
/// Adds two numbers.
///
/// Returns the sum, wrapping on overflow.
pub u32 add(u32 a, u32 b)
```

Rules:

- `///` opens a documentation comment; contiguous `///` lines form one block.
- A blank `///` line is a paragraph break.
- The block immediately preceding a declaration documents it.
- The text after `///` is markdown, as in Rust.
- `//!` at the top of a file would be module documentation, if that is wanted
  later. Not required now.

### Two changes

**1. Grammar.** Add a `doc_comment` node for `///`, ordered **before** the
plain `//` rule so it wins:

```js
doc_comment: $ => token(seq('///', /[^\n]*/)),
comment:     $ => token(choice(seq('//', /[^\n]*/),
                             seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/'))),
```

Contiguous lines can stay a single node — the server can split on the newlines
itself. Worth highlighting distinctly in `highlights.scm` so documentation is
visually distinguishable from chatter.

**2. Server.** Attach the block above a declaration to that declaration's
symbol record, and render it in hover after `Type:`.

> **Check first:** whether the lexer currently retains comments in the AST at
> all. If comments are dropped during analysis, attaching them is larger than
> it looks — they may not survive to the symbol table.

### Resulting hover

For `map.crl`, where the comment already exists and currently goes unread:

````markdown
```coral
Result<V, CollectionError> insert(K key, V value)
```

**In `Map`** · `std/x86_64/linux/collections/map.crl:55`

**Type** `Result<V, CollectionError>`

On `AllocFailed` the tree keeps its previous contents (no node is added).
````

This is the single highest-value hover improvement available: prose for
items across the std library, for a grammar change and an attachment.

## 4. Compiler requirements

**Error explanations**

1. `coral/explain` returns the output of the existing `--explain` renderer.
2. `codeDescription.href` on every diagnostic that has an explanation.
3. `textDocument/codeAction` for `coral.diagnosis.explain`.
4. **Both call sites share one renderer.** This is the requirement that matters
   most — it is what stops the CLI and the editor drifting apart.

**Doc comments** — see [§3b](#3b-doc-comments--)

5. Lex `///` as a distinct doc comment, not a plain `//`.
6. Attach the block above a declaration to that declaration's symbol record.
7. Render it in hover. *(Verify first whether comments survive analysis at
   all — if the lexer drops them this is larger than an attachment.)*

**Hover**

8. Add **Parameters** and **Returns** sections, per llvm/llvm-project#152918.
9. Send `range` with hover responses.

## 5. Client requirements

| Editor | Work |
| --- | --- |
| Both | Surface `codeDescription` (VS Code already does). |
| Both | Render `codeAction` with no `edit` without erroring. |
| VS Code | `CodeActionProvider` → `coral/explain` → side panel. |
| Zed | Same, via the agent panel. |

No settings change needed in either editor.

## 6. Non-goals

- **Auto-fixing.** Anything that rewrites source is `quickfix` with a real
  `WorkspaceEdit`, decided separately. `coral.diagnosis.explain` never edits.
- **A second structured format.** See "The one rule".
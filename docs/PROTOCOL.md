# Coral editor protocol

The contract between an editor and `coralc --serve`.

**Status: this document is normative.** Both extensions are implemented and
tested against it. `coralc --serve` is a work in progress; where it diverges,
the divergence is listed explicitly under [Current state](#current-state) so
the gap is visible rather than assumed.

---

## 1. Transport

**JSON-RPC 2.0 over stdio, with LSP base-protocol framing.**

Every message, in both directions, is preceded by a header block and then
exactly *N* bytes of UTF-8 JSON:

```
Content-Length: 143\r\n
Content-Type: application/vscode-jsonrpc; charset=utf-8\r\n
\r\n
{"jsonrpc":"2.0","id":1,"result":{…}}
```

Rules:

- `Content-Length` is **bytes**, not characters. A UTF-8 multibyte character
  counts as its encoded length.
- The header block ends with a **blank line** (`\r\n\r\n`). The server may omit
  `Content-Type`; clients must accept its absence.
- Messages are not newline-delimited. A `\n` inside a JSON string is escaped as
  `\n` and does not terminate a message.
- **No JSON-RPC batching.** LSP does not support it; clients and servers must
  not send arrays.
- **Stdout carries the protocol and nothing else.** No banners, no progress, no
  debug prints. Anything human-facing goes to **stderr**.

> **Correction.** Earlier revisions of this document specified one JSON object
> per line. That was wrong: the real `coralc --serve` already emits
> `Content-Length` framing. Both clients were fixed to match.

### Startup

```
editor → coralc --serve        (newline-framed argv; the flag, not a subcommand)
coralc → stdio                 (nothing may be written before initialize is answered)
```

---

## 2. Lifecycle

```
editor → {"jsonrpc":"2.0","id":1,"method":"initialize","params":{…}}
coralc → {"jsonrpc":"2.0","id":1,"result":{"capabilities":{…},"serverInfo":{…}}}
editor → {"jsonrpc":"2.0","method":"initialized","params":{}}
editor → {"jsonrpc":"2.0","method":"textDocument/didOpen","params":{…}}
coralc → {"jsonrpc":"2.0","method":"textDocument/publishDiagnostics","params":{…}}
        …
editor → {"jsonrpc":"2.0","id":2,"method":"shutdown","params":null}
coralc → {"jsonrpc":"2.0","id":2,"result":null}
editor → {"jsonrpc":"2.0","method":"exit","params":null}
coralc → process exits
```

Hard requirements, per LSP 3.18:

- `initialize` **must** carry `protocolVersion`, `processId`, `rootUri`, and
  `capabilities`. `rootUri` may be `null` (single-file session); the server
  then anchors analysis to the opened document's own directory — see
  [§3b Standalone files](#3b-standalone-files).
- Before responding to `initialize`, the server must not send any request or
  notification — with one exception: `window/showMessage`,
  `window/logMessage`, `window/showMessageRequest`, `telemetry/event`, and
  `$/progress` are permitted while `initialize` is in flight.
- A request received before `initialize` must be answered with error
  **`-32002` (ServerNotInitialized)**. Notifications received before it are
  dropped, except `exit`.
- `initialize` may be sent **only once**.
- The client must not send anything else until it has received the
  `InitializeResult`.
- `shutdown` is a **request**; `exit` is a **notification**.
- Exit code **0** if `shutdown` was received, **1** otherwise. On stdin EOF the
  server should exit cleanly.

### `initialize` — client → server

```jsonc
{
  "protocolVersion": "3.18",
  "processId": 4711,
  "rootUri": "file:///home/you/coralc",
  "workspaceFolders": null,
  "clientInfo": {"name": "coral-vscode"},
  "capabilities": {
    "textDocument": {
      "hover": {"contentFormat": ["markdown"]},
      "documentSymbol": {"hierarchicalDocumentSymbolSupport": false}
    }
  }
}
```

### `initialize` — server → client

```jsonc
{
  "capabilities": {
    "textDocumentSync": 1,
    "hoverProvider": true,
    "definitionProvider": true
  },
  "serverInfo": {"name": "coralc", "version": "0.1.0"}
}
```

`textDocumentSync: 1` means **Full**. Both extensions send full text and
neither implements incremental sync.

---

## 3. Locating the compiler

Resolution order, first hit wins. Both extensions implement this identically.

1. **Explicit setting** — `coral.languageServer.path` (VS Code) or
   `language_servers.coral.path` (Zed). Absolute or `~`-prefixed.
2. **`CORALC`** environment variable.
3. **`CORAL_HOME`** → `$CORAL_HOME/coralc[.exe]`.
4. **`coralc` on `PATH`**.
5. **Platform install roots:**

   | Platform | Paths |
   | --- | --- |
   | Linux | `~/.coral/bin/coralc`, `~/.local/bin/coralc`, `~/bin/coralc`, `/usr/local/bin/coralc`, `/usr/bin/coralc` |
   | macOS | `~/.coral/bin/coralc`, `~/bin/coralc`, `/opt/homebrew/bin/coralc`, `/usr/local/bin/coralc` |
   | Windows | `%USERPROFILE%\.coral\bin\coralc.exe`, `%LOCALAPPDATA%\coral\coralc.exe`, `%LOCALAPPDATA%\Programs\coral\coralc.exe` |

6. **Give up.** Log `no coralc found`; run no server. Highlighting is
   tree-sitter/TextMate only and keeps working.

A configured path that does not exist falls through to the next candidate rather
than failing outright. A candidate that exists but fails to spawn is a real
error and should be surfaced.

The launcher must invoke `coralc --serve`, never `coralc serve`.

### How each editor starts it

| Editor | Mechanism |
| --- | --- |
| VS Code | The extension spawns the binary itself on activation, probing for `coralc`. No configuration. |
| Zed | The extension's `language_server_command` resolves `coralc` via `worktree.which()` and passes `--serve`. No configuration. |

Neither editor asks the user to configure anything. A `settings.json`
contributor would fix one machine and would not ship.

### Library resolution is the compiler's problem

The editor never passes library paths, module maps, or `CORAL_HOME`. On Linux
the compiler owns `~/.coral/{lib,store,projects}` and the per-project
`.coral/{cache,modules.map,artifacts,graph.dot,metrics.json}`. Encoding any of
that in an editor breaks the moment the compiler changes its layout.

---

## 4. Document synchronisation

Full text, no incremental ranges. Coral files are small and the compiler parses
whole files anyway.

```jsonc
// textDocument/didOpen
{"textDocument":{"uri":"file:///p/x.crl","languageId":"coral","version":1,"text":"…"}}

// textDocument/didChange — one full-content change
{"textDocument":{"uri":"file:///p/x.crl","version":2},"contentChanges":[{"text":"…"}]}

// textDocument/didClose
{"textDocument":{"uri":"file:///p/x.crl"}}
```

`version` is monotonic per document. The editor may coalesce rapid edits and
send the latest text when the server goes quiet.

On `didClose` the server should clear that document's diagnostics.

---

## 5. Methods

Every method is optional. An absent capability means the editor hides the
affordance; it never surfaces an error.

| Method | Direction | Purpose |
| --- | --- | --- |
| `initialize` / `initialized` | both | Handshake |
| `shutdown` / `exit` | both | Teardown |
| `textDocument/didOpen` / `didChange` / `didClose` | editor → server | Sync |
| `textDocument/publishDiagnostics` | server → editor | Errors |
| `textDocument/hover` | editor → server | Type under cursor |
| `textDocument/completion` | editor → server | Completions |
| `textDocument/signatureHelp` | editor → server | Call arguments |
| `textDocument/documentSymbol` | editor → server | Outline |
| `textDocument/definition` / `typeDefinition` / `references` | editor → server | Navigation |
| `textDocument/documentHighlight` | editor → server | Occurrences |
| `textDocument/semanticTokens/full` | server → editor | Type-aware colour |
| `textDocument/inlayHint` | server → editor | Inferred types |
| `textDocument/codeAction` | server → editor | Quick fixes |
| `coral/attributes` | editor → server | Attributes inside `#[[…]]` |
| `coral/typeInfo` | editor → server | Node inspector |

The full list, with phasing and current implementation status, is
[§11 Capability matrix](#11-capability-matrix). The exact payloads for type
information are in [§9b](#9b-type-information).

## 6. `textDocument/publishDiagnostics` (server → editor)

```jsonc
{
  "method": "textDocument/publishDiagnostics",
  "params": {
    "uri": "file:///p/x.crl",
    "version": 2,
    "diagnostics": [
      {
        "range": {"start": {"line": 0, "character": 21},
                  "end":   {"line": 0, "character": 24}},
        "severity": 1,
        "code": "P0001",
        "source": "coral",
        "message": "expected '{', found 'u32'"
      }
    ]
  }
}
```

Rules:

- `severity` is LSP: **1** error, **2** warning, **3** information, **4** hint.
- `code` is the compiler's **stable error-code identifier** (`P0001`, `P0002`,
  `P0003`, …) so editors can key off identity rather than message text.
- `source` is `"coral"`.
- Lines and characters are **zero-based UTF-16 code units**, not bytes.
- The server must publish a **full set per document after every change**,
  including an **empty array** when a document becomes clean — an empty array
  is what clears the file in the editor. Silence is not "no errors".
- Parse failures are diagnostics too. They must not abort the rest of the file;
  recover and keep going so one syntax error does not cascade.

---

## 7. `textDocument/hover` (editor → server)

Request:

```jsonc
{"method":"textDocument/hover",
 "params":{"textDocument":{"uri":"file:///p/x.crl"},
           "position":{"line":4,"character":6}}}
```

Response — `Hover | null`:

```jsonc
{
  "contents": {"kind": "markdown", "value": "```coral\nT at(usize i)\n```\n\nArray element access."},
  "range": {"start": {"line": 4, "character": 5}, "end": {"line": 4, "character": 7}}
}
```

`null` is a valid answer meaning "nothing to say here". It must **not** be an
error, and the editor must not surface one.

---

## 8. `textDocument/documentSymbol` (editor → server)

Returns `DocumentSymbol[] | SymbolInformation[] | null`. The editor advertises
`hierarchicalDocumentSymbolSupport: false`, so `SymbolInformation[]` is the
expected shape.

```jsonc
[{"name": "at", "kind": 12,
  "detail": "T at(usize i)",
  "location": {"uri": "file:///p/x.crl",
               "range": {"start": {"line": 4, "character": 5},
                         "end":   {"line": 4, "character": 7}}}}]
```

| Coral | `SymbolKind` |
| --- | --- |
| `struct`, `union`, `extend`, `variant`, `enum` | 5 Class |
| `trait` | 11 Interface |
| functions, methods, constructors | 12 Function |
| fields, variant members | 8 Field |
| constants, locals | 13 Variable |

`detail` is the declaration as written **minus its body**. Because Coral is
type-first this is what makes an outline readable: `T at(usize i)`, not `at`.

---

## 9. Coral-specific methods

`coral/attributes` — every attribute understood at a position, so the editor
can complete inside `#[[…]]`:

```jsonc
{"result": [
  {"name": "no_drop_all", "doc": "disable auto-RAII for this file"},
  {"name": "packed",      "doc": "packed struct layout"},
  {"name": "generate",    "doc": "generate trait boilerplate",
                          "parameters": [{"name": "traits", "variadic": true}]}
]}
```

`coral/typeInfo` — the node under the cursor for the scopes/inspect
affordances:

```jsonc
{"result": {
  "kind": "method", "name": "at", "qualified": "Arr.at",
  "type": "fn(usize) -> T", "doc": "Array element access.", "attributes": []}}
```

---

## 9b. Type information

This is the core of what makes Coral pleasant to edit, and it is three
separate mechanisms. None of them work today.

### Hover — the type and signature under the cursor

`Hover | null`. `null` is valid; an unimplemented feature must be `-32601`
instead, otherwise editors will keep offering a hover that yields nothing.

```jsonc
{"contents": [
    {"language": "coral", "value": "fn at(usize i) -> T"},
    "
Array element access. Returns `self.data[i]`.
"
  ],
 "range": {"start": {"line": 4, "character": 5}, "end": {"line": 4, "character": 7}}}
```

Contents is `MarkupContent` or an array mixing `MarkedString` and markdown.
Both clients advertise `hover.contentFormat: ["markdown"]`.

### Semantic tokens — colour by meaning, not by syntax

Tree-sitter knows the *shape* of `T at(usize i)`; only the compiler knows `T`
is a type parameter and `i` is a parameter. Semantic tokens close that gap.
This is what makes types visually distinct from values.

```jsonc
// result: { "data": [ ... ] } — flat u32 array, 5 ints per token
{"data": [0, 0, 4, 2, 0, 5, 0, 2, 0, 5, 0, 5, 2, 0, 0]}
```

Token types and modifiers are declared in the server's initialize result:

```jsonc
"semanticTokensProvider": {
  "legend": {
    "tokenTypes": ["type", "parameter", "property", "function", "method",
                   "struct", "genericParameter", "keyword"],
    "tokenModifiers": ["declaration", "readonly"]
  },
  "full": true, "range": false
}
```

Encoding: `deltaLine`, `deltaStartChar`, `length`, `tokenType`, `tokenModifiers`
— all relative to the previous token, sorted, non-overlapping, never spanning
lines.

> **Correction.** An earlier revision said the editor never asks for semantic
> tokens, on the grounds that highlighting belongs to tree-sitter. That is right
> for *syntax* and wrong for *types*: tree-sitter cannot know that `T` is a type
> parameter. Zed supports `"semantic_tokens": "combined"` (LSP colours on top
> of tree-sitter) and `"full"`. VS Code enables this automatically when the
> server advertises the capability.

### Inlay hints — inferred types inline

```jsonc
{"label": ": T", "position": {"line": 8, "character": 20},
 "kind": 1, "paddingRight": true}
```

`kind` 1 is Type, 2 Parameter. Particularly valuable for `let`/`const`
bindings whose type is not written.

### Completion and signature help

`textDocument/completion` returns `CompletionItem[] | CompletionList | null`.
For Coral the trigger characters matter more than usual:

| Trigger | Completes |
| --- | --- |
| `.` | fields and methods on the receiver, narrowed to its type |
| `::` | module paths, types, associated constants |
| `#[[` | attributes, from `coral/attributes` |
| `` ` `` or identifier | declarations in scope |

```jsonc
{"label": "count", "kind": 2, "detail": "fn count() -> usize",
 "documentation": {"kind": "markdown", "value": "Number of elements."},
 "insertText": "count()", "sortText": "0000"}
```

`completionItem/resolve` fills in `documentation` lazily, so the initial
response stays small. Both clients advertise `completionItem.snippetSupport`
and `documentationFormat: markdown`.

`textDocument/signatureHelp` matters more for Coral than most languages
because declarations are type-first and the return type sits in the middle:

```jsonc
{"signatures": [{"label": "at(usize i) -> T",
                 "parameters": [{"label": "usize i"}, {"label": "-> T"}],
                 "activeParameter": 0}],
 "activeSignature": 0}
```

### Occurrences, navigation, quick fixes

- `textDocument/documentHighlight` — every other occurrence of the symbol
  under the cursor (`Read`/`Write`/`Text` document highlight kinds). Cheap, and
  the most visible quality-of-life win after hover.
- `textDocument/definition` returns `Location | Location[] | LocationLink[] | null`.
  Both clients advertise `definition.linkSupport`, which is preferred: it
  carries `originSelectionRange` so the editor can highlight the declaration
  site without a second round trip.
- `textDocument/typeDefinition` — for Coral this is often the more useful jump:
  from a `T` use to the `struct` or `variant` that defines it.
- `textDocument/codeAction` — quick fixes for diagnostics. Coral is a good fit
  because most diagnostics are mechanical (`P0002` array size, unused import).
  A fix is returned as a `WorkspaceEdit`; apply it with
  `workspace/applyEdit`, which both clients advertise support for.

## 9c. Messages the server must accept

Beyond document sync, a conforming server must tolerate these without erroring:

| Message | From | Handling |
| --- | --- | --- |
| `workspace/didChangeConfiguration` | client | Accept. Zed sends it immediately after `initialized`. Must not be treated as unknown. |
| `workspace/didChangeWorkspaceFolders` | client | Accept, optionally re-resolve libraries. |
| `workspace/didChangeWatchedFiles` | client | Accept; useful if std sources change on disk. |
| `$/setTrace`, `$/cancelRequest`, `$/progress` | both | Optional. Honour cancellation before expensive analysis. |

## 9d. Messages the server should send

Without these the compiler fails silently, which is exactly how `--serve`
behaved before `build.crlb` handling was fixed:

```jsonc
// surface a fatal configuration problem instead of exiting quietly
{"method": "window/showMessage",
 "params": {"type": 1, "message": "coralc: no build.crlb found in the project root"}}

// progress for whole-project analysis
{"method": "window/logMessage",
 "params": {"type": 3, "message": "indexed 412 files in 84 ms"}}
```

`type` is 1 Error, 2 Warning, 3 Info, 4 Log. These are permitted even while
`initialize` is in flight.

## 9e. Position encoding

LSP 3.17 added `general.positionEncodings`. The server should pick the first
encoding the client lists, defaulting to **UTF-16 code units**:

```jsonc
// client -> initialize
"capabilities": {"general": {"positionEncodings": ["utf-16", "utf-8"]}},
"positionEncoding": "utf-16"      // server -> initialize, echo the choice
```

`publishDiagnostics` positions must use the negotiated encoding. Coral source
is UTF-8 and may contain non-ASCII identifiers and string literals, so this
is a real off-by-N risk rather than a theoretical one. Both clients currently
advertise UTF-16 only.

## 10. Errors

| Code | Meaning | When |
| --- | --- | --- |
| `-32700` | ParseError | Malformed JSON on the wire |
| `-32600` | InvalidRequest | Valid JSON, invalid JSON-RPC shape |
| `-32601` | **MethodNotFound** | Unsupported method — **the normal "not implemented" answer** |
| `-32602` | InvalidParams | Bad params for a known method |
| `-32603` | InternalError | Server bug |
| `-32002` | ServerNotInitialized | Request before `initialize` |
| `-32800` | RequestCancelled | `$/cancelRequest` was honoured |

`-32601` is the single most important one: a server that does not implement a
method **must** answer with it rather than ignoring the request or crashing.
Both extensions treat `-32601` as "feature absent" and silently degrade.

---

## 11. Capability matrix

Phase 1 is the minimum that makes the editor feel alive. Phase 2 is what a
mature Coral server should grow into. Phases 3+ are optional refinements.

| Method | Purpose | Phase | Status in `coralc 0.1.0` |
| --- | --- | --- | --- |
| `textDocument/publishDiagnostics` | errors, warnings | 1 | works (empty set missing) |
| `textDocument/hover` | signature, type, docs | 1 | returns `null` |
| `textDocument/documentSymbol` | outline | 1 | `-32601` |
| `textDocument/definition` | go to declaration | 1 | `-32601` |
| `textDocument/completion` | member + path completion | 1 | `-32601` |
| `textDocument/signatureHelp` | call argument help | 1 | `-32601` |
| `textDocument/documentHighlight` | occurrence highlighting | 2 | `-32601` |
| `textDocument/semanticTokens/full` | type-aware colouring | 2 | `-32601` |
| `textDocument/inlayHint` | inferred types inline | 2 | `-32601` |
| `textDocument/references` | find uses | 2 | `-32601` |
| `textDocument/typeDefinition` | jump to a type | 2 | `-32601` |
| `textDocument/codeAction` | quick fixes | 2 | `-32601` |
| `textDocument/foldingRange` | fold bodies | 2 | `-32601` |
| `textDocument/rename` | rename safely | 3 | `-32601` |
| `workspace/symbol` | project-wide search | 3 | `-32601` |
| `textDocument/prepareCallHierarchy` | callers/callees | 3 | `-32601` |
| `textDocument/diagnostic` | pull diagnostics (3.17) | 3 | `-32601` |
| `workspace/diagnostic` | workspace pull (3.18) | 3 | `-32601` |
| `textDocument/selectionRange` | expand selection | 3 | `-32601` |
| `textDocument/codeLens`, `textDocument/formatting` | not wanted | — | `-32601` by design |

`textDocument/colorProvider`, `documentLink`, and `inlineValue` are
deliberately out of scope for Coral.

### Responding correctly

Any method not implemented must return **`-32601`**. That is how an editor
learns a feature is absent and hides the affordance. Silence is worse than
`-32601`: the editor waits for a response that never comes.

## 11b. Full method audit

Probed against `coralc 0.1.0` with all 51 standard requests plus 12
notifications. The server answered every one and stayed alive, returning
`-32601` for all 50 it does not implement. **Rejecting correctly is half the
job** — an editor hides the affordance rather than waiting forever.

### Build first — the server is not usable without these

| Method | Why it matters for Coral |
| --- | --- |
| `textDocument/publishDiagnostics` *(empty set)* | Only implemented method that works. Must send `[]` to clear. |
| `textDocument/hover` | Advertised but always `null`. |
| `textDocument/documentSymbol` | Outline is empty. `detail` carries the type-first signature. |
| `textDocument/definition` | Jump to declaration. |
| `textDocument/completion` + `completionItem/resolve` | The single biggest daily-use feature. |
| `textDocument/signatureHelp` | Type-first declarations put the return type mid-signature. |

### Build next — what makes it feel like a real language

| Method | Why |
| --- | --- |
| `textDocument/semanticTokens/full` (+ `/delta`, `/range`) | Only the compiler knows `T` is a type parameter. Needs `positionEncoding`. |
| `textDocument/documentHighlight` | Occurrence highlighting. Cheapest quality-of-life win. |
| `textDocument/typeDefinition` | From a `T` use to its `struct`/`variant`. Often the more useful jump. |
| `textDocument/references` | Shared resolution with definition and highlight. |
| `textDocument/codeAction` + `workspace/applyEdit` | Quick fixes; most Coral diagnostics are mechanical. |
| `textDocument/inlayHint` (+ `inlayHint/resolve`) | Inferred types on bindings. |
| `textDocument/foldingRange` | Struct and function bodies. |
| `textDocument/prepareTypeHierarchy`, `typeHierarchy/supertypes`, `typeHierarchy/subtypes` | **Coral-specific value**: `trait` and `extend` make a real type hierarchy. Cheap once resolution exists. |
| `workspace/executeCommand` | Needed to back code actions and any command the editor surfaces. |
| `window/workDoneProgress/create` + `$/progress` | Whole-project indexing takes real time; progress beats a frozen editor. |
| `languageStatus` (3.18) | Compiler status in the editor status bar — "indexing", "5 errors", "no build.crlb". |
| `window/showMessage` / `window/logMessage` | Report fatal setup problems instead of exiting silently. |

### Build if you want the full story

| Method | Why |
| --- | --- |
| `textDocument/declaration` | Distinct from `definition`: where a symbol is *declared* vs *defined*. Coral has both. |
| `textDocument/prepareRename` + `rename` | Safe rename with shadowing checks. |
| `textDocument/prepareCallHierarchy`, `callHierarchy/incomingCalls`, `outgoingCalls` | Callers/callees — valuable in a systems language. |
| `workspace/symbol` + `workspaceSymbol/resolve` | Project-wide symbol search. |
| `textDocument/diagnostic` + `workspace/diagnostic` | Pull diagnostics (3.17/3.18): versioned results, `relatedInformation`, workspace-wide. |
| `textDocument/selectionRange` | Expand selection structurally. |
| `workspace/willRenameFiles` | **Coral-specific value**: rename a file and fix `import` statements. |
| `textDocument/willSaveWaitUntil` | Compute edits before save. Pairs with `willSave`/`didSave`. |

### Notifications to accept

`workspace/didChangeConfiguration` (**Zed sends this unprompted**),
`workspace/didChangeWatchedFiles`, `workspace/didChangeWorkspaceFolders`,
`textDocument/willSave`, `textDocument/didSave`, `workspace/didCreateFiles`,
`workspace/didDeleteFiles`, `workspace/didRenameFiles`, `$/setTrace`,
`$/progress`.

All were sent during the audit and none crashed the server. They should be
tolerated silently even if ignored.

### Deliberately not built

| Method | Reason |
| --- | --- |
| `textDocument/formatting`, `rangeFormatting`, `onTypeFormatting` | Coral has no formatter. Return `-32601` permanently. |
| `textDocument/codeLens` (+ `resolve`) | Usually annotates test counts or references. Revisit only if Coral gains runnable tests. |
| `textDocument/documentColor`, `colorPresentation` | No colour literals in the language. |
| `textDocument/documentLink` (+ `resolve`) | No URLs in source. |
| `textDocument/inlineValue` | Debugger protocol, not a language server concern. |
| `textDocument/linkedEditingRange` | No delimiter pairs worth linking. |
| `notebookDocument/*` | Only if Coral notebooks exist. |
| `textDocument/implementation` | Meaningless without an inheritance model beyond traits, which `typeHierarchy` covers. |

## 12. Current state

Verified against `~/.coral/bin/coralc 0.1.0` (`coralc --help` advertises
`--serve  run the language server on stdio (LSP)`), including the coral-vscode
live handshake (`tools/test-live-server.js`, 9/9) and the compiler-side suite
(lifecycle, exit codes, UTF-16 columns, project report, cleared markers).

**Working:**

- `Content-Length` framing, exactly as specified above.
- `initialize` → `{textDocumentSync: 1, hoverProvider: true,
  definitionProvider: true}`; a request
  before `initialize` answers **`-32002`**; a second `initialize` answers
  `-32600`.
- Malformed JSON answers **`-32700`**; non-object messages `-32600`.
- `shutdown` / `exit` with the specified exit codes: **0** after `shutdown`,
  **1** without; stdin EOF exits cleanly.
- `textDocument/didOpen` / `didChange` / `didClose` (full text); `didClose`
  publishes an empty set, clearing the document's markers.
- `textDocument/publishDiagnostics` with `source: "coral"`, stable `P####` /
  `T####` codes, UTF-16 `character` offsets, and an **empty array** whenever a
  document becomes clean — silence is not "no errors".
- **Whole-project error report**: opening any file analyzes the build entry
  (`coral.crlb`) and publishes diagnostics for every file in the import
  closure, so errors in files the open buffer never imports appear too. Files
  that stop having records are cleared on the next report.
- `textDocument/hover` returns the markdown-typed declaration of the
  expression or symbol under the cursor, laid out like clangd/rust-analyzer
  cards: a `coral` code block with the declaration, then `Type:` and — for
  fields — `Declared in <file>:<line>`. Struct-field cards name the owner
  inside the block (`// In Point`), both for `p.x` and for `.x` in literals.
  Verified for structs, fields, locals, generics, `self`, `pub` functions,
  imports and libc — e.g. `self` → `Arr<T, N>*`, `data` → `T`,
  `val` → `T val`, `printf` → `i32 printf(const cchar* fmt, ? )`.
  Unknown-field diagnostics append follow-ups: `did you mean 'x'?` then
  `available fields: a, b`.
- `textDocument/definition` resolves; 32 of 64 identifier positions in
  `arr.crl`.
- `-32601` for unimplemented methods; `$/cancelRequest` accepted.

**Gaps to close:**

| Gap | Detail |
| --- | --- |
| **Methods absent from the symbol table** | Hover **and** definition return nothing for every member declaration — `at`, `count`, `ptr`, `constPtr`, `atPtr`, `isEmpty`, `set`, `front`, `back`, `fill`, `copyTo`, `copyFrom`, `new`. Fields, locals, types and free functions all resolve, so member declarations are evidently collected separately and never registered. **Highest-leverage fix remaining:** one table unblocks hover, definition, references, documentSymbol and rename. |
| No `documentSymbol` | `method not found`. Outline is empty. |
| No `references`, `completion`, `signatureHelp` | `method not found`. |
| No `semanticTokens`, `inlayHint`, `foldingRange` | `method not found`. Type info is hover-only, not visible in the buffer. |
| No `coral/attributes` / `coral/typeInfo` | `-32601`. |

### Two behaviours that look like bugs but are not

**Hover resolves by nearest-preceding-identifier.** A caret resting between two
symbols returns the earlier one, and whitespace or punctuation still resolves
to the previous symbol. Always check the reported position before concluding
that resolution is wrong.

**Advertised capabilities are not evidence.** `definitionProvider: true` was
advertised while the method still returned `null` everywhere. Verify per
position rather than trusting the initialize result.

### Verifying a capability

```sh
node /home/cerie/Documents/coral-vscode/tools/lsp-probe.js FILE --method textDocument/hover
node /home/cerie/Documents/coral-vscode/tools/lsp-probe.js FILE --method textDocument/definition
node /home/cerie/Documents/coral-vscode/tools/lsp-probe.js FILE --method textDocument/documentSymbol --json
node /home/cerie/Documents/coral-vscode/tools/lsp-probe.js --list
node /home/cerie/Documents/coral-vscode/tools/vscode-diagnostics.js FILE
python3 /home/cerie/Documents/coral-vscode/tools/lsp-diagnostics.py FILE
```

`lsp-probe.js` reports resolved positions and then the unresolved tokens, which
is how the method-table gap was identified. Run it after each server change.

Hover does not send the optional `range` field yet. Type spellings come from
the compiler's own type printer, so diagnostics and hover follow real
semantics rather than a parallel grammar — there is no separate parser to
drift.
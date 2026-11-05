# Editor ↔ compiler language server

**Status and wiring only. The protocol itself is specified in `PROTOCOL.md` —
that file is normative; this one is not.** Keeping them separate is deliberate:
the wire format changes rarely, the state of the integration changes often.

---

## What exists

| Piece | Location | State |
| --- | --- | --- |
| Protocol spec | `PROTOCOL.md` (both repos) | Normative |
| VS Code client | `coral-vscode/extension.js` | Done, 8 transport tests |
| Zed launcher | `coral-zed/zed/coral-lsp.sh` | Done, installed to `~/.local/bin/coral-lsp` |
| Compiler lookup | both | Done |
| Stand-in server | `coral-vscode/tools/fake-coralc.js` | Mirrors the real wire format |
| Build gating | `coral-zed/build.sh` | Fails on regression |

Highlighting is tree-sitter/TextMate only. **A missing or half-finished
compiler costs diagnostics and navigation, never colour.**

---

## The compiler

`coralc --serve` — a **flag**, not the `serve` subcommand. It exists in
`~/.coral/bin/coralc` and is advertised by `coralc --help`:

```
--serve    run the language server on stdio (LSP)
```

It speaks correct LSP base-protocol framing and handles the lifecycle, document
sync, and diagnostics — opening any file also triggers a **whole-project error
report**: the build entry is analyzed and every file in the import closure gets
its diagnostics, not just the open buffer. `hover` returns clangd/rust-analyzer-
shaped cards (declaration block, then `Type:` and `Declared in <file>:<line>`),
and unknown-field diagnostics suggest near misses and list the available fields;
`documentSymbol`, `references`, `completion`, and `semanticTokens` still answer
`-32601`. Full verified breakdown is the **Current state** section of
`PROTOCOL.md`.

---

## Wiring

### VS Code

No configuration needed. The extension activates on `.crl` and probes for the
compiler itself. Shows `$(search) coralc not found` when there is none.
*Coral: Set Up Language Server* jumps to the path setting; *Coral: Restart
Language Server* relaunches.

### Zed

**Nothing to configure.** The extension declares the language server itself
through `language_server_command`, so `coralc --serve` starts automatically for
anyone who installs it. There is deliberately no `settings.json` entry, because
that would only ever fix one machine.

## Registering the server in Zed (and why it is not settings.json)

Zed extensions declare language servers in `extension.toml`:

```toml
[language_servers.coral]
languages = ["Coral"]
```

and resolve the binary in `src/lib.rs`:

```rust
fn language_server_command(&mut self, _: &LanguageServerId, worktree: &Worktree)
    -> Result<Command, String> {
    worktree.which("coralc")
        .map(|c| Command { command: c, args: vec!["--serve".into()], ..Default::default() })
        .ok_or_else(|| "coralc not found on PATH".into())
}
```

It resolves `coralc` directly and only falls back to the `coral-lsp` launcher.
The launcher exists for the VS Code side and for environments where `coralc` is
not on `PATH`; users should not have to install it.

### Gotchas that cost real time

**`std::fs` does not work in the extension sandbox.** `Path::exists()` cannot be
used to probe for a binary. `worktree.which()` is the only filesystem access
available. Returning `Err` is silent — Zed logs nothing — so an extension that
fails to resolve looks exactly like one that was never declared.

**Zed caches manifests in `extensions/index.json`** and will not re-read
`extension.toml` for an already-installed extension. Installing by copying files
(rather than through Zed's installer) means nothing refreshes that cache, and a
newly added `[language_servers.*]` section is silently ignored. `build.sh` now
rewrites the cached manifest to match, because the alternative is an extension
that looks configured but never starts.

**User `settings.json` cannot register a custom language server.** The
top-level `language_servers` key is a `Vec<String>` of server *ids*, not a
registry. Two wrong shapes, both rejected outright — and because Zed refuses
the whole file, a mistake takes all settings with it:

| Attempted shape | Zed's response |
| --- | --- |
| `"language_servers": { "coral": { "source": { "custom": … } } }` | `invalid type: map, expected a sequence` |
| `"language_servers": [ { "name": "coral", "binary": {…} } ]` | `invalid type: map, expected a string` |

The error names a *type*, never the offending key, so both read as though
something else is broken.

### Why not a `[language_servers.coral]` entry in `extension.toml`?

Zed implements `language_server_command` in a compiled `extension.wasm`, which
needs the wasi-sdk — a ~100 MB download at extension build time. The whole
extension is deliberately build-free: the grammar is compiled locally to wasm
and shipped prebuilt. The settings route keeps that property, so both editors
install with no network access at all.

---

## Enabling type-aware features in Zed

Zed defaults `semantic_tokens` to `"off"`, so a compliant server's semantic
tokens are ignored until a user opts in. To see type-aware colouring:

```json
"languages": {
  "Coral": {
    "semantic_tokens": "combined"
  }
}
```

`combined` layers LSP colours over tree-sitter; `full` replaces them. Start
with `combined` so syntax highlighting stays intact while the server's type
information is still incomplete.

VS Code enables semantic tokens automatically as soon as the server advertises
`semanticTokensProvider`, with no user setting.

## Testing

```sh
node tools/test-client.js          # 8 checks — framing, JSON-RPC, diagnostics, -32601
node tools/test-find-compiler.js   # resolution order
node tools/fake-coralc.js --serve  # stand-in server
```

`build.sh` gates on all of them, plus a **live handshake against the real
`coralc` when one is present**, so a change in the compiler's wire format fails
the build instead of silently breaking the editors.

To exercise the whole path without the compiler:

```sh
CORALC=$PWD/tools/fake-coralc.js coral-lsp
```
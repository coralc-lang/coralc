# Coral editor extensions

Prebuilt editor support, packaged in this repository so the compiler
installers never need the extension source checkouts.

| Artifact | Purpose |
| --- | --- |
| `vscode/coral-<version>.vsix` | Side-loadable extension for VS Code, VSCodium, Cursor, Windsurf, Positron, Kiro and other VS Code forks. |
| `zed/coral-zed-<version>.tar.gz` | Prebuilt Zed extension: `extension.wasm`, tree-sitter grammar wasm, queries, manifest and index entry. |

## VS Code and forks: download only

The downloader saves the `.vsix` to your Downloads folder. It does **not**
install it, because the installer cannot know which fork you use.

```sh
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/download.sh | sh
```

```powershell
# Windows
irm https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/download.ps1 | iex
```

Then install it with your editor's own CLI:

```sh
code --install-extension ~/Downloads/coral-0.4.0.vsix
# or: codium, cursor, windsurf, positron, kiro --install-extension ...
```

Direct download:
<https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/coral-0.4.0.vsix>

## Zed: install

The Zed extension ships a prebuilt wasm module, so no Rust toolchain,
clang or tree-sitter installation is required. The script installs it into
Zed's extension directory and registers it in `index.json`.

```sh
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/zed/install.sh | sh
```

```powershell
# Windows
irm https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/zed/install.ps1 | iex
```

Restart Zed afterwards. Syntax highlighting works without a compiler; the
language server starts when `coralc` is on `PATH` (the compiler installer
adds it).

## Rebuilding the artifacts

Run from this repository with the source checkouts next to it:

```sh
extensions/package.sh
```

Override locations with `CORAL_VSCODE_DIR` and `CORAL_ZED_DIR`. The script
refuses to package a Zed artifact whose `extension.wasm` or grammar wasm is
missing or not a WebAssembly binary, and stamps the Zed manifest with the
extension checkout's current commit instead of a local `file://` URL.

# Coral

Coral is a compiled systems programming language. This repository contains the
compiler, the standard library, prebuilt C sources for bootstrapping, and
editor extensions.

## Install

The release sources in `dist/` build with only a C compiler and `make`; no
Coral compiler or Rust toolchain is needed.

### Linux / macOS

```sh
curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/install.sh | sh
```

The installer clones the repository, builds coralc, copies it and `lib/` into
`~/.coral`, and adds `~/.coral/bin` to your shell profile. Open a new terminal
afterwards.

Use a custom prefix:

```sh
sh install.sh --prefix "$HOME/.local"
```

### Windows

Requires Git, `make`, and `gcc` from
[w64devkit](https://github.com/skeeto/w64devkit) or mingw-w64 on `PATH`.

```powershell
irm https://raw.githubusercontent.com/coralc-lang/coralc/main/install.ps1 | iex
```

Installs to `%USERPROFILE%\.coral` and adds it to the user PATH. Existing
terminals and VS Code must be restarted to see the change.

### Build from source

```sh
make linux      # dist/coralc-linux-x86_64
make windows    # requires x86_64-w64-mingw32-gcc
make install    # install host build + lib into ~/.coral
```

`make package` (or `./package.sh`) regenerates `dist/coralc-{linux,windows}.c`
from a working coralc seed.

## Use

```sh
coralc init myproject
cd myproject
coralc build
coralc run

coralc file.crl       # compile one file
coralc --serve        # language server on stdio
coralc --help
```

## Editor extensions

Prebuilt support is committed under [`extensions/`](extensions/README.md).

### Zed — installs automatically

```sh
curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/zed/install.sh | sh
```

```powershell
irm https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/zed/install.ps1 | iex
```

The Zed package ships prebuilt wasm, so it needs no Rust, clang, or
tree-sitter. Restart Zed afterwards. The extension provides syntax
highlighting, outline, brackets and indentation, and starts `coralc --serve`
when `coralc` is on `PATH`.

### VS Code, VSCodium, Cursor, Windsurf, Positron, Kiro — download only

The downloader saves the `.vsix` to your Downloads folder. It does **not**
install it, because the script cannot know which VS Code fork you use.

```sh
curl -fsSL https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/download.sh | sh
```

```powershell
irm https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/download.ps1 | iex
```

Then install it with your editor's CLI:

```sh
code --install-extension ~/Downloads/coral-0.4.0.vsix
# codium, cursor, windsurf, positron, kiro also accept --install-extension
```

In any fork without a CLI, open the Extensions view, click the `...` menu, and
choose **Install from VSIX...**.

Or download directly:
<https://raw.githubusercontent.com/coralc-lang/coralc/main/extensions/vscode/coral-0.4.0.vsix>

## Repository layout

| Path | Contents |
| --- | --- |
| `compiler/` | Compiler sources and build configuration. |
| `lib/` | Standard library and platform support. |
| `dist/` | Prebuilt C sources used to bootstrap coralc. |
| `extensions/` | Packaged editor extensions and their install/download scripts. |
| `install.sh`, `install.ps1` | Web installers for coralc. |
| `Makefile` | Builds/installs coralc from `dist/`. |
| `package.sh` | Regenerates the C sources in `dist/`. |

## Development

Build the compiler from the Coral sources:

```sh
cd compiler
./build/coralc build --force --flag '{host=linux}'
```

Regenerate the packaged C sources after a compiler change:

```sh
./package.sh
```

Package editor extensions after changing the extension checkouts:

```sh
extensions/package.sh
```

See [`extensions/README.md`](extensions/README.md) for the extension layout and
override variables.

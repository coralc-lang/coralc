# Publishing the Coral Zed extension

Reviewed against the Zed extension publishing docs:

- [Prerequisites](https://zed.dev/docs/extensions/publishing/prerequisites)
- [License requirements](https://zed.dev/docs/extensions/publishing/license-requirements)
- [Publishing guide](https://zed.dev/docs/extensions/publishing/publishing-guide)
- [Updating an extension](https://zed.dev/docs/extensions/publishing/updating-and-maintenance)
- [FAQ](https://zed.dev/docs/extensions/publishing/faq)
- [Developing extensions](https://zed.dev/docs/extensions/developing-extensions)
- [Language extensions](https://zed.dev/docs/extensions/languages)
- [Capabilities](https://zed.dev/docs/extensions/capabilities)

Only the Rust extension code (`src/lib.rs`) is licensed; it is MIT. The
Coral compiler and standard library keep their own licenses.

## Status

| Requirement | Status |
| --- | --- |
| Public extension repository | **Action required**: `coralc-lang/coral-zed` is currently private. |
| Public grammar repository at a branch revision | Same repository; commit and push `tree-sitter-coral` first. |
| Accepted license at extension root | Done: `LICENSE` (MIT), also declared in `Cargo.toml`. |
| Extension ID `coral` | Done: unique in the registry, kebab-case, no `zed`/`extension`. |
| Version is SemVer and matches the registry entry | Done: `0.4.0` in both files. |
| Grammar declared for the language | Done. |
| Rust only because a language server is provided | Done: `Coral Language Server`. |
| Language server is not bundled | Done: the extension runs `coralc --serve` from the user's `PATH`. |
| No extra capabilities | Done: `capabilities = []`; only `worktree.which` is used. |
| Tested at the submitted submodule commit | Verified locally with Zed 1.24.3; repeat after pushing. |

## Grammar repository

The grammar source is at `tree-sitter-coral` in this repository, so there is one
source of truth. It is **not** at `grammars/coral`: Zed's extension builder uses
that path as the clone destination:

```
<extension>/grammars/coral          # builder clones the repo here
<extension>/grammars/coral.wasm     # builder writes the compiled grammar here
<extension>/tree-sitter-coral       # grammar source in the extension repo
```

The builder then appends `[grammars.coral].path`, which is
`tree-sitter-coral`, giving `<extension>/grammars/coral/tree-sitter-coral`.
The `rev` must be a commit containing `tree-sitter-coral/grammar.js` and
`tree-sitter-coral/src/parser.c`.

The registry rebuilds the parser from this source; the prebuilt
`extension.wasm`/`grammars/coral.wasm` are only for our manual installers.

## Prepare a release

1. Commit any grammar changes first. The manifest revision must contain them:

   ```sh
   cd ../coral-zed
   git add -A -- grammars/coral tree-sitter-coral
   git commit -m "move Coral grammar to tree-sitter-coral"
   cd ../coral
   ```

   The `-A` is required to stage both the new directory and the removal of
   the old `grammars/coral` files; otherwise the old directory remains in the
   commit and the builder still collides with it.

2. Stamp the grammar revision and rebuild the extension:

   ```sh
   extensions/zed/prepare-publish.sh --build
   ```

   This writes the current commit into `[grammars.coral].rev`, rebuilds
   `extension.wasm`, and regenerates the downloadable artifacts.

3. Commit and push the extension repository:

   ```sh
   cd ../coral-zed
   git add -A
   git status                    # target/ and extension.wasm stay ignored
   git commit -m "prepare Zed extension 0.4.0 for publishing"
   git push
   ```

4. Regenerate and commit the manual-install artifacts in coralc:

   ```sh
   cd ../coral
   git add extensions
   git commit -m "rebuild editor extension artifacts"
   git push
   ```

5. Make the repository public. The registry fetches it anonymously; private
   repositories fail.

6. Install the extension in Zed from the exact commit and check:

   - Coral files highlight, indent, outline and bracket-match.
   - `coralc --serve` starts when the compiler is on `PATH`.
   - The extension page shows the correct name, version and repository.

7. Open one PR to
   [`zed-industries/extensions`](https://github.com/zed-industries/extensions):

   ```sh
   git submodule add https://github.com/coralc-lang/coral-zed.git extensions/coral
   ```

   Add to `extensions.toml`:

   ```toml
   [coral]
   submodule = "extensions/coral"
   version = "0.4.0"
   ```

   Run `pnpm sort-extensions`, then open the PR. Use a fork in a personal
   account if possible, keep at most three PRs open, and respond to maintainer
   feedback within three weeks.

## Updates

For every release:

1. Update the grammar and commit it.
2. Bump the version in `extension.toml` and `Cargo.toml`.
3. Run `prepare-publish.sh --build` so `[grammars.coral].rev` points at the
   grammar commit.
4. Commit and push the new revision on `main`.
5. Rebuild and commit the artifacts in coralc.
6. Update the `coral` submodule and the version in `zed-industries/extensions`
   in a new PR.

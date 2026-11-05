# Builder is incomplete — flag (raised during the lib_old → lib port)

Status: **known gap.** The port writes sources in the target design; the
builder must catch up. Raised 2026-10-03.

## The design we are building to

- Platform segments (`x86_64`, `linux`, `windows`) must **never appear in
  import paths** in `.crl` sources. `memory::mman`, not
  `x86_64::linux::memory::mman`.
- A **build manifest** (`.crlb`) specifies which physical tree a neutral
  path resolves into; the builder/compiler selects the manifest from the
  target **flags**.
- **Manifests extend each other** (`extends` / `include`): one base std
  manifest, per-platform manifests on top.
- Platform split stays on disk (`lib/std/x86_64/linux/…`,
  `lib/std/x86_64/windows/…`): port **linux first**, then copy and
  surgically change for windows.

## What the parser already accepts

`compiler/coral-build/parser.crl` parses the full v2 `.crlb` grammar:
`schema`, `strict`, `build`, `workspace`, `profile`, `alias`, `task`,
`test`, `bench`, `hook`, `phase`, `target`, `link`, `artifact`,
`features`, `env`, `log`, `metrics`, `lint`, `format`, `lsp`, `ci`,
`remote`, `deps`, `override`, `include`, plus `extends "…"` on labeled
blocks and top-level decls (`hasExtends` / `extendsTarget` are stored on
the AST node).

## What the builder actually does

`compiler/coral-build/builder.crl` consumes **only**:

- `Build` nodes (its fields: root, entry, target, opt, output,
  module_map, cache_dir, flags, modules, skip),
- `Alias` nodes (with E1003 validation).

Everything else parsed is dropped on the floor:

1. **`include "…"` is never expanded.** Include nodes are built and
   ignored — an included manifest silently does nothing.
2. **`extends "…"` is never applied.** `extendsTarget` sits on the AST;
   there is no merge pass (child-wins map merge is not implemented).
3. **`target` is never consulted for resolution.** The field value
   (`native-x86_64`, `Wallvm`, …) is stored, then unused. There is no
   mechanism that routes a neutral import to a platform tree.
4. **Profiles, workspace, override, tasks, tests, hooks, phases, target
   blocks, link, artifact, features, env, log, metrics, lint, format,
   lsp, ci, remote, deps** — all parsed, none acted upon.

## What must land for the lib port to resolve

- `platform_root` (name TBD) on the std `build` block — the
  platform directory that neutral paths resolve under.
- **Resolution order** for a neutral re-export path (e.g.
  `pub mod mman = import memory::mman;` in `lib/std/lib.crl`):
  1. `<platform_root>/memory/mman.crl` (platform wins — lets a platform
     override any portable file),
  2. base tree `lib/std/memory/mman.crl` (portable fallback).
- `include` expansion (paths relative to the including file).
- `extends` merge for `build` blocks (child fields override base).
- Manifest selection from target flags — e.g. the consuming build picks
  `manifest.linux.crlb` vs `manifest.windows.crlb` when
  `target`/os flags say so.

Manifests are checked in under `lib/std/manifest.*.crlb` following that
shape, so the builder has concrete inputs to grow against.

## Stopgap in the tree today

- `lib/std/x86_64/linux/lib.crl` re-exports with **platform-relative**
  paths (`import memory::mman;`), which resolve without builder changes
  from within the platform directory.
- `lib/std/lib.crl` is the **design-correct neutral surface**; its
  `memory::*` entries will fail with E1004 until the resolution rules
  above land. That is expected — do not "fix" it by putting platform
  segments back into import paths.

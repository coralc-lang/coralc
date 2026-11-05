# Compiler defects found while porting the WebGPU API

Status: **D1 and D2 are known limitations, tracked and being resolved.
D3 is the one open question.** Re-tested against the compiler rebuilt
2026-10-08 22:36. Found while hand-porting the wgpu-native headers
(`webgpu.h` + `wgpu.h`) into a Coral extern module at
`Mu_engine/src/webgpu/`. Reported against the `coralc` binary installed at
`/home/cerie/.coral/coralc`.

Two of the three are already-known gaps that this report only
characterises from the outside — see [builder_incomplete.md](builder_incomplete.md)
for the build-system one and the max-file limit for the driver one. The
report exists to record what a porter hits, not to propose root-cause
analysis of known work.

For D1 specifically: semantic checking is **not** broken. Duplicate
declarations are reported correctly (`TC-0004`), and the only problem is
that files over the max-file limit never reach the semantic stage, so their
semantic errors go unreported. Duplicate detection must not be filed as a
defect.

| ID | Area | Symptom | Status |
|----|------|---------|--------|
| D1 | driver | Max source-file limit halts error reporting (semantic stage never runs) | **known** |
| D2 | build driver | `coralc build` compiles nothing, exits 0 | **known** |
| D3 | parser | `import(lib) a::b { c::d }` rejected | **open** |

## Context

**Where this was found.** While hand-porting the wgpu-native C headers into
a Coral extern API module — the same kind of work as the existing `stb`,
`sdl`, `gl`, `physics`, and `cgltf` ports in `Mu_engine/src/`. The
workstream is exploratory, so these defects surfaced before any code
depended on them.

**Working directory:** `/home/cerie/Documents/Mu`

**Compiler under test:** `/home/cerie/.coral/coralc`, installed from
`/home/cerie/Documents/coralc`. No version flag is available
(`coralc --version` is rejected with `DRV-0002`), so the build cannot be
identified from the binary itself; findings are pinned by timestamp and
size instead:

| | first report | after rebuild |
|---|---|---|
| mtime | 2026-10-08 22:12 | 2026-10-08 22:36 |
| size | 482,400 B | 482,472 B |

**Test subject:** the WebGPU module, two files:

| File | Lines | Bytes |
|------|-------|-------|
| `Mu_engine/src/webgpu/webgpu.crl` | 2,130 | 91,788 |
| `Mu_engine/src/webgpu/lib.crl` | 1 | 32 |

`lib.crl` is the one-line module re-export
(`pub mod webgpu = import webgpu;`) required by the repo convention of one
`<name>.crl` plus a one-line `lib.crl` per module. The test file is
`webgpu.crl`: 655 constants, 228 `extern` function declarations (202 from
`webgpu.h`, 26 native from `wgpu.h`), 114 structs, 70 enum typedefs, 8
flag-set typedefs, 23 opaque handle typedefs, and 12 function-pointer
typedefs. The 91,788-byte size is what makes it a useful test subject: it
exceeds the current max-file limit by a wide margin.

**Project build file:** `Mu_engine/coral.crlb` (schema 2, `strict = true`,
18 modules), used as the test project for D2.

**Scope note.** The compiler is not otherwise usable from this project at
the time of writing: the `jolt` build phase that produces
`libmualibs.a` / `libJoltC.a` / `libJolt.a` does not run, and none of
those archives exist, so D2 cannot be exercised through a full link until
that is addressed. Single-file compiles (`coralc <file.crl> --dry-run`)
work and are what the reproductions below use.

### Re-test log — compiler rebuilt 2026-10-08 22:36

Re-ran every reproduction against the rebuilt binary (482,400 B → 482,472 B).
All three reproduce unchanged.

| Check | Expected | Result |
|-------|----------|--------|
| D1 `compiler/coral-test/type.crl` (90 B) duplicate typedef | `TC-0004` | `TC-0004` — correct; under the limit, sema runs |
| D1 `webgpu.crl` (91,788 B) | compile + full diagnostics | `PAR-0006` at **1636:53**; sema stage never reached |
| D2 `coralc build` in `Mu_engine` | compile + artifacts | 18 modules `stale`, exit 0, no `build/muengine` |
| D2 `--force` | differ from default | identical output |
| D2 `.coral/graph` | dependency edges | header comment only, no edges |
| D2 `.coral/cache` | created per `cache_dir` | absent |
| D3 `import(lib) std::io { ios::println }` | parses | `PAR-0001 expected '}', found '::'` |

The D1 failure position is unchanged to the exact column, confirming the
limit is still in force and was not moved by the rebuild.

### Why only parse errors were reported (not undeclared names)

`coralc` uses **queue-based passes**: a work queue feeds each stage, so
circular imports resolve without infinite loops and dependency ordering is
settled by the queue rather than by file order. Exceeding the file limit
halts that pipeline before the semantic-entity stage, which is why
reporting stops at parse:

- parse errors (`PAR-0006` on the truncated construct) are reported,
- undeclared-name / undeclared-symbol errors (`TC-0001` and friends) are
  **not**, because the stage that populates entities never ran.

So a file over the limit shows a parse symptom and suppresses the semantic
diagnostics that would otherwise explain it. Do not read the absence of
`TC-` errors as "the remainder of the file is clean" — it means the limit
was hit before sema could look.

`-ferror-limit=0` was tried on `webgpu.crl` and changed nothing (still
`errors=5 (parse=4 sema=1 mono=0)`): the error limit is not what stopped
reporting, the missing semantic stage is.

### Note on the D3 control

The flat-form control (`std::text::string { String }`) parses its import
correctly but then fails with 52 × `TC-0003 wrong number of generic
arguments` and 1 × `TC-0001`. That is an artefact of the minimal test file
having no entry point, not a new defect — recorded here so it is not
mistaken for one later.

---

## D1 — max source-file limit halts error reporting (known)

**Status:** known limitation, tracked, will be resolved
**Component:** driver — max-file limit

**The only issue is the file limit.** Semantic checking is fine: a
duplicate declaration is detected and reported correctly. What breaks is
the *reporting* for files above the limit, and it breaks as a direct
consequence of the limit — not as a separate defect.

### Mechanism

`coralc` runs as a queue-based pipeline: parse feeds sema, and sema is what
populates semantic entities. When a file exceeds the max-file limit, the
input is cut short and the compile never reaches the semantic-entity
stage. Reporting therefore stops at whatever parse had already queued:

- **above the limit** — parse errors only; undeclared-name and other
  semantic errors are never reported, because the stage that would emit
  them never runs;
- **below the limit** — full reporting, parse and semantic alike.

This is the asymmetry to keep in mind: the absence of `TC-` errors in a
large file is **not** evidence that the unreported remainder is clean. It
only means the limit was hit first.

### Control: reporting below the limit is correct

`compiler/coral-test/type.crl` — 5 lines, two typedefs, `foo` declared
twice:

```coral
pub typedef foo = u8;
pub typedef foo = u16;

pub typedef moo = i8;
pub typedef hoo = i8;
```

Actual, and correct:

```
error[TC-0004]: duplicate declaration of this name
  ┌─► compiler/coral-test/type.crl:2:22
  │
  │  1 │ pub typedef foo = u8;
  │  2 │ pub typedef foo = u16;
  |                           ▲
  │                           ╰─ rename one of the duplicate declarations
  │                           ╰─ try `coralc --explain TC-0004` for more information
coral: compile failed, errors=1 (parse=0 sema=1 mono=0)
```

So duplicate detection is **not** a bug and should not be filed as one.
This file exists only as the below-the-limit control for D1.

### Reporting asymmetry in practice

Same kind of content, one file under the limit and one over it:

| File | Size | Result |
|------|------|--------|
| `compiler/coral-test/type.crl` | 90 B | `TC-0004` reported — sema ran |
| `Mu_engine/src/webgpu/webgpu.crl` | 91,788 B | `parse=4 sema=1 mono=0` — sema never ran |

On the oversized file, the single `sema=1` (`TC-0001 unknown type name:
WGPURend`) is a *consequence* of the truncated parse, not an independent
semantic finding. Running with `-ferror-limit=0` changes nothing — still
`parse=4 sema=1 mono=0` — so the error limit is not what halts reporting;
the missing semantic stage is.

### Observed limit position

- The cutoff sits at byte 65,536, which in `webgpu.crl` falls at line
  1636, column 53, mid-identifier.
- The reported position varies with file contents only through where that
  byte lands — it always falls on whichever construct straddles the limit.
- Comment-only files past the limit do not always trip it, so the limit is
  not simply "first N bytes of the file".

### Misleading diagnostic

Because reporting stops at parse, a file rejected for being too large
shows a parse symptom that names the wrong cause:

```
error[PAR-0006]: unexpected end of file
  ┌─► src/webgpu/webgpu.crl:1636:53
  │
  │ 1636 │ pub extern void wgpuRenderBundleEncoderDraw(WGPURend
    |                                                            ▲
    |                                                            ╰─ the file ended before this construct was closed
```

The message blames EOF and never mentions the file limit, so a porter ends
up hunting a missing brace in a file that is fine. An explicit "file
exceeds max size" diagnostic would keep the symptom from being
misattributed.

### Impact on the WebGPU port

`webgpu.crl` is 91,788 bytes. Everything past the limit — roughly the last
475 lines, including the whole `wgpu.h` native-extension section and its
26 function declarations — is invisible to the parser. Until the limit is
resolved, that file cannot be compiled as a single unit, so the port cannot
be verified against the compiler at all.

This is a size problem, not a correctness problem: the declarations below
the cutoff are fine, and the static header conformance check passes
independently of the compiler.

---

## D2 — `coralc build` compiles nothing and exits 0

**Status:** known limitation — the build system is not complete yet
**Component:** build driver (`coralc build`)

The build system is a known incomplete area (see also
[builder_incomplete.md](builder_incomplete.md), which records that `.crlb`
fields are parsed but not acted upon). This entry records only the
end-to-end symptom from the command line; it is not a new finding, and the
fix is part of completing the build system rather than the compiler.

`coralc build` writes `modules.map`, reports every module as `stale`, and
exits 0. No compilation, no codegen, no link output.

```
$ cd Mu_engine && coralc build
modules.map written (18 modules, 0 aliases)
engine  stale
math  stale
...
webgpu  stale
...
$ echo $?
0
```

### Reproduction

Any project with a `coral.crlb`. `Mu_engine` is a ready-made case.

### Observations

- `--dry-run` behaves identically, i.e. nothing is compiled even when
  compilation is explicitly requested.
- `--force` also behaves identically, which is self-contradictory:
  `--force` is supposed to bypass staleness checks, yet the same "stale"
  verdict appears with and without it.
- `.coral/graph` and `.coral/graph.dot` are written but contain no edges.
- `.coral/cache` is never created, despite `cache_dir = ".coral/cache"`
  being set in the build file.

The driver therefore completes module discovery and then stops before the
compile phase. Because no diagnostic is emitted, a total no-op is
indistinguishable from a successful build.

### Related: build phases do not run

The `jolt` phase in `coral.crlb` is supposed to drive cmake and produce
`build/native/libmualibs.a`, `build/native/joltc/libJoltC.a` and
`libJolt.a`. It does not run, and none of those archives exist. Linking
could not succeed even once D2 is resolved.

This falls under the same known builder gap recorded in
[builder_incomplete.md](builder_incomplete.md), where `.crlb` fields
(`phases`, `deps`, `link`, `target`, …) are parsed but not acted upon.
D2 is that gap seen end-to-end from the command line, so it is already
tracked; no separate root-cause work is implied here.

### Suggested first steps

- Exit non-zero, or at minimum print a clear "nothing to do / driver did
  not reach compile phase" line, when the build produces no artifacts. A
  no-op must not be reportable as success.
- Make `--force` observably differ from the default path, or drop it until
  it does something.

---

## D3 — import form `import(lib) a::b { c::d }` is rejected

**Status:** open
**Component:** parser

The symbol-list import form with a nested path is not accepted:

```coral
import(lib) std::io { ios::println };
```

Actual:

```
error[PAR-0001]: expected '}', found '::'
error[PAR-0004]: unexpected closing token
coral: cannot resolve import(lib) std::io
```

The parser wants `}` immediately after the path and cannot accept
`ios::println` as a symbol inside the braces.

### Reproduction

This is not synthetic — it is the exact line used by the existing engine
entry point, `Mu_engine/src/engine/main.crl:4`, which currently fails to
parse. `grammar.md` documents `A { syms }` as valid, so either the parser
has a gap or the installed binary is out of step with the sources.

### Notes

- The std tree itself uses the flat form and works:
  `import(lib) std::text::string { String };` and
  `import ios { println, eprintln };`
  (see `lib/std/x86_64/linux/io/log.crl:2`).
- Passing a manifest explicitly (`-f lib/std/manifest.linux.crlb`) does
  not change the outcome, so this is a parser gap and not a
  manifest-resolution failure.

### Version-skew note

`coralc --version` is not a recognised flag, so there is no way to ask the
binary what it is. Given that the repo's own engine entry point does not
parse, verifying the installed build against these sources is worth doing
explicitly.

---

## Verification status of the WebGPU port

Independently of the three items above, the port was verified **statically
against the headers only**:

```
structs checked: 114, fns checked: 228 — RESULT: ALL-MATCH
```

That is conformance of declarations to the C ABI (field-for-field and
parameter-for-parameter after type mapping). It is **not** a compile: the
compiler has never accepted this code, because the file exceeds the
max-file limit (D1). Treat the port as unverified by the toolchain until
D1 and D2 are resolved.

---

## Reproducing all three

D1 is a *reporting* asymmetry, so the reproduction must contrast the same
kind of content above and below the limit. Run from the `coralc/` repo
root.

```sh
# D1a — under the limit: semantic errors ARE reported (duplicate typedef)
printf 'pub typedef foo = u8;\npub typedef foo = u16;\n' > /tmp/d1a.crl
coralc /tmp/d1a.crl --dry-run        # expect: TC-0004, parse=0 sema=1

# D1b — over the limit: parse errors only, sema stage never reached
cd ../Mu
coralc src/webgpu/webgpu.crl --dry-run
# actual: PAR-0006 at 1636:53; errors=5 (parse=4 sema=1 mono=0)
# the file is 91,788 B, over the 65,536 limit

# D2 — build driver
cd ./Mu_engine && coralc build; echo "exit=$?"   # exit=0, no artifacts

# D3 — nested symbol import
printf 'import(lib) std::io { ios::println };\nfn t() { }\n' > /tmp/d3.crl
coralc /tmp/d3.crl --dry-run        # expect: ok; actual: PAR-0001
```
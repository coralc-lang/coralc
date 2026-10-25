# Add a wallvm backend to the coral compiler — phased roadmap

## Confirmed decisions

- **`--wallvm` simple switch** (no `--backend` value; no LLVM, no extra backends planned for now). C stays default while wallvm matures; C gets stripped later.
- **No artifacts on disk by default.** Fully in-memory: AST → wallvm IR → passes/regalloc → asm text → piped to gcc (`-x assembler -`) for assemble+link.
- **`--emit-asm`** keeps `<out>.s`; **`--emit-ir`** writes IR text — inspection/debug only, never part of the normal path.
- **HIR stays dead** — `compiler/coral-ir/` is the home of the new backend, not a resurrection of hir.
- Wallvm docs are partly stale; verify every gap against code before fixing. Upper pipeline especially.
- Roadmap is long: wiring → correctness → parity → pipeline quality → x86/gcc-level → wasm → target split → further backends (ARM last).

## Current state (review findings)

- Compiler path today: `analyzeForCompile` (`coral-semantics/analyze.crl:1393`) → `CompileUnit` → `generateC` (`coral-backend/codegen.crl:7548`, single 7672-line file) → C text → `runGcc` (`coral-frontend/compile.crl:37`) pipes to `gcc -x c -` stdin. Both call sites of `compileUnitTo`: `compile.crl:309` (single file), `coralc.crl:322` (build).
- `compiler/coral-ir/` exists, already registered in `compiler/coral.crlb` (modules + `alias ir`), `lib.crl` empty (hir stripped; dangling import already removed in working tree).
- Wallvm entry: `lib/wallvm/lib.crl` (module surface) and facade `lib/wallvm/wallvm.crl` — `irCompileAsm` (545): opt levels 0–3 → structure lane (incl. `irLowerPhis`) → LSRA/graph regalloc → `irCodegen` dispatch (595) → asm `str`. `irCompile` (488) same without text.
- Wallvm IR: `lib/wallvm/base/irtypes.crl` (interned types, `createFunc/createModule/createInst`, use-lists), `irOps.crl` (~100 opcodes), `irBuilder.crl` (exists, unused anywhere — ideal API for our lowering: `pos()` + helpers keep use-lists/CFG correct), `text/irPrinter.crl` (`printModule` → `--emit-ir`), `passes/validate.crl` (`IrValidator` = hard gate; `irPassValidate` never fails a compile).
- Consumer precedent: `test/wallvm/irtool.crl` (`irCtxCreate` → `irCompileAsm(.., SystemV, opt)` → `.s`) and `test/wallvm/run.sh` (plain `gcc` assemble+link, 64/64 baseline).
- Lib resolution: `import(lib)` roots `<dir(entry)>/../../lib` then `./lib` (`analyze.crl:99`) → repo `lib/wallvm` for compiler self-build; wallvm inlines into coralc's generated C (≈56k lines — acceptable, C default still builds).
- Coral inline asm is end-to-end today: `coral-lexer/table.crl:106`, `coral-parser/stmt.crl:581` (GCC extended), `codegen.crl:5659` (emission), std intrinsics (`lib/std/x86_64/linux/intrinsics/memory.crl:60`).

### Known wallvm gaps relevant to this roadmap (verify in code — docs stale)

- **Frame layout ignores the pushed callee-saves (correctness — blocks
  call-heavy tests).** `allocaSlotOf`
  (`lib/wallvm/target/x86_64/x86_64_base.crl:700-720`) returns
  `*outOff = self.allocaBase + cum`, an offset measured from `%rbp`.
  But the prologue pushes the callee-saves *above* the reservation
  (`emitPrologue` ~`:1017-1060`: `pushq %rbx/%r12/…` land at
  `rbp-8..rbp-8k`, then `subq $spillFrameBytes`), and
  `allocaBase = spillSlotCount*16 + pad` (`:1051`) counts only spills +
  alignment pad — never `8 * numCalleeSaves`. So with k saves pushed
  every alloca (and lsra's synthetic spill allocas) sits k*8 bytes too
  high: **on top of the saved registers**.
  Repro: `i32 fib(i32 n) { if (n < 2) return n; return fib(n-1)+fib(n-2); }`
  with `main { return fib(10); }` — prologue emits
  `pushq %rbx/%r12/%r13` then `leaq -24(%rbp), %rbx; movl %esi, (%rbx)`,
  which clobbers the saved `%r13`; the caller keeps its first call's
  result in `%r13`, so after the second call returns it holds the
  callee's `n` instead. Measured against the C backend: fib(2)=0 (want 1),
  fib(4)=2 (want 3), fib(6)=6 (want 8), fib(10)=20 (want 55).
  The printed IR for the same program is correct — purely a frame-layout
  bug. Fix sketch: `*outOff = 8 * self.numCalleeSaves + self.allocaBase + cum`
  (keeping the epilogue's `addq`/pop order and the 16-byte call alignment
  that `pad` guarantees), or fold the pushes into the reservation itself.
  **Reported, not fixed** — deliberately deferred so coral's IR codegen
  lands first; runtime results of any function that both has locals and
  uses callee-saves are untrustworthy until then.
- **Spill quality bar: clang/gcc at -O2, not naive slots.** The current
  scheme is one 16-byte slot per vreg with no packing, coalescing,
  splitting or rematerialisation, and only `xmm2–xmm7` allocatable
  (`docs/codegen-quality.md`, `next-todos.md` paused #3). Whenever the
  frame-layout item above is fixed, spills must move to real O2-quality
  machinery — callee-save use, interval splitting, remat of cheap
  constants, packed slots — rather than papering over the layout with
  more naive slots.

- **Extern lib name is discarded today.** `extern("libname") T name(args);` —
  the parser (`coral-parser/decl.crl:403-409`) accepts the string literal
  but throws it away (`self.expect(TokenKind::String)`); the AST's
  `DeclKind::Func` payload has no lib-name field, only the isExtern flag
  (bit 1). The C backend links everything against libc. For wallvm, the
  lib name must be honoured: `IrFunc.isExtern` + `externLib`/`externSym`
  (see `lib/wallvm/ffi/extern.crl ExternLib`/`FfiCtx`) drive per-symbol
  linker directives (`-l<lib>`). This needs (a) an AST field to carry the
  lib name, (b) lowering into wallvm's FfiCtx, (c) `runGcc` passing the
  collected `-l` flags. Phase 3+ concern.
- **Struct layout attributes are parsed but never honoured.**
  `#[[packed]]` and `#[[reorder]]` (`#[[reorder, packed]]` composite) are
  in the attribute list (`coral-ast/decl.crl:23-27`) but the C backend
  ignores them (no `__attribute__((packed))` emission, no field
  reordering). wallvm's `createStructType` (`irtypes.crl:793`) is already
  alignment-aware (computes offsets/alignment); honouring these becomes
  possible: `packed` = 1-byte alignment for all fields, `reorder` = sort
  fields by descending alignment (best memory layout). Phase 3 concern.


- **G29** no module data emission on native targets; `dataSection` never flushed (`x86_64_base.crl getOutput:153`); zero `Global`/`StringConst` handling in `target/x86_64/`.
- **G37** absolute symbol refs / no PIC → `-no-pie` interim, RIP-relative folds into G29 fix.
- **G40** `InlineAsm` silently dropped on every native backend.
- **G28** unhandled opcodes emitted as comments (silent fall-through, incl. terminators).
- Upper pipeline: **G1** validate return ignored, **G2** mem2reg↔lower_phis ping-pong, **G10** mem2reg refuses loop allocas (perf only), **G11** "sroa" is not SROA, **G12** no critical-edge splitting, **G14** no simplifycfg, **G16** no memcpy/memset idioms, **G17/G19** no loop canonicalization/SCEV, plus `simd_vec` untested and `ipa_cp` unwired.
- x86 quality (`docs/codegen-quality.md`): #1 width-naive mnemonics (correctness + size), compare-branch fusion, GEP disp folding, memory-source operands, xor-zeroing widths; `next-todos.md` paused #3: `rax/rcx/rdx` allocatable (more spill reduction to come).
- Target structure: `target/x86_64/x86_64_base.crl` (5828 lines) branches on `self.isWindows` throughout — to be split into per-target files later.

## Target architecture (phases 1–4)

```
CompileUnit (sema+mono)
   └─ ir::generateWallVm(...)            compiler/coral-ir/wallvm.crl
        ├─ lower AST → IrModule          (multi-file, below)
        ├─ IrValidator per func          hard gate
        ├─ irCompileAsm(mod, ctx, SystemV/Win64, optLevel)
        └─ Slice asm + u32 errors
compileUnitTo --wallvm branch
   ├─ --emit-ir  → <out>.ir              only when flag given
   ├─ --emit-asm → <out>.s               only when flag given
   └─ pipe asm → gcc -x assembler - [-no-pie] -o out -lm
```

Opt mapping: `debug→0`, `size→1`, `release→2`, `O3→3`.

## New files: `compiler/coral-ir/` (flat + `lib.crl` hub, like every other folder)

| File | Contents |
|---|---|
| `lib.crl` | `#[[no_drop_all]]` + `pub mod` re-exports |
| `wallvm.crl` | Entry: `WallVmResult { Slice asm; u32 errors; }`, `generateWallVm(...)`; IrContext lifecycle; validator gate; `irCompileAsm` drive; opt mapping |
| `lower.crl` | Lowering state (the `Codegen` analog: builder pos, label/loop/break/drop stacks, error counters) + decl iteration (file decls + mono instances) |
| `types.crl` | `Ty`/`TypeKind` → `IrType`, struct layout via `createStructType`, `str` = `{ptr, len}` |
| `decl.crl` | Function shells, args (`IrValueKind::Arg`), extern protos, globals, string constants, mangling (reimplement per `coral-docs/mangle_asm.md`) |
| `expr.crl` | Expressions → `IrValue*` (port `cgExpr` semantics; locals as alloca + load/store, mem2reg promotes) |
| `stmt.crl` | Statements/CFG: blocks, cond_br cascades, loops, switch, break/continue, drops/RAII |
| `asm.crl` | Coral `asm` stmt → `IrOpcode::InlineAsm` (lands with phase 4) |

## Wiring changes (existing files)

1. **`coral-frontend/args.crl`**: `Flag::WallVm` (len 8), `Flag::EmitAsm` (len 10), `Flag::EmitIr` (len 9); `Options.wallvm/emitAsm/emitIr` + defaults + usage.
2. **`coral-frontend/compile.crl`**: parameterize `runGcc` (lang `c`|`assembler`; assembler drops `-std=gnu11`, adds `-no-pie`); `asmHasMain` (`main:`/`.globl main`); `compileUnitTo` appends `bool wallvm, bool emitAsm, bool emitIr` (call sites `compile.crl:309`, `coralc.crl:322`); branch, artifacts only on flags, then pipe.
3. **`coral-ir/lib.crl`**: re-export hub. No `coral.crlb` change (already registered).

---

## Phases

### Phase 1 — wire it end-to-end
Flags, `runGcc` assembler mode, `coral-ir` skeleton with minimal real lowering (extern protos, `fn main`, int literals/arith, return, direct calls), selective `import(lib) wallvm::…` (watch flat-merge name collisions). Rebuild compiler; C default untouched.
**Gate:** `coralc --wallvm` on `return 42` runs, exit 42; emit flags write only when passed.

### Phase 2 — first wallvm must-fixes (verify against code, not docs)
G29 data emission (flush `dataSection`; globals/strings/`.rodata`/`.bss`/`.align`/`.size`; unique `.L` labels; `Global`/`StringConst` operand materialization `lea sym(%rip)` — starts G37), G28 unhandled opcode → hard error. `-no-pie` interim. `test/wallvm/run.sh` stays green after every lib change.
**Gate:** hello world (string + extern printf) through `--wallvm`.

### Phase 3 — lowering coverage (parity with the C backend)
Incremental, differential-tested against the C backend: types (structs/slices/tuples/fn ptrs), full expr set, stmts/CFG/loops/switch/drops, globals, mono instances, varargs externs, then prelude/std (`--no-prelude` programs work earlier). `IrValidator` on every function before the pipeline = compile error with coral diagnostics.
**Gate:** corpus of coral programs produce identical stdout/exit on both backends.

### Phase 4 — inline asm
`asm.crl` lowering → `InlineAsm`; wallvm x86_64 emitter case per `docs/assembler-plan.md` P1: parse/validate constraints, pass template text through into the `.s` (gcc assembles it). Then whatever else real programs trip over, correctness first.

### Phase 5 — upper pipeline overhaul
Fix/complete the optimization pipeline properly, driven by what coral lowering actually emits:
- Real **SROA** (G11 — current "sroa" isn't), mem2reg loop-allocas (G10) and G2 ping-pong convergence, validate-as-fixpoint (G1).
- **Vectorization**: `simd_vec` correctness + test coverage, autovec wiring, scalarizer as needed.
- Structural passes to implement: critical-edge splitting (G12), simplifycfg (G14), loop canonicalization/LCSSA (G17), indvars/SCEV (G19), memcpy/memset idioms (G16), reassociation (G15), module-level IPA/CGSCC so `ipa_cp` actually runs (G7).
- New passes as coral lowering reveals needs; wire into `PassPipeline` levels; hard validation gates.

### Phase 6 — x86 output to GCC level
`docs/codegen-quality.md` items: width-correct mnemonics (#1 — correctness + size), compare/branch flag fusion, GEP constant-offset folding, memory-source operands, xor-zeroing widths, cmov from icmp, immediate stores; spill reduction continues (allocatable `rax/rcx/rdx` — paused TODO #3, plus whatever else surfaces); block placement/branch chaining (G31); redundant-move elimination.
**Gate:** correctness suite green; output quality measured against gcc on the same sources (bench + code-size diff).

### Phase 7 — wasm backend perfection
Bring `target/wasm/` to correctness/completeness parity with the x86 path (it has loud `failOp` — good; missing pieces and WAT-only output to be addressed: encoder path via `assembly/wasm`).

### Phase 8 — wire wasm into the compiler
Wasm path in `compileUnitTo` (analogous to `--wallvm`, selection by platform/target flag), **with compiler-enforced restricted profile**: no std, no asm, no un-wasm-able features — enforced as coral diagnostics up front (declare the rule list in diagnostics with clear codes).

### Phase 9 — x64 complete & correct, then AVX/vector series
Gate on x64 full correctness (phases 3–6 done), then complete AVX/AVX2/AVX-512 emission (`assembly/x86/x86_avx.crl`, `target/x86_64/avx.crl`) and the vector opcode coverage (`Vec*`, shuffle/extract/insert), matching the upper-pipeline vectorization from phase 5.

### Phase 10 — split targets completely: linux / generic (bare metal) / windows
Remove the `if (!self.isWindows)` runtime branching from base emitters; separate per-target emitter files (linux, generic/bare-metal, windows) with shared code factored explicitly (composition, not flags). Compiler side selects the target file/CC (SystemV / Win64 / bare) accordingly.

### Phase 11 — further backends (ARM, …)
Only after x64 + wasm are complete and the target split exists (which is what makes adding a target cheap). Not scheduled yet.

---

## Verification (every phase)

- `cd compiler && coralc build` after every wiring change — default C path must stay buildable.
- `test/wallvm/run.sh` after every `lib/wallvm` change (64/64 baseline).
- Differential harness (phase 3+): both backends, same source, compare stdout/exit.
- Emit flags write nothing when absent.

## Risks

- Flat import-merge name collisions (wallvm's generic helper names) — selective imports.
- Compiler binary grows with wallvm inlined — acceptable while C is default.
- Full parity and gcc-level quality are open-ended; C backend remains the shipping path throughout phases 1–6.
- Docs vs code drift — treat every G-number as a claim to verify, not a fact.

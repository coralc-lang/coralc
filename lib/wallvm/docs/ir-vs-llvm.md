# Our IR text vs LLVM IR

Side-by-side of what `lib/wallvm/text/irPrinter.crl` emits and what
clang 23.1.3 emits (`clang -S -emit-llvm -O0/-O1`), so the ugly and the
missing are visible in one place. Samples: the `sum` loop, `countdown`,
recursive `fib`, the `strings`/`addr_phi`/`asm_add`/`d1_sidefwd` cases.

## Samples

Ours (`abi_lower` dump of `sum_phi`):

```
module "sum_phi"

func @main() i32 !abi.lower = "sysv_amd64" {
entry:
    br loop
loop:
    %i = phi i64 [ 0, entry ], [ %in, body ]
    %s = phi i64 [ 0, entry ], [ %acc, body ]
    %cmp = icmp slt i64 %i, 10
    cond_br %cmp, body, done
body:
    %acc = add i64 %s, %i
    %in = add i64 %i, 1
    br loop
done:
    %r32 = trunc i64 %s to i32
    %18 = ret i32 %r32
}
```

LLVM (`-O0`):

```llvm
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  ...
  br label %5

5:                                                ; preds = %13, %1
  %6 = load i32, ptr %1, align 4
  %7 = icmp slt i32 %6, 10
  br i1 %7, label %9, label %16

9:                                                ; preds = %5
  ...
  ret i32 %17
}
```

## Ugly in ours

1. **Terminators get value names.** `%18 = ret i32 %r32`, `%9 = ret i64 %n`.
   `ret` carries the function's result type, so the printer treats it as a
   value and prefixes `%<id> = `. LLVM never names a terminator. Confuses
   anyone pasting into LLVM tooling and wastes an id per return.
2. **Unnamed-value ids are global and out of order.** One `fib_rec`
   function shows `%9 = ret`, then `%23`, `%24`, then `%16 = ret`. Ids come
   from the context-wide counter (pipeline-gaps P2), not per-function
   sequential numbering, so printed ids jump around and never match the
   `%2, %3, ...` rhythm of LLVM.
3. **No `; preds = ...` comments.** LLVM prints the CFG edge set after
   every block label (`5:  ; preds = %13, %1`). This is the single biggest
   readability win we are missing; the info is already in `bb->preds`.
4. **Branch spelling.** `cond_br %cmp, body, done` / `br loop` vs LLVM
   `br i1 %cmp, label %body, label %done` / `br label %loop`. Missing the
   `label %` keyword (and the `i1` on cond_br) — fine for our parser, but
   not copy-paste-compatible.
5. **Phi block refs lack `%`.** `[ 0, entry ]` vs LLVM `[ 0, %entry ]`.
6. **Block labels are names when present, `b<id>` when not.** LLVM
   defaults to per-function numeric labels (`3:`, `13:`); our mix of
   `entry`/`loop`/`body` names and global-id `b4732` forms is inconsistent.
   (Asm labels are already numeric `.L<id>` — see emitBlockDefinition.)
7. **Pointer spellings are inconsistent.** `ptr` (bare), `ptr i8`,
   `ptr ptr i8`, `store ptr i8 %p0` — the pointee prints only when the
   type's `elem` is non-null, and store prints the *value's* type while
   the source usually writes bare `ptr`. LLVM 15+ is uniformly `ptr`.
8. **`bitcast` of pointers is noise.** Opaque pointers made pointer
   bitcasts no-ops in LLVM; we still print `bitcast ptr %q to ptr array i8 0`.
9. **Inline asm is our own shape.**
   `inlineasm void "addq %1, %0" : "+r,r" : "cc" (ptr i64 %res, i64 2)`
   vs LLVM `call void asm sideeffect "addq $1, $0", "=r,r,~{cc}"(...)`.
   Ours is compact and parseable; just not comparable by eye.
10. **No flags anywhere.** No `align` on alloca/load/store, no
    `nsw`/`nuw`/`exact`, no `inbounds` on gep, no fast-math — even when
    the front end knows them.
11. **`!abi.lower = "sysv_amd64"`** rides as per-function metadata
    instead of a calling-convention token on the definition.
12. **`module "name"` header** is ours alone (LLVM keeps ModuleID as a
    comment). Harmless, but non-standard.

## Missing vs LLVM (whole features)

1. **Opaque pointers.** We still have typed pointers (`ptr i64`,
   `ptr ptr i8`); LLVM deleted pointee types in 15.
2. **No `switch`.** There is no `IrOpcode::Switch` — front ends must
   lower to cond_br chains before printing. LLVM prints `switch i32 %x,
   label %a [ i32 1, label %b ... ]`.
3. **No EH.** No `invoke`, `landingpad`, `catchswitch`, `cleanuppad`,
   `resume`, `catchret`, `cleanupret`.
4. **No `freeze`, `undef`, `poison`.** Constants print `0`/literals only;
   there is no spelling for undef/poison operands.
5. **No integer wrap flags / exact shifts / fast-math.** `add nsw`,
   `mul nuw`, `lshr exact`, `fadd fast` all absent.
6. **No `align`** on instructions or globals (`align 8` everywhere in
   LLVM output).
7. **No linkage or visibility.** `dso_local`, `internal`, `private`,
   `weak`, `common`, `linkonce_odr`, `available_externally`, plus
   `section`, `comdat`, `unnamed_addr`, `local_unnamed_addr`. We only
   have `func` / `extern func ... extern "lib" "sym"` / `global` /
   `string`, and no `constant` vs `global` readonly distinction.
8. **No attributes.** No function attrs (`nounwind`, `readonly`,
   `willreturn`, `memory(...)`), no param/ret attrs (`noundef`, `nonnull`,
   `sret`, `byval`, `zeroext`), no `attributes #0` groups, no `#0`
   references on `define`.
9. **No module header.** Missing `target triple`, `target datalayout`,
   `source_filename`, `!llvm.module.flags`, `!llvm.ident`.
10. **No LLVM-style debug info.** `debugLoc`/`varDbg` exist internally but
    print as our own inline `!var = "name", type, line, col` clause, not
    `!dbg !12` attachment + metadata nodes — not consumable by llvm-dbg.
11. **GEP is decay-style only.** `gep @msg, 1` — one index, no source
    element type, no multi-index path, no `inbounds`. LLVM:
    `getelementptr [4 x i8], ptr @msg, i64 0, i64 1`.
12. **Missing instructions:** `blockaddress`, `indirectbr`, `callbr`,
    `va_arg`, `extractvalue` exists but there is no `insertvalue` path in
    samples (opcode is present), no `catchpad`-family, no `addrspacecast`.
13. **No tail markers or calling conventions** on calls
    (`tail call`, `fastcc`, `x86_stdcallcc`, ...).
14. **No loop metadata.** LLVM emits `!llvm.loop !5` on backedges; we
    print nothing (loop info lives only inside passes).

## Where ours deliberately differs (not bugs)

* **First-class opcodes where LLVM uses intrinsics:** `ctlz`/`cttz`/
  `ctpop`/`bswap`/`abs`/`fma`/`smax`/`smin`/`umax`/`umin`/`rotl`/`rotr`
  are instructions for us, `llvm.*` calls for LLVM. Cleaner.
* **`string @msg: "abc";`** declarations with a `.Lcs<id>` pool label at
  the asm level, vs LLVM's inline
  `@msg = private unnamed_addr constant [4 x i8] c"abc\00", align 1`.
* **`extern func @f(...) extern "libc" "memcpy";`** — our lib/sym import
  form has no LLVM spelling.
* **Custom runtime ops:** `gcroot`/`gcWriteBarrier`, the `vec*` family
  (`vadd`, `vbroadcast`, `shufflevector`-like `shufflevector` exists too),
  `inlineasm` tuple form, `!abi.lower`.
* **No `dso_local` / `#0` attribute noise** — headers stay short.

## Suggested order

1. **Readability, cheap:** print `; preds = ...` from `bb->preds`;
   suppress `%<id> = ` on terminators; per-function sequential numbering
   for unnamed values (or at least print in def order).
2. **LLVM-ish spelling:** `label %` in br/cond_br/phi refs (parser keeps
   accepting the old form).
3. **Feature gaps that bite:** `switch`, `align`, `nsw/nuw/inbounds`,
   opaque-pointer migration.
4. **Toolchain interop (only if wanted):** module triple/datalayout,
   attributes, `!dbg` metadata shape.

# HANDOFF — Coral selfhost compiler (coralc → WallVM IR)

Pass this document to any model/engineer continuing the session. It contains full
context, verified state, repro cases, and the remaining task list.

---

## 1. Project context

- Repo: `/home/cerie/Projects/coral`. The compiler is written in its own language
  (**Coral**, files `.crl`) and bootstraps through a C build (`./build` produces
  `./coralc`).
- Pipeline: `src/lexer.crl` → `src/parser.crl` → `src/typecheck/{check,expr}.crl`
  → `src/codegen/emitir.crl` (WallVM IR, `.wir` text output).
- Run: `./coralc <file>.crl --emit-ir -O0` writes `<file>.wir`.
- **lib2 is the live runtime** (`import("std/...")`, wallvm IR types). `lib/` is
  LEGACY — do not fix things there, do not use it as reference for what coralc
  accepts. `src/` must never import `lib2/`.

### Language rules established by the user (NON-NEGOTIABLE)

1. Attributes:
   - Declaration level: `[[attr]]` or comma list `[[reorder, packed]]`. DOUBLE
     brackets, no `@`.
   - Module/file level: `@[[ATTR]]` (double bracket after `@`). This is the ONLY
     valid `@` form.
   - `@[name]` (single bracket) and bare `@name` are **forbidden**. The LEXER must
     reject them (implemented, see §3).
   - There is NO `[[reorder_packed]]` token. Combined mode is `[[reorder, packed]]`
     (both attrs recorded; layoutMode 3).
2. Arrays: 2D arrays supported as `T[N][M]` where the FIRST size is outermost:
   `i32[2][3]` is 2 outer arrays of 3 `i32` (col-major thinking as C). Parser
   collects sizes then wraps in reverse so `i32[2][3]` → `array(array(i32,3),2)`.
   Code at `src/parser.crl:parseType` handles `while([)` loop with `arrSizes[16]`.
   Check `m[1][2]` for `i32[2][3]` is valid; `m[1][2]` with inner 2 would error.
3. Functions: ANY `FOO main()` where `FOO` is not a known primitive/struct (e.g.
   `loo`, `fn`, `xyz`, `int`) is **rejected** via `TC-TYPE "unknown return type
   'FOO'"` in `src/typecheck/expr.crl:typeFunction`. Previously fell through as
   `TY_UNKNOWN` → mapped to `i64`. Also `i32 foo(){}` with no return now emits
   `TC-RETURN "non-void function 'foo' must return a value of type 'i32'"`.
4. Struct layout modes: `[[reorder]]` (sort fields by align/size desc, natural
   padding), `[[packed]]` (no padding), `[[reorder, packed]]` (sorted + tight).
   Parsed in `src/parser.crl` `parseStructDecl` (~line 3170) via
   `self.hasAttr("reorder")` / `hasAttr("packed")` → `d->layoutMode` 1/2/3;
   offsets computed in `src/codegen/emitir.crl` (`structFieldOffset`).
5. Inline asm: `asm [volatile] [inline] { ... }`. Body is ordinary tokens — the
   template MUST be a string literal. Extended GCC style works:
   `asm volatile { "tmpl" : "=a"(out) : "d"(in) : "cc", "memory" }`.
   Parens `asm(...)` are NOT grammar. Do not add raw-text lexer modes.
6. Diagnostics format lives entirely in `src/error.crl` (`diag`):
   ```
   error[CODE]: <summary>
     ┌─► file:line:col
     │
     │  NN │ source line
     │     ▲
     │     ╰─ help text        <- only rendered if help non-empty
   ```
   Entry points: `diag`, `reportCode`, `reportLevel`, `report`. ANSI colors built
   with raw ESC byte (27) + suffix strings because the bootstrap C compiler must
   accept the literals (no `\x` escapes in Coral string literals).

---

## 2. Completed & verified (protect these — regression battery below)

- **Lexer**: `@[...]`/`@name` rejected (LEX-0007); only `[[attr]]` (decl) and
  `@[[ATTR]]` (module) exist. `[[reorder, packed]]` comma form works.
- **Types**: unknown return types rejected (TC-TYPE) — no more silent i64
  fallback for `fn main()`/`loo main()`. Non-void fn without return → TC-RETURN.
  void fn returning value → TC-RETURN.
- **Distinct vs typedef**: distinct needs explicit cast both directions;
  typedef unwraps implicitly. Enforced in assign/call/return.
- **2D arrays** `T[N][M]` parse and lower (outer-first, C semantics).
- **Externs** reach IR as `extern func @name -> ret {}` with isExtern=true →
  backends emit .globl; extern VARS (`__bss_start`) reach IR as extern globals.
- **Dotted module types** (`godot.types.ObjectPtr`): resolveDottedViaLoader +
  retryTypeViaLoader (expr.crl) resolve RETURN TYPES through loaded programs by
  last-segment match over exported STRUCT/DISTINCT/TYPEDEF/ENUM/TRAIT, plus
  valueless `pub <type> <name>;` var-aliases (`pub u8 GBool`). singleton.crl
  and register_class.crl compile 0 errors.
- **Headers (--emit-h)**: array declarators `T name[2][3]`, #pragma once,
  extern vars vs funcs distinguished, valueless globals emit `extern T name;`,
  enums/distinct emitted, packed attribute once, gcc -fsyntax-only clean.
- **Generics in headers**: instantiated display names mangled — `Box<f64>` →
  `Box__f64` (pushMangledName). IR/asm never contain raw `<`.
- **--explain CODE** covers LEX/SYN/TC catalogs; every diagnostic prints
  "try `coralc --explain CODE`".
- **Toolchain**: -o FILE; default build = -O1 + gcc link to a.out; --funroll /
  --fborrowcheck flags exist (unroll/borrowcheck are ON unconditionally inside
  irStructureLane per owner decision; borrowcheck violation is diagnostic-only,
  never aborts).
- **Errors suppress artifacts**: nerrors>0 ⇒ no .wir/.h/.s/.exe written.
- **Per-module attribution**: imported decls carry srcFile; body-typing errors
  report the IMPORTED file's path+line+caret via Typer.curFile/diagSrc.

### Regression battery (run after EVERY change)
```
printf 'i32 main(){return 42;}\n' > t.crl && coralc t.crl -o t -O1 && ./t   # 42
loop.crl (for i<4 s+=i) → ./l exits 6
ios-imp.crl --emit-ir → writes
genh2.crl --emit-h → grep Box__f64 genh2.h
lib2/coral-godot/examples/singleton.crl --emit-ir → 0 errors
lib2/coral-godot/examples/register_class.crl → 0 errors
./build must be warning-free on could-not-import
```

---

## 3. CURRENT OPEN ISSUES (authoritative; C-numbers referenced everywhere)

### C1. hello_entry.crl hangs the compiler — front-end spin, location UNKNOWN
Repro: `cd lib2/coral-godot/examples && timeout 20 coralc hello_entry.crl
--emit-ir` → exit 124, ZERO output bytes (hangs before parse diagnostics).
Happens at -O0 too ⇒ NOT mem2reg/C4, NOT codegen. gdb attach attempts failed
on shell-timeouts + wrong cwd ("cannot read input file" inside gdb session).
Next step: from examples dir run coralc under gdb, Ctrl-C after ~5s, `bt 15`.
Suspects: import-cycle guard bypassed via two path spellings of one file
(guard keys on exact resolved path), or non-converging fixpoint.

### C2. custom_wrapper.crl — TC-TYPE on METHOD return type through alias
`godot.types.ObjectPtr body() { ... }` at :42 errors though ObjectPtr is
`pub distinct` in types.crl and singleton proves top-level fns resolve.
Cause: retryTypeViaLoader hooked ONLY into typeFunction retType. Methods also
resolve via fnSig (declareSym pass-1 sig) which lacks retry, and that earlier
opaque result wins. Fix: wire retryTypeViaLoader into fnSig's return
resolution AND param-type resolution there + declareSym SYM_FUNC branch.
Params currently poison silently (tolerated) — fixing them kills ghosts.

### C3. startup_templates.crl (lib2/start/) — never tested this round.

### C4. mem2reg infinite loop at -O3
lib/wallvm/passes/mem2reg.crl never returns on loops containing arrays/GEP
chains; blocks ALL optimized builds (-O0/-O1 fine). Repro: any loop test with
-O3. Fix pass or gate it behind a flag until convergent.

### C5. println must become formatible (std.debug.print style)
Current: println(const u8*) = msg+newline (runtime segfault in its ASM body is
BACKEND, out of scope this session per owner). Front-end design required:
comptime parse of the format-string literal, `{}`/`{spec}` placeholders matched
against trailing args, type-driven dispatch to existing _fprint* family,
placeholder/arg mismatch = compile error at call-site file:line. Single
emitted function per distinct arg-type tuple once C6 lands.

### C6. Comptime variadics `<T...>` unspecialized
`print<T...>(T... args)` parses/typechecks but mono does not expand call sites
into concrete instances nor lower `for (var arg : args)` pack iteration.
Spec: `<T...>` = comptime pack — caller omits type args; tuple inferred per
call site; one specialized body per tuple, mangled with existing `__` scheme.
Runtime `...` remains C varargs.

### C7. Reachability closure REVERTED — parked in check.crl.bak / scopes.crl.bak
Full-subtree pub inlining is live again ⇒ cross-module same-name collisions
dodged only by manual renames (encodeB64/encodeHx). Re-landing notes:
walker (unExpr/unStmt) + closure code in .bak is sound; before re-applying fix
why the block produced zero [dotdecl] output when instrumented (placement vs
gates), and keep ALL local matrices flattened to 1D — Coral parser rejects
`char m[64][8][128]` locals and mis-parses `(x)*N` inside subscripts.

### C8. `.crl` extension auto-resolve reverted
Wanted: import(lib,"x") AND import(lib,"x.crl") both resolve (probe exact then
+".crl" in resolveLibImport). Current code appends .crl only when imp has no
dot. The two-candidate probe was correct; re-apply standalone.

### C9. Dotted-type coverage gaps beyond return types
Params, local decls, struct fields still poison-silent for dotted names
(tolerated, no safety). Same mechanical wiring as C2 across those positions;
optionally add a strict flag later.

### C10. Small polish (low priority)
- error.crl caret counts BYTE columns → tabs/UTF-8 misalign ▲ (clamp or
  tab-expand extracted line).
- Dead @[...]-parser branches in skipFileAttrs/parseAttachedAttrs are
  unreachable since the lexer hard-rejects; strip when convenient.

---

## 4. Priority order
1. C1 (hang blocks all example work)
2. C2 (mechanical, unlocks custom_wrapper)
3. C6 + C5 (comptime variadics then println formatting)
4. C4 (mem2reg) → unlocks -O2/-O3 validation
5. C7/C8 re-lands, C9/C10 polish

---

## 5. Style constraints for edits

- Coral quirks: 2D local arrays NOW supported (`T[N][M]`), but older bootstrap
  code flattens like `char outConstr[192]` (kept for compat); no `\x`
  escapes in string literals (use raw ESC byte pattern from error.crl); multiple
  declarators on one line with mixed arrays fail to parse (split lines).
- Comments only where explaining non-obvious rationale; match existing terse
  comment style.
- After every change: `./build 2>&1 | grep -E "error" | head` must be clean, then
  rerun the §3 repro battery.
- Never touch `lib/` for fixes (legacy). lib2 mirrors exist for runtime parity work.

## 6. Key file map

- `src/error.crl` — all rendering; `diag(code,file,src,line,col,lvl,msg,help)`.
- `src/token.crl` — OP_TERMS/KW_TERMS/ANON_TERMS + T_* ids (id = index-based; DO
  NOT reorder OP_TERMS/ANON_TERMS without updating constants).
- `src/lexer.crl` — `scanPunct` (LEX-0007 hook), `scanWord`, `lex()` main loop;
  errors LEX-0001..0007.
- `src/parser.crl` — `errorMsg(code,msg,help)` helper at :352; `skipFileAttrs`
  :488; `hasAttr` :520; `parseAttachedAttrs` :529; `parseAsmStmt` :1706;
  `parseStructDecl` :3172; top-level dispatch ~2960-2980 (SYN-1998/-1003).
- `src/typecheck/expr.crl` — `typeExpr`, `typeStmt` (ST_RETURN :1605), 
  `typeFunction` :1897, TC-* sites listed in G3.
- `src/codegen/emitir.crl` — `genAsm`, `parseExprSnippet`, `structFieldOffset`,
  `dumpIR`, `emitIR`, `buildModule`.

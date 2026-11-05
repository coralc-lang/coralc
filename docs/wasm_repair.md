# WASM REPAIR BRIEF — lib/wallvm/target/wasm/wasm.crl

## Mission
Repair the wallvm wasm text backend into a CORRECT emitter. This is a repair, not a
port: semantics are dictated by the IR spec and by the design decisions below. You may
rewrite large parts of emitInst / emitFunc / emitModule.

## Scope (strict)
- READ: this file; coral-docs/PORTING_RULES.md (sections 0, 2, 5 apply — ignore 1, 3, 6
  except the checker); /home/cerie/Documents/Mu/IR.md (the authoritative IR spec — sections
  5-9 especially); lib/wallvm/** ; lib_old/wallvm/target/wasm/** (reference only — it is the
  OLD BROKEN backend, do not trust its semantics over IR.md); lib/std, lib/core, lib/platform.
- WRITE: the ONLY file you normally edit is lib/wallvm/target/wasm/wasm.crl.
- CONDITIONALLY WRITE (only if IR.md proves the contract is broken there, report any such
  edit with exact justification): lib/wallvm/text/irParser.crl, lib/wallvm/base/irBuilder.crl.
- NEVER read or write anything under compiler/. Never run any compiler, build, or the coral
  binary. No git commands.
- Comment style: section 5 of PORTING_RULES (prose colons become commas, first person
  sprinkled, never restate code). Never fight user stylistic edits (section 0) — notably the
  user's `pub str* NAME[] = { ... }` array style and my emitU64 fix (`n = n - 1;`) in the
  u64 emitter must not regress. Any `new` method you touch returns a struct literal
  directly (never declare-then-return).

## Confirmed defects (personally verified by me — each must end as FIXED or JUSTIFIED-DEFER
in your report)
1. Module layout: imports are emitted after definitions; the spec order requires imports
   first (types after imports too).
2. Locals: bare `local $ptr i32` — must be parenthesized `(local ...)` declarations.
3. Argument locals: indexed by IrValue.id (a global counter from ctx.nextValueId(),
   irParser.crl) instead of the parameter's ordinal in func->args (addArg appends in
   order). Map args by position in func->args.
4. CFG: the sibling `block $bb ... end` emission cannot express branches or carry stack
   values. Replaced by the dispatch loop (design D1).
5. emitValuePush handles only ConstInt, ConstFloat, Arg.
6. The default arm of emitInst silently drops 35 of 83 opcodes (Phi, InlineAsm, atomics,
   CtPop, Rotl, ...). Silent drops are forbidden (design D5).
7. Select hardcodes an i32 result; must follow the instruction's result type.
8. Casts ignore source/destination widths.
9. Linear memory is 1 page while $__stack_pointer is initialized to 1 MiB.
10. Min/Max emit an operand stack that does not match the select they feed.
11. Neg emits `x - 0` instead of `0 - x`.
12. Integer Abs is wrong (design D7 gives the sequence).
13. No data section: globals, StringConst and ConstArray have no storage and their pushes
    are unhandled (design D6).
14. Gep does no byte scaling and ignores struct field offsets (IR.md invariant 5).
15. main export uses a prefix match — must be exact `main`.
16. elem is emitted without the table it indexes; guard them together.
17. Alloca carries zero operands BY SPEC (IR.md: `alloca | T` yields `ptr T`; the parser
    emits no ops). The old ops[0]-as-size read is dead — derive the size with
    irTypeSizeOf() (irtypes.crl) from the result pointer's element type.
18. Fresh re-audit: a previous audit produced 27 findings and its full report was lost.
    My list above is the confirmed subset. Re-derive the rest yourself by walking every
    emit* function against IR.md.

## Design decisions (dictated — implement, do not re-litigate)

### D1 — dispatch-loop CFG lowering (fixes defect 4, handles any CFG)
For each function, after collecting func->blocks in their IR order (region index k =
position in the array; no RPO needed), emit:

    local.set $pc          ;; i32.const 0 first, at entry
    loop $L
      block $done
        block $b{n-1}
          ...
            block $b1
              block $b0
                local.get $pc
                br_table $b0 $b1 ... $b{n-1} $done   ;; depths 0..n from inside $b0
              end     ;; b0 end — CODE region 0 begins here
              <CODE_0>
            end       ;; CODE_1 begins here
            ...
          end           ;; CODE_{n-1} begins here
          <CODE_{n-1}>
        end
      end
    end

- br_table depths measured inside $b0: depth 0 = end of $b0 = start of CODE_0, depth 1 =
  start of CODE_1, ..., depth n-1 = start of CODE_{n-1}, default depth n = end of $done =
  fall out of the loop body and the function ends (traps are handled inside regions).
- Every CODE_k region ends with exactly one terminator:
  - br: `i32.const <succRegion>; local.set $pc; br <n-k>` (inside CODE_k the enclosing
    frames are $b{k+1}..$b{n-1} (n-1-k frames), then $done, so the loop is depth n-k).
  - cond_br: push phi incomings first, then
    `i32.const <trueRegion>; i32.const <falseRegion>; local.get <cond>; select;
     local.set $pc; br <n-k>`.
  - ret: push operand (or none) and `return`.
  - unreachable / noret: `unreachable` (no pc update; successors are dead anyway).
- Defensive: if a region's last instruction is not a terminator, end it with `unreachable`.
- Entry region: set pc=0 before the loop; region indices come from the block array.
- All block references in terminators become region indices via a block* -> index map.

### D2 — one wasm local per non-constant IR value
- Producer does `local.set $v<slot>` after computing; consumers do `local.get $v<slot>`.
  Params occupy slots 0..nargs-1 in func->args order (defect 3). Then every non-void
  instruction result, then one slot per phi.
- ConstInt/ConstFloat push immediates (width-aware); Global/StringConst/ConstArray push
  `i32.const <data address>` (D6); Func pushes its table index only where semantically a
  function pointer (otherwise fail, D5); Block operands are only used by terminators as
  region indices.
- Phi: emits no code at its own position. Phi ops are interleaved pairs
  [value0, block0, value1, block1, ...] (even = value, odd = block — irParser.crl).
  At each predecessor's terminator, BEFORE pushing the condition/pc sequence: for every
  phi in each successor block, find the pair whose block operand equals this predecessor
  (match by block identity/name) and `local.set` the incoming value into the phi's slot.

### D3 — module field order
`(module` then all `(import ...)` lines, then types, memory, table, globals, funcs,
exports, elems, data — validated against whatever wasm validation tool you can find.

### D4 — memory sizing
- Data (globals, strings, const arrays) starts at address 0, laid out sequentially with
  natural alignment; let dataEnd = end of data.
- Heap (bump malloc) starts at align(dataEnd, 16).
- Stack top T = align(dataEnd rounded up to a page boundary, 65536) + 1 MiB;
  $__stack_pointer initialized to T.
- memory min pages = ceil((T + 1 MiB heap reserve) / 65536), max = 65536. Emit as
  `(memory $0 <min> <max>)` (or keep existing naming if the file already exports memory).

### D5 — opcode coverage policy (fixes defect 6; no silent drops)
Every opcode must either emit correct code or make the emitter return false with an
explicit diagnostic to stderr naming the function and opcode. Required implementations:
- CtPop -> popcnt, CtLz -> clz, CtTz -> ctz, Rotl/Rotr -> rotl/rotr, Bswap -> shift/mask
  sequence, Noret -> unreachable, Fma -> fmul then fadd (operand order from IR.md `fma a,b,c`),
  Neg/Abs per D7, Min/Max per D7.
- Atomics: emit the matching plain load/store/rmw sequence plus a comment that ordering is
  unobservable on single-threaded wasm. Fence -> no-op with comment. GcRoot/GcWriteBarrier/
  GcSafepoint -> no-op with comment (no GC). LandingPad -> no-op with comment (IR.md: no
  catch in v1).
- Phi handled by D2. InlineAsm -> return false + diagnostic (wasm cannot inline asm).
- Vec* SIMD opcodes: implement with wasm SIMD (v128) if the mapping is direct; otherwise
  return false + diagnostic. ExtractValue/InsertValue -> return false + diagnostic (nothing
  in lib_old passes constructs them — verified — and aggregate values cannot live on the
  wasm stack).
- Select: result type from the instruction (i1/i8..i32/ptr -> i32, i64 -> i64, f32/f64).

### D6 — data section
Emit `(data (i32.const <addr>) "<bytes>")` for every global initializer, string constant
and const array (escape as \xx for anything outside printable ASCII plus \n \t \\ \").
Pushes of those value kinds use their assigned addresses. Extern globals: only if the IR
actually models them — check irtypes/parser; if not modeled, nothing to do.

### D7 — exact instruction sequences (fixes 10, 11, 12)
- Neg: `i32.const 0` (or i64.const 0) FIRST, then the operand, then sub.
- Abs (integer): push operand with `local.tee $t`; compute negation `i32.const 0; local.get
  $t; sub`; push condition `local.get $t; i32.const 0; lt_s` (signed) — stack is now
  [x, -x, x<0]; `select` picks -x when negative. For i64 the same with i64 ops. Use
  dedicated typed scratch locals ($absT) — declared like every other local. FAbs stays
  f32.abs/f64.abs (already correct).
- Min/Max: `local.set $m2; local.set $m1; local.get $m1; local.get $m2; local.get $m1;
  local.get $m2; <cmp>; select` — verify the select arms produce min/max for the signed,
  unsigned and float variants (float Min/Max need f32.min/f64.min directly — those are
  instructions, not selects).

### D8 — exports/elem
Exact-name match for main. Emit elem and table in one guarded block only when there are
function-table entries.

### D9 — casts (defect 8)
Full width matrix (src 1/8/16/32/64 -> dst 1/8/16/32/64) for trunc/zext/sext: trunc keeps
low bits (mask), zext zero-extends, sext sign-extends (shl/shr_s with the width delta —
wasm has no i8/i16 so everything runs at i32/i64 with masks/sign handling; verify each
against IR.md cast semantics). bitcast: reinterpret per width (f32<->i32, f64<->i64, same
widths only — otherwise diagnostic). Float casts: existing f32/f64 convert ops are fine —
audit each against IR.md (`fptosi fptoui fptrunc fpext sitofp uitofp`).

## Verification requirements
1. python3 coral-docs/check_crl.py lib/wallvm/target/wasm/wasm.crl (from the repo root)
   -> PASS.
2. Stale-syntax greps (section 6 patterns) clean; pub entry points keep their signatures
   (irCodegenWasm32 / the Asm entry you find).
3. Tooling: this machine had no wat2wasm/wasmtime/wabt on PATH and python imports of
   wasmtime/wabt failed earlier. You MAY try `pip install --user wasmtime` (it validates
   wat text and wasm binaries); if the network is unavailable, fall back to hand-tracing.
4. For every defect 1-18 and every opcode you rewrote: give a stack-effect trace
   (values pushed/popped) in your report. For every defect: FIXED or JUSTIFIED-DEFER.
5. Do NOT run the coral compiler. Logical correctness only.

## Report format
- Table: defect 1-18 -> FIXED / DEFER (+one-line how).
- Additional findings from your fresh audit, same treatment.
- File line count before/after; checker output; tooling you managed to use.
- Any edit you made outside wasm.crl with justification, or "none".
- Assumptions.

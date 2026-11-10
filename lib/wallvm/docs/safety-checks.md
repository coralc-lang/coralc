# Wallvm safety checks (O0 instrumentation)

Debug-only runtime checks. `irPassSafety` (`lib/wallvm/passes/safety.crl`,
481 lines) runs from `irOptimize` before the L0 pipeline, **only at O0**,
never on O1+ and never on wasm (`irCompile` passes the target's
`CallingConvention`; wasm has no `error.crl` to link). The whole design
rule: the backend learns zero new instructions — every check is an
ordinary

```
call void @_trap(kind, a, b, file, line, fn)
```

placed before the operation that can fail. `_trap` lives in each
platform's std `error.crl` (pub-symbol parity across
`lib/std/x86_64/{linux,windows}/error.crl` and
`lib/std/arm64/{android,macos}/error.crl`); the test harness links
`test/wallvm/trap_stub.c` instead, which applies the same predicate and
`exit(70)`s when it fails.

## Trap kinds

| kind | name    | args                 | ok condition    | inserted for |
|------|---------|----------------------|-----------------|--------------|
| 0    | bounds  | a=index, b=array len | `a < b`         | `gep` on a fixed-size array whose index is not a provably in-range constant (both base shapes: the aggregate alloca's bare `array` type and `ptr array`) |
| 1    | null    | a=pointer            | `a != 0`        | `load`/`store` through a pointer not `provenNonNull` (alloca/global/string-literal/function provenance; gep/bitcast preserve it) |
| 2    | divzero | a=divisor            | `a != 0`        | `sdiv`/`udiv`/`srem`/`urem` whose divisor is not a literal non-zero constant |
| 3    | overflow | a=_flag             | `a == 0`        | integer `add`/`sub` — see [overflow-checks.md](overflow-checks.md) |
| 4    | badvariant | a=tag, b=nvariants | `a < b`        | reserved, not inserted yet |

A zero-length array type is a decay target for unsized buffers
(`bitcast ptr %q to ptr array i8 0`, then gep) — there is no static
bound, so kind 0 instruments nothing there rather than trapping
always.

## Insertion-time proofs (cheap, always applied)

Before a site is even recorded:

- constant index already `< len` → no bounds site;
- pointer proven non-null through the alloca/gep/bitcast chain → no
  null site;
- literal non-zero divisor → no divzero site.

## Dominance-based dedup

Sites are recorded per function (`SafetySite`: block, anchor, kind,
args, file/line, insertion `pos`), then a pass drops every site whose
**equivalent check already runs strictly before its insertion point**:

- `sameCheck`: same kind, both args the same SSA value or equal
  constants (equal `valData` + width), and — for kind 3, whose flag
  formula depends on the op — the anchor opcode and `isUnsignedArith()`
  must match.
- `covers(p, q)`: earlier `pos` in the same block, or `p`'s block
  strictly dominates `q`'s block (`wallvm::domtree`, Lengauer-Tarjan;
  `irDomtreeDominates` is reflexive, so same-block pairs are decided by
  position alone).

Soundness: the call is **unconditional** — `_trap` itself evaluates the
predicate and returns when the guarded property holds — so reaching `q`
means `p`'s call already returned, and SSA values cannot change
underneath it. `covers` is transitive (strict dominance and check
equality both are), so skipping needs no fixpoint: any covering chain
bottoms out at a site nothing covers. Equal sites where neither block
dominates the other **both stay** — either path can reach one without
the other having run.

`test/wallvm/checks/dedup.ir` pins the behavior: three geps on the same
index (first in `entry`, two in the dominated `body`) must leave
**exactly one** `call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v` in the O0 asm (run_checks asserts the
count, not just presence).

## Kill-switch

`WALLVM_CHECKS=0` in the environment disables the pass entirely
(read by `test/wallvm/irtool.crl` before compiling, which sets
`gSafetyChecks = false`; `irOptimize` reads the same global). Unset
keeps checks on. Used for with/without-checks asm comparisons.

## Testing

`test/wallvm/checks/*.ir` — 9 cases, 30 assertions in
`run_checks.sh`:

- `clean` — instrumented at O0, runs at O0 **and** O2 with the original
  result (no false positives), no `_trap` at O2;
- `oob` (kind 0), `nonnull` (kind 1), `divzero` (kind 2) — each must
  fire (exit 70) at O0 and contain `_trap` in the O0 asm only;
- `overflow_add` / `overflow_sub` (signed kind 3), `overflow_u`
  (aux-tagged unsigned path, `.u` text syntax), `overflow_safe` (in
  range, expect 0);
- `dedup` — dominance dedup (count == 1);
- `WALLVM_CHECKS=0` — even O0 inserts nothing.

Gates: `run_checks.sh` 30/30 · `run.sh` 132/132 (33 cases × O0-O3) ·
`run_borrow.sh` 8/8 · `run_passes.sh` 19/19 ·
ASAN-built irtool runs 30+132+8 · self-host
(`coralc -f coral.crlb --force`) rebuilds and runs.

## Open

- The driver must link `error.crl`'s `_trap` for user builds with
  checks on (coralc TODO).
- Kind 4 (badvariant) is reserved: `_trap` and `trap_stub.c` already
  implement the predicate; nothing inserts it yet.
- `mul` overflow is reserved — see
  [overflow-checks.md](overflow-checks.md#mul-is-reserved).

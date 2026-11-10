# Integer overflow checks (trap kind 3)

O0-only instrumentation contract for signed/unsigned `add`/`sub`
overflow. Insertion lives in `lib/wallvm/passes/safety.crl`; the
predicate itself is evaluated by `_trap` (`kind == 3`, ok `a == 0`)
as for every other kind. Semantics are **C-like**: source arithmetic
that wraps is *defined*; the check reports when the mathematical result
would not fit the width.

## IR contract: how an op's signedness reaches the pass

The IR op (`Add`/`Sub`) does not carry signedness — the same opcode
serves both. The frontend tags **unsigned source operations** by storing
`IR_AUX_UNSIGNED` (`lib/wallvm/base/irOps.crl`) in the instruction's
aux slot:

- `IrContext::createInst(..., icmpP, ...)` reuses the `icmpPred` field
  as a smuggling slot for `Add`/`Sub`/`Mul` (the same slot atomics use
  for their ordering/opacity payload);
- `IrInst.isUnsignedArith()` (`lib/wallvm/base/irtypes.crl`) reads the
  flag back;
- text IR spells it as an opcode suffix — `add.u`, `sub.u`, `mul.u`
  (`irParser.crl` accepts it in `isBinShape`/`binShapeOpcode` and passes
  the aux through `emitFinish`; `irPrinter.crl` prints the suffix), so
  the encoding round-trips through dumps;
- the pass-side contract and both directions are exercised by
  `test/wallvm/checks/overflow_u.ir`.

Frontend wiring (Coral source unsigned ops → aux) is the backend/codegen
side of the contract; the pass, parser and printer are done.

## Flag formulas (branchless, computed after the arithmetic)

For an op of width `w`, the pass captures the *next* instruction index
during the scan (block `insts[]` is index-spliced, not a list — there is
no `next` pointer), then splices the chain immediately before it, so the
layout is `[t1 t2 m _flag call <original next>]`.

**Signed** (sign-bit mask — nonzero exactly when the result's sign
differs from the operands' common sign):

```
add:  ((a ^ r) & (b ^ r)) >>s (w - 1)
sub:  ((a ^ b) & (a ^ r)) >>s (w - 1)
```

where `r` is the (wrapping) result, `>>s` is arithmetic shift.

**Unsigned** (carry/borrow):

```
add:  select(r  <u a, 1, 0)      // carry out
sub:  select(a  <u b, 1, 0)      // borrow
```

The chain ends in `_trap(3, _flag, 0, file, line, fn)`; `_flag == 0` means
the result is fine and the call returns.

## `mul` is reserved

Not implemented: a correct check needs a **guarded-div CFG split**, not
an in-block select chain. The tempting select shape

```
q = select(a == 0, 0, sdiv r, a)   // WRONG: sdiv still executes
ov = icmp ne q, b
```

is unsound because `select` does not guard: the `sdiv` executes
unconditionally and **faults** (`#DE`) on exactly the edge cases the
check exists to classify (`a == 0`, and for signed also
`r == INT_MIN, a == -1`). Any operand-side "guard by arithmetic" has the
same problem — the faulting instruction still runs.

The design when it lands:

```
entry:
    r  = mul a, b
    %z = icmp eq a, 0
    cond_br %z, cont, chk          // a == 0: product 0, never overflows
chk:                               // signed only: pre-guard the idiv edge
    %m1 = icmp eq a, -1
    %mn = icmp eq r, INT_MIN
    %bad = and %m1, %mn
    cond_br %bad, ovy, div
div:
    q = sdiv r, a                  // a != 0 and not the MIN/-1 edge
    %ov = icmp ne q, b
    br merge
ovy:
    %ov1 = true
    br merge
cont:                              // unsigned can jump straight here
    br merge2                       // flag = 0
merge:
    ... phi carries %ov/%ov1        // real branch — this is the point
    br merge2
merge2:
    call void @_trap(3, flag, 0, file, line, fn)
    <original next>
```

- **unsigned**: only the `a == 0` branch is needed — `udiv` never
  faults otherwise, and `(a*b)/a == b` iff no wrap for `a != 0`;
- **signed**: additionally pre-guards `a == -1 && r == INT_MIN` (the
  one `sdiv` edge that traps) and routes the flag through a phi at the
  merge — hence "CFG split": the block must actually split, which the
  current site model (splice-before-anchor inside one block) does not
  do yet;
- a `mulhi`-based check (`imul` high half, sign-correct) would be
  branchless but needs high-half ops on every backend (x86 `imul`
  hi, aarch64 `smulh`/`umulh`) — a future optimization, not the
  contract.

`IrOpcode::Mul` is therefore intentionally absent from the safety scan
(see the comment at the `Add | Sub` arm in `safety.crl`).

## Kind 4 (badvariant) — reserved

`a = tag, b = nvariants`, ok `a < b`. `_trap` and `trap_stub.c` already
implement the predicate; no pass inserts it yet.

## Dedup interplay

Dominance dedup treats two kind-3 sites as the same check only when the
anchor opcode **and** `isUnsignedArith()` match — `add`/`sub` and
signed/unsigned compute different flags from the same operands.

## Tests

- `overflow_add.ir` / `overflow_sub.ir` — signed wrap traps, exit 70,
  O0 asm shows `kind=3` with the sign-mask operands;
- `overflow_u.ir` — `add.u` path (aux round-trip), traps `kind=3`;
- `overflow_safe.ir` — in-range adds, expect 0 (no false positives);
- O2 asm for every case must contain no `_trap` (release never
  instruments).

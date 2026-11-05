# Borrow checker

Diagnostic-only alias/borrow pass over wallvm IR. It never rewrites IR and
never fails a compile by itself — violations are printed only when the
driver asks for them.

## What it checks

`lib/wallvm/passes/borrowcheck.crl` records these violation kinds
(`BorrowCheckKind`); the six with live detectors:

| Kind | Rule |
|---|---|
| `StaleLoadAcrossCall` | a load stays live across a call whose pointer arg the callee may write |
| `AliasingCallArgs` | two pointer args of one call overlap while the callee can write one |
| `StoreVsLiveLoad` | a store invalidates a load whose value is still used afterwards (same block, or a straight single-pred/succ edge) |
| `EscapingBorrow` | `ret` of a pointer whose region is a local alloca (first-`nparams` entry allocas — the frontend param-slot shape — are exempt) |
| `DanglingPointerDeref` | `load` through a pointer that was itself loaded from memory |
| `DoubleBorrow` | store through a loaded pointer while an overlapping earlier load is still live |

Reserved but **not yet implemented** (enum + messages exist, no detector):
`UseAfterFree`, `UninitLoad`, `InvalidAliasWrite`.

Model notes:

- Regions are base + constant offset (GEP indices scale by 8); bitcasts and
  phis are unioned so casts/merges cannot hide aliasing.
- Write capability per parameter is a fixed point over the module. Evidence
  is a store through the param — either through a load over the param's
  entry alloca (frontend shape) or directly to the param `Arg` value
  (text-IR shape, added with the test suite).
- Unknown callees (extern, no body) are assumed to write.
- Liveness is real CFG liveness (per-block live-in/out bitvecs).

## Running it

The structure lane (`wallvm.crl irStructureLane`) runs the pass on every
compile but discards the result — it is a crash-shake, not a reporter.

To actually see violations, set the env var on `irtool`:

```sh
WALLVM_BORROW_CHECK=1 ./irtool case.ir out.s O0
```

- Runs on the freshly parsed module (pre-optimization, so load/store
  patterns are still explicit).
- Prints one line per violation to stderr:

  ```
  borrow: StaleLoadAcrossCall: main: <message> (<detail>)
  ```

- Exit codes: `3` when any violation fired (codegen is skipped), `0` when
  clean (falls through to the normal compile), `1` on parse/IO errors.

`irPassBorrowCheckPrint(func, ctx)` (bottom of `borrowcheck.crl`) is the
entry point; `borrowKindName(kind)` gives the stable names used above.

## Tests

`test/wallvm/borrow/*.ir` + `test/wallvm/run_borrow.sh`:

```sh
cd test/wallvm && bash run_borrow.sh     # pass=8 fail=0
```

Each case carries `// borrow-expect:` — a space-separated **exact set** of
kinds (or `none`). The runner asserts both the printed kind set and the
exit code (3 / 0), so a case fails if a rule fires that should not, or
silently does not fire. `REBUILD=1` rebuilds `irtool` first.

| case | expects |
|---|---|
| `clean.ir` | none (also exercises the full compile path) |
| `stale_load.ir` | `StaleLoadAcrossCall` |
| `alias_args.ir` | `AliasingCallArgs` |
| `store_live_load.ir` | `StoreVsLiveLoad` |
| `escape_borrow.ir` | `EscapingBorrow` (non-entry alloca) |
| `escape_entry.ir` | `EscapingBorrow` (entry alloca, not a param slot) |
| `dangling.ir` | `DanglingPointerDeref` |
| `double_borrow.ir` | `DoubleBorrow DanglingPointerDeref StoreVsLiveLoad` (one shape, three rules) |

## Fixes landed with the suite

1. **Text-IR write caps** — `storeCapIndex` now accepts a store directly
   to an `Arg` (params in text IR are plain `Arg` values, not entry
   allocas), and `buildCaps` no longer skips functions with zero entry
   allocas. Without this, `calleeWrites` was always false for internal
   callees and rules 5 never fired.
2. **Escape rule narrowed** — the old check exempted *any* alloca in the
   entry block, so returning a local declared in the entry block (the
   classic dangling return) was missed. Exemption is now only the first
   `nparams` entry allocas (frontend param slots).
3. **Parser: bare `ptr` at end of line** — `parseTypeAfter("ptr")` used
   `skipWs`, which crossed the newline and left the cursor on the next
   line, so `%p = alloca ptr` failed with "extra tokens after
   instruction". Now `skipSpaces` (horizontal only); the function-header
   brace check crosses the newline itself so `func @f() ptr` + `{` on the
   next line still works.

## Known gaps

- The three reserved kinds above have no detectors.
- Structure-lane result is discarded (the `TC-BORROW` / `--fborrowcheck`
  mentioned at `wallvm.crl:381` does not exist yet).
- `irPassBorrowCheckCollect` hands back only a count — `deinit()` frees
  the list — so the print entry point is the way to read violations.

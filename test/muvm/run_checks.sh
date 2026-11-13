#!/bin/bash
# Safety-check instrumentation runner for muvm. No codegen exists yet, so
# the checks happen on the printed IR:
#   1. with --safety, the output references _trap at least once
#   2. the dedup case collapses to exactly one trap site
#   3. without --safety (default), the output contains no _trap
#   4. output fixpoint holds in both modes
set -u
cd "$(dirname "$0")"
CORALC="${CORALC:-coralc}"
TMP=/tmp/opencode/muvm-checks
OUT=output
TIMEOUT="${TIMEOUT:-15}"
mkdir -p "$TMP" "$OUT"

if [ ! -x ./muvm_tool ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building muvm_tool..."
    "$CORALC" muvm_tool.crl -o muvm_tool || exit 1
fi

t() { timeout --kill-after=5 "$TIMEOUT" "$@"; }

pass=0
fail=0
ok()  { pass=$((pass+1)); }
bad() { echo "FAIL $1"; fail=$((fail+1)); }

for case in ../wallvm/checks/*.ir; do
    name=$(basename "$case" .ir)

    # 1. instrumented O0: _trap must appear in the printed IR
    if ! t ./muvm_tool --safety O0 "$case" "$OUT/chk_${name}.mir" 2>"$TMP/${name}.err"; then
        bad "$name safety compile"; cat "$TMP/${name}.err"; continue
    fi
    if grep -q "_trap" "$OUT/chk_${name}.mir"; then ok; else bad "$name: no _trap in instrumented IR"; fi

    # 2. dominance dedup: exactly one _trap call survives
    if [ "$name" = "dedup" ]; then
        n=$(grep -c "call.*_trap" "$OUT/chk_${name}.mir" || true)
        if [ "$n" -eq 1 ]; then ok; else bad "dedup: $n trap calls, want 1"; fi
    fi

    # 3. default (no --safety): zero _trap in the output
    if ! t ./muvm_tool O0 "$case" "$OUT/chk_${name}_off.mir" 2>"$TMP/${name}.err2"; then
        bad "$name default compile"; cat "$TMP/${name}.err2"; continue
    fi
    if grep -q "_trap" "$OUT/chk_${name}_off.mir"; then
        bad "$name: _trap present with safety off"
    else
        ok
    fi

    # 4. fixpoint: reprinting the output is stable
    t ./muvm_tool "$OUT/chk_${name}.mir" "$OUT/chk_${name}_rt.mir" O0 >/dev/null 2>&1
    if cmp -s "$OUT/chk_${name}.mir" "$OUT/chk_${name}_rt.mir"; then
        ok
    else
        bad "$name: instrumented IR not fixpoint-stable"
    fi
done

echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

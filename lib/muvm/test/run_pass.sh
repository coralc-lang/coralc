#!/bin/bash
# Single-pass isolation runner: feeds each $CASES/*.ir through
# muvm_tool --only $PASS and diffs the resulting .mir against
# $EXPECTED/<name>.gold byte-for-byte.
#
# Used for passes whose effect is best observed in isolation
# (dse, macro_fusion, ...). PASS is required.
set -u
cd "$(dirname "$0")"
CORALC="${CORALC:-coralc}"
PASS="${PASS:?set PASS=<pipeline name, e.g. dse>}"
CASES="${CASES:-cases_$PASS}"
EXPECTED="${EXPECTED:-expected_$PASS}"
TMP=/tmp/opencode/muvm-pass
TIMEOUT="${TIMEOUT:-15}"
mkdir -p "$TMP" "$EXPECTED"

if [ ! -x ./muvm_tool ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building muvm_tool..."
    "$CORALC" muvm_tool.crl -o muvm_tool || exit 1
fi

t() { timeout --kill-after=5 "$TIMEOUT" "$@"; }

pass=0
fail=0
for case in "$CASES"/*.ir; do
    name=$(basename "$case" .ir)
    t ./muvm_tool "$case" "$TMP/$name.mir" O2 --only "$PASS" 2>"$TMP/$name.err"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "FAIL driver $name (exit $rc)"
        cat "$TMP/$name.err"
        fail=$((fail+1))
        continue
    fi
    if [ ! -f "$EXPECTED/$name.gold" ]; then
        echo "FAIL missing golden $EXPECTED/$name.gold"
        fail=$((fail+1))
        continue
    fi
    if ! diff -u "$EXPECTED/$name.gold" "$TMP/$name.mir" > "$TMP/$name.diff"; then
        echo "FAIL $name"
        cat "$TMP/$name.diff"
        fail=$((fail+1))
        continue
    fi
    pass=$((pass+1))
done
echo "$PASS: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

#!/bin/bash
# muvm driver test runner: .ir -> muvm_tool (parse + driver pipeline +
# print) -> reparse fixture check.
#
# Checks:
#   1. the tool exits 0 (driver ran the module without error)
#   2. its output parses again through the same path (fixpoint stable)
#   3. if <case>.gold exists, output must match it byte-for-byte at every
#      level
# LEVELS defaults to O0..O3. Error output (.err) goes to TMP, not OUT —
# OUT only holds the .mir fixtures.
set -u
cd "$(dirname "$0")"
CORALC="${CORALC:-coralc}"
LEVELS="${LEVELS:-O0 O1 O2 O3}"
CASES="${CASES:-../wallvm/cases}"
OUT=output
TMP=/tmp/opencode/muvm
TIMEOUT="${TIMEOUT:-15}"
mkdir -p "$TMP" "$OUT"

if [ ! -x ./muvm_tool ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building muvm_tool..."
    "$CORALC" muvm_tool.crl -o muvm_tool || exit 1
fi

t() { timeout --kill-after=5 "$TIMEOUT" "$@"; }

pass=0
fail=0
for caseset in "$CASES" cases; do
    [ -d "$caseset" ] || continue
for case in "$caseset"/*.ir; do
    name=$(basename "$case" .ir)
    for lv in $LEVELS; do
        echo "TEST $name $lv"
        t ./muvm_tool "$case" "$OUT/${name}_${lv}.mir" "$lv" 2>"$TMP/${name}_${lv}.err"
        rc=$?
        if [ "$rc" -ne 0 ]; then
            echo "FAIL driver $name $lv (exit $rc)"
            cat "$TMP/${name}_${lv}.err"
            fail=$((fail+1))
            continue
        fi
        t ./muvm_tool "$OUT/${name}_${lv}.mir" "$OUT/${name}_${lv}.mir2" "$lv" 2>"$TMP/${name}_${lv}.err2"
        rc=$?
        if [ "$rc" -ne 0 ]; then
            echo "FAIL reparse $name $lv (exit $rc)"
            fail=$((fail+1))
            continue
        fi
        cmp -s "$OUT/${name}_${lv}.mir" "$OUT/${name}_${lv}.mir2"
        if [ "$?" -ne 0 ]; then
            echo "FAIL fixpoint $name $lv (output changed on reparse)"
            fail=$((fail+1))
            continue
        fi
        if [ -f "$caseset/$name.gold" ]; then
            cmp -s "$OUT/${name}_${lv}.mir" "$caseset/$name.gold"
            if [ "$?" -ne 0 ]; then
                echo "FAIL golden $name $lv"
                fail=$((fail+1))
                continue
            fi
        fi
        pass=$((pass+1))
    done
done
done
echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

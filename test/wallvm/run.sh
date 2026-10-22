#!/bin/bash
# Wallvm IR pipeline test runner: .ir -> irtool (parse + irCompileAsm) ->
# gcc assemble/link -> run -> compare exit code against "; expect:".
# Every step runs under timeout so a stuck stage cannot hang the suite.
# Generated assembly lands in output/ next to this script.
set -u
cd "$(dirname "$0")"
CORALC="${CORALC:-coralc}"
LEVELS="${LEVELS:-O0 O1 O2 O3}"
OUT=output
TMP=/tmp/opencode/wallvm-tests
TIMEOUT="${TIMEOUT:-15}"
mkdir -p "$TMP" "$OUT"

if [ ! -x ./irtool ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building irtool..."
    "$CORALC" irtool.crl -o irtool || exit 1
fi

t() { timeout --kill-after=5 "$TIMEOUT" "$@"; }

pass=0
fail=0
for case in cases/*.ir; do
    name=$(basename "$case" .ir)
    expect=$(sed -n 's|^// *expect: *||p' "$case" | head -1)
    [ -z "$expect" ] && expect=0
    for lv in $LEVELS; do
        echo "TEST $name $lv (expect $expect)"
        t ./irtool "$case" "$OUT/${name}_${lv}.s" "$lv" 2>"$TMP/${name}_${lv}.err"
        rc=$?
        if [ "$rc" -ne 0 ]; then
            if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
                echo "FAIL compile $name $lv: timeout after ${TIMEOUT}s"
            else
                echo "FAIL compile $name $lv (exit $rc)"
                cat "$TMP/${name}_${lv}.err"
            fi
            fail=$((fail+1))
            continue
        fi
        t gcc -o "$TMP/${name}_${lv}" "$OUT/${name}_${lv}.s" 2>"$TMP/${name}_${lv}.link.err"
        rc=$?
        if [ "$rc" -ne 0 ]; then
            echo "FAIL link $name $lv (exit $rc)"
            cat "$TMP/${name}_${lv}.link.err"
            fail=$((fail+1))
            continue
        fi
        t "$TMP/${name}_${lv}"
        rc=$?
        if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
            echo "FAIL run $name $lv: timeout after ${TIMEOUT}s"
            fail=$((fail+1))
        elif [ "$rc" -eq "$expect" ]; then
            pass=$((pass+1))
        else
            echo "FAIL run $name $lv: exit $rc, want $expect"
            fail=$((fail+1))
        fi
    done
done
echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

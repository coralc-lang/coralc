#!/bin/bash
# Wallvm IR pipeline test runner: .ir -> irtool (parse + irCompileAsm) ->
# gcc assemble/link -> run -> compare exit code against "; expect:".
set -u
cd "$(dirname "$0")"
CORALC="${CORALC:-coralc}"
LEVELS="${LEVELS:-O0 O1 O2 O3}"
TMP=/tmp/opencode/wallvm-tests
mkdir -p "$TMP"

if [ ! -x ./irtool ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building irtool..."
    "$CORALC" irtool.crl -o irtool || exit 1
fi

pass=0
fail=0
for case in cases/*.ir; do
    name=$(basename "$case" .ir)
    expect=$(sed -n 's/^; expect: *//p' "$case" | head -1)
    [ -z "$expect" ] && expect=0
    for lv in $LEVELS; do
        if ! ./irtool "$case" "$TMP/${name}_${lv}.s" "$lv" 2>"$TMP/${name}_${lv}.err"; then
            echo "FAIL compile $name $lv"
            cat "$TMP/${name}_${lv}.err"
            fail=$((fail+1))
            continue
        fi
        if ! gcc -o "$TMP/${name}_${lv}" "$TMP/${name}_${lv}.s" 2>"$TMP/${name}_${lv}.link.err"; then
            echo "FAIL link $name $lv"
            cat "$TMP/${name}_${lv}.link.err"
            fail=$((fail+1))
            continue
        fi
        "$TMP/${name}_${lv}"
        rc=$?
        if [ "$rc" -eq "$expect" ]; then
            pass=$((pass+1))
        else
            echo "FAIL run $name $lv: exit $rc, want $expect"
            fail=$((fail+1))
        fi
    done
done
echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

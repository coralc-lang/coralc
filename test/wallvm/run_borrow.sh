#!/bin/bash
# Borrow-checker diagnostic runner: parse each borrow/*.ir with
# WALLVM_BORROW_CHECK=1 and compare the set of violation kinds printed
# against the case's "// borrow-expect:" line (space-separated kinds, or
# "none"). Violation cases must exit 3; clean cases fall through to a
# normal compile and must exit 0.
set -u
cd "$(dirname "$0")"
TIMEOUT="${TIMEOUT:-15}"
OUT=/home/cerie/Documents/coral/test/wallvm/output
mkdir -p "$OUT"

if [ ! -x ./irtool ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building irtool..."
    CORALC="${CORALC:-coralc}" "$CORALC" irtool.crl -o irtool || exit 1
fi

t() { timeout --kill-after=5 "$TIMEOUT" "$@"; }

pass=0
fail=0
for case in borrow/*.ir; do
    name=$(basename "$case" .ir)
    expect=$(sed -n 's|^// *borrow-expect: *||p' "$case" | head -1)
    [ -z "$expect" ] && expect="none"
    exp_sorted=$(echo "$expect" | tr ' ' '\n' | grep -v '^$' | sort | tr '\n' ' ' | sed 's/ $//')
    want_rc=0
    [ "$exp_sorted" != "none" ] && want_rc=3

    echo "BORROW $name (expect: $exp_sorted, rc $want_rc)"
    t env WALLVM_BORROW_CHECK=1 ./irtool "$case" "$OUT/${name}.s" O0 2>"$OUT/${name}.err"
    rc=$?
    kinds=$(grep -o '^borrow: [A-Za-z]*:' "$OUT/${name}.err" | sed 's/^borrow: //; s/:$//' | sort -u | tr '\n' ' ' | sed 's/ $//')
    [ -z "$kinds" ] && kinds="none"

    if [ "$rc" -ne "$want_rc" ]; then
        echo "FAIL $name: exit $rc, want $want_rc"
        cat "$OUT/${name}.err"
        fail=$((fail+1))
        continue
    fi
    if [ "$kinds" != "$exp_sorted" ]; then
        echo "FAIL $name: kinds [$kinds], want [$exp_sorted]"
        cat "$OUT/${name}.err"
        fail=$((fail+1))
        continue
    fi
    pass=$((pass+1))
done
echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

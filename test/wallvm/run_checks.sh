#!/bin/bash
# Safety-check instrumentation runner: verifies that O0 inserts
# `call _trap` (and that programs behave — in-bounds passes with the
# original result, violations exit 70 through trap_stub.c), that O2
# inserts nothing, and that WALLVM_CHECKS=0 disables everything.
set -u
cd "$(dirname "$0")"
CORALC="${CORALC:-coralc}"
TMP=/tmp/opencode/wallvm-checks
OUT=output
TIMEOUT="${TIMEOUT:-15}"
mkdir -p "$TMP" "$OUT"

if [ ! -x ./irtool ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building irtool..."
    "$CORALC" irtool.crl -o irtool || exit 1
fi

t() { timeout --kill-after=5 "$TIMEOUT" "$@"; }

pass=0
fail=0
ok()  { pass=$((pass+1)); }
bad() { echo "FAIL $1"; fail=$((fail+1)); }

for case in checks/*.ir; do
    name=$(basename "$case" .ir)
    expect=$(sed -n 's|^// *expect: *||p' "$case" | head -1)
    [ -z "$expect" ] && expect=0

    # O0: instrumented — the asm must reference _trap
    if ! t ./irtool "$case" "$OUT/chk_${name}_O0.s" O0 2>"$TMP/${name}_O0.err"; then
        bad "$name O0 compile"; cat "$TMP/${name}_O0.err"; continue
    fi
    if ! grep -q "5_trap" "$OUT/chk_${name}_O0.s"; then
        bad "$name O0: no _trap in instrumented asm"; continue
    fi
    ok

    # dominance dedup: the dominated duplicate geps collapse into their
    # dominating original — exactly one unconditional call remains
    if [ "$name" = "dedup" ]; then
        n=$(grep -c "call.*5_trap" "$OUT/chk_${name}_O0.s" || true)
        if [ "$n" -eq 1 ]; then ok; else bad "dedup O0: $n trap calls, want 1"; fi
    fi

    # O0 run: trap_stub returns on safe checks, exits 70 on violations
    if ! t gcc -o "$TMP/${name}_O0" "$OUT/chk_${name}_O0.s" trap_stub.c 2>"$TMP/${name}_O0.link"; then
        bad "$name O0 link"; cat "$TMP/${name}_O0.link"; continue
    fi
    t "$TMP/${name}_O0"; rc=$?
    if [ "$rc" -eq "$expect" ]; then ok; else bad "$name O0 run: exit $rc want $expect"; fi

    # O2: release — no instrumentation in the asm
    if ! t ./irtool "$case" "$OUT/chk_${name}_O2.s" O2 2>"$TMP/${name}_O2.err"; then
        bad "$name O2 compile"; cat "$TMP/${name}_O2.err"; continue
    fi
    if grep -q "5_trap" "$OUT/chk_${name}_O2.s"; then
        bad "$name O2: _trap present at release"
        continue
    fi
    ok

    # clean programs also run at O2 (same behavior, no checks)
    if [ "$name" = "clean" ]; then
        if ! t gcc -o "$TMP/${name}_O2" "$OUT/chk_${name}_O2.s" trap_stub.c 2>"$TMP/${name}_O2.link"; then
            bad "$name O2 link"; cat "$TMP/${name}_O2.link"; continue
        fi
        t "$TMP/${name}_O2"; rc=$?
        if [ "$rc" -eq "$expect" ]; then ok; else bad "$name O2 run: exit $rc want $expect"; fi
    fi
done

# WALLVM_CHECKS=0: even O0 inserts nothing (direct invocation so the
# environment does not leak through a shell function)
if timeout --kill-after=5 "$TIMEOUT" env WALLVM_CHECKS=0 ./irtool checks/clean.ir "$OUT/chk_off_O0.s" O0 2>"$TMP/off.err"; then
    if grep -q "5_trap" "$OUT/chk_off_O0.s"; then
        bad "WALLVM_CHECKS=0: _trap still present"
    else
        ok
    fi
else
    bad "WALLVM_CHECKS=0 compile"; cat "$TMP/off.err"
fi

echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

#!/bin/bash
# Alias-analysis test runner: feeds each cases_aa/*.ir through
# muvm_tool --only alias_analysis --verbose and compares the filtered
# analysis dump (objects, value->object map, mayClobber query verdicts)
# against expected_aa/<name>.gold byte-for-byte.
#
# The goldens were hand-verified against each fixture's semantics:
#   - distinct allocas/globals must produce NoAlias (mayClobber = 0)
#   - same-object accesses must produce mayClobber = 1
#   - unknown pointers (loads, calls, mixed phis) must stay UNKNOWN and
#     therefore may-alias everything
set -u
cd "$(dirname "$0")"
CORALC="${CORALC:-coralc}"
CASES="${CASES:-cases_aa}"
EXPECTED="${EXPECTED:-expected_aa}"
TMP=/tmp/opencode/muvm-aa
TIMEOUT="${TIMEOUT:-15}"
mkdir -p "$TMP"

if [ ! -x ./muvm_tool ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building muvm_tool..."
    "$CORALC" muvm_tool.crl -o muvm_tool || exit 1
fi

t() { timeout --kill-after=5 "$TIMEOUT" "$@"; }

pass=0
fail=0
for case in "$CASES"/*.ir; do
    name=$(basename "$case" .ir)
    t ./muvm_tool "$case" /dev/null O2 --only alias_analysis --verbose 2>&1 \
        | grep -E '^aa:|^  obj| -> obj|query' > "$TMP/$name.out"
    rc=${PIPESTATUS[0]}
    if [ "$rc" -ne 0 ]; then
        echo "FAIL driver $name (exit $rc)"
        fail=$((fail+1))
        continue
    fi
    if [ ! -f "$EXPECTED/$name.gold" ]; then
        echo "FAIL missing golden $EXPECTED/$name.gold"
        fail=$((fail+1))
        continue
    fi
    if ! diff -u "$EXPECTED/$name.gold" "$TMP/$name.out" > "$TMP/$name.diff"; then
        echo "FAIL $name"
        cat "$TMP/$name.diff"
        fail=$((fail+1))
        continue
    fi
    pass=$((pass+1))
done
echo "aa: pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

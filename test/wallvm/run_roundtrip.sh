#!/bin/bash
# IR printer round-trip harness: parse -> print (p1) -> reparse -> print
# (p2), and require the printer output to be a fixed point (hash equality).
# No new .ir inputs: it walks the existing cases/ and passes/ corpora.
set -u
cd "$(dirname "$0")"
CORALC="${CORALC:-coralc}"
OUT=output/roundtrip
TMP=/home/cerie/Documents/coral/test/wallvm/output
TIMEOUT="${TIMEOUT:-15}"
mkdir -p "$TMP" "$OUT"

if [ ! -x ./irtool ] || [ "${REBUILD:-0}" = "1" ]; then
    echo "building irtool..."
    "$CORALC" irtool.crl -o irtool || exit 1
fi

t() { timeout --kill-after=5 "$TIMEOUT" "$@"; }

pass=0
fail=0
for f in cases/*.ir passes/*.ir; do
    name=$(basename "$f" .ir)
    p1="$OUT/${name}.p1.ir"
    p2="$OUT/${name}.p2.ir"
    echo "ROUNDTRIP $name"
    t ./irtool --emit-ir "$f" > "$p1" 2>"$TMP/${name}_rt.err"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "FAIL parse $name (exit $rc)"
        cat "$TMP/${name}_rt.err"
        fail=$((fail+1))
        continue
    fi
    t ./irtool --emit-ir "$p1" > "$p2" 2>>"$TMP/${name}_rt.err"
    rc=$?
    if [ "$rc" -ne 0 ]; then
        echo "FAIL reparse $name (exit $rc)"
        cat "$TMP/${name}_rt.err"
        fail=$((fail+1))
        continue
    fi
    h1=$(sha256sum "$p1" | cut -d' ' -f1)
    h2=$(sha256sum "$p2" | cut -d' ' -f1)
    if [ "$h1" = "$h2" ]; then
        pass=$((pass+1))
    else
        echo "FAIL fixed-point $name: print output differs after reparse"
        diff "$p1" "$p2" | head -20
        fail=$((fail+1))
    fi
done
echo "roundtrip: $pass passed, $fail failed"
[ "$fail" -eq 0 ]

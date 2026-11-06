#!/bin/bash
# Pass-effectiveness runner: asserts that the optimizer passes actually
# do their job. Each passes/*.ir declares the level to compile at, the
# runtime result the optimized program must still compute, and asm
# fingerprints of the targeted pass:
#   // level: O1        (default O1)
#   // expect: N        exit code when the binary runs
#   // absent: regex    asm must NOT match
#   // present: regex   asm must match
#   // count: N, regex  asm must match the pattern on exactly N lines
set -u
cd "$(dirname "$0")"
CORALC="${CORALC:-coralc}"
TMP=/tmp/opencode/wallvm-passes
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

for case in passes/*.ir; do
    name=$(basename "$case" .ir)
    level=$(sed -n 's|^// *level: *||p' "$case" | head -1)
    [ -z "$level" ] && level=O1
    expect=$(sed -n 's|^// *expect: *||p' "$case" | head -1)
    [ -z "$expect" ] && expect=0
    asm="$OUT/pass_${name}_${level}.s"

    if ! t ./irtool "$case" "$asm" "$level" 2>"$TMP/${name}.err"; then
        bad "$name compile"; cat "$TMP/${name}.err"; continue
    fi

    while IFS= read -r pat; do
        if grep -q -- "$pat" "$asm"; then
            bad "$name absent: '$pat' present"
        else
            ok
        fi
    done < <(sed -n 's|^// *absent: *||p' "$case")

    while IFS= read -r pat; do
        if grep -q -- "$pat" "$asm"; then
            ok
        else
            bad "$name present: '$pat' missing"
        fi
    done < <(sed -n 's|^// *present: *||p' "$case")

    while IFS= read -r line; do
        n=${line%%,*}
        pat=${line#*,}
        pat=${pat# }
        got=$(grep -c -- "$pat" "$asm" || true)
        if [ "$got" -eq "$n" ]; then
            ok
        else
            bad "$name count: '$pat' got $got want $n"
        fi
    done < <(sed -n 's|^// *count: *||p' "$case")

    # the optimized program still computes the declared result
    if ! t gcc -o "$TMP/$name" "$asm" 2>"$TMP/${name}.link"; then
        bad "$name link"; cat "$TMP/${name}.link"; continue
    fi
    t "$TMP/$name"; rc=$?
    if [ "$rc" -eq "$expect" ]; then
        ok
    else
        bad "$name run: exit $rc want $expect"
    fi
done

echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

/* Link stub for the resolved core/error `_trap` (mangle.md), the wallvm
 * safety-check handler (test harness). Real programs get it from
 * core/error.crl; the harness links only generated .s, so this provides
 * the same entry point with the same contract: return when the guarded
 * operation is safe, print the failing site to stdout and exit(70)
 * otherwise so `// expect: 70` asserts that a check fired. Kinds: 0
 * bounds, 1 null, 2 divzero, 3 overflow, 4 badvariant. */
#include <stdio.h>
#include <stdlib.h>

void _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v(
    unsigned long kind, unsigned long a, unsigned long b,
    const char* file, unsigned long line, const char* fn)
{
    if (kind == 0) { if (a < b) return; }
    else if (kind == 1 || kind == 2) { if (a != 0) return; }
    else if (kind == 3) { if (a == 0) return; }
    else if (kind == 4) { if (a < b) return; }
    printf("trap kind=%lu a=%lu b=%lu %s:%lu in %s\n",
           kind, a, b, file ? file : "?", line, fn ? fn : "?");
    exit(70);
}

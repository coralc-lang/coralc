/* Link stub for _trap, the wallvm safety-check handler (test harness).
 * Real programs get _trap from each platform's std error.crl; the harness
 * links only generated .s, so this provides the same entry point with the
 * same contract: return when the guarded operation is safe, print the
 * failing site to stdout and exit(70) otherwise so `// expect: 70`
 * asserts that a check fired. Kinds: 0 bounds, 1 null, 2 divzero,
 * 3 overflow, 4 badvariant. */
#include <stdio.h>
#include <stdlib.h>

void _trap(unsigned long kind, unsigned long a, unsigned long b,
           const char* file, unsigned long line)
{
    if (kind == 0) { if (a < b) return; }
    else if (kind == 1 || kind == 2) { if (a != 0) return; }
    else if (kind == 3) { if (a == 0) return; }
    else if (kind == 4) { if (a < b) return; }
    printf("trap kind=%lu a=%lu b=%lu %s:%lu\n",
           kind, a, b, file ? file : "?", line);
    exit(70);
}

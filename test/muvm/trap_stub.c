/* Link stub for the default `_trap` symbol used by muvm's safety checks.
 * The library default is the plain C name; embeddings that want a
 * different symbol override MuvmOptions.trapName with their own handler
 * (coral's core/error.crl exports the same ABI under a mangled name).
 * Contract: return when the guarded operation is safe, print the failing
 * site and exit(70) otherwise. Kinds: 0 bounds, 1 null, 2 divzero,
 * 3 overflow, 4 badvariant. */
#include <stdio.h>
#include <stdlib.h>

void _trap(unsigned long kind, unsigned long a, unsigned long b,
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

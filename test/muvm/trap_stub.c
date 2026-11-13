/* Link stub for the default `_trap` symbol used by muvm's safety checks.
 * The library default is the plain C name; embeddings that want a
 * different symbol override MuvmOptions.trapName with their own handler
 * (coral's core/error.crl exports the same ABI under a mangled name).
 * Contract: return when the guarded operation is safe, print the failing
 * site (file:line in fn) and exit(70) otherwise. */
#include <stdio.h>
#include <stdlib.h>

void _trap(unsigned long kind, unsigned long a, unsigned long b,
           const char* file, unsigned long line, const char* fn)
{
    if (kind == 0) { if (a < b) return; }
    else if (kind == 1 || kind == 2) { if (a != 0) return; }
    else if (kind == 3) { if (a == 0) return; }
    else if (kind == 4) { if (a < b) return; }

    fprintf(stderr, "trap %s:%lu in %s: ", file ? file : "?", line, fn ? fn : "?");
    switch (kind)
    {
        case 0: fprintf(stderr, "bounds: index %lu out of bounds for length %lu\n", a, b); break;
        case 1: fprintf(stderr, "null dereference of %#016lx\n", a); break;
        case 2: fprintf(stderr, "division by zero (divisor %lu)\n", a); break;
        case 3: fprintf(stderr, "integer overflow (a=%lu, b=%lu)\n", a, b); break;
        case 4: fprintf(stderr, "invalid variant tag %lu for %lu variants\n", a, b); break;
        default: fprintf(stderr, "unknown trap kind %lu (a=%lu, b=%lu)\n", kind, a, b); break;
    }
    exit(70);
}

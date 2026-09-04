// Coral C++ source
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#include "build_ios-imp.hpp"

int32_t main()
{
    double e = 3.14;
    printf("The Value of pi is: %f, %llu", e, truncF(e));
    return 0;
}


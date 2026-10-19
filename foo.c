#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <assert.h>

extern int memcmp(const void*, const void*, size_t);

#undef INT8_MIN
#undef INT8_MAX
#undef INT16_MIN
#undef INT16_MAX
#undef INT32_MIN
#undef INT32_MAX
#undef INT64_MIN
#undef INT64_MAX

typedef struct _coral_str { const uint8_t* ptr; size_t len; } _coral_str;
static bool _coral_streq(_coral_str a, _coral_str b) { return a.len == b.len && memcmp(a.ptr, b.ptr, a.len) == 0; }
static bool _coral_strtruth(_coral_str s) { return s.len > 0; }
typedef struct crl__loc____foo crl__loc____foo;
struct crl__loc____foo {
    _coral_str boy;
    _coral_str girl;
    _Bool full;
};

crl__loc____foo crl__loc____foo_new(void);
_Bool crl__loc____foo_equals(crl__loc____foo* self, crl__loc____foo other);
void crl__loc____foo_drop(crl__loc____foo* self);
void main(void);
crl__loc____foo crl__loc____foo_new(void) {
    return ((crl__loc____foo){.boy = (_coral_str){ (const uint8_t*)"gay", 3 }, .girl = (_coral_str){ (const uint8_t*)"gay gay", 7 }, .full = 1});
}
_Bool crl__loc____foo_equals(crl__loc____foo* self, crl__loc____foo other) {
    return ((_coral_streq(self->boy, other.boy)) && (_coral_streq(self->girl, other.girl)));
}
void crl__loc____foo_drop(crl__loc____foo* self) {
    ((self->boy = (_coral_str){ (const uint8_t*)"", 0 }));
    ((self->girl = (_coral_str){ (const uint8_t*)"", 0 }));
}
void main(void) {
    crl__loc____foo c = crl__loc____foo_new();
    crl__loc____foo d = crl__loc____foo_new();
    int32_t a = 0;
    while (1)
    {
        if (crl__loc____foo_equals((&(c)), d))
        {
            break;
        }
        if (((a == 10)))
        {
            break;
        }
    }
    ((d.full = 0));
    crl__loc____foo_drop(&c);
}
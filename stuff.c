int gx = 4;
int gy = 4;

int main(void) {
    int x = gx, y = gy;
    _Bool c = x == y;
    if (c) {
        _Bool e = x == y;
        if (e) return 1;
    } else {
        return 2;
    }
}

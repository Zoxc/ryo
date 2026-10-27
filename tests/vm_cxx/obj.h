/* The C++ exception the callbacks throw, counting its live copies. */
#include <cstdint>
#include <cstdio>

extern "C" {
void vcx_init(void);
uint32_t vcx_through(void (*cb)(uint32_t), uint32_t n);
void vcx_catcher(void (*cb)(uint32_t), uint32_t n);
void vcx_terminate(void (*cb)(uint32_t), uint32_t n);
void vcx_bomb(void (*cb)(uint32_t), uint32_t n);
}

static int live = 0;

struct Obj {
    int v;
    Obj(int v) : v(v) {
        live++;
        printf("Obj(%d)\n", v);
    }
    Obj(const Obj &o) : v(o.v) {
        live++;
        printf("copy Obj(%d)\n", v);
    }
    ~Obj() {
        live--;
        printf("~Obj(%d)\n", v);
    }
};

static void thrower(uint32_t n) {
    if (n > 0) {
        throw Obj((int)n);
    }
}

/* Unbuffered, so that the lines interleave with Rust's in order. */
static void init(void) {
    setvbuf(stdout, nullptr, _IONBF, 0);
    vcx_init();
}

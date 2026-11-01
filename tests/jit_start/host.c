/* Loads the cdylib `jitlib.rs` at run time (argv[1]), calls into it, unloads it and runs on, for
   the `jit-start` check. */
#include <stdint.h>
#include <stdio.h>

#ifdef _WIN32
#include <windows.h>
#define LOAD(p) ((void *)LoadLibraryA(p))
#define SYM(h, n) ((void *)GetProcAddress((HMODULE)(h), n))
#define UNLOAD(h) FreeLibrary((HMODULE)(h))
#else
#include <dlfcn.h>
#define LOAD(p) dlopen(p, RTLD_NOW)
#define SYM(h, n) dlsym(h, n)
#define UNLOAD(h) dlclose(h)
#endif

typedef uint64_t (*ctor_fn)(void);
typedef uint64_t (*hot_fn)(uint64_t);

int main(int argc, char **argv) {
    if (argc < 2) return 2;
    void *h = LOAD(argv[1]);
    if (!h) {
        printf("load failed\n");
        return 1;
    }
    ctor_fn ctor = (ctor_fn)SYM(h, "jitlib_ctor");
    hot_fn hot = (hot_fn)SYM(h, "jitlib_hot");
    if (!ctor || !hot) return 1;
    uint64_t sum = 0;
    for (int i = 0; i < 1000; i++) sum += hot(100);
    printf("ctor %llu hot %llu\n", (unsigned long long)ctor(), (unsigned long long)sum);
    UNLOAD(h);
    /* Runs on after the unload (a no-op: the JIT pinned the library). */
    volatile uint64_t x = 0;
    for (int i = 0; i < 1000000; i++) x += (uint64_t)i;
    printf("unloaded %llu\n", (unsigned long long)x);
    return 0;
}

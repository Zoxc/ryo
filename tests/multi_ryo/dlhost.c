// A C program (no ryo runtime of its own) loading the sibling Rust dylibs `argv[1]` (`da`) and
// `argv[2]` (`db`), which share one std, and closing them again: whichever runtime copy
// merges must stay loaded (pinned), since the other copy's registry or rendezvous page
// refers to it. `da` registers first and wins, then is closed before its JIT starts; `db`
// joins (forwarding to `da`'s copy), runs hot, and is closed. Prints the result and whether
// each library is still loaded after its `dlclose`.
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

static void *open_or_die(const char *path, int mode) {
    void *h = dlopen(path, mode);
    if (!h) {
        fprintf(stderr, "dlopen: %s\n", dlerror());
        _exit(1);
    }
    return h;
}

int main(int argc, char **argv) {
    (void)argc;
    dlclose(open_or_die(argv[1], RTLD_NOW | RTLD_LOCAL));
    int a_loaded = dlopen(argv[1], RTLD_NOW | RTLD_NOLOAD) != NULL;
    void *b = open_or_die(argv[2], RTLD_NOW | RTLD_LOCAL);
    uint64_t (*run)(uint64_t) = (uint64_t (*)(uint64_t))dlsym(b, "db_run");
    uint64_t s = 0;
    for (int i = 0; i < 200; i++) s += run(100);
    dlclose(b);
    int b_loaded = dlopen(argv[2], RTLD_NOW | RTLD_NOLOAD) != NULL;
    printf("%llu\nloaded after dlclose: %d %d\n", (unsigned long long)s, a_loaded, b_loaded);
    return 0;
}

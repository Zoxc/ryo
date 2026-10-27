/* An access violation in a C callback below VM frames with drops (`lib.rs`), caught by
   `__except` above them: the drops run (or not) as for native Rust frames. windows-msvc only. */
#include <stdio.h>
#include <windows.h>

unsigned vse_guarded(void (*cb)(unsigned), unsigned n);

static void poke(unsigned n) {
    if (n > 0) {
        *(volatile int *)0 = (int)n;
    }
}

int main(void) {
    setvbuf(stdout, NULL, _IONBF, 0);
    printf("%u\n", vse_guarded(poke, 0));
    __try {
        vse_guarded(poke, 1);
        printf("not reached\n");
    } __except (GetExceptionCode() == EXCEPTION_ACCESS_VIOLATION ? EXCEPTION_EXECUTE_HANDLER : EXCEPTION_CONTINUE_SEARCH) {
        printf("caught AV\n");
    }
    printf("done\n");
    return 0;
}

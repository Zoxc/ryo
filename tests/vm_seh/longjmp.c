/* `longjmp` from a C callback over VM frames without drops (`lib.rs`, `plain`), back to the
   `setjmp` in `main`. */
#include <setjmp.h>
#include <stdio.h>

unsigned vse_plain(void (*cb)(unsigned), unsigned n);

static jmp_buf env;

static void jumper(unsigned n) {
    if (n > 2) {
        longjmp(env, (int)n);
    }
}

int main(void) {
    setvbuf(stdout, NULL, _IONBF, 0);
    int r = setjmp(env);
    if (r == 0) {
        printf("%u\n", vse_plain(jumper, 1));
        vse_plain(jumper, 5);
        printf("not reached\n");
    } else {
        printf("jumped %d\n", r);
    }
    return 0;
}

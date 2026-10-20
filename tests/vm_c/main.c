/* Calls the Rust library `vm_c/lib.rs` (linked as a staticlib or a cdylib). */
#include <stdio.h>

int vmc_answer(void);

int main(void) {
    printf("%d\n", vmc_answer());
    return 0;
}

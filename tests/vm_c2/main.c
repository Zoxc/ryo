/* Calls two Rust staticlibs, `vm_c2/a.rs` and `vm_c2/b.rs`, each with its own registry stub. */
#include <stdio.h>

int vma_answer(void);
int vmb_answer(void);

int main(void) {
    printf("%d %d\n", vma_answer(), vmb_answer());
    return 0;
}

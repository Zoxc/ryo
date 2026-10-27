/* A C++ exception reaching a VM function that can't unwind (`lib.rs`, `nounwind`): the frames
   inside it unwind, then `panic_cannot_unwind` aborts (the exit status is compared too). */
#include "obj.h"

int main() {
    init();
    try {
        vcx_terminate(thrower, 0);
        printf("returned\n");
        vcx_terminate(thrower, 5);
        printf("not reached\n");
    } catch (Obj &o) {
        printf("caught %d\n", o.v);
    }
    return 0;
}

/* A C++ exception unwinding through a VM frame whose drop panics (`lib.rs`, `with_bomb`):
   "panic in a destructor during cleanup" aborts (the exit status is compared too). */
#include "obj.h"

int main() {
    init();
    try {
        vcx_bomb(thrower, 0);
        printf("returned\n");
    } catch (Obj &o) {
        printf("caught %d\n", o.v);
    }
    try {
        vcx_bomb(thrower, 3);
        printf("not reached\n");
    } catch (Obj &o) {
        printf("caught %d\n", o.v);
    }
    return 0;
}

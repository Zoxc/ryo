/* C++ exceptions through VM frames to a C++ catch (`lib.rs`): the drops run innermost first,
   the catch gets the thrown object, and a drop catching a panic of its own on the way doesn't
   disturb it. */
#include "obj.h"

int main() {
    init();
    printf("%u\n", vcx_through(thrower, 0));
    try {
        vcx_through(thrower, 42);
        printf("not thrown\n");
    } catch (Obj &o) {
        printf("caught %d, live %d\n", o.v, live);
    }
    try {
        vcx_catcher(thrower, 7);
    } catch (const Obj &o) {
        printf("caught %d, live %d\n", o.v, live);
    }
    printf("live %d\n", live);
    return 0;
}

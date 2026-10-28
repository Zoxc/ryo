#include <stdio.h>
#include <stdint.h>
uint64_t a_run(uint64_t); uint64_t b_run(uint64_t); uint64_t c_run(uint64_t);
int main(void){ uint64_t a=0,b=0,c=0; for(int i=0;i<200;i++){a+=a_run(1000);b+=b_run(50);c+=c_run(100);} printf("%llu %llu %llu\n",(unsigned long long)a,(unsigned long long)b,(unsigned long long)c); return 0; }

#include <xc.h>

extern unsigned int count_primes(unsigned int a,unsigned int b);
void main(void) {
    volatile unsigned int ans = count_primes(35677,65521);
    while(1);
    return;
}


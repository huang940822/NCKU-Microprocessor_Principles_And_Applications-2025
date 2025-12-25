#include <xc.h>

extern unsigned int is_prime(unsigned int a);


void main(void) {
    volatile unsigned int result = is_prime(107);
    while(1);
    return;
}

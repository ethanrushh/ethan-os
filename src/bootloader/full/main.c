#include "stdint.h"
#include "stdio.h"

void _cdecl cstart_(uint16_t bootDrive)
{
    int iterations = 0;

    puts("Successfully started EthanOS");
    printf("Testing formatting: %% %c %s\r\n", 'a', "string");
    printf("Testing more formatting: %d %i %x %p %o\r\n", 1234, 5678, 0xdead, 0xbeef);

    for(;;) 
    {
        //printf("Iteration %d\r\n", iterations);
        //iterations++;
    }
}

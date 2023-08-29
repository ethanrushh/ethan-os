#include "stdint.h"
#include "stdio.h"

void _cdecl cstart_(uint16_t bootDrive)
{
    int i = 5;

    while (i > 0) {
        puts(" < i is ");
        putc(i + '0');
        puts(" > ");
        i = i - 1;
    }

    for(;;);
}

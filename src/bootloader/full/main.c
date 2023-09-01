#include <stdint.h>
#include "stdio.h"


void __attribute((cdecl)) start(uint16_t bootDrive)
{
    clrscr();
    printf("Hello from stage 2\r\n");
    printf("Fuck your life bing bong\r\n");
    printf("What would you like to tell Joe Biden right now?\r\n");

    for(;;);
}

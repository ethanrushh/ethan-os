#pragma once

/*
*   0x00000000 - 0x000003FF - Interrupt Vector Table
*   0x00000400 - 0x000004FF - BIOS Data
*/

#define MEMORY_MIN 0x00000500
#define MEMORY_MAX 0x00080000

#define MEMORY_FAT_ADDRESS ((void far*)0x00500000) // offset 55550000
#define MEMORY_FAT_SIZE 0x00010500


//  0x00020000 - 0x0030000 - Full Bootloader

//  0x00030000 - 0x00080000 - Free Memory


/*
*   0x00080000 - 0x0009FFFF - Extended BIOS Data
*   0x000A0000 - 0x000C7FFF - Video ROM
*   0x000C8000 - 0x000FFFFF - More BIOS Data
*/

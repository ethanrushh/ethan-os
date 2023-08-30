#include "stdint.h"
#include "stdio.h"
#include "disk.h"
#include "fat.h"

void _cdecl cstart_(uint16_t bootDrive)
{
    DISK disk;
    if (!DISK_Initialize(&disk, bootDrive))
    {
        log(INFO, "Disk init error");
        goto end;
    }

    if (!FAT_Initialize(&disk))
    {
        log(INFO, "FAT init error");
        goto end;
    }

    FAT_File far* fd = FAT_Open(&disk, "/");
    FAT_DirectoryEntry entry;
    while (FAT_ReadEntry(&disk, fd, &entry))
    {
        printf("  ");
        for (int i = 0; i < 11; i++)
            putc(entry.Name[i]);
        printf("\r\n");
    }
    FAT_Close(fd);

    puts("Successfully started EthanOS\r\n\r\n");
    printf("Testing formatting: %% %c %s\r\n", 'a', "string");
    printf("Testing more formatting: %d %i %x %p %o\r\n", -1234, 5678, 0xdead, 0xbeef);


end:
    for (;;);
}

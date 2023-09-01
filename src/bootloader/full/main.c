#include "stdint.h"
#include "stdio.h"
#include "disk.h"
#include "fat.h"

#define EVER ;;

void far* g_data = (void far*)0x00500200;

void _cdecl cstart_(uint16_t bootDrive)
{
    SetVideoMode();
    log(VIDEO, "BIOS VESA mode to Graphics");

    log(IO, "OK"); // idk, if we've gotten this far then IO must be fine


    log(INFO, "Printing root DIR");

    
    DISK disk;
    if (!DISK_Initialize(&disk, bootDrive))
    {
        printf("Disk init error\r\n");
        goto end;
    }

    DISK_ReadSectors(&disk, 19, 1, g_data);

    if (!FAT_Initialize(&disk))
    {
        printf("FAT init error\r\n");
        goto end;
    }

    // browse files in root
    FAT_File far* fd = FAT_Open(&disk, "/");
    FAT_DirectoryEntry entry;
    int i = 0;
    while (FAT_ReadEntry(&disk, fd, &entry) && i++ < 5)
    {
        printf("  ");
        for (int i = 0; i < 11; i++)
            putc(entry.Name[i]);
        printf("\r\n");
    }
    FAT_Close(fd);




    //catFile("test.txt", disk);

    goto end;


// Hang
end:
    for (;;);
}

void catFile(const char* absolutePath, DISK disk)
{
    FAT_File far* fd = FAT_Open(&disk, "/");

    // read test.txt
    char buffer[100];
    uint32_t read;
    fd = FAT_Open(&disk, absolutePath);
    while ((read = FAT_Read(&disk, fd, sizeof(buffer), buffer)))
    {
        for (uint32_t i = 0; i < read; i++)
        {
            if (buffer[i] == '\n')
                putc('\r');
            putc(buffer[i]);
        }
    }
    printf("\r\n");
    FAT_Close(fd);
}

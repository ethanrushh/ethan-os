#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef uint8_t bool;
#define true 1
#define false 0


typedef struct {
    uint8_t BootJumpInstruction[3];
    uint8_t OemIdentifier[8];
    uint16_t BytesPerSector;
    uint8_t SectorsPerClustor;
    uint16_t ReservedSectors;
    uint8_t FatCount;
    uint16_t DirEntryCount;
    uint16_t TotalSectors;
    uint8_t MediaDescriptorType;
    uint16_t SectorsPerFat;
    uint16_t SectorsPerTrack;
    uint16_t Heads;
    uint32_t HiddenSectors;
    uint32_t LargeSectorCount;

    // EBR
    uint8_t DriveNumber;
    uint8_t _Reserved;
    uint8_t Signature;
    uint32_t VolumeId;
    uint8_t VolumeLabel[11];
    uint8_t SystemId[8];
} __attribute__((packed)) BootSector;

typedef struct {
    uint8_t Name[11];
    uint8_t Attributes;
    uint8_t _Reserved;
    uint8_t CreatedTimeTenths;
    uint16_t CreatedTime;
    uint16_t CreatedDate;
    uint16_t AccessedDate;
    uint16_t FirstClusterHigh;
    uint16_t ModifiedTime;
    uint16_t ModifiedDate;
    uint16_t FirstClusterLow;
    uint32_t Size;
} __attribute__((packed)) DirectoryEntry;


BootSector g_BootSector;
uint8_t* g_Fat = NULL;
DirectoryEntry* g_RootDirectory = NULL;
uint32_t g_RootDirectoryEnd;


bool readBootSector(FILE* disk) 
{
    return fread(&g_BootSector, sizeof(g_BootSector), 1, disk) > 0;
}

bool readSectors(FILE* disk, uint32_t lba, uint32_t count, void* bufferOut) 
{
    bool success = true;
    success = success && (fseek(disk, lba * g_BootSector.BytesPerSector, SEEK_SET) == 0);
    success = success && (fread(bufferOut, g_BootSector.BytesPerSector, count, disk) == count);
    return success;
}

bool readFat(FILE* disk) 
{
    g_Fat = (uint8_t*) malloc(g_BootSector.SectorsPerFat * g_BootSector.BytesPerSector);
    return readSectors(disk, g_BootSector.ReservedSectors, g_BootSector.SectorsPerFat, g_Fat);
}

bool readRootDirectry(FILE* disk) {
    uint32_t lba = g_BootSector.ReservedSectors + g_BootSector.SectorsPerFat * g_BootSector.FatCount;
    uint32_t totalSize = sizeof(DirectoryEntry) * g_BootSector.DirEntryCount;
    uint32_t sectors = (totalSize / g_BootSector.BytesPerSector);
    
    if (totalSize % g_BootSector.BytesPerSector > 0)
        sectors++;

    g_RootDirectoryEnd = lba + sectors;
    g_RootDirectory = (DirectoryEntry*) malloc(sectors * g_BootSector.BytesPerSector);
    return readSectors(disk, lba, sectors, g_RootDirectory);
}

DirectoryEntry* findFile(const char* name) 
{
    for (uint32_t i = 0; i < g_BootSector.DirEntryCount; i++) {
        if (memcmp(name, g_RootDirectory[i].Name, 11) == 0) {
            return &g_RootDirectory[i];
        }
    }

    return NULL;
}

bool readFile(DirectoryEntry* fileEntry, FILE* disk, uint8_t* outputBuffer) 
{
    bool success = true;
    uint16_t currentCluster = fileEntry -> FirstClusterLow;

    do {
        uint32_t lba = g_RootDirectoryEnd + (currentCluster - 2) * g_BootSector.SectorsPerClustor;
        success = success && readSectors(disk, lba, g_BootSector.SectorsPerClustor, outputBuffer);
        outputBuffer += g_BootSector.SectorsPerClustor * g_BootSector.BytesPerSector;

        uint32_t fatIndex = currentCluster * 3 / 2;

        if (currentCluster % 2 == 0)
            currentCluster = (*(uint16_t*)(g_Fat + fatIndex)) & 0x0FFF;
        else
            currentCluster = (*(uint16_t*)(g_Fat + fatIndex)) >> 4;

    } while (success && currentCluster < 0xFF8);

    return success;
}


int main(int argc, char** argv) 
{
    if (argc < 3) {
        printf("Invalid number of arguments\n");
        printf("Syntax: %s <disk image> <file name>\n", argv[0]);
        return -1;
    }

    FILE* disk = fopen(argv[1], "rb");
    if (!disk) {
        fprintf(stderr, "Failed to open disk image %s!\n", argv[1]);
        return -1;
    }

    if (!readBootSector(disk)) {
        fprintf(stderr, "Failed to read boot sector\n");
        return -2;
    }

    if (!readFat(disk)) {
        fprintf(stderr, "Failed to read FAT sectors\n");

        free(g_Fat);

        return -3;
    }

    if (!readRootDirectry(disk)) {
        fprintf(stderr, "Failed to read FAT root directory\n");

        free(g_Fat);
        free(g_RootDirectory);

        return -4;
    }

    DirectoryEntry* fileEntry = findFile(argv[2]);
    if (!fileEntry) {
        fprintf(stderr, "Failed to find file %s\n", argv[2]);

        free(g_Fat);
        free(g_RootDirectory);

        return -5;
    }

    uint8_t* buffer = (uint8_t*) malloc(fileEntry -> Size + g_BootSector.BytesPerSector);
    if (!readFile(fileEntry, disk, buffer)) {
        fprintf(stderr, "Failed to read file %s\n", argv[2]);

        free(g_Fat);
        free(g_RootDirectory);
        free(buffer);

        return -6;
    }

    for (size_t i = 0; i < fileEntry -> Size; i++) {
        if (isprint(buffer[i]))
            fputc(buffer[i], stdout);
        else
            printf("<%02x>", buffer[i]);
    }
    printf("\n");


    free(buffer);
    free(g_Fat);
    free(g_RootDirectory);
    return 0;
}

ASSEMBLER=nasm
CC=gcc

SRC_DIR=src
UTILS_DIR=utils
BUILD_DIR=build

.PHONY: all floppy_image kernel bootloader clean always utils_fat

all: floppy_image utils_fat

# Floppy
# Contains both the boot loader and the kernel
floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img testfile.txt "::test.txt"


# Boot loader
# Contains both the required FAT12 headers and the boot loader
bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASSEMBLER) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin


# Kernel
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASSEMBLER) $(SRC_DIR)/kernel/main.asm -f bin -o build/kernel.bin


# Utils
utils_fat: $(SRC_DIR)/$(BUILD_DIR)/utils/fat
$(SRC_DIR)/$(BUILD_DIR)/utils/fat: always $(SRC_DIR)/$(UTILS_DIR)/fat/fat.c
	mkdir -p $(BUILD_DIR)/utils
	$(CC) -g -o $(BUILD_DIR)/utils/fat $(SRC_DIR)/$(UTILS_DIR)/fat/fat.c


always:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)/*

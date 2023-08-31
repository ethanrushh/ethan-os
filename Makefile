ASSEMBLER=nasm
CC=gcc
CC16=/usr/bin/watcom/binl/wcc
LD16=/usr/bin/watcom/binl/wlink

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
	dd if=$(BUILD_DIR)/initial.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/full.bin "::full.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/main_floppy.img testfile.txt "::test.txt"
	mmd -i $(BUILD_DIR)/main_floppy.img "::testdir"
	mcopy -i $(BUILD_DIR)/main_floppy.img testfile.txt "::testdir/test2.txt"


# Boot loader
# Contains both the required FAT12 headers and the boot loader
bootloader: initial full

initial: $(BUILD_DIR)/initial.bin

$(BUILD_DIR)/initial.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/initial BUILD_DIR=$(abspath $(BUILD_DIR))

full: $(BUILD_DIR)/full.bin

$(BUILD_DIR)/full.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/full BUILD_DIR=$(abspath $(BUILD_DIR))


# Kernel
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR))


# Utils
utils_fat: $(SRC_DIR)/$(BUILD_DIR)/utils/fat
$(SRC_DIR)/$(BUILD_DIR)/utils/fat: always $(SRC_DIR)/$(UTILS_DIR)/fat/fat.c
	mkdir -p $(BUILD_DIR)/utils
	$(CC) -g -o $(BUILD_DIR)/utils/fat $(SRC_DIR)/$(UTILS_DIR)/fat/fat.c


always:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)/*

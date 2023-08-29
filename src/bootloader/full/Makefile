BUILD_DIR?=build/
ASM?=nasm
ASMFLAGS?=-f obj
CC16?=/usr/bin/watcom/binl/wcc
CFLAGS16?=-4 -d3 -s -wx -ms -zl -zq
LD16?=/usr/bin/watcom/binl/wlink

SOURCES_C=$(wildcard *.c)
SOURCES_ASM=$(wildcard *.asm)
OBJECTS_C=$(patsubst %.c, $(BUILD_DIR)/full/c/%.obj, $(SOURCES_C))
OBJECTS_ASM=$(patsubst %.asm, $(BUILD_DIR)/full/asm/%.obj, $(SOURCES_ASM))

.PHONY: all full clean

all: full

full: $(BUILD_DIR)/full.bin

$(BUILD_DIR)/full.bin: $(OBJECTS_ASM) $(OBJECTS_C)
	$(LD16) NAME $(BUILD_DIR)/full.bin FILE \{ $(OBJECTS_ASM) $(OBJECTS_C) \} OPTION MAP=$(BUILD_DIR)/full.map @linker.lnk

$(BUILD_DIR)/full/c/%.obj: %.c always
	$(CC16) $(CFLAGS16) -fo=$@ $<

$(BUILD_DIR)/full/asm/%.obj: %.asm always
	$(ASM) $(ASMFLAGS) -o $@ $<

always:
	mkdir -p $(BUILD_DIR)/full/c
	mkdir -p $(BUILD_DIR)/full/asm

clean:
	rm -f $(BUILD_DIR)/full.bin
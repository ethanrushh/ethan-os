TARGET_ASSEMBLER_FLAGS += -f elf
TARGET_CFLAGS += -ffreestanding -nostdlib
TARGET_LIBS += -lgcc
TARGET_LINKFLAGS += -T linker.ld -nostdlib

SOURCES_C=$(wildcard *.c)
SOURCES_ASM=$(wildcard *.asm)
OBJECTS_C=$(patsubst %.c, $(BUILD_DIR)/full/c/%.obj, $(SOURCES_C))
OBJECTS_ASM=$(patsubst %.asm, $(BUILD_DIR)/full/asm/%.obj, $(SOURCES_ASM))

.PHONY: all full clean

all: full

full: $(BUILD_DIR)/full.bin

$(BUILD_DIR)/full.bin: $(OBJECTS_ASM) $(OBJECTS_C)
	$(TARGET_LD) $(TARGET_LINKFLAGS) -Wl,-Map=$(BUILD_DIR)/full.map -o $@ $^ $(TARGET_LIBS)

$(BUILD_DIR)/full/c/%.obj: %.c always
	$(TARGET_CC) $(TARGET_CFLAGS) -c -o $@ $<

$(BUILD_DIR)/full/asm/%.obj: %.asm always
	echo $@ $<
	$(TARGET_ASSEMBLER) $(TARGET_ASSEMBLER_FLAGS) -o $@ $<

always:
	mkdir -p $(BUILD_DIR)/full/c
	mkdir -p $(BUILD_DIR)/full/asm

clean:
	rm -f $(BUILD_DIR)/full.bin

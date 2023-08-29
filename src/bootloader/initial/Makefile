BUILD_DIR?=build/
ASM?=nasm

.PHONY: all clean

all: initial

initial: $(BUILD_DIR)/initial.bin

$(BUILD_DIR)/initial.bin:
	$(ASM) boot.asm -f bin -o $(BUILD_DIR)/initial.bin

clean:
	rm -f $(BUILD_DIR)/initial.bin
# Ensure BUILD_DIR fallback exists
BUILD_DIR ?= ../../../build

# Concrete local fallbacks for compiler tool variables
TARGET_ASM ?= nasm
TARGET_CC  ?= gcc
TARGET_LD  ?= ld

TARGET_ASMFLAGS += -f elf
TARGET_CFLAGS   += -m32 -ffreestanding -nostdlib
TARGET_LIBS     += -lgcc
TARGET_LINKFLAGS += -m elf_i386 -T linker.ld -nostdlib

HEADERS_C = $(wildcard *.h) $(wildcard */*.h) $(wildcard */*/*.h)
SOURCES_C = $(wildcard *.c) $(wildcard */*.c) $(wildcard */*/*.c) 
OBJECTS_C = $(patsubst %.c, $(BUILD_DIR)/loader/c/%.obj, $(SOURCES_C))

HEADERS_ASM = $(wildcard *.inc) $(wildcard */*.inc)
SOURCES_ASM = $(wildcard *.asm) $(wildcard */*.asm) $(wildcard *.s)
OBJECTS_ASM = $(patsubst %.asm, $(BUILD_DIR)/loader/asm/%.obj, $(SOURCES_ASM))

.PHONY: all clean always

all: $(BUILD_DIR)/loader.bin

$(BUILD_DIR)/loader.bin: $(OBJECTS_ASM) $(OBJECTS_C)
	@mkdir -p $(@D)
	$(TARGET_CC) $(TARGET_CFLAGS) -Wl,-m,elf_i386 -Wl,-T,linker.ld -o $@ $^ $(TARGET_LIBS)
	@echo "--> Created loader.bin"

$(BUILD_DIR)/loader/c/%.obj: %.c
	@mkdir -p $(@D)
	$(TARGET_CC) $(TARGET_CFLAGS) -c -o $@ $<
	@echo "--> Compiled: " $<

$(BUILD_DIR)/loader/asm/%.obj: %.asm
	@mkdir -p $(@D)
	$(TARGET_ASM) $(TARGET_ASMFLAGS) -o $@ $<
	@echo "--> Compiled: " $<

clean:
	rm -rf $(BUILD_DIR)/loader

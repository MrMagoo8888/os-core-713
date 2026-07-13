include build_scripts/config.mk

ASM=nasm
CC=gcc
LD=ld
OBJCOPY=objcopy

SRC_DIR=kernel/src
BUILD_DIR=build/

.PHONY: all floppy_image bootloader clean always 

all: floppy_image bootloader

include build_scripts/toolchain.mk

#
# Floppy image
#
floppy_image: $(BUILD_DIR)/main_floppy.img

$(BUILD_DIR)/main_floppy.img: always kernel_sys
	$(MAKE) -C $(SRC_DIR)/boot BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Compile C Logic Subsystem First
#
kernel_sys: always
	$(MAKE) -C $(SRC_DIR)/sys BUILD_DIR=$(abspath $(BUILD_DIR))


#
# Bootloader
#
bootloader: boot5 

boot5: $(BUILD_DIR)/boot5.bin

$(BUILD_DIR)/boot5.bin: always
	$(MAKE) -C $(SRC_DIR)/boot BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)

#
# Clean
#
clean:
	$(MAKE) -C $(SRC_DIR)/sys BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/boot BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	rm -rf $(BUILD_DIR)/*
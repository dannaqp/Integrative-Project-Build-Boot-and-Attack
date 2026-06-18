# Variables
CC = gcc
CFLAGS = -m64 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -Wall -O -fno-pie
AS = nasm
ASFLAGS = -f elf64
LD = ld
LDFLAGS = -m elf_x86_64 -T src/linker.ld

.PHONY: all clean iso

all: kernel.bin

src/boot.o: src/boot.asm
	$(AS) $(ASFLAGS) $< -o $@

src/kernel.o: src/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

kernel.bin: src/boot.o src/kernel.o
	$(LD) $(LDFLAGS) src/boot.o src/kernel.o -o targets/iso/boot/kernel.bin

iso: kernel.bin
	grub-mkrescue -o kernel.iso targets/iso

clean:
	rm -f src/*.o targets/iso/boot/kernel.bin kernel.iso
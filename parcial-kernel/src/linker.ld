ENTRY(_start)

SECTIONS {
    /* Tradicionalmente los kernels se cargan a partir de 1 Megabyte */
    . = 1M;

    .text : {
        /* El encabezado Multiboot2 DEBE ir al principio absoluto */
        KEEP(*(.multiboot_header))
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}

grub.cfg:
set timeout=0
set default=0

menuentry "Unix Proyecto Kernel" {
    multiboot2 /boot/kernel.bin
    boot
}
section .multiboot_header
align 8
header_start:
    dd 0xe85250d6                ; Número mágico de Multiboot2
    dd 0                         ; Arquitectura: Modo protegido i386
    dd header_end - header_start ; Longitud del encabezado
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start)) ; Checksum

    ; Tag de finalización obligatorio
    dw 0
    dw 0
    dd 8
header_end:

section .text
bits 32 ; GRUB nos deja aquí (Modo de 32 bits obligatorio)
global _start

_start:
    ; 1. Configurar tablas de paginación para Modo Largo
    mov eax, p3_table
    or eax, 0b11 ; present + writable
    mov [p4_table], eax

    mov eax, p2_table
    or eax, 0b11 ; present + writable
    mov [p3_table], eax

    ; Mapear 512 páginas de 2MB (Total 1GB de memoria)
    mov ecx, 0
.map_p2_table:
    mov eax, 0x200000 ; 2MB
    mul ecx
    or eax, 0b10000011 ; present + writable + huge page
    mov [p2_table + ecx * 8], eax
    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ; 2. Habilitar PAE (Physical Address Extension)
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; 3. Activar el bit de Modo Largo en el MSR (Model Specific Register)
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; 4. Habilitar Paginación
    mov eax, p4_table
    mov cr3, eax
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; 5. Cargar la GDT de 64 bits y dar el gran salto
    lgdt [gdt64.pointer]
    jmp gdt64.code:long_mode_start

bits 64 ; ¡Bienvenidos al verdadero entorno de 64 bits!
long_mode_start:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    
    extern kernel_main
    call kernel_main             ; Salta al código de C
    cli
.halt:
    hlt
    jmp .halt

section .rodata
gdt64:
    dq 0 ; Entrada vacía obligatoria
.code: equ $ - gdt64
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; Segmento de código de 64 bits
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

section .bss
align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096
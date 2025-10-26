[org 0x7c00]

BIOS_TELETYPE equ 0xE
BIOS_READ_SECTOR equ 0x2
ASCII_CARR_RET equ 0xD
ASCII_LINE_FEED equ 0xA


_start:
    mov [BOOT_DRIVE], dl

    mov bp, 0x8000
    mov sp, bp

    xor ax, ax
    mov es, ax

    mov si, TAG16_MES
    call __print_str

    call __switch_to_pm
    jmp $

[bits 16]
__drop_flags:
    push ax
    push dx
    pushf
    pop dx
    call __print_hex
    pop dx
    pop ax
    ret

[bits 16]
__print_str:
    mov ah, BIOS_TELETYPE
.__prn_l:
    lodsb
    cmp al, 0
    jz .__prn_ext
    int 0x10
    jmp .__prn_l
.__prn_ext:
    ret

[bits 16]
__new_line:
    push ax
    mov ah, BIOS_TELETYPE
    mov al, ASCII_CARR_RET
    int 0x10
    mov al, ASCII_LINE_FEED
    int 0x10
    pop ax
    ret

[bits 16]
__print:
    push ax
    mov ah, BIOS_TELETYPE
    int 0x10
    pop ax
    ret

[bits 16]
__chr_or_num:
    cmp al, 0xA
    jge .__chr
    jle .__num
    jmp .__cnext
    .__chr:
        mov ah, 55
        jmp .__cnext
    .__num:
        mov ah, 48
    .__cnext:
        ret

[bits 16]
__print_hex:
    push dx
    push ax

    mov al, dh
    shr al, 4
    call __chr_or_num
    add al, ah
    call __print

    mov al, dh
    and al, 0x0F
    call __chr_or_num
    add al, ah
    call __print

    mov al, dl
    shr al, 4
    call __chr_or_num
    add al, ah
    call __print

    mov al, dl
    and al, 0x0F
    call __chr_or_num
    add al, ah
    call __print

    pop ax
    pop dx
    ret

[bits 16]
__load_boot:
    push dx
    mov ah, BIOS_READ_SECTOR
    mov al, dh ; sectors arg in dh
    mov ch, 0x0 ;  cylinder 0
    mov dh, 0x0 ;   head 0
    mov cl, 0x2 ; from second sector
    int 0x13
    pop dx
    jc __load_err
    cmp dh, al
    jne __load_err
    ret
    __load_err:
        call __drop_flags
        call __new_line
        mov si, BOOT_ERR_MES
        call __print_str
        hlt
        ret

TAG16_MES: db "hello from 16-bit", 0x0
BOOT_DRIVE: db 0
BOOT_ERR_MES: db "bad load", 0x0


[bits 16]
__switch_to_pm:
    cli
    lgdt [__gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp dword __code_sg_offt:__init_pm ; far jump with 0x8 (code selector)

[bits 32]
__init_pm:
    mov ax, __data_sg_offt
    mov ds, ax
    mov ss, ax
    mov fs, ax
    mov es, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    call __im_in_pm

VID_MEM equ 0xb8000
W_ON_H equ 0xf

TAG32_MES: db "hello from 32-bit", 0x0

[bits 32]
__print_string_pm: ; ebx contains pointer to a null-terminated string
    push edx
    push eax
    mov edx, VID_MEM
    __pr_str_pm_loop:
        mov al, [ebx]
        mov ah, W_ON_H
        cmp al, 0
        je __ext_pr_str_pm
        mov [edx], ax
        inc ebx
        add edx, 2
        jmp __pr_str_pm_loop
    __ext_pr_str_pm:
        pop eax
        pop edx
        ret

[bits 32]
__im_in_pm:
    mov ebx, TAG32_MES
    call __print_string_pm
    jmp $

__gdt_start:
    __gdt_null:
        dq 0x0
    
    __gdt_code:
        ; base=0x0, limit=0xfffff ,
        ; 1st flags: (present )1 (privilege )00 (descriptor type)1 -> 1001b        taken from "Writing a Simple Operating System from Scratch by Nick Blundell"
        ; type flags: (code)1 (conforming )0 (readable )1 (accessed )0 -> 1010b
        ; 2nd flags: (granularity )1 (32-bit default )1 (64-bit seg)0 (AVL)0 -> 1100b
        dw 0xffff ; Limit (bits 0-15)
        dw 0x0 ; Base (bits 0-15)
        db 0x0 ; Base (bits 16 -23)
        db 10011010b ; 1st flags , type flags
        db 11001111b ; 2nd flags , Limit (bits 16-19)
        db 0x0 ; Base (bits 24 -31)

    __gdt_data:
        ;the data segment descriptor
        ; Same as code segment except for the type flags:
        ; type flags: (code)0 (expand down)0 (writable )1 (accessed )0 -> 0010b
        dw 0xffff ; Limit (bits 0-15)
        dw 0x0 ; Base (bits 0-15)
        db 0x0 ; Base (bits 16 -23)
        db 10010010b ; 1st flags , type flags
        db 11001111b ; 2nd flags , Limit (bits 16-19)
        db 0x0
__gdt_end:

__gdt_descriptor:
    dw __gdt_end - __gdt_start -1 ; gdt size
    dd __gdt_start ; gdt start

__code_sg_offt equ __gdt_code - __gdt_start ; = 0x8 offset
__data_sg_offt equ __gdt_data - __gdt_start ; = 0x10 offset




times 510 - ($ - $$) db 0
dw 0xAA55

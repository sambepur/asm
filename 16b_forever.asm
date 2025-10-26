bits 16
[org 0x7c00]

BIOS_TELETYPE equ 0xE
BIOS_READ_SECTOR equ 0x2
ASCII_SCROLL_UP equ 0x6
ASCII_CARR_RET equ 0xD
ASCII_LINE_FEED equ 0xA


_start:
    mov [BOOT_DRIVE], dl

    mov bp, 0x8000
    mov sp, bp
    call __clr_screen
    xor ax, ax
    mov es, ax

    mov bx, 0x9000 ; prepare es:bx to read from disk
    mov dh, 2 ; sectors to read
    mov dl, [BOOT_DRIVE]
    call __load_boot
    call __new_line
    mov si, bx
    call __print_str
    cli
    hlt

__drop_flags:
    push ax
    push dx
    pushf
    pop dx
    call __print_hex
    pop dx
    pop ax
    ret

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

__clr_screen:
    pusha
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    popa
    ret

__new_line:
    push ax
    mov ah, BIOS_TELETYPE
    mov al, ASCII_CARR_RET
    int 0x10
    mov al, ASCII_LINE_FEED
    int 0x10
    pop ax
    ret

__print:
    push ax
    mov ah, BIOS_TELETYPE
    int 0x10
    pop ax
    ret


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


TAG_MES: db "tag", 0x0
BOOT_DRIVE: db 0
BOOT_ERR_MES: db "bad load", 0x0
times 510 - ($ - $$) db 0
dw 0xAA55

HI : db "A strange game.", ASCII_LINE_FEED, ASCII_CARR_RET, "the only winning move is not to play", 0x0
times 458 db 0x0
times 256 dw 0xdead
bits 16
[org 0x7c00]
_start:
    
    cli
    hlt

__print_str:
    mov ah, 0x0E
.__prn_l:
    lodsb
    cmp al, 0
    jz .__prn_ext
    int 0x10
    jmp .__prn_l
.__prn_ext:
    ret

__new_line:
    mov ah, 0xe
    mov al, 0xd
    int 0x10
    mov al, 0xa
    int 0x10
    ret

__print:
    push ax
    mov ah, 0x0E
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
    ret

disk_load:
    push dx ; Store DX on stack so later we can recall
    ; how many sectors were request to be read ,
    ; even if it is altered in the meantime
    mov ah, 0x02 ; BIOS read sector function
    mov al, dh ; Read DH sectors
    mov ch, 0x00 ; Select cylinder 0
    mov dh, 0x00 ; Select head 0
    mov cl, 0x02 ; Start reading from second sector (i.e. after the boot sector)
    int 0x13 ; BIOS interrupt
    jc disk_error ; Jump if error (i.e. carry flag set)
    pop dx ; Restore DX from the stack
    cmp dh, al ; if AL (sectors read) != DH (sectors expected)
    jne disk_error ; display error message
    ret
disk_error:
    mov si, DISK_ERROR_MSG
    call __print_str
    jmp $
; Variables
DISK_ERROR_MSG: db "Disk read error!", 0

msg: db "data",0
data: db 'X'

times 510 - ($ - $$) db 0
dw 0xAA55
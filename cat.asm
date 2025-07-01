global _start
MB equ 1048576

section .data
    new_line: db 0xA

section .bss
    buffer: resb MB

section .text

    newline: ; for new line if it wasn't reached during reading
        mov rax, 1
        mov rdi, 1
        mov rsi, new_line
        mov rdx, 1
        syscall
        jmp exit

    _start:
        pop rbx ;argc
        pop rbp ;kill argv[0]
        xor rbp, rbp
        cmp rbx, 2
        jz open
        jmp exit

    open: 
        mov rax, 2 ; open
        pop rdi
        mov rsi, 00000000
        syscall
        mov rcx, rax
        sub rsp, 40
        jmp read

    read:
        mov rax, 0 ; read
        mov rdi, rcx
        mov rsi, buffer
        mov rdx, MB
        syscall

        cmp rax, 0; if EOF reached
        jle newline

        xor rcx, rcx
        mov rcx, rax
        jmp write

    write:
        mov rax, 1 ;write
        mov rdi, 1
        mov rsi, buffer
        mov rdx, rcx
        syscall

        jmp read

    exit:
        add rsp, 40
        mov rax, 60
        mov rdi, 0
        syscall

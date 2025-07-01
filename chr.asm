global _start

section .data
    buff: db 0x41, 0x42, 0x43, 0xA
    len equ $ - buff

section .text
    _start:
        mov rax, 1
        mov rdi, 1
        mov rsi, buff
        mov rdx, len
        syscall
    exit:
        mov rax, 60
        mov rdi, 0
        syscall
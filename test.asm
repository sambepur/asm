global _start

_start:
    mov ax, 0xABCD
    shr ah, 4
    cmp ah, 0xA
    je scc
    jmp ext
    scc:
        mov rdi, 0
        mov rax, 60
        syscall
    ext:
        mov rdi, 20
        mov rax, 60
        syscall
        
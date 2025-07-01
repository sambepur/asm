global _start

section .text
    _start:
    mov al, 500
    jmp exit

    exit:
        mov rax, 60
        movzx rdi, al
        syscall
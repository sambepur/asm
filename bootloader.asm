bits 16
org 0x7c00

buff: db "hi", 0
call enter_bios_video_mode
_start:
	mov al, 'S'
	int 0x10
	ret
enter_bios_video_mode:
	mov ah, 0xE
times 510 - ($ - $$) db 0
dw 0xaa55

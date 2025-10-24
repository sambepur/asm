REAL ?= bootloader
AS = nasm
LN = ld
ASFLAGS = -f bin
ASDEBUGF = -g -f elf64 -F dwarf
LNDEBUGF = -m elf_x86_64
RAW = $(REAL).asm
NAME = $(REAL).bin
RUN_DBG_FL = -gdb tcp:127.0.0.1:1234

$(REAL): $(RAW)
	$(AS) $(ASFLAGS) $(RAW) -o $(NAME)

run:
	qemu-system-x86_64 -drive format=raw,file=$(NAME)

clean:
	rm -f $(NAME)

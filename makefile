REAL ?= bootloader
AS = nasm
LN = ld
ASFLAGS = -f bin
ASDEBUGF = -g -f elf64 -F dwarf
LNDEBUGF = -m elf_x86_64
RAW = $(REAL).asm
NAME = $(REAL).bin

$(REAL): $(RAW)
	$(AS) $(ASFLAGS) $(RAW) -o $(NAME)

clean:
	rm -f $(NAME)

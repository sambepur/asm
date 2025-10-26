REAL = bootloader
STAY = 16b_forever
STASM = $(STAY).asm
STAOUT = build.d/$(STAY).bin
AS = nasm
LN = ld
ASFLAGS = -f bin
ASDEBUGF = -g -f elf64 -F dwarf
LNDEBUGF = -m elf_x86_64
RAW = $(REAL).asm
NAME = build.d/$(REAL).bin
RUN_DBG_FL = -gdb tcp:127.0.0.1:1234

$(REAL): $(RAW)
	$(AS) $(ASFLAGS) $(RAW) -o $(NAME)

$(STAY): $(STASM)
	$(AS) $(ASFLAGS) $(STASM) -o $(STAOUT)

run_16b:
	qemu-system-x86_64 -drive format=raw,file=$(STAOUT)
run:
	qemu-system-x86_64 -drive format=raw,file=$(NAME)

clean:
	rm -f $(NAME)

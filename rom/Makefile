
# test depends on the instruction sequence in example.s
# example.s: example.c
# 	riscv32-unknown-elf-gcc -S example.c

all: test

example: _start.s example.s
	riscv32-unknown-elf-gcc -ffreestanding -nostdlib _start.s example.s -o example

example.bin: example
	riscv32-unknown-elf-objcopy --only-section '.text' -O binary example example.bin

example.hex: example.bin
	./makehex.py example.bin example.hex

tb: tb.v
	iverilog -o tb tb.v

.PHONY: dump
dump: example
	riscv32-unknown-elf-objdump -x -d example

.PHONY: test
test: tb example.hex
	vvp tb

.PHONY: clean
clean:
	rm -f example example.bin example.hex
	rm -f tb


main.s: main.c
	riscv32-unknown-elf-gcc -ffreestanding -nostdlib -O -S main.c

example: _start.S main.s
	riscv32-unknown-elf-gcc -ffreestanding -nostdlib _start.S main.s -O -o example

example.bin: example
	riscv32-unknown-elf-objcopy --only-section '.text' -O binary example example.bin

example.hex: example.bin
	./makehex.py example.bin example.hex

barrel: barrel.v tb.v
	iverilog -o barrel -s tb tb.v barrel.v

run: example.hex barrel
	vvp barrel

.PHONY: clean
clean:
	rm -f example example.bin example.hex barrel

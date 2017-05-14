
example: _start.s
	riscv32-unknown-elf-gcc -ffreestanding -nostdlib _start.s -o example

example.bin: example
	riscv32-unknown-elf-objcopy --only-section '.text' -O binary example example.bin

example.hex: example.bin
	./makehex.py example.bin example.hex

barrel: barrel.v
	/usr/local/iverilog/bin/iverilog -o barrel -s tb tb.v barrel.v

run: example.hex
	/usr/local/iverilog/bin/vvp barrel

.PHONY: clean
clean:
	rm -f example example.bin example.hex barrel

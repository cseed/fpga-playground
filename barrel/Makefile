
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

rv32ui_tests = \
	simple \
	add addi \
	and andi \
	auipc \
	beq bge bgeu blt bltu bne \
	fence_i \
	jal jalr \
	lb lbu lh lhu lw \
	lui \
	or ori \
	sb sh sw \
	sll slli \
	slt slti sltiu sltu \
	sra srai \
	srl srli \
	sub \
	xor xori \

TESTS = $(addprefix tests/isa/rv32ui/p-,$(rv32ui_tests))

OLD_TESTS = $(addprefix tests/isa/rv32ui/,$(rv32ui_tests))

TESTS_DUMP = $(addsuffix .dump,$(TESTS))

TESTS_BIN = $(addsuffix .bin,$(TESTS))

TESTS_HEX = $(addsuffix .hex,$(TESTS))

TESTS_BARREL = $(addsuffix .barrel,$(TESTS))

TESTS_STAMP = $(addsuffix -stamp,$(TESTS))

$(TESTS): tests/isa/rv32ui/p-%: tests/isa/rv32ui/%.S
	riscv32-unknown-elf-gcc -ffreestanding -nostdlib -Itests/env/p/include -Itests/isa/include -Ttests/env/p/lib/ldscripts/link.ld $< -o $@

$(TESTS_DUMP): %.dump: %
	riscv32-unknown-elf-objdump -d -s $< > $@

$(TESTS_BIN): %.bin: %
	riscv32-unknown-elf-objcopy -O binary $< $@

$(TESTS_HEX): %.hex: %.bin
	./makehex.py $< $@

$(TESTS_BARREL): %.barrel: %.hex tb.v barrel.v
	iverilog -D 'IMAGE="$<"' -o $@ -s tb tb.v barrel.v

$(TESTS_STAMP): %-stamp: %.barrel
	vvp $< && touch $@

.PHONY:
test: $(TESTS_DUMP) $(TESTS_STAMP)

.PHONY: clean
clean:
	rm -f example example.bin example.hex barrel
	rm -f tests/isa/rv32ui/p-*

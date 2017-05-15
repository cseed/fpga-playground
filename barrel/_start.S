// halt: xxx ... 001_0000_0 000_1011
#define halt .word 0x0000100b

// display x1: xxx ... rrrr_r 000 0000_0 000_1011
#define display(rs1) .word (0x0000000b | (((rs1) & 0x1f) << 15))

	.text
	.option nopic
	.align 2
	.globl _start
	.type _start, @function
_start:
	li x2, 0
	j L
	li x2, 5
L:
	li x1, 10
	display(1)
	display(2)
	halt

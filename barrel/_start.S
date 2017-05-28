// halt: xxx ... 001_0000_0 000_1011
#define halt .word 0x0000100b

// display x1: xxx ... rrrr_r 000 0000_0 000_1011
#define display(rs1) .word (0x0000000b | (((rs1) & 0x1f) << 15))

	.option nopic
	.text
	.align 2
	.globl _start
	.type _start, @function
_start:
        li x2, 0x4000 // sp
        call main
        halt
L:
        j L

	.option nopic
	.text
	.align	2
	.globl	print_int
	.type	print_int, @function
print_int:
        display(10)
        ret

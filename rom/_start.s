	.text
	.option nopic
	.align 2
	.globl _start
	.type _start, @function
_start:
	jal main
L:
	j L

	.file	"example.c"
	.option nopic
	.globl	x
	.section	.sdata,"aw",@progbits
	.align	2
	.type	x, @object
	.size	x, 4
x:
	.word	9
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	add	sp,sp,-16
	sw	s0,12(sp)
	add	s0,sp,16
	li	a5,1
	mv	a0,a5
	lw	s0,12(sp)
	add	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 7.1.1 20170509"

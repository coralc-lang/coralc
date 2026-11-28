	.att_syntax
	.file "muvm"

	.text
	.globl	main                            # -- Begin function main
	.p2align	4
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
.LBB5_6:
	movq	$7, g1(%rip)
	movq	g2(%rip), %rdi
	movl	%edi, %eax
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end5:
	.size	main, .Lfunc_end5-main
	.cfi_endproc
                                        # -- End function


	.section	.data
	.p2align	3, 0x0
	.type	g1,@object
	.globl	g1
g1:
	.quad 1
	.size	g1, .-g1

	.section	.data
	.p2align	3, 0x0
	.type	g2,@object
	.globl	g2
g2:
	.quad 2
	.size	g2, .-g2


	.ident	"muvm"
	.section	".note.GNU-stack","",@progbits


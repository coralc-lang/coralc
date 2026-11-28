	.att_syntax
	.file "muvm"

	.text
	.globl	main                            # -- Begin function main
	.p2align	4
	.type	main,@function
main:                                   # @main
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
# %bb.0:
.LBB1_2:
	leaq	-8(%rbp), %rdi
	movq	$42, (%rdi)
	movl	$42, %eax
	movq	%rbp, %rsp
	popq	%rbp
	.cfi_restore %rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function



	.ident	"muvm"
	.section	".note.GNU-stack","",@progbits


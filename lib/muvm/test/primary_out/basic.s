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
	subq	$16, %rsp
# %bb.0:
.LBB1_2:
	leaq	-16(%rbp), %rdi
	leaq	-8(%rbp), %rsi
	movq	$1, (%rdi)
	movq	$2, (%rsi)
	movq	(%rdi), %rdi
	movq	%rdi, %rsi
	addq	$3, %rsi
	addq	%rsi, %rdi
	movl	%edi, %eax
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


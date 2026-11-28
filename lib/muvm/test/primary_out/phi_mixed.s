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
	movq	%rdi, %r8
# %bb.0:
.LBB1_3:
	leaq	-16(%rbp), %rdi
	leaq	-32(%rbp), %rsi
	cmpq	$0, %r8
	jne	.LBB1_5
	movq	%rdi, %r8
	jmp	.LBB1_6
# %bb.1:
.LBB1_5:
	movq	%rsi, %r8
	jmp	.LBB1_6
# %bb.2:
.LBB1_6:
	movq	(%r8), %rdi
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


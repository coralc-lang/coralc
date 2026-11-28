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
	movq	%rdi, %rsi
# %bb.0:
.LBB1_3:
	leaq	-16(%rbp), %rdi
	movq	%rdi, %r9
	movq	%rdi, %r8
	movq	%r8, %r10
	movq	%r10, %r9
	movq	%r9, %r8
	jmp	.LBB1_6
# %bb.1:
.LBB1_6:
	cmpq	$10, %rsi
	jge	.LBB1_7
	jmp	.LBB1_6
# %bb.2:
.LBB1_7:
	movq	(%r9), %rdi
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


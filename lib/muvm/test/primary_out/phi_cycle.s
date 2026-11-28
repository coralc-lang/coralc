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
	movq	%rdi, %rsi
	jmp	.LBB1_3
# %bb.1:
.LBB1_3:
	movq	(%rsi), %r8
	cmpq	$7, %r8
	jge	.LBB1_5
	jmp	.LBB1_4
# %bb.2:
.LBB1_4:
	movq	$7, (%rsi)
	jmp	.LBB1_3
# %bb.3:
.LBB1_5:
	movl	%r8d, %eax
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


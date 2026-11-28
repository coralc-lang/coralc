	.att_syntax
	.file "muvm"

	.text
	.globl	mkptr                           # -- Begin function mkptr
	.p2align	4
	.type	mkptr,@function
mkptr:                                  # @mkptr
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
	movq	%rdi, %rax
	movq	%rbp, %rsp
	popq	%rbp
	.cfi_restore %rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end1:
	.size	mkptr, .Lfunc_end1-mkptr
	.cfi_endproc
                                        # -- End function


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
	pushq	%rbx
	.cfi_offset %rbx, -24
	pushq	%r12
	.cfi_offset %r12, -32
	subq	$16, %rsp
	movq	%rdi, %rbx
# %bb.0:
.LBB5_7:
	leaq	-32(%rbp), %r12
	call	mkptr
	movq	%rax, %rdi
	cmpq	$0, %rbx
	jne	.LBB5_9
	movq	%r12, %rsi
	jmp	.LBB5_10
# %bb.1:
.LBB5_9:
	movq	%rdi, %rsi
	jmp	.LBB5_10
# %bb.2:
.LBB5_10:
	movq	(%rsi), %rdi
	movl	%edi, %eax
	leaq	-16(%rbp), %rsp
	popq	%r12
	.cfi_restore %r12
	popq	%rbx
	.cfi_restore %rbx
	popq	%rbp
	.cfi_restore %rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end5:
	.size	main, .Lfunc_end5-main
	.cfi_endproc
                                        # -- End function



	.ident	"muvm"
	.section	".note.GNU-stack","",@progbits


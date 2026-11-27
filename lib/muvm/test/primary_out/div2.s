	.att_syntax
	.file "muvm"

	.text
	.globl	main                            # -- Begin function main
	.p2align	4
	.type	main,@function
main:                                   # @main
	.cfi_startproc
.LBB1_3:
	movq %rdi, %rax
	cqo
	movq $7, %r10
	idivq %r10
	movq %rax, %r8
	movq %rdi, %rax
	cqo
	movq $7, %r10
	idivq %r10
	movq %rdx, %rsi
	movq %r8, %rdi
	addq %rsi, %rdi
	movl %edi, %eax
	.cfi_def_cfa %rsp, 8
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function


	.section .note.GNU-stack,"",@progbits


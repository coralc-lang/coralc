	.att_syntax
	.file "muvm"

	.text
	.globl	main                            # -- Begin function main
	.p2align	4
	.type	main,@function
main:                                   # @main
	.cfi_startproc
	pushq %rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq %rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq $16, %rsp
.LBB1_2:
	leaq -16(%rbp), %rdi
	leaq 8(%rdi), %rsi
	movq $1, (%rdi)
	movq $2, (%rsi)
	movq (%rdi), %rsi
	movq %rsi, %rdi
	addq $3, %rdi
	addq %rdi, %rsi
	movl %esi, %eax
	movq %rbp, %rsp
	popq %rbp
	.cfi_restore %rbp
	.cfi_def_cfa %rsp, 8
	ret
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function


	.section .note.GNU-stack,"",@progbits


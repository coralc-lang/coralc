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
	subq $64, %rsp
	movq %rdi, %r8
.LBB1_3:
	leaq -64(%rbp), %rdi
	movq %rdi, %rsi
	movq %r8, %r11
	imulq $8, %r11
	addq %r11, %rsi
	leaq 24(%rdi), %rdi
	movq $1, (%rsi)
	movq $2, (%rdi)
	movl $2, %eax
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


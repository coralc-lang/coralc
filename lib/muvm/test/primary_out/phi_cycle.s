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
	movq %rdi, %rsi
	jmp .LBB1_3
.LBB1_3:
	movq (%rsi), %r8
	movq %r8, %r10
	cmpq $7, %r10
	setl %r9b
	movzbl %r9b, %r9d
	movq %r8, %r10
	cmpq $7, %r10
	jl .LBB1_4
	jmp .LBB1_5
.LBB1_4:
	movq $7, (%rsi)
	movq %rsi, %r10
	movq %r10, %rsi
	jmp .LBB1_3
.LBB1_5:
	movl %r8d, %eax
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


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
	leaq -32(%rbp), %rdi
	leaq -64(%rbp), %rsi
	movq %r8, %r10
	cmpq $0, %r10
	sete %r8b
	movzbl %r8b, %r8d
	movq %rdi, %r8
	movq %r8, %r10
	cmpq $0, %r10
	je .LBB1_6
	jmp .LBB1_5
.LBB1_5:
	movq %rsi, %r8
	jmp .LBB1_6
.LBB1_6:
	leaq 2(%r8), %r8
	movq $9, (%r8)
	movl $9, %eax
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


	.att_syntax
	.file "muvm"

	.text
	.globl	write                           # -- Begin function write
	.p2align	4
	.type	write,@function
write:                                  # @write
	.cfi_startproc
.LBB1_4:
	movq %rsi, (%rdi)
	.cfi_def_cfa %rsp, 8
	ret
.Lfunc_end1:
	.size	write, .Lfunc_end1-write
	.cfi_endproc
                                        # -- End function

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
	subq $32, %rsp
.LBB7_8:
	leaq -24(%rbp), %r10
	movq %r10, -8(%rbp)
	movq -8(%rbp), %r11
	movq %r11, %r10
	movq %r10, -8(%rbp)
	subq $16, %rsp
	movq -8(%rbp), %r10
	movq %r10, 0(%rsp)
	movq $5, 8(%rsp)
	movq 0(%rsp), %rdi
	movq 8(%rsp), %rsi
	call write
	addq $16, %rsp
	movq -8(%rbp), %r11
	movq (%r11), %rdi
	movl %edi, %eax
	movq %rbp, %rsp
	popq %rbp
	.cfi_restore %rbp
	.cfi_def_cfa %rsp, 8
	ret
.Lfunc_end7:
	.size	main, .Lfunc_end7-main
	.cfi_endproc
                                        # -- End function


	.section .note.GNU-stack,"",@progbits


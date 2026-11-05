.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $56, %rsp
.Lmain_entry_2:
	leaq -64(%rbp), %rbx
	leaq -80(%rbp), %r12
	movq $0x0000000000000000, (%rbx)
	movq $0x0000000000000000, (%r12)
.Lmain_outer_3:
	movq (%rbx), %rsi
	cmpq $0x0000000000000004, %rsi
	jge .Lmain_done_8
.Lmain_inner_pre_4:
	leaq -96(%rbp), %r13
	movq $0x0000000000000000, (%r13)
.Lmain_inner_5:
	movq (%r13), %rsi
	cmpq $0x0000000000000003, %rsi
	jge .Lmain_inner_done_7
.Lmain_inner_body_6:
	movq (%rbx), %rsi
	movq (%r13), %rdi
	imulq %rdi, %rsi
	movq (%r12), %rdi
	movq %rdi, %r14
	addq %rsi, %r14
	xorq %r14, %rdi
	xorq %r14, %rsi
	andq %rsi, %rdi
	movq %rdi, %r15
	movq $0x000000000000003f, %rcx
	sarq %cl, %r15
	movq $0x0000000000000003, %rdi
	movq %r15, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs45(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r14, (%r12)
	movq (%r13), %rsi
	movq %rsi, %r14
	incq %r14
	xorq %r14, %rsi
	movq $0x0000000000000001, %rdi
	xorq %r14, %rdi
	andq %rdi, %rsi
	movq %rsi, %r15
	movq $0x000000000000003f, %rcx
	sarq %cl, %r15
	movq $0x0000000000000003, %rdi
	movq %r15, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs52(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	addq $0x0000000000000001, (%r13)
	jmp .Lmain_inner_5
.Lmain_inner_done_7:
	movq (%rbx), %rsi
	movq %rsi, %r13
	incq %r13
	xorq %r13, %rsi
	movq $0x0000000000000001, %rdi
	xorq %r13, %rdi
	andq %rdi, %rsi
	movq %rsi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs58(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	addq $0x0000000000000001, (%rbx)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq (%r12), %rsi
	movq %rsi, %rax
	addq $56, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs45:
	.byte 63
	.byte 0
.Lcs52:
	.byte 63
	.byte 0
.Lcs58:
	.byte 63
	.byte 0

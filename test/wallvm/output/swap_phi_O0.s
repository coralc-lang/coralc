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
	subq $32, %rsp
.Lmain_entry_2:
	leaq -64(%rbp), %rsi
	movq $0x0000000000000001, %rbx
	movq $0x0000000000000002, %r12
	movq $0x0000000000000000, %rsi
.Lmain_loop_3:
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
	leaq .Lcs22(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	cmpq $0x0000000000000004, %r13
	jl .Lmain_main.split0_36
.Lmain_done_4:
	leaq (%rbx,%rbx,4), %rbx
	addq %rbx, %rbx
	movq %rbx, %r13
	addq %r12, %r13
	xorq %r13, %rbx
	xorq %r13, %r12
	andq %r12, %rbx
	movq $0x000000000000003f, %rcx
	sarq %cl, %rbx
	movq $0x0000000000000003, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs30(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r13, %rax
	addq $32, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_main.split0_36:
	movq %r13, %rsi
	movq %rbx, %r11
	movq %r11, -48(%rbp)
	movq %r12, %rbx
	movq -48(%rbp), %r12
	jmp .Lmain_loop_3
.section .rodata.str1.1,"aM",@progbits,1
.Lcs22:
	.byte 63
	.byte 0
.Lcs30:
	.byte 63
	.byte 0

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
	subq $64, %rsp
.Lmain_entry_2:
	leaq -80(%rbp), %rbx
	leaq -96(%rbp), %r12
	movq $0x0000000000000000, (%r12)
.Lmain_loop_3:
	movq (%r12), %rsi
	cmpq $0x0000000000000007, %rsi
	jge .Lmain_done_5
.Lmain_body_4:
	movq (%r12), %r13
	movq $0x0000000000000000, %rdi
	movq %r13, %rsi
	movq $0x0000000000000005, %rdx
	leaq .Lcs27(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	leaq (%rbx, %r13, 8), %rsi
	movq $0x0000000000000001, (%rsi)
	movq (%r12), %rsi
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
	leaq .Lcs29(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	addq $0x0000000000000001, (%r12)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq $0x0000000000000000, %rax
	addq $64, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs27:
	.byte 63
	.byte 0
.Lcs29:
	.byte 63
	.byte 0

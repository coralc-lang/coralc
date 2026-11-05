.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $16, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rsi
	leaq (%rsi), %rdi
	leaq 8(%rsi), %r8
	movl $0x0000000000000007, (%rdi)
	movq $0x0000000000000032, (%r8)
	movl (%rdi), %esi
	movl %esi, %edi
	movq (%r8), %rsi
	movq %rdi, %rbx
	addq %rsi, %rbx
	xorq %rbx, %rdi
	xorq %rbx, %rsi
	andq %rsi, %rdi
	movq %rdi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	leaq .Lcs19(%rip), %r11
	leaq .Lcs19(%rip), %r11
	leaq .Lcs19(%rip), %r11
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs19(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %rbx, %rax
	addq $16, %rsp
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs19:
	.byte 63
	.byte 0

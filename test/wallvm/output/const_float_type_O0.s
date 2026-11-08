.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	movl g(%rip), %esi
	cvtsi2sd %rsi, %xmm2
	addsd	%rsi, %xmm2
	cvttsd2si %xmm2, %rsi
	movl $0x0000000000000003, %r10d
	movl %r10d, %ebx
	addl %esi, %ebx
	movl $0x0000000000000003, %r10d
	movl %r10d, %edi
	xorl %ebx, %edi
	xorl %ebx, %esi
	andl %esi, %edi
	movl $0x000000000000001f, %r11d
	movl %edi, %r12d
	movq %r11, %rcx
	sarl %cl, %r12d
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs18(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %rbx, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs18:
	.asciz "?"
.section .data
	.balign 4
g:
	.long 0x0000000000000003

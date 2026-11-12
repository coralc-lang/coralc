.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	movl g(%rip), %esi
	cvtsi2sd %rsi, %xmm2
	addsd	.Lcf11(%rip), %xmm2
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
	leaq .Lcs19(%rip), %rcx
	movq $0x0000000000000000, %r8
	leaq .Lcs18(%rip), %r9
	call _CNl4core5error5_trapEFmmmKPNl4core5cchar5ccharEmKPNl4core5cchar5ccharE_v@PLT
	movq %rax, %rsi
	movq %rbx, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.section .rodata.cst8,"aM",@progbits,8
	.balign 8
.Lcf11:
	.quad 0x3ff0000000000000
.section .rodata,"a",@progbits
.Lcs18:
	.asciz "main"
.Lcs19:
	.asciz "?"
.section .data
	.balign 4
g:
	.long 0x0000000000000003

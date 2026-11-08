.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	movl g(%rip), %esi
	cmpl $0x0000000000000005, %esi
	jne .L6
.L5:
	jmp .L7
.L6:
	jmp .L5
.L7:
	movq %rsi, %rbx
	incq %rbx
	xorl %ebx, %esi
	movl $0x0000000000000001, %r10d
	movl %r10d, %edi
	xorl %ebx, %edi
	andl %edi, %esi
	movl $0x000000000000001f, %r11d
	movl %esi, %r12d
	movq %r11, %rcx
	sarl %cl, %r12d
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs19(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %rbx, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs19:
	.asciz "?"
.section .data
	.balign 4
g:
	.long 0x0000000000000007

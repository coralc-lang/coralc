.section .text
.globl _CNf4arra7shuffleEFA20_i_i
.type _CNf4arra7shuffleEFA20_i_i, @function
_CNf4arra7shuffleEFA20_i_i:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $104, %rsp
	leaq -96(%rbp), %rsi
	movq %rdi, (%rsi)
	leaq -112(%rbp), %rdi
	leaq (%rsi), %r8
	movl (%r8), %r9d
	movl %r9d, (%rdi)
	leaq (%rsi), %r8
	leaq 76(%rsi), %r9
	movl (%r9), %ebx
	movl %ebx, (%r8)
	leaq 76(%rsi), %r8
	movl (%rdi), %esi
	movl %esi, (%r8)
	movq $0x0000000000000000, %rax
	addq $104, %rsp
	popq %rbx
	leave
	ret
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $40, %rsp
	leaq -48(%rbp), %rbx
	leaq _CNf4arra1aEG(%rip), %rdi
	call _CNf4arra7shuffleEFA20_i_i
	movq %rax, %rsi
	movl %esi, (%rbx)
	leaq .Lcs43(%rip), %rsi
	leaq -64(%rbp), %rdi
	movq %rsi, (%rdi)
	leaq 8(%rdi), %rsi
	movq $0x0000000000000002, (%rsi)
	leaq (%rdi), %rsi
	movq (%rsi), %r12
	movl (%rbx), %r13d
	movq %r12, %rdi
	movq %r13, %rsi
	movb $0, %al
	call printf@PLT
	movq %rax, %rsi
	addq $40, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata,"a",@progbits
.Lcs43:
	.asciz "%d"
.section .data
	.balign 4
_CNf4arra1aEG:
	.long 0x0000000000000016
	.long 0x0000000000000021
	.long 0x0000000000000003
	.long 0x0000000000000004
	.long 0x0000000000000005
	.long 0x0000000000000006
	.long 0x0000000000000006
	.long 0x0000000000000006
	.long 0x0000000000000006
	.long 0x0000000000000006
	.long 0x0000000000000017
	.long 0x000000000000002d
	.long 0x000000000000000d
	.long 0x000000000000000e
	.long 0x000000000000000f
	.long 0x0000000000000010
	.long 0x0000000000000041
	.long 0x000000000000002d
	.long 0x000000000000002c
	.long 0x0000000000000036

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
	subq $136, %rsp
	leaq msg+1(%rip), %rsi
	leaq msg+2(%rip), %rdi
	leaq msg+3(%rip), %r8
	leaq msg+4(%rip), %r9
	leaq msg+5(%rip), %rbx
	leaq msg+6(%rip), %r12
	leaq msg+7(%rip), %r13
	leaq msg+8(%rip), %r14
	movb msg(%rip), %r15b
	movb msg+1(%rip), %r10b
	movb %r10b, -56(%rbp)
	movb msg+2(%rip), %r10b
	movb %r10b, -72(%rbp)
	movb msg+3(%rip), %r10b
	movb %r10b, -88(%rbp)
	movb msg+4(%rip), %r10b
	movb %r10b, -104(%rbp)
	movb msg+5(%rip), %r10b
	movb %r10b, -120(%rbp)
	movb msg+6(%rip), %r10b
	movb %r10b, -136(%rbp)
	movb msg+7(%rip), %r10b
	movb %r10b, -152(%rbp)
	movb msg+8(%rip), %r10b
	movb %r10b, -168(%rbp)
	movzbl %r15b, %r14d
	movzbl -56(%rbp), %r15d
	movzbl -72(%rbp), %esi
	movzbl -88(%rbp), %edi
	movzbl -104(%rbp), %r8d
	movzbl -120(%rbp), %r9d
	movzbl -136(%rbp), %ebx
	movzbl -152(%rbp), %r12d
	movzbl -168(%rbp), %r13d
	xorq %r15, %r14
	xorq %r14, %rsi
	xorq %rsi, %rdi
	xorq %rdi, %r8
	xorq %r8, %r9
	xorq %r9, %rbx
	xorq %rbx, %r12
	xorq %r12, %r13
	movq %r13, %rax
	addq $136, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata,"a",@progbits
msg:
	.asciz "a\"b\\c\012d\001\377"

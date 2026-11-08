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
	subq $152, %rsp
	leaq msg(%rip), %rsi
	leaq msg+1(%rip), %rdi
	leaq msg+2(%rip), %r8
	leaq msg+3(%rip), %r9
	leaq msg+4(%rip), %rbx
	leaq msg+5(%rip), %r12
	leaq msg+6(%rip), %r13
	leaq msg+7(%rip), %r14
	leaq msg+8(%rip), %r15
	movb msg(%rip), %r10b
	movb %r10b, -56(%rbp)
	movb msg+1(%rip), %r10b
	movb %r10b, -72(%rbp)
	movb msg+2(%rip), %r10b
	movb %r10b, -88(%rbp)
	movb msg+3(%rip), %r10b
	movb %r10b, -104(%rbp)
	movb msg+4(%rip), %r10b
	movb %r10b, -120(%rbp)
	movb msg+5(%rip), %r10b
	movb %r10b, -136(%rbp)
	movb msg+6(%rip), %r10b
	movb %r10b, -152(%rbp)
	movb msg+7(%rip), %r10b
	movb %r10b, -168(%rbp)
	movb msg+8(%rip), %r10b
	movb %r10b, -184(%rbp)
	movzbl -56(%rbp), %r15d
	movzbl -72(%rbp), %esi
	movzbl -88(%rbp), %edi
	movzbl -104(%rbp), %r8d
	movzbl -120(%rbp), %r9d
	movzbl -136(%rbp), %ebx
	movzbl -152(%rbp), %r12d
	movzbl -168(%rbp), %r13d
	movzbl -184(%rbp), %r14d
	xorq %rsi, %r15
	xorq %rdi, %r15
	xorq %r8, %r15
	xorq %r9, %r15
	xorq %rbx, %r15
	xorq %r12, %r15
	xorq %r13, %r15
	xorq %r14, %r15
	movq %r15, %rax
	addq $152, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
msg:
	.asciz "a\"b\\c\012d\001\377"

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
.Lmain_entry_2:
	leaq -112(%rbp), %rsi
	leaq -128(%rbp), %rdi
	leaq -144(%rbp), %r10
	movq %r10, -72(%rbp)
	leaq -160(%rbp), %r10
	movq %r10, -56(%rbp)
	leaq -176(%rbp), %rbx
	leaq -192(%rbp), %r10
	movq %r10, -88(%rbp)
	leaq (%rsi), %r13
	movl $0x000000000000000a, %r10d
	movq %r10, (%r13)
	leaq 8(%rsi), %r13
	movl $0x0000000000000014, %r10d
	movq %r10, (%r13)
	leaq (%rdi), %r13
	movl $0x0000000000000001, %r10d
	movq %r10, (%r13)
	leaq 8(%rdi), %r13
	movl $0x0000000000000002, %r10d
	movq %r10, (%r13)
	movl $0x0000000000000000, %r10d
	movq %r10, (%rbx)
.Lmain_loop1_3:
	movq (%rbx), %r13
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r13
	setl %r11b
	movzbq %r11b, %r14
	movq %r13, %r11
	leaq (%rsi, %r11, 8), %r15
	movq %r13, %r11
	leaq (%rdi, %r11, 8), %r9
	movq (%r15), %r8
	movq (%r9), %r12
	movq %r8, (%r9)
	movq %r12, (%r15)
	testq %r14, %r14
	je .Lmain_loop2_pre_5
.Lmain_body1_4:
	addq $0x0000000000000001, (%rbx)
	jmp .Lmain_loop1_3
.Lmain_loop2_pre_5:
	movl $0x0000000000000000, %r10d
	movq -88(%rbp), %rdx
	movq %r10, (%rdx)
.Lmain_loop2_6:
	movq -88(%rbp), %rdx
	movq (%rdx), %r8
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	movq %r8, %r11
	leaq (%rsi, %r11, 8), %rbx
	movq (%rbx), %r12
	addq $0x000000000000000a, %r12
	movq -72(%rbp), %r10
	movq %r8, %r11
	leaq (%r10, %r11, 8), %rbx
	movq %r12, (%rbx)
	movq %r8, %r11
	leaq (%rdi, %r11, 8), %rbx
	movq (%rbx), %r12
	addq $0x0000000000000014, %r12
	movq -56(%rbp), %r10
	movq %r8, %r11
	leaq (%r10, %r11, 8), %rbx
	movq %r12, (%rbx)
	testq %r9, %r9
	je .Lmain_done_8
.Lmain_body2_7:
	movq -88(%rbp), %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_loop2_6
.Lmain_done_8:
	leaq 8(%rsi), %rdi
	movq (%rdi), %rsi
	movq -72(%rbp), %r10
	leaq 8(%r10), %rdi
	movq (%rdi), %r8
	movq -56(%rbp), %r10
	leaq 8(%r10), %rdi
	movq (%rdi), %r9
	addq %r8, %rsi
	addq %r9, %rsi
	movq %rsi, %rax
	addq $152, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

.section .text
.globl nest
.type nest, @function
nest:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $216, %rsp
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %r11
	movq %r11, -56(%rbp)
	addq $176, %rsp
.Lnest_entry_3:
	leaq -176(%rbp), %r10
	movq %r10, -120(%rbp)
	leaq -192(%rbp), %r10
	movq %r10, -136(%rbp)
	leaq -208(%rbp), %r9
	leaq -224(%rbp), %rbx
	leaq -240(%rbp), %r12
	leaq -256(%rbp), %r13
	movl $0x0000000000000000, %r10d
	movq -120(%rbp), %rdx
	movq %r10, (%rdx)
	movl $0x0000000000000000, %r10d
	movq -136(%rbp), %rdx
	movq %r10, (%rdx)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r9)
.Lnest_outer_4:
	movq -120(%rbp), %rdx
	movq (%rdx), %r14
	movq -136(%rbp), %rdx
	movq (%rdx), %r10
	movq %r10, -88(%rbp)
	movq (%r9), %r10
	movq %r10, -72(%rbp)
	movq $0x0000000000000001, %r10
	addq %r14, %r10
	movq %r10, -104(%rbp)
	movl $0x0000000000000003, %r11d
	cmpq %r11, %r14
	setl %r11b
	movzbq %r11b, %r15
	movl $0x0000000000000000, %r10d
	movq %r10, (%rbx)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r12)
	testq %r15, %r15
	je .Lnest_done_13
.Lnest_inner_6:
	movq (%rbx), %r15
	movq (%r12), %rdi
.Lnest_ibody_7:
	movq $0x0000000000000001, %rsi
	addq %rdi, %rsi
	movl $0x0000000000000007, %r11d
	cmpq %r11, -56(%rbp)
	sete %r11b
	movzbq %r11b, %r8
	movq %rsi, (%r13)
	testq %r8, %r8
	jne .Lnest_imerge_10
.Lnest_ielse_9:
	movq $0x0000000000000002, %rsi
	addq %rdi, %rsi
	movq %rsi, (%r13)
.Lnest_imerge_10:
	movq (%r13), %r10
	movq %r10, -152(%rbp)
.Lnest_ilatch_11:
	movq $0x0000000000000001, %r8
	addq %r15, %r8
	movl $0x0000000000000004, %r11d
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %rsi
	movq -104(%rbp), %r10
	movq -120(%rbp), %rdx
	movq %r10, (%rdx)
	movq -136(%rbp), %rdx
	movq %r15, (%rdx)
	movq %rdi, (%r9)
	movq %r8, (%rbx)
	movq -152(%rbp), %r10
	movq %r10, (%r12)
	testq %rsi, %rsi
	jne .Lnest_inner_6
	jmp .Lnest_outer_4
.Lnest_done_13:
	movq $0x000000000000000a, %rsi
	imulq -88(%rbp), %rsi
	addq %rsi, %r14
	addq -72(%rbp), %r14
	movq %r14, %rax
	addq $216, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.globl main
.type main, @function
main:
.Lmain_entry_49:
	movq $0x0000000000000007, %rdi
	call nest
	movq %rax, %rsi
	movq %rsi, %rax
	ret

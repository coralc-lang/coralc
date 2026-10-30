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
	subq $200, %rsp
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %r11
	movq %r11, -56(%rbp)
	addq $176, %rsp
.Lnest_entry_3:
	leaq -160(%rbp), %r10
	movq %r10, -104(%rbp)
	leaq -176(%rbp), %r10
	movq %r10, -120(%rbp)
	leaq -192(%rbp), %r9
	leaq -208(%rbp), %rbx
	leaq -224(%rbp), %r12
	leaq -240(%rbp), %r13
	movl $0x0000000000000000, %r10d
	movq -104(%rbp), %rdx
	movq %r10, (%rdx)
	movl $0x0000000000000000, %r10d
	movq -120(%rbp), %rdx
	movq %r10, (%rdx)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r9)
.Lnest_outer_4:
	movq -104(%rbp), %rdx
	movq (%rdx), %r14
	movq -120(%rbp), %rdx
	movq (%rdx), %r10
	movq %r10, -88(%rbp)
	movq (%r9), %r10
	movq %r10, -72(%rbp)
	movl $0x0000000000000003, %r11d
	cmpq %r11, %r14
	setl %r11b
	movzbq %r11b, %rdi
	testq %rdi, %rdi
	je .Lnest_done_13
.Lnest_inner_pre_5:
	movl $0x0000000000000000, %r10d
	movq %r10, (%rbx)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r12)
.Lnest_inner_6:
	movq (%rbx), %rdi
	movq (%r12), %r15
.Lnest_ibody_7:
	movl $0x0000000000000007, %r11d
	cmpq %r11, -56(%rbp)
	sete %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	je .Lnest_ielse_9
.Lnest_ithen_8:
	movq %r15, %rsi
	incq %rsi
	movq %rsi, (%r13)
	jmp .Lnest_imerge_10
.Lnest_ielse_9:
	movq %r15, %rsi
	addq $0x0000000000000002, %rsi
	movq %rsi, (%r13)
.Lnest_imerge_10:
	movq (%r13), %r10
	movq %r10, -136(%rbp)
.Lnest_ilatch_11:
	movq %rdi, %r8
	incq %r8
	movl $0x0000000000000004, %r11d
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %rsi
	addq $0x0000000000000001, (%rbx)
	movq -136(%rbp), %r10
	movq %r10, (%r12)
	testq %rsi, %rsi
	jne .Lnest_inner_6
.Lnest_olatch_12:
	movq -104(%rbp), %r10
	addq $0x0000000000000001, (%r10)
	movq -120(%rbp), %rdx
	movq %rdi, (%rdx)
	movq %r15, (%r9)
	jmp .Lnest_outer_4
.Lnest_done_13:
	movq -88(%rbp), %r10
	leaq (%r10,%r10,4), %rsi
	addq %rsi, %rsi
	addq %rsi, %r14
	addq -72(%rbp), %r14
	movq %r14, %rax
	addq $200, %rsp
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

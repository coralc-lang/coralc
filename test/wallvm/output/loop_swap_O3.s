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
	subq $40, %rsp
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %r11
	movq %r11, -56(%rbp)
	addq $176, %rsp
.Lnest_entry_3:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
	movq $0x0000000000000000, %r9
.Lnest_outer_4:
	movq $0x0000000000000001, %rbx
	addq %rdi, %rbx
	movl $0x0000000000000003, %r11d
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %r12
	movq $0x0000000000000000, %r12
	movq $0x0000000000000000, %r13
	testq %r12, %r12
	je .Lnest_done_13
.Lnest_inner_6:
.Lnest_ibody_7:
	movq $0x0000000000000001, %r14
	addq %r13, %r14
	movl $0x0000000000000007, %r11d
	cmpq %r11, -56(%rbp)
	sete %r11b
	movzbq %r11b, %r15
	movq %r14, -72(%rbp)
	testq %r15, %r15
	jne .Lnest_imerge_10
.Lnest_ielse_9:
	movq $0x0000000000000002, %r15
	addq %r13, %r15
	movq %r15, -72(%rbp)
.Lnest_imerge_10:
.Lnest_ilatch_11:
	movq $0x0000000000000001, %r14
	addq %r12, %r14
	movl $0x0000000000000004, %r11d
	cmpq %r11, %r14
	setl %r11b
	movzbq %r11b, %rsi
	movq %rbx, %rdi
	movq %r12, %r8
	movq %r13, %r9
	movq %r14, %r12
	movq -72(%rbp), %r13
	testq %rsi, %rsi
	jne .Lnest_inner_6
	jmp .Lnest_outer_4
.Lnest_done_13:
	imulq $0x000000000000000a, %r8
	addq %r8, %rdi
	addq %rdi, %r9
	movq %r9, %rax
	addq $40, %rsp
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

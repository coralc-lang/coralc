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
	subq $168, %rsp
.Lmain_entry_2:
	leaq -136(%rbp), %rsi
	leaq -152(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_outer_3
.Lmain_outer_3:
	movq (%rsi), %r8
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_inner_pre_4
	jmp .Lmain_done_8
.Lmain_inner_pre_4:
	leaq -168(%rbp), %rbx
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rbx)
	jmp .Lmain_inner_5
.Lmain_inner_5:
	movq (%rbx), %r12
	movabsq $0x0000000000000003, %r11
	cmpq %r11, %r12
	setl %r11b
	movzbq %r11b, %r13
	testq %r13, %r13
	jne .Lmain_inner_body_6
	jmp .Lmain_inner_done_7
.Lmain_inner_body_6:
	movq (%rsi), %r10
	movq %r10, -16(%rbp)
	movq (%rbx), %r10
	movq %r10, -32(%rbp)
	movq -16(%rbp), %r10
	imulq -32(%rbp), %r10
	movq %r10, -48(%rbp)
	movq (%rdi), %r10
	movq %r10, -64(%rbp)
	movq -64(%rbp), %r10
	addq -48(%rbp), %r10
	movq %r10, -80(%rbp)
	movq -48(%rbp), %r11
	movq %rdi, %r10
	addq %r11, (%r10)
	movq (%rbx), %r10
	movq %r10, -96(%rbp)
	movq -96(%rbp), %r10
	incq %r10
	movq %r10, -112(%rbp)
	movq %rbx, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_inner_5
.Lmain_inner_done_7:
	movq (%rsi), %r15
	movq %r15, %r14
	incq %r14
	movq %rsi, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq (%rdi), %rsi
	movl %esi, %r8d
	movq %r8, %rax
	addq $168, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

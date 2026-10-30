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
	subq $104, %rsp
.Lmain_entry_2:
	leaq -80(%rbp), %r10
	movq %r10, -56(%rbp)
	leaq -96(%rbp), %rdi
	leaq -112(%rbp), %r8
	leaq -128(%rbp), %r9
	leaq -144(%rbp), %rbx
	movl $0x0000000000000000, %r10d
	movq -56(%rbp), %r11
	movq %r10, (%r11)
	movl $0x0000000000000000, %r10d
	movq %r10, (%rdi)
.Lmain_outer_3:
	movq -56(%rbp), %r11
	movq (%r11), %r12
	movq (%rdi), %r13
	movl $0x0000000000000004, %r11d
	cmpq %r11, %r12
	setl %r11b
	movzbq %r11b, %r14
	testq %r14, %r14
	je .Lmain_done_8
.Lmain_inner_pre_4:
	movq %r12, (%r8)
	movq %r13, (%r9)
	movl $0x0000000000000000, %r10d
	movq %r10, (%rbx)
.Lmain_inner_5:
	movq (%r8), %r12
	movq (%r9), %r14
	movq (%rbx), %r15
	movl $0x0000000000000003, %r11d
	cmpq %r11, %r15
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	je .Lmain_inner_done_7
.Lmain_inner_body_6:
	movq %r12, %rsi
	imulq %r15, %rsi
	addq %r14, %rsi
	movq %r12, (%r8)
	movq %rsi, (%r9)
	addq $0x0000000000000001, (%rbx)
	jmp .Lmain_inner_5
.Lmain_inner_done_7:
	incq %r12
	movq -56(%rbp), %r11
	movq %r12, (%r11)
	movq %r14, (%rdi)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq %r13, %rax
	addq $104, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

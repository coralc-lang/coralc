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
	leaq -72(%rbp), %rsi
	leaq -88(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	jmp .Lmain_outer_3
.Lmain_outer_3:
	movq (%rdi), %r8
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_inner_pre_4
	jmp .Lmain_done_8
.Lmain_inner_pre_4:
	leaq -104(%rbp), %rbx
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
	jmp .Lmain_inner_done_3206437840
.Lmain_inner_body_6:
	movq %r8, %r10
	imulq %r12, %r10
	movq %r10, -16(%rbp)
	movq (%rsi), %r10
	movq %r10, -32(%rbp)
	movq -16(%rbp), %r10
	addq -32(%rbp), %r10
	movq %r10, -48(%rbp)
	movq -48(%rbp), %r10
	movq %r10, (%rsi)
	movq $0x0000000000000001, %r15
	addq %r12, %r15
	movq %r15, (%rbx)
	jmp .Lmain_inner_5
.Lmain_inner_done_3206437840:
	movq $0x0000000000000001, %r14
	addq %r8, %r14
	movq %r14, (%rdi)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq (%rsi), %rdi
	movl %edi, %r8d
	movq %r8, %rax
	addq $104, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

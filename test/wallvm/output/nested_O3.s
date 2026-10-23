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
	subq $48, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rbx
	leaq -32(%rbp), %r9
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r9)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rbx)
	jmp .Lmain_outer_3
.Lmain_outer_3:
	movq (%r9), %r8
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lmain_inner_pre_4
	jmp .Lmain_done_8
.Lmain_inner_pre_4:
	leaq -48(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_inner_5
.Lmain_inner_5:
	movq (%rdi), %rsi
	movabsq $0x0000000000000003, %r11
	cmpq %r11, %rsi
	setl %r11b
	movzbq %r11b, %r12
	testq %r12, %r12
	jne .Lmain_inner_body_6
	jmp .Lmain_inner_done_1043225864
.Lmain_inner_body_6:
	movq %r8, %r14
	imulq %rsi, %r14
	movq (%rbx), %r13
	movq %r14, %r12
	addq %r13, %r12
	movq %r12, (%rbx)
	movq $0x0000000000000001, %r12
	addq %rsi, %r12
	movq %r12, (%rdi)
	jmp .Lmain_inner_5
.Lmain_inner_done_1043225864:
	movq $0x0000000000000001, %rsi
	addq %r8, %rsi
	movq %rsi, (%r9)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq (%rbx), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $48, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

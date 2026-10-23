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
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
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
	leaq -48(%rbp), %r9
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r9)
	jmp .Lmain_inner_5
.Lmain_inner_5:
	movq (%r9), %rbx
	movabsq $0x0000000000000003, %r11
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %r12
	testq %r12, %r12
	jne .Lmain_inner_body_6
	jmp .Lmain_inner_done_7
.Lmain_inner_body_6:
	movq %r8, %r12
	imulq %rbx, %r12
	movq (%rdi), %r13
	addq %r13, %r12
	movq %r12, (%rdi)
	incq %rbx
	addq $0x0000000000000001, (%r9)
	jmp .Lmain_inner_5
.Lmain_inner_done_7:
	incq %r8
	addq $0x0000000000000001, (%rsi)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq (%rdi), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $48, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

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
	subq $136, %rsp
.Lmain_entry_2:
	leaq -104(%rbp), %rsi
	leaq -120(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_fill_3
.Lmain_fill_3:
	movq (%rdi), %r8
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_fill_body_4
	jmp .Lmain_sum_pre_5
.Lmain_fill_body_4:
	movq (%rdi), %rbx
	movq %rsi, %r10
	movq %rbx, %r11
	leaq (%r10, %r11, 8), %r12
	movq %rbx, %r13
	incq %r13
	movq %r13, (%r12)
	movq (%rdi), %r14
	movq %r14, %r15
	incq %r15
	movq %rdi, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	leaq -136(%rbp), %r8
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r8)
	jmp .Lmain_sum_6
.Lmain_sum_6:
	movq (%rdi), %r9
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	jne .Lmain_sum_body_7
	jmp .Lmain_done_8
.Lmain_sum_body_7:
	movq (%rdi), %r10
	movq %r10, -16(%rbp)
	movq %rsi, %r10
	movq -16(%rbp), %r11
	leaq (%r10, %r11, 8), %r10
	movq %r10, -32(%rbp)
	movq -32(%rbp), %r11
	movq (%r11), %r10
	movq %r10, -48(%rbp)
	movq (%r8), %r15
	movq -48(%rbp), %r12
	addq %r15, %r12
	movq %r12, (%r8)
	movq (%rdi), %r13
	movq %r13, %r14
	incq %r14
	movq %rdi, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq (%r8), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $136, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

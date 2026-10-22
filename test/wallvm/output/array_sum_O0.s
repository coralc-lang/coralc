.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $272, %rsp
.Lmain_entry_2:
	leaq -240(%rbp), %r10
	movq %r10, -64(%rbp)
	leaq -256(%rbp), %rdi
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
	movq (%rdi), %r10
	movq %r10, -16(%rbp)
	movq -64(%rbp), %r10
	movq -16(%rbp), %r11
	leaq (%r10, %r11, 8), %r10
	movq %r10, -32(%rbp)
	movq -16(%rbp), %r10
	incq %r10
	movq %r10, -48(%rbp)
	movq -48(%rbp), %r10
	movq -32(%rbp), %r11
	movq %r10, (%r11)
	movq (%rdi), %r10
	movq %r10, -80(%rbp)
	movq -80(%rbp), %rsi
	incq %rsi
	movq %rdi, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	leaq -272(%rbp), %rsi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	jmp .Lmain_sum_6
.Lmain_sum_6:
	movq (%rdi), %r8
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r10
	movq %r10, -192(%rbp)
	movq -192(%rbp), %r10
	testq %r10, %r10
	jne .Lmain_sum_body_7
	jmp .Lmain_done_8
.Lmain_sum_body_7:
	movq (%rdi), %r10
	movq %r10, -96(%rbp)
	movq -64(%rbp), %r10
	movq -96(%rbp), %r11
	leaq (%r10, %r11, 8), %r10
	movq %r10, -112(%rbp)
	movq -112(%rbp), %r11
	movq (%r11), %r10
	movq %r10, -128(%rbp)
	movq (%rsi), %r10
	movq %r10, -144(%rbp)
	movq -144(%rbp), %r10
	addq -128(%rbp), %r10
	movq %r10, -160(%rbp)
	movq -128(%rbp), %r11
	movq %rsi, %r10
	addq %r11, (%r10)
	movq (%rdi), %r10
	movq %r10, -176(%rbp)
	movq -176(%rbp), %r9
	incq %r9
	movq %rdi, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq (%rsi), %rdi
	movl %edi, %r8d
	movq %r8, %rax
	addq $272, %rsp
	leave
	ret

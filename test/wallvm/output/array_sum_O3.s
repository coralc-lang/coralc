.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $192, %rsp
.Lmain_entry_2:
	leaq -128(%rbp), %rsi
	leaq -176(%rbp), %r10
	movq %r10, -32(%rbp)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	jmp .Lmain_fill_3
.Lmain_fill_3:
	movq (%rsi), %r8
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_fill_body_4
	jmp .Lmain_sum_pre_5
.Lmain_fill_body_4:
	movq -32(%rbp), %r10
	movq %r8, %r11
	leaq (%r10, %r11, 8), %r10
	movq %r10, -16(%rbp)
	movq $0x0000000000000001, %rdi
	addq %r8, %rdi
	movq -16(%rbp), %r11
	movq %rdi, (%r11)
	movq %rdi, (%rsi)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	leaq -192(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_sum_6
.Lmain_sum_6:
	movq (%rsi), %r8
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r10
	movq %r10, -112(%rbp)
	movq -112(%rbp), %r10
	testq %r10, %r10
	jne .Lmain_sum_body_7
	jmp .Lmain_done_8
.Lmain_sum_body_7:
	movq -32(%rbp), %r10
	movq %r8, %r11
	leaq (%r10, %r11, 8), %r10
	movq %r10, -48(%rbp)
	movq -48(%rbp), %r11
	movq (%r11), %r10
	movq %r10, -64(%rbp)
	movq (%rdi), %r10
	movq %r10, -80(%rbp)
	movq -64(%rbp), %r10
	addq -80(%rbp), %r10
	movq %r10, -96(%rbp)
	movq -96(%rbp), %r10
	movq %r10, (%rdi)
	movq $0x0000000000000001, %r9
	addq %r8, %r9
	movq %r9, (%rsi)
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq (%rdi), %rsi
	movl %esi, %r8d
	movq %r8, %rax
	addq $192, %rsp
	leave
	ret

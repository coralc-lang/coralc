.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $176, %rsp
.Lmain_entry_2:
	leaq -144(%rbp), %r10
	movq %r10, -128(%rbp)
	leaq -160(%rbp), %r10
	movq %r10, -32(%rbp)
	movabsq $0x0000000000000000, %r10
	movq -32(%rbp), %r11
	movq %r10, (%r11)
	movabsq $0x0000000000000000, %r10
	movq -128(%rbp), %r11
	movq %r10, (%r11)
	jmp .Lmain_outer_3
.Lmain_outer_3:
	movq -32(%rbp), %r11
	movq (%r11), %r8
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r10
	movq %r10, -16(%rbp)
	movq -16(%rbp), %r10
	testq %r10, %r10
	jne .Lmain_inner_pre_4
	jmp .Lmain_done_8
.Lmain_inner_pre_4:
	leaq -176(%rbp), %r9
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r9)
	jmp .Lmain_inner_5
.Lmain_inner_5:
	movq (%r9), %rdi
	movabsq $0x0000000000000003, %r11
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %r10
	movq %r10, -48(%rbp)
	movq -48(%rbp), %r10
	testq %r10, %r10
	jne .Lmain_inner_body_6
	jmp .Lmain_inner_done_1905662936
.Lmain_inner_body_6:
	movq %r8, %r10
	imulq %rdi, %r10
	movq %r10, -64(%rbp)
	movq -128(%rbp), %r11
	movq (%r11), %r10
	movq %r10, -80(%rbp)
	movq -64(%rbp), %r10
	addq -80(%rbp), %r10
	movq %r10, -96(%rbp)
	movq -96(%rbp), %r10
	movq -128(%rbp), %r11
	movq %r10, (%r11)
	movq $0x0000000000000001, %r10
	addq %rdi, %r10
	movq %r10, -112(%rbp)
	movq -112(%rbp), %r10
	movq %r10, (%r9)
	jmp .Lmain_inner_5
.Lmain_inner_done_1905662936:
	movq $0x0000000000000001, %rsi
	addq %r8, %rsi
	movq -32(%rbp), %r11
	movq %rsi, (%r11)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq -128(%rbp), %r11
	movq (%r11), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $176, %rsp
	leave
	ret

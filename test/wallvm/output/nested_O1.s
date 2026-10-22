.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $240, %rsp
.Lmain_entry_2:
	leaq -208(%rbp), %rsi
	leaq -224(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_outer_3
.Lmain_outer_3:
	movq (%rsi), %r10
	movq %r10, -16(%rbp)
	movabsq $0x0000000000000004, %r11
	cmpq %r11, -16(%rbp)
	setl %r11b
	movzbq %r11b, %r10
	movq %r10, -32(%rbp)
	movq -32(%rbp), %r10
	testq %r10, %r10
	jne .Lmain_inner_pre_4
	jmp .Lmain_done_8
.Lmain_inner_pre_4:
	leaq -240(%rbp), %r8
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r8)
	jmp .Lmain_inner_5
.Lmain_inner_5:
	movq (%r8), %r10
	movq %r10, -176(%rbp)
	movabsq $0x0000000000000003, %r11
	cmpq %r11, -176(%rbp)
	setl %r11b
	movzbq %r11b, %r10
	movq %r10, -48(%rbp)
	movq -48(%rbp), %r10
	testq %r10, %r10
	jne .Lmain_inner_body_6
	jmp .Lmain_inner_done_7
.Lmain_inner_body_6:
	movq (%rsi), %r10
	movq %r10, -64(%rbp)
	movq (%r8), %r10
	movq %r10, -80(%rbp)
	movq -64(%rbp), %r10
	imulq -80(%rbp), %r10
	movq %r10, -96(%rbp)
	movq (%rdi), %r10
	movq %r10, -112(%rbp)
	movq -96(%rbp), %r10
	addq -112(%rbp), %r10
	movq %r10, -128(%rbp)
	movq -128(%rbp), %r10
	movq %r10, (%rdi)
	movq (%r8), %r10
	movq %r10, -144(%rbp)
	movq -144(%rbp), %r10
	incq %r10
	movq %r10, -160(%rbp)
	movq %r8, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_inner_5
.Lmain_inner_done_7:
	movq (%rsi), %r10
	movq %r10, -192(%rbp)
	movq -192(%rbp), %r9
	incq %r9
	movq %rsi, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq (%rdi), %rsi
	movl %esi, %r8d
	movq %r8, %rax
	addq $240, %rsp
	leave
	ret

.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $112, %rsp
.Lmain_entry_2:
	leaq -80(%rbp), %r10
	movq %r10, -32(%rbp)
	leaq -96(%rbp), %r10
	movq %r10, -48(%rbp)
	leaq -112(%rbp), %r8
	movabsq $0x0000000000000001, %r10
	movq -32(%rbp), %r11
	movq %r10, (%r11)
	movabsq $0x0000000000000002, %r10
	movq -48(%rbp), %r11
	movq %r10, (%r11)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r8)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq -32(%rbp), %r11
	movq (%r11), %r10
	movq %r10, -16(%rbp)
	movq -48(%rbp), %r11
	movq (%r11), %r10
	movq %r10, -64(%rbp)
	movq (%r8), %rsi
	movq $0x0000000000000001, %rdi
	addq %rsi, %rdi
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %r9
	movq -64(%rbp), %r10
	movq -32(%rbp), %r11
	movq %r10, (%r11)
	movq -16(%rbp), %r10
	movq -48(%rbp), %r11
	movq %r10, (%r11)
	movq %rdi, (%r8)
	testq %r9, %r9
	jne .Lmain_loop_3
	jmp .Lmain_done_4
.Lmain_done_4:
	movq $0x000000000000000a, %rsi
	imulq -16(%rbp), %rsi
	movq -64(%rbp), %rdi
	addq %rsi, %rdi
	movl %edi, %r8d
	movq %r8, %rax
	addq $112, %rsp
	leave
	ret

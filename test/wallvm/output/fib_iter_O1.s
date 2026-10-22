.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $144, %rsp
.Lmain_entry_2:
	leaq -112(%rbp), %rsi
	leaq -128(%rbp), %rdi
	leaq -144(%rbp), %r8
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000001, %r10
	movq %r10, (%rdi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r8)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rsi), %r9
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %r10
	movq %r10, -16(%rbp)
	movq -16(%rbp), %r10
	testq %r10, %r10
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rdi), %r10
	movq %r10, -32(%rbp)
	movq (%r8), %r10
	movq %r10, -48(%rbp)
	movq -32(%rbp), %r10
	addq -48(%rbp), %r10
	movq %r10, -64(%rbp)
	movq -48(%rbp), %r10
	movq %r10, (%rdi)
	movq -64(%rbp), %r10
	movq %r10, (%r8)
	movq (%rsi), %r10
	movq %r10, -80(%rbp)
	movq -80(%rbp), %r10
	incq %r10
	movq %r10, -96(%rbp)
	movq %rsi, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%r8), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $144, %rsp
	leave
	ret

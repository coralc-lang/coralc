.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $80, %rsp
.Lmain_entry_2:
	leaq -64(%rbp), %rsi
	leaq -80(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rsi), %r8
	movq (%rdi), %r9
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r10
	movq %r10, -16(%rbp)
	movq -16(%rbp), %r10
	testq %r10, %r10
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq %r8, %r10
	addq %r9, %r10
	movq %r10, -32(%rbp)
	movq $0x0000000000000001, %r10
	addq %r8, %r10
	movq %r10, -48(%rbp)
	movq -48(%rbp), %r10
	movq %r10, (%rsi)
	movq -32(%rbp), %r10
	movq %r10, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %r9d, %esi
	movq %rsi, %rax
	addq $80, %rsp
	leave
	ret

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
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rdi), %r10
	movq %r10, -16(%rbp)
	movq -16(%rbp), %r10
	addq $0x0000000000000015, %r10
	movq %r10, -32(%rbp)
	movq %rdi, %r10
	addq $0x0000000000000015, (%r10)
	movq %r8, -48(%rbp)
	incq -48(%rbp)
	movq %rsi, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rdi), %rsi
	movl %esi, %r8d
	movq %r8, %rax
	addq $80, %rsp
	leave
	ret

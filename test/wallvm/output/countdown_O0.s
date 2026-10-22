.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $112, %rsp
.Lmain_entry_2:
	leaq -96(%rbp), %rsi
	leaq -112(%rbp), %rdi
	movabsq $0x000000000000000a, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rsi), %r8
	testq %r8, %r8
	setg %r11b
	movzbq %r11b, %r10
	movq %r10, -80(%rbp)
	movq -80(%rbp), %r10
	testq %r10, %r10
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rsi), %r10
	movq %r10, -16(%rbp)
	movq (%rdi), %r10
	movq %r10, -32(%rbp)
	movq -32(%rbp), %r10
	addq -16(%rbp), %r10
	movq %r10, -48(%rbp)
	movq -16(%rbp), %r11
	movq %rdi, %r10
	addq %r11, (%r10)
	movq (%rsi), %r10
	movq %r10, -64(%rbp)
	movq -64(%rbp), %r9
	decq %r9
	movq %rsi, %r10
	subq $0x0000000000000001, (%r10)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rdi), %rsi
	movl %esi, %r8d
	movq %r8, %rax
	addq $112, %rsp
	leave
	ret

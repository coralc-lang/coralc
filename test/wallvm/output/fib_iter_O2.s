.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $56, %rsp
.Lmain_entry_2:
	leaq -48(%rbp), %rsi
	leaq -64(%rbp), %rdi
	leaq -80(%rbp), %r8
	movl $0x0000000000000000, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000001, %r10d
	movq %r10, (%rdi)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r8)
.Lmain_loop_3:
	movq (%rsi), %r9
	movq (%rdi), %rbx
	movq (%r8), %r12
	movl $0x000000000000000a, %r11d
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %r13
	testq %r13, %r13
	je .Lmain_done_5
.Lmain_body_4:
	addq %r12, %rbx
	addq $0x0000000000000001, (%rsi)
	movq %r12, (%rdi)
	movq %rbx, (%r8)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %r12, %rax
	addq $56, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

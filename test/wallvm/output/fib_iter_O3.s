.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	subq $48, %rsp
.Lmain_entry_2:
	leaq -48(%rbp), %r14
	leaq -64(%rbp), %r13
	leaq -80(%rbp), %r12
	movl $0x0000000000000000, %r10d
	movq %r10, (%r14)
	movl $0x0000000000000001, %r10d
	movq %r10, (%r13)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r12)
.Lmain_loop_3:
	movq (%r14), %rbx
	movq (%r13), %r9
	movq (%r12), %r8
	movl $0x000000000000000a, %r11d
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	je .Lmain_done_5
.Lmain_body_4:
	movq %r9, %rdi
	addq %r8, %rdi
	movq $0x0000000000000001, %rsi
	addq %rbx, %rsi
	movq %rsi, (%r14)
	movq %r8, (%r13)
	movq %rdi, (%r12)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %r8d, %esi
	movq %rsi, %rax
	addq $48, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

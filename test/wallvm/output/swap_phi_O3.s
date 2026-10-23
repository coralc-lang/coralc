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
	leaq -16(%rbp), %r14
	leaq -32(%rbp), %r13
	leaq -48(%rbp), %r12
	movabsq $0x0000000000000001, %r10
	movq %r10, (%r14)
	movabsq $0x0000000000000002, %r10
	movq %r10, (%r13)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r12)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%r14), %rbx
	movq (%r13), %r9
	movq (%r12), %r8
	movq $0x0000000000000001, %rdi
	addq %r8, %rdi
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %rsi
	movq %r9, (%r14)
	movq %rbx, (%r13)
	movq %rdi, (%r12)
	testq %rsi, %rsi
	jne .Lmain_loop_3
	jmp .Lmain_done_4
.Lmain_done_4:
	movq $0x000000000000000a, %r8
	imulq %rbx, %r8
	movq %r9, %rdi
	addq %r8, %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $48, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

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
	leaq -24(%rbp), %r13
	leaq -40(%rbp), %r12
	leaq -56(%rbp), %rbx
	movabsq $0x0000000000000001, %r10
	movq %r10, (%r13)
	movabsq $0x0000000000000002, %r10
	movq %r10, (%r12)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rbx)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%r13), %r9
	movq (%r12), %r8
	movq (%rbx), %rsi
	movq $0x0000000000000001, %rdi
	addq %rsi, %rdi
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %rsi
	movq %r8, (%r13)
	movq %r9, (%r12)
	movq %rdi, (%rbx)
	testq %rsi, %rsi
	jne .Lmain_loop_3
	jmp .Lmain_done_4
.Lmain_done_4:
	movq $0x000000000000000a, %rsi
	imulq %r9, %rsi
	movq %r8, %rdi
	addq %rsi, %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $56, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

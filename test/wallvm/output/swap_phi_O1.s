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
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
	leaq -48(%rbp), %r8
	movabsq $0x0000000000000001, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000002, %r10
	movq %r10, (%rdi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r8)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rsi), %r9
	movq (%rdi), %rbx
	movq (%r8), %r12
	movq %r12, %r13
	incq %r13
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %r13
	setl %r11b
	movzbq %r11b, %r14
	movq %rbx, (%rsi)
	movq %r9, (%rdi)
	movq %r8, %r10
	addq $0x0000000000000001, (%r10)
	testq %r14, %r14
	jne .Lmain_loop_3
	jmp .Lmain_done_4
.Lmain_done_4:
	leaq (%r9,%r9,4), %rsi
	addq %rsi, %rsi
	movq %rbx, %rdi
	addq %rsi, %rdi
	movl %edi, %r8d
	movq %r8, %rax
	addq $48, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

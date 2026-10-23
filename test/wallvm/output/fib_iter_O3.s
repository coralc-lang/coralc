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
	pushq %r15
	subq $56, %rsp
.Lmain_entry_2:
	leaq -24(%rbp), %rsi
	leaq -40(%rbp), %r15
	leaq -56(%rbp), %r14
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r15)
	movabsq $0x0000000000000001, %r10
	movq %r10, (%r14)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%r15), %r13
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %r13
	setl %r11b
	movzbq %r11b, %r12
	testq %r12, %r12
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%r14), %rbx
	movq (%rsi), %r9
	movq %rbx, %r8
	addq %r9, %r8
	movq %r9, (%r14)
	movq %r8, (%rsi)
	movq $0x0000000000000001, %rdi
	addq %r13, %rdi
	movq %rdi, (%r15)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rsi), %r8
	movl %r8d, %edi
	movq %rdi, %rax
	addq $56, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

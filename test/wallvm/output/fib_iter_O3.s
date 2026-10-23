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
	leaq -24(%rbp), %rsi
	leaq -40(%rbp), %r13
	leaq -56(%rbp), %r12
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r13)
	movabsq $0x0000000000000001, %r10
	movq %r10, (%r12)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%r13), %rbx
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %rdi
	testq %rdi, %rdi
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%r12), %r9
	movq (%rsi), %r8
	movq %r9, %rdi
	addq %r8, %rdi
	movq %r8, (%r12)
	movq %rdi, (%rsi)
	movq $0x0000000000000001, %rdi
	addq %rbx, %rdi
	movq %rdi, (%r13)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rsi), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $56, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

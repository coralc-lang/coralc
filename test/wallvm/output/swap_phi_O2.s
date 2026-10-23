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
	leaq -40(%rbp), %rdi
	leaq -56(%rbp), %r8
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
	incq %r12
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %r12
	setl %r11b
	movzbq %r11b, %r13
	movq %rbx, (%rsi)
	movq %r9, (%rdi)
	addq $0x0000000000000001, (%r8)
	testq %r13, %r13
	jne .Lmain_loop_3
	jmp .Lmain_done_4
.Lmain_done_4:
	leaq (%r9,%r9,4), %r9
	addq %r9, %r9
	addq %r9, %rbx
	movl %ebx, %esi
	movq %rsi, %rax
	addq $56, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

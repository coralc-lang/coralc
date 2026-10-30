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
	movl $0x0000000000000001, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000002, %r10d
	movq %r10, (%rdi)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r8)
.Lmain_loop_3:
	movq (%rsi), %r9
	movq (%rdi), %rbx
	movq (%r8), %r12
	incq %r12
	movl $0x0000000000000004, %r11d
	cmpq %r11, %r12
	setl %r11b
	movzbq %r11b, %r13
	movq %rbx, (%rsi)
	movq %r9, (%rdi)
	addq $0x0000000000000001, (%r8)
	testq %r13, %r13
	jne .Lmain_loop_3
.Lmain_done_4:
	leaq (%r9,%r9,4), %r9
	addq %r9, %r9
	addq %rbx, %r9
	movq %r9, %rax
	addq $56, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

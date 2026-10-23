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
	subq $72, %rsp
.Lmain_entry_2:
	leaq -40(%rbp), %rsi
	leaq -56(%rbp), %rdi
	leaq -72(%rbp), %r8
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000001, %r10
	movq %r10, (%rdi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r8)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rsi), %r9
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rdi), %r10
	movq %r10, -16(%rbp)
	movq (%r8), %r13
	movq -16(%rbp), %r14
	addq %r13, %r14
	movq %r13, (%rdi)
	movq %r14, (%r8)
	movq (%rsi), %r15
	movq %r15, %r12
	incq %r12
	movq %rsi, %r10
	addq $0x0000000000000001, (%r10)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%r8), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $72, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

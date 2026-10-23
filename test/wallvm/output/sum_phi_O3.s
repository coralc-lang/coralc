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
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %r13
	leaq -32(%rbp), %r12
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r13)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r12)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%r13), %rbx
	movq (%r12), %r9
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq %rbx, %rdi
	addq %r9, %rdi
	movq $0x0000000000000001, %rsi
	addq %rbx, %rsi
	movq %rsi, (%r13)
	movq %rdi, (%r12)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %r9d, %esi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

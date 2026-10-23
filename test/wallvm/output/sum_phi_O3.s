.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r14
	subq $40, %rsp
.Lmain_entry_2:
	leaq -24(%rbp), %r12
	leaq -40(%rbp), %rbx
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r12)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rbx)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%r12), %r9
	movq (%rbx), %r8
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq %r9, %rdi
	addq %r8, %rdi
	movq $0x0000000000000001, %rsi
	addq %r9, %rsi
	movq %rsi, (%r12)
	movq %rdi, (%rbx)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %r8d, %esi
	movq %rsi, %rax
	addq $40, %rsp
	popq %r14
	popq %r12
	popq %rbx
	leave
	ret

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
	movabsq $0x0000000000000030, %r10
	movq %r10, (%r12)
	movabsq $0x0000000000000012, %r10
	movq %r10, (%rbx)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rbx), %r9
	testq %r9, %r9
	setne %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%r12), %rdi
	movq %rdi, %rax
	cqo
	idivq %r9
	movq %rdx, %rsi
	movq %r9, (%r12)
	movq %rsi, (%rbx)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%r12), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $40, %rsp
	popq %r14
	popq %r12
	popq %rbx
	leave
	ret

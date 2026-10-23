.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $40, %rsp
.Lmain_entry_2:
	leaq -24(%rbp), %rsi
	leaq -40(%rbp), %rdi
	movabsq $0x0000000000000030, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000012, %r10
	movq %r10, (%rdi)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rdi), %r8
	testq %r8, %r8
	setne %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rsi), %r8
	movq (%rdi), %r9
	movq %r8, %rax
	cqo
	idivq %r9
	movq %rdx, %rbx
	movq %r9, (%rsi)
	movq %rbx, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rsi), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $40, %rsp
	popq %rbx
	leave
	ret

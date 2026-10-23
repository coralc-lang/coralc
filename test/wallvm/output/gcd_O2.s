.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r14
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
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
	movq (%rsi), %r9
	movq %r9, %rax
	cqo
	idivq %r8
	movq %rdx, %rbx
	movq %r8, (%rsi)
	movq %rbx, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rsi), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r14
	popq %rbx
	leave
	ret

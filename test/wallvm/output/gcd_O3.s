.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $40, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rbx
	leaq -48(%rbp), %r9
	movl $0x0000000000000030, %r10d
	movq %r10, (%rbx)
	movl $0x0000000000000012, %r10d
	movq %r10, (%r9)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rbx), %r8
	movq (%r9), %rdi
	testq %rdi, %rdi
	setne %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq %r8, %rax
	cqo
	idivq %rdi
	movq %rdx, %rsi
	movq %rdi, (%rbx)
	movq %rsi, (%r9)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %r8d, %esi
	movq %rsi, %rax
	addq $40, %rsp
	popq %rbx
	leave
	ret

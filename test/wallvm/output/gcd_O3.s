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
	leaq -16(%rbp), %rbx
	leaq -32(%rbp), %r9
	movabsq $0x0000000000000030, %r10
	movq %r10, (%rbx)
	movabsq $0x0000000000000012, %r10
	movq %r10, (%r9)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%r9), %r8
	testq %r8, %r8
	setne %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rbx), %rdi
	movq %rdi, %rax
	cqo
	idivq %r8
	movq %rdx, %rsi
	movq %r8, (%rbx)
	movq %rsi, (%r9)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rbx), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r14
	popq %rbx
	leave
	ret

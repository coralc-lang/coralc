.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $40, %rsp
.Lmain_entry_2:
	leaq -48(%rbp), %rsi
	movq $0x0000000000000000, %rbx
	movq $0x0000000000000001, %r9
	movq $0x0000000000000000, %r8
.Lmain_loop_3:
	movl $0x000000000000000a, %r11d
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	je .Lmain_done_5
.Lmain_body_4:
	movq %r9, %rdi
	addq %r8, %rdi
	movq $0x0000000000000001, %rsi
	addq %rbx, %rsi
	movq %rsi, %rbx
	movq %rdi, -24(%rbp)
	movq %r8, %r9
	movq -24(%rbp), %r8
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %r8d, %esi
	movq %rsi, %rax
	addq $40, %rsp
	popq %rbx
	leave
	ret

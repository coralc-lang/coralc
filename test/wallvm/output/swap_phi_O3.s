.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rsi
	movq $0x0000000000000001, %r9
	movq $0x0000000000000002, %r8
	movq $0x0000000000000000, %rsi
.Lmain_loop_3:
	movq $0x0000000000000001, %rdi
	addq %rsi, %rdi
	movl $0x0000000000000004, %r11d
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %rsi
	movq %rdi, %rsi
	movq %r9, -16(%rbp)
	movq %r8, %r9
	movq -16(%rbp), %r8
	testq %rsi, %rsi
	jne .Lmain_loop_3
.Lmain_done_4:
	movq $0x000000000000000a, %rsi
	imulq %r9, %rsi
	movq %r8, %rdi
	addq %rsi, %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $32, %rsp
	leave
	ret

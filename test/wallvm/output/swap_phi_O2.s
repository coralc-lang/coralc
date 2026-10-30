.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rsi
	movq $0x0000000000000001, %rsi
	movq $0x0000000000000002, %rdi
	movq $0x0000000000000000, %r8
.Lmain_loop_3:
	incq %r8
	movl $0x0000000000000004, %r11d
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	movq %rsi, -16(%rbp)
	movq %rdi, %rsi
	movq -16(%rbp), %rdi
	testq %r9, %r9
	jne .Lmain_loop_3
.Lmain_done_4:
	leaq (%rsi,%rsi,4), %rsi
	addq %rsi, %rsi
	addq %rsi, %rdi
	movq %rdi, %rax
	addq $32, %rsp
	leave
	ret

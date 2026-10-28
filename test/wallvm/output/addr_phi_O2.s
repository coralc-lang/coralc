.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
	movq %rsi, (%rdi)
.Lmain_loop_3:
	movq (%rdi), %rsi
	movq (%rsi), %r8
	movl $0x0000000000000007, %r11d
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	je .Lmain_done_5
.Lmain_body_4:
	movl $0x0000000000000007, %r10d
	movq %r10, (%rsi)
	movq %rsi, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %r8, %rax
	addq $32, %rsp
	leave
	ret

.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %r9
	movq %rsi, (%r9)
.Lmain_loop_3:
	movq (%r9), %r8
	movq (%r8), %rdi
	movl $0x0000000000000007, %r11d
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	je .Lmain_done_5
.Lmain_body_4:
	movl $0x0000000000000007, %r10d
	movq %r10, (%r8)
	movq %r8, (%r9)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %edi, %esi
	movq %rsi, %rax
	addq $32, %rsp
	leave
	ret

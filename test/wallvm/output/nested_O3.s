.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %r8
	jmp .Lmain_outer_3
.Lmain_outer_3:
	movl $0x0000000000000000, %r10d
	movq %r10, (%r8)
	jmp .Lmain_inner_5
.Lmain_inner_5:
	movq (%r8), %rdi
	movl $0x0000000000000003, %r11d
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lmain_inner_body_3917362336
	jmp .Lmain_outer_3
.Lmain_inner_body_3917362336:
	movq $0x0000000000000001, %rsi
	addq %rdi, %rsi
	jmp .Lmain_inner_5

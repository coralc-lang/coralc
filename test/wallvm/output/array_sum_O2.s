.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $56, %rsp
.Lmain_entry_2:
	leaq -64(%rbp), %rsi
	movq $0x0000000000000000, %rdi
.Lmain_fill_3:
	movl $0x0000000000000005, %r11d
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	je .Lmain_sum_pre_5
.Lmain_fill_body_4:
	movq %rdi, %r11
	leaq (%rsi, %r11, 8), %r8
	incq %rdi
	movq %rdi, (%r8)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
.Lmain_sum_6:
	movl $0x0000000000000005, %r11d
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	je .Lmain_done_8
.Lmain_sum_body_7:
	movq %rdi, %r11
	leaq (%rsi, %r11, 8), %r9
	movq (%r9), %rbx
	addq %r8, %rbx
	incq %rdi
	movq %rbx, %r8
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq %r8, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret

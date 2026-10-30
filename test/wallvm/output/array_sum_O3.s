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
	movq $0x0000000000000000, %r9
.Lmain_fill_3:
	movl $0x0000000000000005, %r11d
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rdi
	movq $0x0000000000000000, %rbx
	movq $0x0000000000000000, %r9
	testq %rdi, %rdi
	je .Lmain_sum_6
.Lmain_fill_body_4:
	movq %r9, %r11
	leaq (%rsi, %r11, 8), %r8
	movq $0x0000000000000001, %rdi
	addq %r9, %rdi
	movq %rdi, (%r8)
	movq %rdi, %r9
	jmp .Lmain_fill_3
.Lmain_sum_6:
	movl $0x0000000000000005, %r11d
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %rdi
	testq %rdi, %rdi
	je .Lmain_done_8
.Lmain_sum_body_7:
	movq %rbx, %r11
	leaq (%rsi, %r11, 8), %r8
	movq (%r8), %rdi
	movq %rdi, %r8
	addq %r9, %r8
	movq $0x0000000000000001, %rdi
	addq %rbx, %rdi
	movq %rdi, %rbx
	movq %r8, %r9
	jmp .Lmain_sum_6
.Lmain_done_8:
	movl %r9d, %esi
	movq %rsi, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret

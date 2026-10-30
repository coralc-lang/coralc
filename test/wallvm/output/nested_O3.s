.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	pushq %r13
.Lmain_entry_2:
	movq $0x0000000000000000, %r8
	movq $0x0000000000000000, %rdi
.Lmain_outer_3:
	movl $0x0000000000000004, %r11d
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	movq %r8, %rsi
	movq %rdi, %r13
	movq $0x0000000000000000, %r12
	testq %r9, %r9
	je .Lmain_done_8
.Lmain_inner_5:
	movq $0x0000000000000001, %rbx
	addq %rsi, %rbx
	movl $0x0000000000000003, %r11d
	cmpq %r11, %r12
	setl %r11b
	movzbq %r11b, %r9
	movq %rbx, %r8
	movq %r13, %rdi
	testq %r9, %r9
	je .Lmain_outer_3
.Lmain_inner_body_6:
	movq %rsi, %r9
	imulq %r12, %r9
	movq %r9, %rbx
	addq %r13, %rbx
	movq $0x0000000000000001, %r9
	addq %r12, %r9
	movq %rbx, %r13
	movq %r9, %r12
	jmp .Lmain_inner_5
.Lmain_done_8:
	movl %edi, %esi
	movq %rsi, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret

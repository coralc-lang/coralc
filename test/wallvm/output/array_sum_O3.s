.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $88, %rsp
.Lmain_entry_2:
	leaq -24(%rbp), %r9
	leaq -72(%rbp), %r8
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r9)
	jmp .Lmain_fill_3
.Lmain_fill_3:
	movq (%r9), %rbx
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lmain_fill_body_4
	jmp .Lmain_sum_pre_5
.Lmain_fill_body_4:
	movq %rbx, %r11
	leaq (%r8, %r11, 8), %rdi
	movq $0x0000000000000001, %rsi
	addq %rbx, %rsi
	movq %rsi, (%rdi)
	movq %rsi, (%r9)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r9)
	leaq -88(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_sum_6
.Lmain_sum_6:
	movq (%r9), %rsi
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %rsi
	setl %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	jne .Lmain_sum_body_7
	jmp .Lmain_done_8
.Lmain_sum_body_7:
	movq %rsi, %r11
	leaq (%r8, %r11, 8), %rbx
	movq (%rbx), %r13
	movq (%rdi), %r12
	movq %r13, %rbx
	addq %r12, %rbx
	movq %rbx, (%rdi)
	movq $0x0000000000000001, %rbx
	addq %rsi, %rbx
	movq %rbx, (%r9)
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq (%rdi), %r8
	movl %r8d, %esi
	movq %rsi, %rax
	addq $88, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

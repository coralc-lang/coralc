.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $104, %rsp
.Lmain_entry_2:
	leaq -80(%rbp), %rsi
	leaq -96(%rbp), %rdi
	leaq -112(%rbp), %r8
	leaq -128(%rbp), %r9
	movl $0x0000000000000000, %r10d
	movq %r10, (%rdi)
	jmp .Lmain_fill_3
.Lmain_fill_3:
	movq (%rdi), %rbx
	movl $0x0000000000000005, %r11d
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %r12
	testq %r12, %r12
	jne .Lmain_fill_body_4
	jmp .Lmain_sum_pre_5
.Lmain_fill_body_4:
	movq %rbx, %r11
	leaq (%rsi, %r11, 8), %r12
	incq %rbx
	movq %rbx, (%r12)
	addq $0x0000000000000001, (%rdi)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movl $0x0000000000000000, %r10d
	movq %r10, (%r8)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r9)
	jmp .Lmain_sum_6
.Lmain_sum_6:
	movq (%r8), %rdi
	movq (%r9), %rbx
	movl $0x0000000000000005, %r11d
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %r12
	testq %r12, %r12
	jne .Lmain_sum_body_7
	jmp .Lmain_done_8
.Lmain_sum_body_7:
	movq %rdi, %r11
	leaq (%rsi, %r11, 8), %r12
	movq (%r12), %r13
	addq %rbx, %r13
	addq $0x0000000000000001, (%r8)
	movq %r13, (%r9)
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq %rbx, %rax
	addq $104, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

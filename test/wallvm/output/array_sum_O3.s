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
	leaq -80(%rbp), %rbx
	leaq -96(%rbp), %r13
	leaq -112(%rbp), %r9
	leaq -128(%rbp), %r8
	movl $0x0000000000000000, %r10d
	movq %r10, (%r13)
.Lmain_fill_3:
	movq (%r13), %r12
	movl $0x0000000000000005, %r11d
	cmpq %r11, %r12
	setl %r11b
	movzbq %r11b, %rsi
	movl $0x0000000000000000, %r10d
	movq %r10, (%r9)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r8)
	testq %rsi, %rsi
	je .Lmain_sum_6
.Lmain_fill_body_4:
	movq %r12, %r11
	leaq (%rbx, %r11, 8), %rdi
	movq $0x0000000000000001, %rsi
	addq %r12, %rsi
	movq %rsi, (%rdi)
	movq %rsi, (%r13)
	jmp .Lmain_fill_3
.Lmain_sum_6:
	movq (%r9), %rdi
	movq (%r8), %rsi
	movl $0x0000000000000005, %r11d
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %r12
	testq %r12, %r12
	je .Lmain_done_8
.Lmain_sum_body_7:
	movq %rdi, %r11
	leaq (%rbx, %r11, 8), %r13
	movq (%r13), %r12
	movq %r12, %r13
	addq %rsi, %r13
	movq $0x0000000000000001, %r12
	addq %rdi, %r12
	movq %r12, (%r9)
	movq %r13, (%r8)
	jmp .Lmain_sum_6
.Lmain_done_8:
	movl %esi, %edi
	movq %rdi, %rax
	addq $104, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $88, %rsp
.Lmain_entry_2:
	leaq -80(%rbp), %rsi
	leaq -96(%rbp), %rdi
	leaq -112(%rbp), %r8
	leaq -128(%rbp), %r10
	movq %r10, -56(%rbp)
	leaq (%rsi), %rbx
	movl $0x000000000000000a, %r10d
	movq %r10, (%rbx)
	leaq 8(%rsi), %rbx
	movl $0x0000000000000014, %r10d
	movq %r10, (%rbx)
	leaq (%rdi), %rbx
	movl $0x0000000000000001, %r10d
	movq %r10, (%rbx)
	leaq 8(%rdi), %rbx
	movl $0x0000000000000002, %r10d
	movq %r10, (%rbx)
	movq $0x0000000000000000, %rbx
.Lmain_loop1_3:
	movl $0x0000000000000002, %r11d
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %r12
	movq %rbx, %r11
	leaq (%rsi, %r11, 8), %r13
	movq %rbx, %r11
	leaq (%rdi, %r11, 8), %r14
	movq (%r13), %r15
	movq (%r14), %r9
	movq %r15, (%r14)
	movq %r9, (%r13)
	testq %r12, %r12
	je .Lmain_loop2_pre_5
.Lmain_body1_4:
	incq %rbx
	jmp .Lmain_loop1_3
.Lmain_loop2_pre_5:
	movq $0x0000000000000000, %r9
.Lmain_loop2_6:
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rbx
	movq %r9, %r11
	leaq (%rsi, %r11, 8), %r12
	movq (%r12), %r13
	addq $0x000000000000000a, %r13
	movq %r9, %r11
	leaq (%r8, %r11, 8), %r12
	movq %r13, (%r12)
	movq %r9, %r11
	leaq (%rdi, %r11, 8), %r12
	movq (%r12), %r13
	addq $0x0000000000000014, %r13
	movq -56(%rbp), %r10
	movq %r9, %r11
	leaq (%r10, %r11, 8), %r12
	movq %r13, (%r12)
	testq %rbx, %rbx
	je .Lmain_done_8
.Lmain_body2_7:
	incq %r9
	jmp .Lmain_loop2_6
.Lmain_done_8:
	leaq 8(%rsi), %rdi
	movq (%rdi), %rsi
	leaq 8(%r8), %rdi
	movq (%rdi), %r8
	movq -56(%rbp), %r10
	leaq 8(%r10), %rdi
	movq (%rdi), %r9
	addq %r8, %rsi
	addq %r9, %rsi
	movq %rsi, %rax
	addq $88, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

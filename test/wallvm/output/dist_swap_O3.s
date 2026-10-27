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
	subq $136, %rsp
.Lmain_entry_2:
	leaq -96(%rbp), %rsi
	leaq -112(%rbp), %rdi
	leaq -128(%rbp), %r10
	movq %r10, -56(%rbp)
	leaq -144(%rbp), %r10
	movq %r10, -72(%rbp)
	leaq -160(%rbp), %rbx
	leaq -176(%rbp), %r12
	movl $0x000000000000000a, %r10d
	movq %r10, (%rsi)
	leaq 8(%rsi), %r13
	movl $0x0000000000000014, %r10d
	movq %r10, (%r13)
	movl $0x0000000000000001, %r10d
	movq %r10, (%rdi)
	leaq 8(%rdi), %r13
	movl $0x0000000000000002, %r10d
	movq %r10, (%r13)
	movl $0x0000000000000000, %r10d
	movq %r10, (%rbx)
.Lmain_loop1_3:
	movq (%rbx), %r13
	movq %r13, %r11
	leaq (%rsi, %r11, 8), %r14
	movq %r13, %r11
	leaq (%rdi, %r11, 8), %r15
	movq (%r14), %r8
	movq (%r15), %r9
	movq %r8, (%r15)
	movq %r9, (%r14)
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r13
	setl %r11b
	movzbq %r11b, %r8
	movl $0x0000000000000000, %r10d
	movq %r10, (%r12)
	testq %r8, %r8
	je .Lmain_loop2_6
.Lmain_body1_4:
	addq $0x0000000000000001, %r13
	movq %r13, (%rbx)
	jmp .Lmain_loop1_3
.Lmain_loop2_6:
	movq (%r12), %r8
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_loopdist0_64
.Lmain_done_8:
	leaq 8(%rsi), %r9
	movq (%r9), %rbx
	movq -56(%rbp), %r10
	leaq 8(%r10), %r9
	movq (%r9), %r13
	movq -72(%rbp), %r10
	leaq 8(%r10), %r9
	movq (%r9), %r14
	addq %r13, %rbx
	addq %rbx, %r14
	movq %r14, %rax
	addq $136, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_loopdist0_64:
	movq %r8, %r11
	leaq (%rsi, %r11, 8), %r9
	movq (%r9), %rbx
	addq $0x000000000000000a, %rbx
	movq -56(%rbp), %r10
	movq %r8, %r11
	leaq (%r10, %r11, 8), %r9
	movq %rbx, (%r9)
.Lmain_loopdist1_65:
	movq %r8, %r11
	leaq (%rdi, %r11, 8), %r9
	movq (%r9), %rbx
	addq $0x0000000000000014, %rbx
	movq -72(%rbp), %r10
	movq %r8, %r11
	leaq (%r10, %r11, 8), %r9
	movq %rbx, (%r9)
	addq $0x0000000000000001, %r8
	movq %r8, (%r12)
	jmp .Lmain_loop2_6

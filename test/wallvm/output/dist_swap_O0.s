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
	subq $168, %rsp
.Lmain_entry_2:
	leaq -112(%rbp), %rbx
	leaq -144(%rbp), %r12
	leaq -176(%rbp), %r10
	movq %r10, -72(%rbp)
	leaq -208(%rbp), %r10
	movq %r10, -56(%rbp)
	leaq (%rbx), %rsi
	movq $0x000000000000000a, (%rsi)
	leaq 8(%rbx), %rsi
	movq $0x0000000000000014, (%rsi)
	leaq (%r12), %rsi
	movq $0x0000000000000001, (%rsi)
	leaq 8(%r12), %rsi
	movq $0x0000000000000002, (%rsi)
	movq $0x0000000000000000, %r15
.Lmain_loop1_3:
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r15
	setl %r11b
	movzbq %r11b, %r14
	leaq .Lcs66(%rip), %r11
	leaq .Lcs66(%rip), %r11
	leaq .Lcs66(%rip), %r11
	movq $0x0000000000000000, %rdi
	movq %r15, %rsi
	movq $0x0000000000000003, %rdx
	leaq .Lcs66(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	leaq (%rbx, %r15, 8), %r13
	leaq .Lcs68(%rip), %r11
	leaq .Lcs68(%rip), %r11
	leaq .Lcs68(%rip), %r11
	movq $0x0000000000000000, %rdi
	movq %r15, %rsi
	movq $0x0000000000000003, %rdx
	leaq .Lcs68(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	leaq (%r12, %r15, 8), %rsi
	movq (%r13), %rdi
	movq (%rsi), %r8
	movq %rdi, (%rsi)
	movq %r8, (%r13)
	testq %r14, %r14
	je .Lmain_loop2_pre_5
.Lmain_body1_4:
	incq %r15
	jmp .Lmain_loop1_3
.Lmain_loop2_pre_5:
	movq $0x0000000000000000, %r13
.Lmain_loop2_6:
	movl $0x0000000000000002, %r11d
	cmpq %r11, %r13
	setl %r11b
	movzbq %r11b, %r14
	leaq .Lcs70(%rip), %r11
	leaq .Lcs70(%rip), %r11
	leaq .Lcs70(%rip), %r11
	movq $0x0000000000000000, %rdi
	movq %r13, %rsi
	movq $0x0000000000000003, %rdx
	leaq .Lcs70(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	leaq (%rbx, %r13, 8), %rsi
	movq (%rsi), %rdi
	movq %rdi, %r15
	addq $0x000000000000000a, %r15
	leaq .Lcs72(%rip), %r11
	leaq .Lcs72(%rip), %r11
	leaq .Lcs72(%rip), %r11
	movq $0x0000000000000000, %rdi
	movq %r13, %rsi
	movq $0x0000000000000003, %rdx
	leaq .Lcs72(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq -72(%rbp), %r10
	leaq (%r10, %r13, 8), %rsi
	movq %r15, (%rsi)
	leaq .Lcs74(%rip), %r11
	leaq .Lcs74(%rip), %r11
	leaq .Lcs74(%rip), %r11
	movq $0x0000000000000000, %rdi
	movq %r13, %rsi
	movq $0x0000000000000003, %rdx
	leaq .Lcs74(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	leaq (%r12, %r13, 8), %rsi
	movq (%rsi), %rdi
	movq %rdi, %r15
	addq $0x0000000000000014, %r15
	leaq .Lcs76(%rip), %r11
	leaq .Lcs76(%rip), %r11
	leaq .Lcs76(%rip), %r11
	movq $0x0000000000000000, %rdi
	movq %r13, %rsi
	movq $0x0000000000000003, %rdx
	leaq .Lcs76(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq -56(%rbp), %r10
	leaq (%r10, %r13, 8), %rsi
	movq %r15, (%rsi)
	testq %r14, %r14
	je .Lmain_done_8
.Lmain_body2_7:
	incq %r13
	jmp .Lmain_loop2_6
.Lmain_done_8:
	leaq 8(%rbx), %rsi
	movq (%rsi), %rdi
	movq -72(%rbp), %r10
	leaq 8(%r10), %rsi
	movq (%rsi), %r8
	movq -56(%rbp), %r10
	leaq 8(%r10), %rsi
	movq (%rsi), %r9
	addq %r8, %rdi
	addq %r9, %rdi
	movq %rdi, %rax
	addq $168, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs66:
	.byte 63
	.byte 0
.Lcs68:
	.byte 63
	.byte 0
.Lcs70:
	.byte 63
	.byte 0
.Lcs72:
	.byte 63
	.byte 0
.Lcs74:
	.byte 63
	.byte 0
.Lcs76:
	.byte 63
	.byte 0

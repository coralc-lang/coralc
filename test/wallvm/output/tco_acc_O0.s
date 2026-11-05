.section .text
.globl sumto
.type sumto, @function
sumto:
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rbx
	addq $8, %rsp
.Lsumto_entry_3:
	cmpq $0x0000000000000000, %rbx
	jg .Lsumto_step_5
.Lsumto_base_4:
	movq $0x0000000000000000, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.Lsumto_step_5:
	movq %rbx, %r12
	decq %r12
	movq %rbx, %rsi
	xorq $0x0000000000000001, %rsi
	movq %rbx, %rdi
	xorq %r12, %rdi
	andq %rdi, %rsi
	movq %rsi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	leaq .Lcs22(%rip), %r11
	leaq .Lcs22(%rip), %r11
	leaq .Lcs22(%rip), %r11
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs22(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r12, %rdi
	call sumto
	movq %rax, %rsi
	movq %rsi, %r12
	addq %rbx, %r12
	xorq %r12, %rsi
	movq %rbx, %rdi
	xorq %r12, %rdi
	andq %rdi, %rsi
	movq %rsi, %rbx
	movq $0x000000000000003f, %rcx
	sarq %cl, %rbx
	leaq .Lcs30(%rip), %r11
	leaq .Lcs30(%rip), %r11
	leaq .Lcs30(%rip), %r11
	movq $0x0000000000000003, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs30(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r12, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.globl main
.type main, @function
main:
.Lmain_entry_16:
	movq $0x0000000000000005, %rdi
	call sumto
	movq %rax, %rsi
	movq %rsi, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs22:
	.byte 63
	.byte 0
.Lcs30:
	.byte 63
	.byte 0

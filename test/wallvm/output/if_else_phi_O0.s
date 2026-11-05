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
	subq $16, %rsp
.Lmain_entry_2:
	leaq -48(%rbp), %rsi
	movq $0x0000000000000007, (%rsi)
	movq (%rsi), %rdi
	cmpq $0x0000000000000005, %rdi
	jle .Lmain_els_4
.Lmain_then_3:
	movq (%rsi), %rdi
	movq %rdi, %rbx
	movq $0x0000000000000001, %rcx
	shlq %cl, %rbx
	movq %rbx, %r12
	jmp .Lmain_merge_5
.Lmain_els_4:
	movq (%rsi), %rdi
	movq %rdi, %r13
	negq %r13
	xorq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %rsi
	xorq %r13, %rsi
	andq %rsi, %rdi
	movq %rdi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs25(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r13, %r12
.Lmain_merge_5:
	movq %r12, %rax
	addq $16, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs25:
	.byte 63
	.byte 0

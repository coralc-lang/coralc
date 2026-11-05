.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	subq $8, %rsp
.Lmain_entry_2:
	movq $0x0000000000000000, %rbx
	movq $0x0000000000000000, %r12
.Lmain_loop_3:
	cmpq $0x000000000000000a, %rbx
	jge .Lmain_done_5
.Lmain_body_4:
	movq %r12, %r13
	addq %rbx, %r13
	movq %r12, %rsi
	xorq %r13, %rsi
	movq %rbx, %rdi
	xorq %r13, %rdi
	andq %rdi, %rsi
	movq %rsi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs20(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %rbx, %r14
	incq %r14
	xorq %r14, %rbx
	movq $0x0000000000000001, %rsi
	xorq %r14, %rsi
	andq %rsi, %rbx
	movq $0x000000000000003f, %rcx
	sarq %cl, %rbx
	movq $0x0000000000000003, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs28(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r14, %rbx
	movq %r13, %r12
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %r12, %rax
	addq $8, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs20:
	.byte 63
	.byte 0
.Lcs28:
	.byte 63
	.byte 0

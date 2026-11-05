.section .text
.globl fib
.type fib, @function
fib:
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rbx
	addq $8, %rsp
.Lfib_entry_3:
	cmpq $0x0000000000000002, %rbx
	jge .Lfib_rec_5
.Lfib_base_4:
	movq %rbx, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.Lfib_rec_5:
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
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs25(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %rbx, %r13
	subq $0x0000000000000002, %r13
	movq %rbx, %rsi
	xorq $0x0000000000000002, %rsi
	movq %rbx, %rdi
	xorq %r13, %rdi
	andq %rdi, %rsi
	movq %rsi, %rbx
	movq $0x000000000000003f, %rcx
	sarq %cl, %rbx
	movq $0x0000000000000003, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs33(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r12, %rdi
	call fib
	movq %rax, %rbx
	movq %r13, %rdi
	call fib
	movq %rax, %rsi
	movq %rbx, %r12
	addq %rsi, %r12
	xorq %r12, %rbx
	xorq %r12, %rsi
	andq %rsi, %rbx
	movq $0x000000000000003f, %rcx
	sarq %cl, %rbx
	movq $0x0000000000000003, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs39(%rip), %rcx
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
.Lmain_entry_18:
	movq $0x000000000000000a, %rdi
	call fib
	movq %rax, %rsi
	movq %rsi, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs25:
	.byte 63
	.byte 0
.Lcs33:
	.byte 63
	.byte 0
.Lcs39:
	.byte 63
	.byte 0

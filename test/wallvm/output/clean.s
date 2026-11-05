.section .text
.globl add
.type add, @function
add:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	subq $16, %rsp
	movq %rdi, 0(%rsp)
	movq %rsi, 8(%rsp)
	movq 0(%rsp), %rsi
	movq 8(%rsp), %rdi
	addq $16, %rsp
.Ladd_entry_4:
	movq %rsi, %rbx
	addq %rdi, %rbx
	movq %rsi, %r8
	xorq %rbx, %r8
	movq %rdi, %rsi
	xorq %rbx, %rsi
	andq %rsi, %r8
	movq %r8, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs16(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %rbx, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.globl main
.type main, @function
main:
.Lmain_entry_8:
	movq $0x0000000000000014, %rdi
	movq $0x0000000000000016, %rsi
	call add
	movq %rax, %rsi
	movq %rsi, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs16:
	.byte 63
	.byte 0

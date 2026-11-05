.section .text
.globl inf
.type inf, @function
inf:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
.Linf_entry_3:
	call inf
	movq %rax, %rsi
	movq %rsi, %rbx
	addq %rdi, %rbx
	xorq %rbx, %rsi
	movq %rdi, %r8
	xorq %rbx, %r8
	andq %r8, %rsi
	movq %rsi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	leaq .Lcs13(%rip), %r11
	leaq .Lcs13(%rip), %r11
	leaq .Lcs13(%rip), %r11
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs13(%rip), %rcx
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
	movq $0x0000000000000000, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs13:
	.byte 63
	.byte 0

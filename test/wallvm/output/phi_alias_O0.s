.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $48, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rsi
	leaq -48(%rbp), %rbx
	leaq -64(%rbp), %rdi
	movq $0x0000000000000000, (%rsi)
	movq $0x0000000000000005, (%rbx)
	movq $0x0000000000000001, (%rdi)
	movb $0x0000000000000001, (%rdi)
	movq (%rdi), %r8
	cmpq $0x0000000000000000, %r8
	jg .Lmain_els_4
.Lmain_then_3:
	movq $0x000000000000000a, (%rsi)
	movq %rsi, %r12
	jmp .Lmain_merge_5
.Lmain_els_4:
	movq $0x0000000000000014, (%rbx)
	movq %rbx, %r12
.Lmain_merge_5:
	movq $0x0000000000000001, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs35(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq (%r12), %rsi
	movq $0x000000000000001e, (%rbx)
	movq (%r12), %rdi
	movq %rsi, %rbx
	addq %rdi, %rbx
	xorq %rbx, %rsi
	xorq %rbx, %rdi
	andq %rdi, %rsi
	movq %rsi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs37(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %rbx, %rax
	addq $48, %rsp
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs35:
	.byte 63
	.byte 0
.Lcs37:
	.byte 63
	.byte 0

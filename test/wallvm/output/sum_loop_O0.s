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
	subq $32, %rsp
.Lmain_entry_2:
	leaq -48(%rbp), %rbx
	leaq -64(%rbp), %r12
	movq $0x0000000000000000, (%rbx)
	movq $0x0000000000000000, (%r12)
.Lmain_loop_3:
	movq (%rbx), %rsi
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_done_5
.Lmain_body_4:
	movq (%rbx), %rsi
	movq (%r12), %rdi
	movq %rdi, %r13
	addq %rsi, %r13
	xorq %r13, %rdi
	xorq %r13, %rsi
	andq %rsi, %rdi
	movq %rdi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	leaq .Lcs29(%rip), %r11
	leaq .Lcs29(%rip), %r11
	leaq .Lcs29(%rip), %r11
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs29(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r13, (%r12)
	movq (%rbx), %rsi
	movq %rsi, %r13
	incq %r13
	xorq %r13, %rsi
	movq $0x0000000000000001, %rdi
	xorq %r13, %rdi
	andq %rdi, %rsi
	movq %rsi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	leaq .Lcs37(%rip), %r11
	leaq .Lcs37(%rip), %r11
	leaq .Lcs37(%rip), %r11
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs37(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	addq $0x0000000000000001, (%rbx)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%r12), %rsi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs29:
	.byte 63
	.byte 0
.Lcs37:
	.byte 63
	.byte 0

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
	subq $80, %rsp
.Lmain_entry_2:
	leaq -80(%rbp), %rbx
	leaq -96(%rbp), %r12
	movq $0x0000000000000000, (%r12)
.Lmain_fill_3:
	movq (%r12), %rsi
	cmpq $0x0000000000000005, %rsi
	jge .Lmain_sum_pre_5
.Lmain_fill_body_4:
	movq (%r12), %r13
	leaq .Lcs48(%rip), %r11
	leaq .Lcs48(%rip), %r11
	leaq .Lcs48(%rip), %r11
	movq $0x0000000000000000, %rdi
	movq %r13, %rsi
	movq $0x0000000000000005, %rdx
	leaq .Lcs48(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	leaq (%rbx, %r13, 8), %rsi
	incq %r13
	movq %r13, (%rsi)
	movq (%r12), %rsi
	addq $0x0000000000000001, (%r12)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movq $0x0000000000000000, (%r12)
	leaq -112(%rbp), %r13
	movq $0x0000000000000000, (%r13)
.Lmain_sum_6:
	movq (%r12), %rsi
	cmpq $0x0000000000000005, %rsi
	jge .Lmain_done_8
.Lmain_sum_body_7:
	movq (%r12), %r14
	leaq .Lcs50(%rip), %r11
	leaq .Lcs50(%rip), %r11
	leaq .Lcs50(%rip), %r11
	movq $0x0000000000000000, %rdi
	movq %r14, %rsi
	movq $0x0000000000000005, %rdx
	leaq .Lcs50(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	leaq (%rbx, %r14, 8), %rsi
	movq (%rsi), %rdi
	movq (%r13), %rsi
	addq %rdi, %rsi
	movq %rsi, (%r13)
	movq (%r12), %rsi
	addq $0x0000000000000001, (%r12)
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq (%r13), %rsi
	movq %rsi, %rax
	addq $80, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs48:
	.byte 63
	.byte 0
.Lcs50:
	.byte 63
	.byte 0

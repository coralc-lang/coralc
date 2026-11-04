.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $24, %rsp
.Lmain_entry_2:
	leaq -48(%rbp), %rbx
	movq %rbx, %r12
.Lmain_loop_3:
	leaq .Lcs19(%rip), %r11
	leaq .Lcs19(%rip), %r11
	leaq .Lcs19(%rip), %r11
	movq $0x0000000000000001, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs19(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq (%r12), %r13
	cmpq $0x0000000000000007, %r13
	jge .Lmain_done_5
.Lmain_body_4:
	leaq .Lcs22(%rip), %r11
	leaq .Lcs22(%rip), %r11
	leaq .Lcs22(%rip), %r11
	movq $0x0000000000000001, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs22(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq $0x0000000000000007, (%r12)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %r13, %rax
	addq $24, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs19:
	.byte 63
	.byte 0
.Lcs22:
	.byte 63
	.byte 0

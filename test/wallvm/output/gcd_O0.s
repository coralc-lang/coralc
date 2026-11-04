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
	movq $0x0000000000000030, (%rbx)
	movq $0x0000000000000012, (%r12)
.Lmain_loop_3:
	movq (%r12), %rsi
	cmpq $0x0000000000000000, %rsi
	je .Lmain_done_5
.Lmain_body_4:
	movq (%rbx), %r13
	movq (%r12), %r14
	leaq .Lcs27(%rip), %r11
	leaq .Lcs27(%rip), %r11
	leaq .Lcs27(%rip), %r11
	movq $0x0000000000000002, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs27(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r13, %rax
	cqo
	idivq %r14
	movq %rdx, %rsi
	movq %r14, (%rbx)
	movq %rsi, (%r12)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rbx), %rsi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs27:
	.byte 63
	.byte 0

.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $40, %rsp
.Lmain_entry_2:
	leaq -48(%rbp), %rsi
	movq $0x0000000000000000, %rbx
	movq $0x0000000000000000, %r8
.Lmain_outer_3:
	cmpq $0x0000000000000004, %rbx
	jl .Lmain_preheader_50
.Lmain_done_8:
	movl %r8d, %esi
	movq %rsi, %rax
	addq $40, %rsp
	popq %rbx
	leave
	ret
.Lmain_preheader_50:
	movq %r8, %rdi
	movq %rbx, %rsi
	movq %rsi, %r9
	addq %rdi, %r9
	leaq 1(%rbx), %r8
	movq %rbx, %rdi
	movq $0x0000000000000001, %rcx
	shlq %cl, %rdi
	movq %rdi, %rsi
	addq %r9, %rsi
	movq %rsi, %r11
	movq %r11, -24(%rbp)
	movq %r8, %rbx
	movq -24(%rbp), %r8
	jmp .Lmain_outer_3

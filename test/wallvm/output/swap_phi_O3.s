.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rsi
	movq $0x0000000000000001, %r9
	movq $0x0000000000000002, %r8
	movq $0x0000000000000000, %rsi
.Lmain_loop_3:
	movq $0x0000000000000001, %rdi
	addq %rsi, %rdi
	cmpq $0x0000000000000004, %rdi
	jl .Lmain_main.split0_21
.Lmain_done_4:
	movq $0x000000000000000a, %rsi
	imulq %r9, %rsi
	movq %r8, %rdi
	addq %rsi, %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $32, %rsp
	leave
	ret
.Lmain_main.split0_21:
	movq %rdi, %rsi
	movq %r9, -16(%rbp)
	movq %r8, %r9
	movq -16(%rbp), %r8
	jmp .Lmain_loop_3

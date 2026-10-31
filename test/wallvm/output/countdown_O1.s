.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
	movq $0x000000000000000a, (%rsi)
	movq $0x0000000000000000, (%rdi)
.Lmain_loop_3:
	movq (%rsi), %r8
	cmpq $0x0000000000000000, %r8
	jle .Lmain_done_5
.Lmain_body_4:
	movq (%rsi), %r8
	movq (%rdi), %r9
	addq %r9, %r8
	movq %r8, (%rdi)
	movq (%rsi), %r8
	subq $0x0000000000000001, (%rsi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rdi), %rsi
	movq %rsi, %rax
	addq $32, %rsp
	leave
	ret

.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $56, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rsi
	leaq -48(%rbp), %rdi
	leaq -64(%rbp), %r8
	movq $0x0000000000000000, (%rsi)
	movq $0x0000000000000001, (%rdi)
	movq $0x0000000000000000, (%r8)
.Lmain_loop_3:
	movq (%rsi), %r9
	cmpq $0x000000000000000a, %r9
	jge .Lmain_done_5
.Lmain_body_4:
	movq (%rdi), %r9
	movq (%r8), %rbx
	addq %rbx, %r9
	movq %rbx, (%rdi)
	movq %r9, (%r8)
	movq (%rsi), %r9
	addq $0x0000000000000001, (%rsi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%r8), %rsi
	movq %rsi, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret

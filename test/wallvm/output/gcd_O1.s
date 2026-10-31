.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $40, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rsi
	leaq -48(%rbp), %rdi
	movl $0x0000000000000030, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000012, %r10d
	movq %r10, (%rdi)
.Lmain_loop_3:
	movq (%rdi), %r8
	cmpq $0x0000000000000000, %r8
	je .Lmain_done_5
.Lmain_body_4:
	movq (%rsi), %r8
	movq (%rdi), %r9
	movq %r8, %rax
	cqo
	idivq %r9
	movq %rdx, %rbx
	movq %r9, (%rsi)
	movq %rbx, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rsi), %rdi
	movq %rdi, %rax
	addq $40, %rsp
	popq %rbx
	leave
	ret

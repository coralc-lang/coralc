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
	movl $0x0000000000000000, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000000, %r10d
	movq %r10, (%rdi)
.Lmain_outer_3:
	movq (%rsi), %r8
	cmpq $0x0000000000000004, %r8
	jge .Lmain_done_8
.Lmain_inner_pre_4:
	leaq -64(%rbp), %r8
	movl $0x0000000000000000, %r10d
	movq %r10, (%r8)
.Lmain_inner_5:
	movq (%r8), %r9
	cmpq $0x0000000000000003, %r9
	jge .Lmain_inner_done_7
.Lmain_inner_body_6:
	movq (%rsi), %r9
	movq (%r8), %rbx
	imulq %rbx, %r9
	movq (%rdi), %rbx
	addq %rbx, %r9
	movq %r9, (%rdi)
	movq (%r8), %r9
	addq $0x0000000000000001, (%r8)
	jmp .Lmain_inner_5
.Lmain_inner_done_7:
	movq (%rsi), %r8
	addq $0x0000000000000001, (%rsi)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq (%rdi), %rsi
	movq %rsi, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret

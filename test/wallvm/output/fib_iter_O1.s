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
	movl $0x0000000000000000, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000001, %r10d
	movq %r10, (%rdi)
	movl $0x0000000000000000, %r10d
	movq %r10, (%r8)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rsi), %r9
	movl $0x000000000000000a, %r11d
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	jne .Lmain_body_4
	jmp .Lmain_done_5
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

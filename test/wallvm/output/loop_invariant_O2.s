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
	movl $0x0000000000000000, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000000, %r10d
	movq %r10, (%rdi)
.Lmain_loop_3:
	movq (%rsi), %r8
	movq (%rdi), %r9
	movl $0x000000000000000a, %r11d
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	je .Lmain_done_5
.Lmain_body_4:
	addq $0x0000000000000001, (%rsi)
	addq $0x0000000000000015, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %r9, %rax
	addq $40, %rsp
	popq %rbx
	leave
	ret

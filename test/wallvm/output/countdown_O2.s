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
	movl $0x000000000000000a, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000000, %r10d
	movq %r10, (%rdi)
.Lmain_loop_3:
	movq (%rsi), %r8
	movq (%rdi), %r9
	testq %r8, %r8
	setg %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	je .Lmain_done_5
.Lmain_body_4:
	movq %r8, %rbx
	addq %r9, %rbx
	subq $0x0000000000000001, (%rsi)
	movq %rbx, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %r9, %rax
	addq $40, %rsp
	popq %rbx
	leave
	ret

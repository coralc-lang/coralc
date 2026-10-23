.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $40, %rsp
.Lmain_entry_2:
	leaq -24(%rbp), %rsi
	leaq -40(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rsi), %r8
	movq (%rdi), %r9
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq %r8, %rbx
	addq %r9, %rbx
	incq %r8
	addq $0x0000000000000001, (%rsi)
	movq %rbx, (%rdi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movl %r9d, %esi
	movq %rsi, %rax
	addq $40, %rsp
	popq %rbx
	leave
	ret

.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %r13
	leaq -32(%rbp), %r12
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r12)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r13)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%r12), %rbx
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %rbx
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%r13), %r8
	movq $0x0000000000000015, %rdi
	addq %r8, %rdi
	movq %rdi, (%r13)
	movq $0x0000000000000001, %rsi
	addq %rbx, %rsi
	movq %rsi, (%r12)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%r13), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret

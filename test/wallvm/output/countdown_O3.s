.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r14
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rbx
	leaq -32(%rbp), %r9
	movabsq $0x000000000000000a, %r10
	movq %r10, (%r9)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rbx)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%r9), %r8
	testq %r8, %r8
	setg %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rbx), %rdi
	movq %r8, %rsi
	addq %rdi, %rsi
	movq %rsi, (%rbx)
	movq %r8, %rsi
	decq %rsi
	subq $0x0000000000000001, (%r9)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rbx), %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $32, %rsp
	popq %r14
	popq %rbx
	leave
	ret

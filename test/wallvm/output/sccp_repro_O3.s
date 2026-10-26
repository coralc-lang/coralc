.section .text
.globl fib
.type fib, @function
fib:
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rdi
	addq $176, %rsp
.Lfib_entry_3:
	movl $0x0000000000000002, %r11d
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lfib_base_4
	jmp .Lfib_rec_5
.Lfib_base_4:
	movq %rdi, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.Lfib_rec_5:
	movq %rdi, %rbx
	decq %rbx
	movq %rdi, %r12
	subq $0x0000000000000002, %r12
	movq %rbx, %rdi
	call fib
	movq %rax, %r13
	movq %r12, %rdi
	call fib
	movq %rax, %rsi
	addq %rsi, %r13
	movq %r13, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $16, %rsp
.Lmain_entry_18:
	leaq -32(%rbp), %rbx
	jmp .Lmain_inl25_3_29
.Lmain_inl25_0_26:
	movq %rsi, %rax
	addq $16, %rsp
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_inl25_3_29:
	movq $0x0000000000000009, %rdi
	call fib
	movq %rax, %r12
	movq $0x0000000000000008, %rdi
	call fib
	movq %rax, %rsi
	addq %rsi, %r12
	movq %r12, (%rbx)
	jmp .Lmain_inl25_4_40
.Lmain_inl25_4_40:
	movq (%rbx), %rsi
	jmp .Lmain_inl25_0_26

.section .text
.globl fib
.type fib, @function
fib:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rdi
	addq $176, %rsp
.Lfib_entry_3:
	movabsq $0x0000000000000002, %r11
	cmpq %r11, %rdi
	setl %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lfib_base_4
	jmp .Lfib_rec_5
.Lfib_base_4:
	movq %rdi, %rax
	addq $48, %rsp
	leave
	ret
.Lfib_rec_5:
	movq %rdi, -16(%rbp)
	decq -16(%rbp)
	movq %rdi, %r10
	subq $0x0000000000000002, %r10
	movq %r10, -32(%rbp)
	movq -16(%rbp), %rdi
	call fib
	movq %rax, -48(%rbp)
	movq -32(%rbp), %rdi
	call fib
	movq %rax, %rsi
	movq -48(%rbp), %rdi
	addq %rsi, %rdi
	movq %rdi, %rax
	addq $48, %rsp
	leave
	ret
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp
.Lmain_entry_18:
	leaq -64(%rbp), %r10
	movq %r10, -16(%rbp)
	jmp .Lmain_inl25_3_29
.Lmain_inl25_0_26:
	movl %esi, -32(%rbp)d
	movq -32(%rbp), %rax
	addq $64, %rsp
	leave
	ret
.Lmain_inl25_3_29:
	movq $0x0000000000000009, %rdi
	call fib
	movq %rax, -48(%rbp)
	movq $0x0000000000000008, %rdi
	call fib
	movq %rax, %rsi
	movq -48(%rbp), %rdi
	addq %rsi, %rdi
	movq -16(%rbp), %r11
	movq %rdi, (%r11)
	jmp .Lmain_inl25_4_40
.Lmain_inl25_4_40:
	movq -16(%rbp), %r11
	movq (%r11), %rsi
	jmp .Lmain_inl25_0_26

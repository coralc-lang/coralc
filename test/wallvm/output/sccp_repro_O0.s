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
	subq $8, %rsp
.Lmain_entry_18:
	movq $0x000000000000000a, %rdi
	call fib
	movq %rax, %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $8, %rsp
	ret

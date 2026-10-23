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
	movabsq $0x0000000000000002, %r11
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
	movq %r13, %rdi
	addq %rsi, %rdi
	movq %rdi, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.globl main
.type main, @function
main:
.Lmain_entry_18:
	movq $0x000000000000000a, %rdi
	call fib
	movq %rax, %rsi
	movl %esi, %edi
	movq %rdi, %rax
	ret

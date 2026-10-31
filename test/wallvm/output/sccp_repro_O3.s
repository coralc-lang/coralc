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
	cmpq $0x0000000000000002, %rdi
	jge .Lfib_rec_5
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
	pushq %rbx
.Lmain_entry_18:
	jmp .Lmain_inl25_3_29
.Lmain_inl25_0_26:
	movq %rsi, %rax
	popq %rbx
	ret
.Lmain_inl25_3_29:
	movq $0x0000000000000009, %rdi
	call fib
	movq %rax, %rbx
	movq $0x0000000000000008, %rdi
	call fib
	movq %rax, %rsi
	addq %rsi, %rbx
	movq %rbx, %rsi
.Lmain_inl25_4_40:
	jmp .Lmain_inl25_0_26

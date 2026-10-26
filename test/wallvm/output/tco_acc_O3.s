.section .text
.globl sumto
.type sumto, @function
sumto:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $40, %rsp
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rsi
	addq $176, %rsp
.Lsumto_entry_3:
	leaq -48(%rbp), %r13
	leaq -64(%rbp), %r12
	movl $0x0000000000000000, %r10d
	movq %r10, (%r13)
	movq %rsi, (%r12)
.Lsumto_acc_loop_23:
	movq (%r13), %rbx
	movq (%r12), %r9
.Lsumto_entry_26:
	movq %rbx, %rdi
	addq %r9, %rdi
	testq %r9, %r9
	setle %r11b
	movzbq %r11b, %rsi
	movq %rdi, (%r13)
	subq $0x0000000000000001, (%r12)
	testq %rsi, %rsi
	je .Lsumto_acc_loop_23
.Lsumto_base_27:
	movq %rbx, %rax
	addq $40, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $40, %rsp
.Lmain_entry_16:
	leaq -48(%rbp), %r13
	leaq -64(%rbp), %r12
	movl $0x0000000000000000, %r10d
	movq %r10, (%r13)
	movl $0x0000000000000005, %r10d
	movq %r10, (%r12)
	jmp .Lmain_inl22_2_48
.Lmain_inl22_0_46:
	movl %ebx, %esi
	movq %rsi, %rax
	addq $40, %rsp
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_inl22_2_48:
	movq (%r13), %rbx
	movq (%r12), %r9
.Lmain_inl22_3_49:
	movq %rbx, %rdi
	addq %r9, %rdi
	testq %r9, %r9
	setle %r11b
	movzbq %r11b, %rsi
	movq %rdi, (%r13)
	subq $0x0000000000000001, (%r12)
	testq %rsi, %rsi
	jne .Lmain_inl22_0_46
	jmp .Lmain_inl22_2_48

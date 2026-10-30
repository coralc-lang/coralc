.section .text
.globl sumto
.type sumto, @function
sumto:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rsi
	addq $176, %rsp
.Lsumto_entry_3:
	movq $0x0000000000000000, %r12
	movq %rsi, %rbx
.Lsumto_acc_loop_23:
.Lsumto_entry_26:
	movq %rbx, %r9
	decq %r9
	movq %r12, %r8
	addq %rbx, %r8
	testq %rbx, %rbx
	setle %r11b
	movzbq %r11b, %rdi
	movq %r8, %r12
	movq %r9, %rbx
	testq %rdi, %rdi
	je .Lsumto_acc_loop_23
.Lsumto_base_27:
	movq %r12, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
.Lmain_entry_16:
	testq %rbx, %rbx
	setle %r11b
	movzbq %r11b, %rdi
	jmp .Lmain_inl22_3_45
.Lmain_inl22_0_42:
	movl %r12d, %esi
	movq %rsi, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.Lmain_inl22_2_44:
.Lmain_inl22_3_45:
	testq %rdi, %rdi
	jne .Lmain_inl22_0_42
	jmp .Lmain_inl22_2_44

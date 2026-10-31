.section .text
.globl sumto
.type sumto, @function
sumto:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rbx
	addq $176, %rsp
.Lsumto_entry_3:
	cmpq $0x0000000000000000, %rbx
	jg .Lsumto_step_5
.Lsumto_base_4:
	movq $0x0000000000000000, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.Lsumto_step_5:
	movq %rbx, %r12
	decq %r12
	movq %r12, %rdi
	call sumto
	movq %rax, %rsi
	addq %rbx, %rsi
	movq %rsi, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.globl main
.type main, @function
main:
.Lmain_entry_16:
.Lmain_inl22_0_23:
	movq $0x000000000000000f, %rax
	ret

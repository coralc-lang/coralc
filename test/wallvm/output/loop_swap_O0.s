.section .text
.globl nest
.type nest, @function
nest:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $40, %rsp
	subq $176, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %r11
	movq %r11, -56(%rbp)
	addq $176, %rsp
.Lnest_entry_3:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
	movq $0x0000000000000000, %r9
.Lnest_outer_4:
	cmpq $0x0000000000000003, %rdi
	jge .Lnest_done_13
.Lnest_inner_pre_5:
	movq $0x0000000000000000, %rbx
	movq $0x0000000000000000, %r12
.Lnest_inner_6:
.Lnest_ibody_7:
	cmpq $0x0000000000000007, -56(%rbp)
	jne .Lnest_ielse_9
.Lnest_ithen_8:
	movq %r12, -72(%rbp)
	incq -72(%rbp)
	movq -72(%rbp), %r14
	jmp .Lnest_imerge_10
.Lnest_ielse_9:
	movq %r12, %r15
	addq $0x0000000000000002, %r15
	movq %r15, %r14
.Lnest_imerge_10:
.Lnest_ilatch_11:
	movq %rbx, %rsi
	incq %rsi
	cmpq $0x0000000000000004, %rsi
	jl .Lnest_nest.split0_53
.Lnest_olatch_12:
	movq %rdi, %r13
	incq %r13
	movq %r13, %rdi
	movq %rbx, %r8
	movq %r12, %r9
	jmp .Lnest_outer_4
.Lnest_done_13:
	leaq (%r8,%r8,4), %r8
	addq %r8, %r8
	addq %rdi, %r8
	addq %r9, %r8
	movq %r8, %rax
	addq $40, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lnest_nest.split0_53:
	movq %rsi, %rbx
	movq %r14, %r12
	jmp .Lnest_inner_6
.globl main
.type main, @function
main:
.Lmain_entry_49:
	movq $0x0000000000000007, %rdi
	call nest
	movq %rax, %rsi
	movq %rsi, %rax
	ret

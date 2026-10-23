.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $56, %rsp
.Lmain_entry_2:
	leaq -24(%rbp), %rsi
	leaq -40(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_outer_3
.Lmain_outer_3:
	movq (%rsi), %r8
	movabsq $0x0000000000000004, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_inner_pre_4
	jmp .Lmain_done_8
.Lmain_inner_pre_4:
	leaq -56(%rbp), %r8
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r8)
	jmp .Lmain_inner_5
.Lmain_inner_5:
	movq (%r8), %r9
	movabsq $0x0000000000000003, %r11
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	jne .Lmain_inner_body_6
	jmp .Lmain_inner_done_7
.Lmain_inner_body_6:
	movq (%rsi), %r9
	movq (%r8), %rbx
	imulq %rbx, %r9
	movq (%rdi), %rbx
	addq %rbx, %r9
	movq %r9, (%rdi)
	movq (%r8), %r9
	incq %r9
	addq $0x0000000000000001, (%r8)
	jmp .Lmain_inner_5
.Lmain_inner_done_7:
	movq (%rsi), %r8
	incq %r8
	addq $0x0000000000000001, (%rsi)
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq (%rdi), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret

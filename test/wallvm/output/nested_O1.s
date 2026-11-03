.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
.Lmain_entry_2:
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdi
.Lmain_outer_3:
	cmpq $0x0000000000000004, %rsi
	jge .Lmain_done_8
.Lmain_inner_pre_4:
	movq %rsi, %r8
	movq %rdi, %r9
	movq $0x0000000000000000, %rbx
.Lmain_inner_5:
	cmpq $0x0000000000000003, %rbx
	jge .Lmain_inner_done_7
.Lmain_inner_body_6:
	movq %r8, %r12
	imulq %rbx, %r12
	addq %r9, %r12
	incq %rbx
	movq %r12, %r9
	jmp .Lmain_inner_5
.Lmain_inner_done_7:
	movq %r8, %rsi
	incq %rsi
	movq %r9, %rdi
	jmp .Lmain_outer_3
.Lmain_done_8:
	movq %rdi, %rax
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret

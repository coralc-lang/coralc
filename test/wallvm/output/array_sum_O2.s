.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $56, %rsp
.Lmain_entry_2:
	leaq -64(%rbp), %rsi
	movq $0x0000000000000000, %rdi
.Lmain_fill_3:
	cmpq $0x0000000000000005, %rdi
	jge .Lmain_sum_pre_5
.Lmain_fill_body_4:
	leaq (%rsi, %rdi, 8), %r8
	incq %rdi
	movq %rdi, (%r8)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
.Lmain_sum_6:
	cmpq $0x0000000000000005, %rdi
	jge .Lmain_done_8
.Lmain_sum_body_7:
	leaq (%rsi, %rdi, 8), %r9
	movq (%r9), %rbx
	addq %r8, %rbx
	incq %rdi
	movq %rbx, %r8
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq %r8, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret

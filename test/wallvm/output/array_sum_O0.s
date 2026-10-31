.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $88, %rsp
.Lmain_entry_2:
	leaq -64(%rbp), %rsi
	leaq -80(%rbp), %rdi
	movl $0x0000000000000000, %r10d
	movq %r10, (%rdi)
.Lmain_fill_3:
	movq (%rdi), %r8
	cmpq $0x0000000000000005, %r8
	jge .Lmain_sum_pre_5
.Lmain_fill_body_4:
	movq (%rdi), %r8
	movq %r8, %r11
	leaq (%rsi, %r11, 8), %r9
	incq %r8
	movq %r8, (%r9)
	movq (%rdi), %r8
	addq $0x0000000000000001, (%rdi)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movl $0x0000000000000000, %r10d
	movq %r10, (%rdi)
	leaq -96(%rbp), %r8
	movl $0x0000000000000000, %r10d
	movq %r10, (%r8)
.Lmain_sum_6:
	movq (%rdi), %r9
	cmpq $0x0000000000000005, %r9
	jge .Lmain_done_8
.Lmain_sum_body_7:
	movq (%rdi), %r9
	movq %r9, %r11
	leaq (%rsi, %r11, 8), %rbx
	movq (%rbx), %r9
	movq (%r8), %rbx
	addq %r9, %rbx
	movq %rbx, (%r8)
	movq (%rdi), %r9
	addq $0x0000000000000001, (%rdi)
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq (%r8), %rsi
	movq %rsi, %rax
	addq $88, %rsp
	popq %rbx
	leave
	ret

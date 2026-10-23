.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $88, %rsp
.Lmain_entry_2:
	leaq -56(%rbp), %rsi
	leaq -72(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_fill_3
.Lmain_fill_3:
	movq (%rdi), %r8
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_fill_body_4
	jmp .Lmain_sum_pre_5
.Lmain_fill_body_4:
	movq (%rdi), %r8
	movq %r8, %r11
	leaq (%rsi, %r11, 8), %r9
	incq %r8
	movq %r8, (%r9)
	movq (%rdi), %r8
	incq %r8
	addq $0x0000000000000001, (%rdi)
	jmp .Lmain_fill_3
.Lmain_sum_pre_5:
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	leaq -88(%rbp), %r8
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r8)
	jmp .Lmain_sum_6
.Lmain_sum_6:
	movq (%rdi), %r9
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	jne .Lmain_sum_body_7
	jmp .Lmain_done_8
.Lmain_sum_body_7:
	movq (%rdi), %r9
	movq %r9, %r11
	leaq (%rsi, %r11, 8), %rbx
	movq (%rbx), %r9
	movq (%r8), %rbx
	addq %rbx, %r9
	movq %r9, (%r8)
	movq (%rdi), %r9
	incq %r9
	addq $0x0000000000000001, (%rdi)
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq (%r8), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $88, %rsp
	popq %rbx
	leave
	ret

.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rdi)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rsi), %r8
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %r8
	setl %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rsi), %r8
	movq (%rdi), %r9
	addq %r9, %r8
	movq %r8, (%rdi)
	movq (%rsi), %r8
	incq %r8
	addq $0x0000000000000001, (%rsi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%rdi), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $32, %rsp
	leave
	ret

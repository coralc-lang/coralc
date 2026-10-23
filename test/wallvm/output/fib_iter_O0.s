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
	leaq -56(%rbp), %r8
	movabsq $0x0000000000000000, %r10
	movq %r10, (%rsi)
	movabsq $0x0000000000000001, %r10
	movq %r10, (%rdi)
	movabsq $0x0000000000000000, %r10
	movq %r10, (%r8)
	jmp .Lmain_loop_3
.Lmain_loop_3:
	movq (%rsi), %r9
	movabsq $0x000000000000000a, %r11
	cmpq %r11, %r9
	setl %r11b
	movzbq %r11b, %rbx
	testq %rbx, %rbx
	jne .Lmain_body_4
	jmp .Lmain_done_5
.Lmain_body_4:
	movq (%rdi), %r9
	movq (%r8), %rbx
	addq %rbx, %r9
	movq %rbx, (%rdi)
	movq %r9, (%r8)
	movq (%rsi), %r9
	incq %r9
	addq $0x0000000000000001, (%rsi)
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq (%r8), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret

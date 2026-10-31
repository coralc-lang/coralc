.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rsi
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000001, %rdi
	movq $0x0000000000000000, %r8
.Lmain_loop_3:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_done_5
.Lmain_body_4:
	addq %r8, %rdi
	incq %rsi
	movq %rdi, -16(%rbp)
	movq %r8, %rdi
	movq -16(%rbp), %r8
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %r8, %rax
	addq $32, %rsp
	leave
	ret

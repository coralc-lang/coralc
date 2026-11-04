.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
.Lmain_entry_2:
	leaq -48(%rbp), %rsi
	movq $0x0000000000000000, %rdi
.Lmain_loop_3:
	cmpq $0x0000000000000007, %rdi
	jge .Lmain_done_5
.Lmain_body_4:
	leaq (%rsi, %rdi, 8), %r8
	movq $0x0000000000000001, (%r8)
	incq %rdi
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq $0x0000000000000000, %rax
	addq $48, %rsp
	leave
	ret

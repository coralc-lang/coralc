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
	jmp .Lmain_preheader_50
.Lmain_sum_6:
	cmpq $0x0000000000000005, %rdi
	jge .Lmain_done_8
.Lmain_sum_body_7:
	leaq (%rsi, %rdi, 8), %r9
	movq (%r9), %rbx
	addq %r8, %rbx
	leaq 1(%rdi), %rdi
	movq %rbx, %rdi
	jmp .Lmain_sum_6
.Lmain_done_8:
	movq %r8, %rax
	addq $56, %rsp
	popq %rbx
	leave
	ret
.Lmain_preheader_50:
.Lmain__52:
	movq $0x0000000000000000, %r8
.Lmain__53:
.Lmain__54:
	movq $0x0000000000000000, %r8
.Lmain__55:
.Lmain__56:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
.Lmain__57:
.Lmain__58:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
.Lmain__59:
.Lmain__60:
	movq $0x0000000000000000, %rdi
.Lmain__61:

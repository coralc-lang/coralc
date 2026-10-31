.section .text
.globl main
.type main, @function
main:
.Lmain_entry_2:
	movq $0x0000000000000000, %rdi
.Lmain_outer_3:
	cmpq $0x0000000000000004, %rsi
	jl .Lmain_preheader_50
.Lmain_done_8:
	movq %rdi, %rax
	ret
.Lmain_preheader_50:
.Lmain__52:
	movq %r15, %rsi
	movq %r13, %rdi
.Lmain__53:
.Lmain__54:
	movq %r15, %rsi
	movq %r13, %rdi
.Lmain__55:
.Lmain__56:
	movq %r13, %rsi
.Lmain__57:

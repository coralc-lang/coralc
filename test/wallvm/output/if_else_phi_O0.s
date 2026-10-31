.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	movl $0x0000000000000007, %r10d
	movq %r10, (%rsi)
	movq (%rsi), %rdi
	cmpq $0x0000000000000005, %rdi
	jle .Lmain_els_4
.Lmain_then_3:
	movq (%rsi), %rdi
	movq $0x0000000000000001, %rcx
	shlq %cl, %rdi
	movq %rdi, %r8
	jmp .Lmain_merge_5
.Lmain_els_4:
	movq (%rsi), %r9
	movq %r9, %rsi
	negq %rsi
	movq %rsi, %r8
.Lmain_merge_5:
	movq %r8, %rax
	addq $16, %rsp
	leave
	ret

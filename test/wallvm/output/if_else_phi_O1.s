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
	movabsq $0x0000000000000007, %r10
	movq %r10, (%rsi)
	movq (%rsi), %r8
	movabsq $0x0000000000000005, %r11
	cmpq %r11, %r8
	setg %r11b
	movzbq %r11b, %r9
	testq %r9, %r9
	jne .Lmain_then_3
	jmp .Lmain_els_4
.Lmain_then_3:
	movq (%rsi), %r8
	movq $0x0000000000000001, %rcx
	shlq %cl, %r8
	movq %r8, (%rdi)
	jmp .Lmain_merge_5
.Lmain_els_4:
	movq (%rsi), %r8
	movq %r8, %rsi
	negq %rsi
	movq %rsi, (%rdi)
	jmp .Lmain_merge_5
.Lmain_merge_5:
	movq (%rdi), %rsi
	movl %esi, %edi
	movq %rdi, %rax
	addq $32, %rsp
	leave
	ret

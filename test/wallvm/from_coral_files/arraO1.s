.section .text
.globl _CNf4arra7shuffleEFA20_a_a
.type _CNf4arra7shuffleEFA20_a_a, @function
_CNf4arra7shuffleEFA20_a_a:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $40, %rsp
	leaq -48(%rbp), %rsi
	movq %rdi, (%rsi)
	leaq (%rsi), %rdi
	movb (%rdi), %r8b
	leaq (%rsi), %rdi
	leaq 19(%rsi), %r9
	movb (%r9), %bl
	movb %bl, (%rdi)
	leaq 19(%rsi), %rdi
	movb %r8b, (%rdi)
	movq $0x0000000000000000, %rax
	addq $40, %rsp
	popq %rbx
	leave
	ret
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	subq $8, %rsp
	leaq _CNf4arra1aEG(%rip), %rdi
	call _CNf4arra7shuffleEFA20_a_a
	movq %rax, %rsi
	leaq .Lcs44(%rip), %rbx
	movsbq %sil, %r12
	movq %rbx, %rdi
	movq %r12, %rsi
	movb $0, %al
	call printf@PLT
	movq %rax, %rsi
	addq $8, %rsp
	popq %r12
	popq %rbx
	ret
.section .rodata,"a",@progbits
.Lcs44:
	.asciz "%c"
.section .data
	.balign 1
_CNf4arra1aEG:
	.byte 0x0000000000000016, 0x0000000000000021, 0x0000000000000003, 0x0000000000000004, 0x0000000000000005, 0x0000000000000006, 0x0000000000000006, 0x0000000000000006, 0x0000000000000006, 0x0000000000000006, 0x0000000000000017, 0x000000000000002d, 0x000000000000000d, 0x000000000000000e, 0x000000000000000f, 0x0000000000000010
	.byte 0x0000000000000041, 0x000000000000002d, 0x000000000000002c, 0x0000000000000036

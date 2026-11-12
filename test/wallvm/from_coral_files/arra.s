.section .text
.globl _CNf4arra7shuffleEFA20_a_a
.type _CNf4arra7shuffleEFA20_a_a, @function
_CNf4arra7shuffleEFA20_a_a:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rsi
	addq $8, %rsp
	leaq -32(%rbp), %r9
	movq %rsi, (%r9)
	movb (%r9), %r8b
	leaq 19(%r9), %rdi
	movb (%rdi), %sil
	movb %sil, (%r9)
	leaq 19(%r9), %rsi
	movb %r8b, (%rsi)
	movq $0x0000000000000000, %rax
	addq $32, %rsp
	leave
	ret
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	jmp .L52
.L51:
	leaq .Lcs44(%rip), %rdi
	movq $0x0000000000000000, %rsi
	movb $0, %al
	call printf@PLT
	movq %rax, %rsi
	addq $32, %rsp
	leave
	ret
.L52:
	leaq -32(%rbp), %rsi
	leaq _CNf4arra1aEG(%rip), %r11
	movq %r11, (%rsi)
	movb (%rsi), %dil
	leaq 19(%rsi), %r8
	movb (%r8), %r9b
	movb %r9b, (%rsi)
	leaq 19(%rsi), %r8
	movb %dil, (%r8)
	jmp .L51
.section .rodata,"a",@progbits
.Lcs44:
	.asciz "%c"
.section .data
	.balign 1
_CNf4arra1aEG:
	.byte 0x0000000000000016, 0x0000000000000021, 0x0000000000000003, 0x0000000000000004, 0x0000000000000005, 0x0000000000000006, 0x0000000000000006, 0x0000000000000006, 0x0000000000000006, 0x0000000000000006, 0x0000000000000017, 0x000000000000002d, 0x000000000000000d, 0x000000000000000e, 0x000000000000000f, 0x0000000000000010
	.byte 0x0000000000000041, 0x000000000000002d, 0x000000000000002c, 0x0000000000000036

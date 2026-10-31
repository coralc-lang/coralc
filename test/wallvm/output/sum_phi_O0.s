.section .text
.globl main
.type main, @function
main:
.Lmain_entry_2:
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdi
.Lmain_loop_3:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_done_5
.Lmain_body_4:
	movq %rdi, %r8
	addq %rsi, %r8
	incq %rsi
	movq %r8, %rdi
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %rdi, %rax
	ret

.section .text
.globl main
.type main, @function
main:
.Lmain_entry_2:
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdi
.Lmain_loop_3:
	movl $0x000000000000000a, %r11d
	cmpq %r11, %rsi
	setl %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	je .Lmain_done_5
.Lmain_body_4:
	movq %rdi, %r8
	addq $0x0000000000000015, %r8
	incq %rsi
	movq %r8, %rdi
	jmp .Lmain_loop_3
.Lmain_done_5:
	movq %rdi, %rax
	ret

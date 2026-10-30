.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $72, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rsi
	leaq -48(%rbp), %rdi
	leaq -64(%rbp), %r8
	leaq -80(%rbp), %r9
	movl $0x0000000000000000, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000005, %r10d
	movq %r10, (%rdi)
	movl $0x0000000000000001, %r10d
	movq %r10, (%r8)
	movl $0x0000000000000001, %r10d
	movb %r10b, (%r8)
	movq (%r8), %rbx
	testq %rbx, %rbx
	setg %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	jne .Lmain_els_4
.Lmain_then_3:
	movl $0x000000000000000a, %r10d
	movq %r10, (%rsi)
	movq %rsi, (%r9)
	jmp .Lmain_merge_5
.Lmain_els_4:
	movl $0x0000000000000014, %r10d
	movq %r10, (%rdi)
	movq %rdi, (%r9)
.Lmain_merge_5:
	movq (%r9), %rsi
	movq (%rsi), %r8
	movl $0x000000000000001e, %r10d
	movq %r10, (%rdi)
	movq (%rsi), %rdi
	addq %rdi, %r8
	movq %r8, %rax
	addq $72, %rsp
	popq %rbx
	leave
	ret

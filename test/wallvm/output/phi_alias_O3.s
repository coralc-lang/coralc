.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $72, %rsp
.Lmain_entry_2:
	leaq -32(%rbp), %rbx
	leaq -48(%rbp), %rsi
	leaq -64(%rbp), %r9
	leaq -80(%rbp), %r8
	movl $0x0000000000000000, %r10d
	movq %r10, (%r9)
	movl $0x0000000000000005, %r10d
	movq %r10, (%rbx)
	movl $0x0000000000000001, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000001, %r10d
	movb %r10b, (%rsi)
	movq (%rsi), %rdi
	testq %rdi, %rdi
	setg %r11b
	movzbq %r11b, %rsi
	testq %rsi, %rsi
	jne .Lmain_els_4
.Lmain_then_3:
	movl $0x000000000000000a, %r10d
	movq %r10, (%r9)
	movq %r9, (%r8)
	jmp .Lmain_merge_5
.Lmain_els_4:
	movl $0x0000000000000014, %r10d
	movq %r10, (%rbx)
	movq %rbx, (%r8)
.Lmain_merge_5:
	movq (%r8), %rdi
	movq (%rdi), %r8
	movl $0x000000000000001e, %r10d
	movq %r10, (%rbx)
	movq (%rdi), %rsi
	movq %r8, %rdi
	addq %rsi, %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $72, %rsp
	popq %rbx
	leave
	ret

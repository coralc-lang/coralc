.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %r9
	leaq -32(%rbp), %rsi
	leaq -48(%rbp), %r8
	movl $0x0000000000000000, %r10d
	movq %r10, (%r8)
	movl $0x0000000000000005, %r10d
	movq %r10, (%r9)
	movl $0x0000000000000001, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000001, %r10d
	movb %r10b, (%rsi)
	movq (%rsi), %rdi
	cmpq $0x0000000000000000, %rdi
	jg .Lmain_els_4
.Lmain_then_3:
	movl $0x000000000000000a, %r10d
	movq %r10, (%r8)
	movq %r8, %rdi
	jmp .Lmain_merge_5
.Lmain_els_4:
	movl $0x0000000000000014, %r10d
	movq %r10, (%r9)
	movq %r9, %rdi
.Lmain_merge_5:
	movq (%rdi), %r8
	movl $0x000000000000001e, %r10d
	movq %r10, (%r9)
	movq (%rdi), %rsi
	movq %r8, %rdi
	addq %rsi, %rdi
	movl %edi, %esi
	movq %rsi, %rax
	addq $48, %rsp
	leave
	ret

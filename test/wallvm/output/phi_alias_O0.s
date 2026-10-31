.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
.Lmain_entry_2:
	leaq -16(%rbp), %rsi
	leaq -32(%rbp), %rdi
	leaq -48(%rbp), %r8
	movl $0x0000000000000000, %r10d
	movq %r10, (%rsi)
	movl $0x0000000000000005, %r10d
	movq %r10, (%rdi)
	movl $0x0000000000000001, %r10d
	movq %r10, (%r8)
	movl $0x0000000000000001, %r10d
	movb %r10b, (%r8)
	movq (%r8), %r9
	cmpq $0x0000000000000000, %r9
	jg .Lmain_els_4
.Lmain_then_3:
	movl $0x000000000000000a, %r10d
	movq %r10, (%rsi)
	movq %rsi, %r8
	jmp .Lmain_merge_5
.Lmain_els_4:
	movl $0x0000000000000014, %r10d
	movq %r10, (%rdi)
	movq %rdi, %r8
.Lmain_merge_5:
	movq (%r8), %rsi
	movl $0x000000000000001e, %r10d
	movq %r10, (%rdi)
	movq (%r8), %rdi
	addq %rdi, %rsi
	movq %rsi, %rax
	addq $48, %rsp
	leave
	ret

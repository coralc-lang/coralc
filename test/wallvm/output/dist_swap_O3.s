.section .text
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $136, %rsp
.Lmain_entry_2:
	leaq -80(%rbp), %rbx
	leaq -112(%rbp), %r9
	leaq -144(%rbp), %r8
	leaq -176(%rbp), %rdi
	movq $0x000000000000000a, (%rbx)
	leaq 8(%rbx), %rsi
	movq $0x0000000000000014, (%rsi)
	movq $0x0000000000000001, (%r9)
	leaq 8(%r9), %rsi
	movq $0x0000000000000002, (%rsi)
	jmp .Lmain__80
.Lmain_done_8:
	leaq 8(%rbx), %r12
	movq (%r12), %rsi
	leaq 8(%r8), %r12
	movq (%r12), %r15
	leaq 8(%rdi), %r12
	movq (%r12), %r14
	movq %rsi, %r13
	addq %r15, %r13
	movq %r14, %r12
	addq %r13, %r12
	movl %r12d, %esi
	movq %rsi, %rax
	addq $136, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain__80:
	leaq (%rbx), %r14
	leaq (%r9), %r13
	movq (%r14), %r12
	movq (%r13), %rsi
	movq %r12, (%r13)
	movq %rsi, (%r14)
.Lmain__82:
	leaq 8(%rbx), %r14
	leaq 8(%r9), %r13
	movq (%r14), %r12
	movq (%r13), %rsi
	movq %r12, (%r13)
	movq %rsi, (%r14)
.Lmain__110:
	leaq (%rbx), %r12
	movq (%r12), %rsi
	leaq 10(%rsi), %r12
	leaq (%r8), %rsi
	movq %r12, (%rsi)
.Lmain__111:
	leaq (%r9), %r12
	movq (%r12), %rsi
	leaq 20(%rsi), %r12
	leaq (%rdi), %rsi
	movq %r12, (%rsi)
.Lmain__113:
	leaq 8(%rbx), %r12
	movq (%r12), %rsi
	leaq 10(%rsi), %r12
	leaq 8(%r8), %rsi
	movq %r12, (%rsi)
.Lmain__114:
	leaq 8(%r9), %r12
	movq (%r12), %rsi
	leaq 20(%rsi), %r9
	leaq 8(%rdi), %rsi
	movq %r9, (%rsi)
	jmp .Lmain_done_8

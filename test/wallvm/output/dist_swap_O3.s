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
	subq $72, %rsp
.Lmain_entry_2:
	leaq -64(%rbp), %rsi
	leaq -80(%rbp), %rdi
	leaq -96(%rbp), %r8
	leaq -112(%rbp), %r9
	movq $0x000000000000000a, (%rsi)
	leaq 8(%rsi), %rbx
	movq $0x0000000000000014, (%rbx)
	movq $0x0000000000000001, (%rdi)
	leaq 8(%rdi), %rbx
	movq $0x0000000000000002, (%rbx)
	jmp .Lmain_preheader_78
.Lmain_loop2_6:
	cmpq $0x0000000000000002, %rbx
	jl .Lmain_loopdist0_64
.Lmain_done_8:
	leaq 8(%rsi), %r12
	movq (%r12), %r13
	leaq 8(%r8), %r12
	movq (%r12), %r14
	leaq 8(%r9), %r12
	movq (%r12), %r15
	addq %r14, %r13
	addq %r13, %r15
	movq %r15, %rax
	addq $72, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_loopdist0_64:
	leaq (%rsi, %rbx, 8), %r12
	movq (%r12), %r13
	leaq 10(%r13), %r13
	leaq (%r8, %rbx, 8), %r12
	movq %r13, (%r12)
.Lmain_loopdist1_65:
	leaq (%rdi, %rbx, 8), %r12
	movq (%r12), %r13
	leaq 20(%r13), %r13
	leaq (%r9, %rbx, 8), %r12
	movq %r13, (%r12)
	leaq 1(%rbx), %rbx
	jmp .Lmain_loop2_6
.Lmain_preheader_78:
.Lmain__80:
	movq $0x0000000000000000, %rbx
.Lmain__81:
.Lmain__82:
	movq $0x0000000000000000, %rbx
.Lmain__83:

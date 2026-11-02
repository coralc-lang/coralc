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
	subq $24, %rsp
.Lmain_entry_2:
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %rdi
.Lmain_outer_3:
	cmpq $0x0000000000000004, %rsi
	jl .Lmain_preheader_50
.Lmain_done_8:
	movl %edi, %r8d
	movq %r8, %rax
	addq $24, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_preheader_50:
	movq %rsi, %r8
	movq %rdi, %r9
	movq $0x0000000000000000, %rsi
.Lmain__52:
	leaq 1(%r8), %r10
	movq %r10, -56(%rbp)
	cmpq $0x0000000000000003, %rsi
	jge .Lmain_main.split0_88
.Lmain__53:
	movq %r8, %rbx
	imulq %rsi, %rbx
	addq %r9, %rbx
	leaq 1(%rsi), %rsi
	movq %r8, %r12
	movq %rbx, %r13
	movq %rsi, %r14
.Lmain__54:
	leaq 1(%r12), %rsi
	cmpq $0x0000000000000003, %r14
	jge .Lmain_main.split1_90
.Lmain__55:
	movq %r12, %r8
	imulq %r14, %r8
	addq %r13, %r8
	leaq 1(%r14), %r14
	movq %r12, %rbx
	movq %r8, %r15
	movq %r14, %rdi
.Lmain__56:
	leaq 1(%rbx), %r8
	cmpq $0x0000000000000003, %rdi
	jge .Lmain_main.split2_92
.Lmain__57:
	imulq %rdi, %rbx
	addq %r15, %rbx
	leaq 1(%rdi), %rdi
	movq %r8, %rsi
	movq %rbx, %rdi
	jmp .Lmain_outer_3
.Lmain_main.split0_88:
	movq -56(%rbp), %rsi
	movq %r9, %rdi
	jmp .Lmain_outer_3
.Lmain_main.split1_90:
	movq %r13, %rdi
	jmp .Lmain_outer_3
.Lmain_main.split2_92:
	movq %r8, %rsi
	movq %r15, %rdi
	jmp .Lmain_outer_3

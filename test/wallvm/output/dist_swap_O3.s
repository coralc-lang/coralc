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
	leaq -80(%rbp), %rsi
	leaq -112(%rbp), %rdi
	leaq -144(%rbp), %r8
	leaq -176(%rbp), %r9
	movq $0x000000000000000a, (%rsi)
	leaq 8(%rsi), %rbx
	movq $0x0000000000000014, (%rbx)
	movq $0x0000000000000001, (%rdi)
	leaq 8(%rdi), %rbx
	movq $0x0000000000000002, (%rbx)
	jmp .Lmain_preheader_78
.Lmain_done_8:
	leaq 8(%rsi), %rbx
	movq (%rbx), %r12
	leaq 8(%r8), %rbx
	movq (%rbx), %r13
	leaq 8(%r9), %rbx
	movq (%rbx), %r14
	addq %r13, %r12
	addq %r12, %r14
	movq %r14, %rax
	addq $136, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_preheader_78:
	movq $0x0000000000000000, %rbx
.Lmain__80:
	leaq (%rsi, %rbx, 8), %r12
	leaq (%rdi, %rbx, 8), %r13
	movq (%r12), %r14
	movq (%r13), %r15
	movq %r14, (%r13)
	movq %r15, (%r12)
	cmpq $0x0000000000000002, %rbx
	jge .Lmain_main.split0_147
.Lmain__81:
	leaq 1(%rbx), %rbx
	movq %rbx, %r12
.Lmain__82:
	leaq (%rsi, %r12, 8), %rbx
	leaq (%rdi, %r12, 8), %r13
	movq (%rbx), %r14
	movq (%r13), %r15
	movq %r14, (%r13)
	movq %r15, (%rbx)
	cmpq $0x0000000000000002, %r12
	jge .Lmain_main.split1_149
.Lmain__83:
	leaq 1(%r12), %r12
	movq $0x0000000000000000, %rbx
.Lmain_preheader_106:
	movq %rbx, %r12
.Lmain__109:
	cmpq $0x0000000000000002, %r12
	jge .Lmain_done_8
.Lmain__110:
	leaq (%rsi, %r12, 8), %rbx
	movq (%rbx), %r13
	leaq 10(%r13), %r13
	leaq (%r8, %r12, 8), %rbx
	movq %r13, (%rbx)
.Lmain__111:
	leaq (%rdi, %r12, 8), %rbx
	movq (%rbx), %r13
	leaq 20(%r13), %r13
	leaq (%r9, %r12, 8), %rbx
	movq %r13, (%rbx)
	leaq 1(%r12), %r12
	movq %r12, %rbx
.Lmain__112:
	cmpq $0x0000000000000002, %rbx
	jge .Lmain_done_8
.Lmain__113:
	leaq (%rsi, %rbx, 8), %r12
	movq (%r12), %r13
	leaq 10(%r13), %r13
	leaq (%r8, %rbx, 8), %r12
	movq %r13, (%r12)
.Lmain__114:
	leaq (%rdi, %rbx, 8), %r12
	movq (%r12), %rdi
	leaq 20(%rdi), %rdi
	leaq (%r9, %rbx, 8), %r12
	movq %rdi, (%r12)
	leaq 1(%rbx), %rbx
	jmp .Lmain_done_8
.Lmain_main.split0_147:
	movq $0x0000000000000000, %rbx
	jmp .Lmain_preheader_106
.Lmain_main.split1_149:
	movq $0x0000000000000000, %rbx
	jmp .Lmain_preheader_106

.section .text
.globl _CNf4baby4name3addEMvFNf4baby4nameE_v
.type _CNf4baby4name3addEMvFNf4baby4nameE_v, @function
_CNf4baby4name3addEMvFNf4baby4nameE_v:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $32, %rsp
	subq $8, %rsp
	movq %rsi, 0(%rsp)
	movq 0(%rsp), %r8
	leaq -48(%rbp), %r10
	movq 0(%rsp), %r11
	movq %r11, (%r10)
	addq $8, %rsp
	leaq -32(%rbp), %rsi
	movq %rdi, (%rsi)
	leaq -48(%rbp), %rdi
	movb %r8b, (%rdi)
	movq (%rsi), %r8
	leaq (%r8), %r9
	movl (%r9), %r8d
	leaq (%rdi), %rbx
	movl (%rbx), %r12d
	addl %r12d, %r8d
	movl %r8d, (%r9)
	movq (%rsi), %r8
	leaq 4(%r8), %rsi
	movl (%rsi), %r8d
	leaq 4(%rdi), %r9
	movl (%r9), %edi
	addl %edi, %r8d
	movl %r8d, (%rsi)
	addq $32, %rsp
	popq %r12
	popq %rbx
	leave
	ret
.globl _CNf4baby3newEF_Nf4baby4nameE
.type _CNf4baby3newEF_Nf4baby4nameE, @function
_CNf4baby3newEF_Nf4baby4nameE:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	leaq -16(%rbp), %rsi
	leaq (%rsi), %rdi
	movl $0x0000000000000002, (%rdi)
	leaq 4(%rsi), %rdi
	movl $0x0000000000000003, (%rdi)
	movq %rsi, %r10
	movq (%r10), %rax
	addq $16, %rsp
	leave
	ret
.globl _CNf4baby3addEFNf4baby4nameENf4baby4nameE_Nf4baby4nameE
.type _CNf4baby3addEFNf4baby4nameENf4baby4nameE_Nf4baby4nameE, @function
_CNf4baby3addEFNf4baby4nameENf4baby4nameE_Nf4baby4nameE:
	pushq %rbp
	movq %rsp, %rbp
	subq $48, %rsp
	subq $16, %rsp
	movq %rdi, 0(%rsp)
	movq %rsi, 8(%rsp)
	movq 0(%rsp), %rdi
	leaq -16(%rbp), %r10
	movq 0(%rsp), %r11
	movq %r11, (%r10)
	movq 8(%rsp), %r8
	leaq -32(%rbp), %r10
	movq 8(%rsp), %r11
	movq %r11, (%r10)
	addq $16, %rsp
	leaq -16(%rbp), %rsi
	movb %dil, (%rsi)
	leaq -32(%rbp), %rsi
	movb %r8b, (%rsi)
	leaq -48(%rbp), %rsi
	movq %rsi, %r10
	movq (%r10), %rax
	addq $48, %rsp
	leave
	ret
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	subq $96, %rsp
	leaq -32(%rbp), %rbx
	call _CNf4baby3newEF_Nf4baby4nameE
	movq %rax, -48(%rbp)
	leaq -48(%rbp), %rsi
	leaq (%rbx), %rdi
	leaq (%rsi), %r8
	movl (%r8), %r9d
	movl %r9d, (%rdi)
	leaq 4(%rbx), %rdi
	leaq 4(%rsi), %r8
	movl (%r8), %esi
	movl %esi, (%rdi)
	leaq -64(%rbp), %r12
	call _CNf4baby3newEF_Nf4baby4nameE
	movq %rax, -80(%rbp)
	leaq -80(%rbp), %rsi
	leaq (%r12), %rdi
	leaq (%rsi), %r8
	movl (%r8), %r9d
	movl %r9d, (%rdi)
	leaq 4(%r12), %rdi
	leaq 4(%rsi), %r8
	movl (%r8), %esi
	movl %esi, (%rdi)
	movq %r12, %rdi
	movq (%rbx), %rsi
	call _CNf4baby4name3addEMvFNf4baby4nameE_v
	movq %rax, %rsi
	movq (%r12), %rdi
	movq (%rbx), %rsi
	call _CNf4baby3addEFNf4baby4nameENf4baby4nameE_Nf4baby4nameE
	movq %rax, -96(%rbp)
	leaq -96(%rbp), %rsi
	leaq (%r12), %rdi
	leaq (%rsi), %r8
	movl (%r8), %r9d
	movl %r9d, (%rdi)
	leaq 4(%r12), %rdi
	leaq 4(%rsi), %r8
	movl (%r8), %esi
	movl %esi, (%rdi)
	leaq .Lcs79(%rip), %rsi
	leaq -112(%rbp), %rdi
	movq %rsi, (%rdi)
	leaq 8(%rdi), %rsi
	movq $0x0000000000000002, (%rsi)
	leaq (%rdi), %rsi
	movq (%rsi), %rbx
	leaq (%r12), %rsi
	movl (%rsi), %r12d
	movq %rbx, %rdi
	movq %r12, %rsi
	movb $0, %al
	call printf@PLT
	movq %rax, %rsi
	addq $96, %rsp
	popq %r12
	popq %rbx
	leave
	ret
.section .rodata,"a",@progbits
.Lcs79:
	.asciz "%d"

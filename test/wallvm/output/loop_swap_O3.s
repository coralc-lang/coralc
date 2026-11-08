.section .text
.globl nest
.type nest, @function
nest:
	pushq %rbx
	pushq %r12
	pushq %r13
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rsi
	addq $8, %rsp
	movq $0x0000000000000000, %rdi
	jmp .L59
.L13:
	imulq $0x000000000000000a, %rdi
	leaq 3(%rdi), %rdi
	addq %rdi, %r8
	movq %r8, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.L59:
.L60:
	cmpq $0x0000000000000007, %rsi
	je .L62
.L61:
.L62:
.L63:
	leaq 1(%rdi), %rdi
	cmpq $0x0000000000000004, %rdi
	jl .L142
.L64:
	movq $0x0000000000000000, %rdi
.L65:
.L66:
	cmpq $0x0000000000000007, %rsi
	je .L68
.L67:
.L68:
.L69:
	leaq 1(%rdi), %rdi
	cmpq $0x0000000000000004, %rdi
	jl .L144
.L70:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
.L71:
.L72:
	leaq 1(%r8), %r9
	cmpq $0x0000000000000007, %rsi
	je .L148
.L73:
	leaq 2(%r8), %rbx
	movq %rbx, %r12
.L74:
.L75:
	leaq 1(%rdi), %r9
	cmpq $0x0000000000000004, %r9
	jl .L146
.L140:
	jmp .L13
.L142:
	jmp .L59
.L144:
	jmp .L65
.L146:
	movq %r9, %rdi
	movq %r12, %r8
	jmp .L71
.L148:
	movq %r9, %r12
	jmp .L74
.globl main
.type main, @function
main:
	movq $0x0000000000000007, %rdi
	call nest
	movq %rax, %rsi
	movq %rsi, %rax
	ret

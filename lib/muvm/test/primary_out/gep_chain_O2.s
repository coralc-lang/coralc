.text
.p2align 4,,15
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
.Lmain_BB2:
	leaq -32(%rbp), %rdi
	leaq 16(%rdi), %rdi
	leaq 8(%rdi), %rdi
	movq $42, (%rdi)
	movl $42, %eax
	movq %rbp, %rsp
	popq %rbp
	ret
.size main,.-main



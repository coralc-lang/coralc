.section .text
.globl crl$loc$foo$div
.type crl$loc$foo$div, @function
crl$loc$foo$div:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	subq $32, %rsp
	movdqu %xmm0, 0(%rsp)
	movdqu %xmm1, 16(%rsp)
	movdqu 0(%rsp), %xmm2
	movdqu 16(%rsp), %xmm3
	addq $32, %rsp
.Lcrl$loc$foo$div_entry_3:
	leaq -16(%rbp), %rsi
	movd %xmm2, (%rsi)
	leaq -32(%rbp), %rdi
	movd %xmm3, (%rdi)
	movd (%rdi), %xmm2
	movss %xmm2, %xmm0
	ucomiss $0x0000000000000000, %xmm0
	setne %r11b
	setnp %r10b
	and %r10b, %r11b
	movzbq %r11b, %r8
	testq %r8, %r8
	je .Lcrl$loc$foo$div_if.end_14
.Lcrl$loc$foo$div_if.then_13:
	movd (%rsi), %xmm2
	movd (%rdi), %xmm3
	divss	%xmm3, %xmm2
	movsd %xmm2, %xmm0
	addq $32, %rsp
	leave
	ret
.Lcrl$loc$foo$div_if.end_14:
	movsd %rsi, %xmm0
	addq $32, %rsp
	leave
	ret
.globl main
.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	subq $24, %rsp
.Lmain_entry_23:
	leaq -32(%rbp), %rbx
	movabsq $0x4072c4ccc0000000, %r11
	movq %r11, %xmm0
	movq $0x0000000000000400, %rdi
	call crl$loc$foo$div
	movss %xmm0, %xmm2
	movd %xmm2, (%rbx)
	movd (%rbx), %xmm2
	movss %xmm2, %xmm0
	movq $0x0000000000000003, %rdi
	call crl$loc$foo$div
	movss %xmm0, %xmm3
	movd %xmm3, (%rbx)
	addq $24, %rsp
	popq %rbx
	leave
	ret

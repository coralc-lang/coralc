.section .text
.globl nest
.type nest, @function
nest:
	pushq %rbp
	movq %rsp, %rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	subq $120, %rsp
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %r11
	movq %r11, -56(%rbp)
	addq $8, %rsp
.Lnest_entry_3:
	movq $0x0000000000000000, %r12
	movq $0x0000000000000000, %r11
	movq %r11, -88(%rbp)
	movq $0x0000000000000000, %r11
	movq %r11, -136(%rbp)
.Lnest_outer_4:
	cmpq $0x0000000000000003, %r12
	jge .Lnest_done_13
.Lnest_inner_pre_5:
	movq $0x0000000000000000, %r15
	movq $0x0000000000000000, %rbx
.Lnest_inner_6:
.Lnest_ibody_7:
	cmpq $0x0000000000000007, -56(%rbp)
	jne .Lnest_ielse_9
.Lnest_ithen_8:
	movq %rbx, -72(%rbp)
	incq -72(%rbp)
	movq %rbx, %rsi
	xorq -72(%rbp), %rsi
	movq $0x0000000000000001, %rdi
	xorq -72(%rbp), %rdi
	andq %rdi, %rsi
	movq %rsi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs54(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq -72(%rbp), %r11
	movq %r11, -104(%rbp)
	jmp .Lnest_imerge_10
.Lnest_ielse_9:
	movq %rbx, %r10
	addq $0x0000000000000002, %r10
	movq %r10, -120(%rbp)
	movq %rbx, %rsi
	xorq -120(%rbp), %rsi
	movq $0x0000000000000002, %rdi
	xorq -120(%rbp), %rdi
	andq %rdi, %rsi
	movq %rsi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs61(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq -120(%rbp), %r11
	movq %r11, -104(%rbp)
.Lnest_imerge_10:
.Lnest_ilatch_11:
	movq %r15, -152(%rbp)
	incq -152(%rbp)
	movq %r15, %rsi
	xorq -152(%rbp), %rsi
	movq $0x0000000000000001, %rdi
	xorq -152(%rbp), %rdi
	andq %rdi, %rsi
	movq %rsi, %r14
	movq $0x000000000000003f, %rcx
	sarq %cl, %r14
	movq $0x0000000000000003, %rdi
	movq %r14, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs67(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	cmpq $0x0000000000000004, -152(%rbp)
	jl .Lnest_nest.split0_91
.Lnest_olatch_12:
	movq %r12, %r14
	incq %r14
	movq %r12, %rsi
	xorq %r14, %rsi
	movq $0x0000000000000001, %rdi
	xorq %r14, %rdi
	andq %rdi, %rsi
	movq %rsi, %r13
	movq $0x000000000000003f, %rcx
	sarq %cl, %r13
	movq $0x0000000000000003, %rdi
	movq %r13, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs73(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r14, %r12
	movq %r15, %r11
	movq %r11, -88(%rbp)
	movq %rbx, %r11
	movq %r11, -136(%rbp)
	jmp .Lnest_outer_4
.Lnest_done_13:
	movq -88(%rbp), %r10
	leaq (%r10,%r10,4), %rsi
	addq %rsi, %rsi
	movq %rsi, %rbx
	addq %r12, %rbx
	xorq %rbx, %rsi
	xorq %rbx, %r12
	andq %r12, %rsi
	movq %rsi, %r12
	movq $0x000000000000003f, %rcx
	sarq %cl, %r12
	movq $0x0000000000000003, %rdi
	movq %r12, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs79(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %rbx, %r12
	addq -136(%rbp), %r12
	xorq %r12, %rbx
	movq -136(%rbp), %rsi
	xorq %r12, %rsi
	andq %rsi, %rbx
	movq $0x000000000000003f, %rcx
	sarq %cl, %rbx
	movq $0x0000000000000003, %rdi
	movq %rbx, %rsi
	movq $0x0000000000000000, %rdx
	leaq .Lcs85(%rip), %rcx
	movq $0x0000000000000000, %r8
	call _trap@PLT
	movq %rax, %rsi
	movq %r12, %rax
	addq $120, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lnest_nest.split0_91:
	movq -152(%rbp), %r15
	movq -104(%rbp), %rbx
	jmp .Lnest_inner_6
.globl main
.type main, @function
main:
.Lmain_entry_49:
	movq $0x0000000000000007, %rdi
	call nest
	movq %rax, %rsi
	movq %rsi, %rax
	ret
.section .rodata.str1.1,"aM",@progbits,1
.Lcs54:
	.byte 63
	.byte 0
.Lcs61:
	.byte 63
	.byte 0
.Lcs67:
	.byte 63
	.byte 0
.Lcs73:
	.byte 63
	.byte 0
.Lcs79:
	.byte 63
	.byte 0
.Lcs85:
	.byte 63
	.byte 0

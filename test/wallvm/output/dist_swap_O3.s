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
	leaq -64(%rbp), %r9
	leaq -80(%rbp), %r8
	leaq -96(%rbp), %rdi
	leaq -112(%rbp), %rsi
	movq $0x000000000000000a, (%r9)
	leaq 8(%r9), %rbx
	movq $0x0000000000000014, (%rbx)
	movq $0x0000000000000001, (%r8)
	leaq 8(%r8), %rbx
	movq $0x0000000000000002, (%rbx)
	movq $0x0000000000000000, %rbx
.Lmain_loop1_3:
	movq %rbx, %r11
	leaq (%r9, %r11, 8), %r15
	movq %rbx, %r11
	leaq (%r8, %r11, 8), %r14
	movq (%r15), %r13
	movq (%r14), %r12
	movq %r13, (%r14)
	movq %r12, (%r15)
	cmpq $0x0000000000000002, %rbx
	jge .Lmain_main.split0_78
.Lmain_body1_4:
	movq $0x0000000000000001, %r12
	addq %rbx, %r12
	movq %r12, %rbx
	jmp .Lmain_loop1_3
.Lmain_loop2_6:
	cmpq $0x0000000000000002, %r15
	jl .Lmain_loopdist0_64
.Lmain_done_8:
	leaq 8(%r9), %rbx
	movq (%rbx), %r14
	leaq 8(%rdi), %rbx
	movq (%rbx), %r13
	leaq 8(%rsi), %rbx
	movq (%rbx), %r12
	movq %r14, %rbx
	addq %r13, %rbx
	movq %r12, %r13
	addq %rbx, %r13
	movl %r13d, %ebx
	movq %rbx, %rax
	addq $72, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_loopdist0_64:
	movq %r15, %r11
	leaq (%r9, %r11, 8), %r12
	movq (%r12), %rbx
	movq $0x000000000000000a, %r12
	addq %rbx, %r12
	movq %r15, %r11
	leaq (%rdi, %r11, 8), %rbx
	movq %r12, (%rbx)
.Lmain_loopdist1_65:
	movq %r15, %r11
	leaq (%r8, %r11, 8), %r12
	movq (%r12), %rbx
	movq $0x0000000000000014, %r12
	addq %rbx, %r12
	movq %r15, %r11
	leaq (%rsi, %r11, 8), %rbx
	movq %r12, (%rbx)
	movq $0x0000000000000001, %rbx
	addq %r15, %rbx
	movq %rbx, %r15
	jmp .Lmain_loop2_6
.Lmain_main.split0_78:
	movq $0x0000000000000000, %r15
	jmp .Lmain_loop2_6

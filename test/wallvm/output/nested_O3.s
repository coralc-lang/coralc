.section .text
.globl main
.type main, @function
main:
	pushq %rbx
	pushq %r12
	pushq %r13
.Lmain_entry_2:
	movq $0x0000000000000000, %r8
	movq $0x0000000000000000, %rdi
.Lmain_outer_3:
	cmpq $0x0000000000000004, %r8
	jl .Lmain_main.split1_52
	jmp .Lmain_done_8
.Lmain_inner_5:
	movq $0x0000000000000001, %rbx
	addq %rsi, %rbx
	cmpq $0x0000000000000003, %r12
	jge .Lmain_main.split0_50
.Lmain_inner_body_6:
	movq %rsi, %r9
	imulq %r12, %r9
	movq %r9, %rbx
	addq %r13, %rbx
	movq $0x0000000000000001, %r9
	addq %r12, %r9
	movq %rbx, %r13
	movq %r9, %r12
	jmp .Lmain_inner_5
.Lmain_done_8:
	movl %edi, %esi
	movq %rsi, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.Lmain_main.split0_50:
	movq %rbx, %r8
	movq %r13, %rdi
	jmp .Lmain_outer_3
.Lmain_main.split1_52:
	movq %r8, %rsi
	movq %rdi, %r13
	movq $0x0000000000000000, %r12
	jmp .Lmain_inner_5

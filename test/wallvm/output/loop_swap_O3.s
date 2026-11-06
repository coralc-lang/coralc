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
.Lnest_entry_3:
	movq $0x0000000000000000, %rdi
	jmp .Lnest__59
.Lnest_done_13:
	imulq $0x000000000000000a, %rdi
	leaq 3(%rdi), %rdi
	addq %rdi, %r8
	movq %r8, %rax
	popq %r13
	popq %r12
	popq %rbx
	ret
.Lnest__59:
.Lnest__60:
	cmpq $0x0000000000000007, %rsi
	je .Lnest__62
.Lnest__61:
.Lnest__62:
.Lnest__63:
	leaq 1(%rdi), %rdi
	cmpq $0x0000000000000004, %rdi
	jl .Lnest_nest.split1_142
.Lnest__64:
	movq $0x0000000000000000, %rdi
.Lnest__65:
.Lnest__66:
	cmpq $0x0000000000000007, %rsi
	je .Lnest__68
.Lnest__67:
.Lnest__68:
.Lnest__69:
	leaq 1(%rdi), %rdi
	cmpq $0x0000000000000004, %rdi
	jl .Lnest_nest.split2_144
.Lnest__70:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
.Lnest__71:
.Lnest__72:
	leaq 1(%r8), %r9
	cmpq $0x0000000000000007, %rsi
	je .Lnest_nest.split4_148
.Lnest__73:
	leaq 2(%r8), %rbx
	movq %rbx, %r12
.Lnest__74:
.Lnest__75:
	leaq 1(%rdi), %r9
	cmpq $0x0000000000000004, %r9
	jl .Lnest_nest.split3_146
.Lnest_nest.split0_140:
	jmp .Lnest_done_13
.Lnest_nest.split1_142:
	jmp .Lnest__59
.Lnest_nest.split2_144:
	jmp .Lnest__65
.Lnest_nest.split3_146:
	movq %r9, %rdi
	movq %r12, %r8
	jmp .Lnest__71
.Lnest_nest.split4_148:
	movq %r9, %r12
	jmp .Lnest__74
.globl main
.type main, @function
main:
.Lmain_entry_49:
	movq $0x0000000000000007, %rdi
	call nest
	movq %rax, %rsi
	movq %rsi, %rax
	ret

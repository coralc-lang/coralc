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
	subq $168, %rsp
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %r11
	movq %r11, -56(%rbp)
	addq $8, %rsp
.Lnest_entry_3:
	jmp .Lnest_preheader_56
.Lnest_done_13:
	imulq $0x000000000000000a, %rdi
	addq %rdi, %r8
	addq %r8, %r9
	movq %r9, %rax
	addq $168, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lnest_preheader_56:
	movq $0x0000000000000000, %r11
	movq %r11, -136(%rbp)
	movq $0x0000000000000000, %r11
	movq %r11, -72(%rbp)
	movq $0x0000000000000000, %r11
	movq %r11, -88(%rbp)
.Lnest__58:
	movq -136(%rbp), %r11
	leaq 1(%r11), %rbx
	cmpq $0x0000000000000003, -136(%rbp)
	jl .Lnest_nest.split4_144
	jmp .Lnest_nest.split0_136
.Lnest__59:
.Lnest__60:
	leaq 1(%r13), %r14
	cmpq $0x0000000000000007, -56(%rbp)
	je .Lnest_nest.split6_148
.Lnest__61:
	leaq 2(%r13), %r15
	movq %r15, %rsi
.Lnest__62:
.Lnest__63:
	leaq 1(%r12), %r14
	cmpq $0x0000000000000004, %r14
	jl .Lnest_nest.split5_146
	jmp .Lnest_nest.split7_150
.Lnest__64:
	leaq 1(%r9), %rsi
	cmpq $0x0000000000000003, %r9
	jl .Lnest_nest.split8_152
	jmp .Lnest_nest.split1_138
.Lnest__65:
.Lnest__66:
	leaq 1(%rbx), %r12
	cmpq $0x0000000000000007, -56(%rbp)
	je .Lnest_nest.split10_156
.Lnest__67:
	leaq 2(%rbx), %r10
	movq %r10, -168(%rbp)
	movq -168(%rbp), %r11
	movq %r11, -152(%rbp)
.Lnest__68:
.Lnest__69:
	leaq 1(%r8), %r12
	cmpq $0x0000000000000004, %r12
	jl .Lnest_nest.split9_154
	jmp .Lnest_nest.split11_158
.Lnest__70:
	leaq 1(%rdi), %rsi
	cmpq $0x0000000000000003, %rdi
	jl .Lnest_nest.split12_160
	jmp .Lnest_nest.split2_140
.Lnest__71:
.Lnest__72:
	leaq 1(%rbx), %r12
	cmpq $0x0000000000000007, -56(%rbp)
	je .Lnest_nest.split14_164
.Lnest__73:
	leaq 2(%rbx), %r10
	movq %r10, -200(%rbp)
	movq -200(%rbp), %r11
	movq %r11, -184(%rbp)
.Lnest__74:
.Lnest__75:
	leaq 1(%r8), %r12
	cmpq $0x0000000000000004, %r12
	jl .Lnest_nest.split13_162
	jmp .Lnest_nest.split3_142
.Lnest_nest.split0_136:
	movq -72(%rbp), %rdi
	movq -136(%rbp), %r8
	movq -88(%rbp), %r9
	jmp .Lnest_done_13
.Lnest_nest.split1_138:
	movq -104(%rbp), %rdi
	movq %r9, %r8
	movq -120(%rbp), %r9
	jmp .Lnest_done_13
.Lnest_nest.split2_140:
	movq %rdi, %r8
	movq %r13, %r9
	movq %r14, %rdi
	jmp .Lnest_done_13
.Lnest_nest.split3_142:
	movq %r8, %rdi
	movq %rsi, %r8
	movq %rbx, %r9
	jmp .Lnest_done_13
.Lnest_nest.split4_144:
	movq $0x0000000000000000, %r12
	movq $0x0000000000000000, %r13
	jmp .Lnest__59
.Lnest_nest.split5_146:
	movq %r14, %r12
	movq %rsi, %r13
	jmp .Lnest__59
.Lnest_nest.split6_148:
	movq %r14, %rsi
	jmp .Lnest__62
.Lnest_nest.split7_150:
	movq %rbx, %r9
	movq %r12, %r11
	movq %r11, -104(%rbp)
	movq %r13, %r11
	movq %r11, -120(%rbp)
	jmp .Lnest__64
.Lnest_nest.split8_152:
	movq $0x0000000000000000, %r8
	movq $0x0000000000000000, %rbx
	jmp .Lnest__65
.Lnest_nest.split9_154:
	movq %r12, %r8
	movq -152(%rbp), %rbx
	jmp .Lnest__65
.Lnest_nest.split10_156:
	movq %r12, %r11
	movq %r11, -152(%rbp)
	jmp .Lnest__68
.Lnest_nest.split11_158:
	movq %rsi, %rdi
	movq %r8, %r14
	movq %rbx, %r13
	jmp .Lnest__70
.Lnest_nest.split12_160:
	movq $0x0000000000000000, %r8
	movq $0x0000000000000000, %rbx
	jmp .Lnest__71
.Lnest_nest.split13_162:
	movq %r12, %r8
	movq -184(%rbp), %rbx
	jmp .Lnest__71
.Lnest_nest.split14_164:
	movq %r12, %r11
	movq %r11, -184(%rbp)
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

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
	subq $56, %rsp
.Lmain_entry_2:
	leaq -96(%rbp), %rsi
	jmp .Lmain_preheader_50
.Lmain_done_8:
	movq %rdi, %rax
	addq $56, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_preheader_50:
	movq $0x0000000000000000, %rdi
.Lmain__52:
	cmpq $0x0000000000000005, %rdi
	jge .Lmain_main.split5_167
.Lmain__53:
	leaq (%rsi, %rdi, 8), %r8
	leaq 1(%rdi), %rdi
	movq %rdi, (%r8)
	movq %rdi, %r8
.Lmain__54:
	cmpq $0x0000000000000005, %r8
	jge .Lmain_main.split6_169
.Lmain__55:
	leaq (%rsi, %r8, 8), %rdi
	leaq 1(%r8), %r8
	movq %r8, (%rdi)
	movq %r8, %rdi
.Lmain__56:
	cmpq $0x0000000000000005, %rdi
	jge .Lmain_main.split7_171
.Lmain__57:
	leaq (%rsi, %rdi, 8), %r8
	leaq 1(%rdi), %rdi
	movq %rdi, (%r8)
	movq %rdi, %r8
.Lmain__58:
	cmpq $0x0000000000000005, %r8
	jge .Lmain_main.split8_173
.Lmain__59:
	leaq (%rsi, %r8, 8), %rdi
	leaq 1(%r8), %r8
	movq %r8, (%rdi)
	movq %r8, %rdi
.Lmain__60:
	cmpq $0x0000000000000005, %rdi
	jge .Lmain_main.split9_175
.Lmain__61:
	leaq (%rsi, %rdi, 8), %r8
	leaq 1(%rdi), %rdi
	movq %rdi, (%r8)
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
.Lmain_preheader_97:
	movq %r8, %r9
	movq %rdi, %rbx
.Lmain__101:
	cmpq $0x0000000000000005, %r9
	jge .Lmain_main.split0_157
.Lmain__102:
	leaq (%rsi, %r9, 8), %rdi
	movq (%rdi), %r8
	addq %rbx, %r8
	leaq 1(%r9), %r9
	movq %r9, %rdi
	movq %r8, %r12
.Lmain__103:
	cmpq $0x0000000000000005, %rdi
	jge .Lmain_main.split1_159
.Lmain__104:
	leaq (%rsi, %rdi, 8), %r8
	movq (%r8), %r9
	addq %r12, %r9
	leaq 1(%rdi), %rdi
	movq %rdi, %r8
	movq %r9, %r13
.Lmain__105:
	cmpq $0x0000000000000005, %r8
	jge .Lmain_main.split2_161
.Lmain__106:
	leaq (%rsi, %r8, 8), %rdi
	movq (%rdi), %r9
	addq %r13, %r9
	leaq 1(%r8), %r8
	movq %r8, %rdi
	movq %r9, %r14
.Lmain__107:
	cmpq $0x0000000000000005, %rdi
	jge .Lmain_main.split3_163
.Lmain__108:
	leaq (%rsi, %rdi, 8), %r8
	movq (%r8), %r9
	addq %r14, %r9
	leaq 1(%rdi), %rdi
	movq %rdi, %r8
	movq %r9, %r15
.Lmain__109:
	cmpq $0x0000000000000005, %r8
	jge .Lmain_main.split4_165
.Lmain__110:
	leaq (%rsi, %r8, 8), %rdi
	movq (%rdi), %rsi
	addq %r15, %rsi
	leaq 1(%r8), %r8
	movq %rsi, %rdi
	jmp .Lmain_done_8
.Lmain_main.split0_157:
	movq %rbx, %rdi
	jmp .Lmain_done_8
.Lmain_main.split1_159:
	movq %r12, %rdi
	jmp .Lmain_done_8
.Lmain_main.split2_161:
	movq %r13, %rdi
	jmp .Lmain_done_8
.Lmain_main.split3_163:
	movq %r14, %rdi
	jmp .Lmain_done_8
.Lmain_main.split4_165:
	movq %r15, %rdi
	jmp .Lmain_done_8
.Lmain_main.split5_167:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
	jmp .Lmain_preheader_97
.Lmain_main.split6_169:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
	jmp .Lmain_preheader_97
.Lmain_main.split7_171:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
	jmp .Lmain_preheader_97
.Lmain_main.split8_173:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
	jmp .Lmain_preheader_97
.Lmain_main.split9_175:
	movq $0x0000000000000000, %rdi
	movq $0x0000000000000000, %r8
	jmp .Lmain_preheader_97

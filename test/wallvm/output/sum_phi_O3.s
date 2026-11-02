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
	jmp .Lmain_preheader_19
.Lmain_done_5:
	movq %rsi, %rax
	addq $72, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_preheader_19:
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %r11
	movq %r11, -56(%rbp)
.Lmain__21:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_main.split0_112
.Lmain__22:
	movq %rsi, %r8
	addq -56(%rbp), %r8
	leaq 1(%rsi), %rsi
	movq %rsi, %r9
	movq %r8, %r11
	movq %r11, -72(%rbp)
.Lmain__23:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split1_114
.Lmain__24:
	movq %r9, %rsi
	addq -72(%rbp), %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %r11
	movq %r11, -88(%rbp)
.Lmain__25:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split2_116
.Lmain__26:
	movq %r8, %rsi
	addq -88(%rbp), %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %r11
	movq %r11, -104(%rbp)
.Lmain__27:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split3_118
.Lmain__28:
	movq %r9, %rsi
	addq -104(%rbp), %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %r14
.Lmain__29:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split4_120
.Lmain__30:
	movq %r8, %rsi
	addq %r14, %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %r15
.Lmain__31:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split5_122
.Lmain__32:
	movq %r9, %rsi
	addq %r15, %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %rdi
.Lmain__33:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split6_124
.Lmain__34:
	movq %r8, %rsi
	addq %rdi, %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %rbx
.Lmain__35:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split7_126
.Lmain__36:
	movq %r9, %rsi
	addq %rbx, %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %r12
.Lmain__37:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split8_128
.Lmain__38:
	movq %r8, %rsi
	addq %r12, %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %r13
.Lmain__39:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split9_130
.Lmain__40:
	movq %r9, %rsi
	addq %r13, %rsi
	leaq 1(%r9), %r9
	jmp .Lmain_done_5
.Lmain_main.split0_112:
	movq -56(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split1_114:
	movq -72(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split2_116:
	movq -88(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split3_118:
	movq -104(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split4_120:
	movq %r14, %rsi
	jmp .Lmain_done_5
.Lmain_main.split5_122:
	movq %r15, %rsi
	jmp .Lmain_done_5
.Lmain_main.split6_124:
	movq %rdi, %rsi
	jmp .Lmain_done_5
.Lmain_main.split7_126:
	movq %rbx, %rsi
	jmp .Lmain_done_5
.Lmain_main.split8_128:
	movq %r12, %rsi
	jmp .Lmain_done_5
.Lmain_main.split9_130:
	movq %r13, %rsi
	jmp .Lmain_done_5

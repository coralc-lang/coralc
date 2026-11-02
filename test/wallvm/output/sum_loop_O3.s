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
	jmp .Lmain_preheader_30
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
.Lmain_preheader_30:
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %r11
	movq %r11, -56(%rbp)
.Lmain__32:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_main.split0_123
.Lmain__33:
	movq %rsi, %r8
	addq -56(%rbp), %r8
	leaq 1(%rsi), %rsi
	movq %rsi, %r9
	movq %r8, %r11
	movq %r11, -72(%rbp)
.Lmain__34:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split1_125
.Lmain__35:
	movq %r9, %rsi
	addq -72(%rbp), %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %r11
	movq %r11, -88(%rbp)
.Lmain__36:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split2_127
.Lmain__37:
	movq %r8, %rsi
	addq -88(%rbp), %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %r11
	movq %r11, -104(%rbp)
.Lmain__38:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split3_129
.Lmain__39:
	movq %r9, %rsi
	addq -104(%rbp), %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %r14
.Lmain__40:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split4_131
.Lmain__41:
	movq %r8, %rsi
	addq %r14, %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %r15
.Lmain__42:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split5_133
.Lmain__43:
	movq %r9, %rsi
	addq %r15, %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %rdi
.Lmain__44:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split6_135
.Lmain__45:
	movq %r8, %rsi
	addq %rdi, %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %rbx
.Lmain__46:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split7_137
.Lmain__47:
	movq %r9, %rsi
	addq %rbx, %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %r12
.Lmain__48:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split8_139
.Lmain__49:
	movq %r8, %rsi
	addq %r12, %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %r13
.Lmain__50:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split9_141
.Lmain__51:
	movq %r9, %rsi
	addq %r13, %rsi
	leaq 1(%r9), %r9
	jmp .Lmain_done_5
.Lmain_main.split0_123:
	movq -56(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split1_125:
	movq -72(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split2_127:
	movq -88(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split3_129:
	movq -104(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split4_131:
	movq %r14, %rsi
	jmp .Lmain_done_5
.Lmain_main.split5_133:
	movq %r15, %rsi
	jmp .Lmain_done_5
.Lmain_main.split6_135:
	movq %rdi, %rsi
	jmp .Lmain_done_5
.Lmain_main.split7_137:
	movq %rbx, %rsi
	jmp .Lmain_done_5
.Lmain_main.split8_139:
	movq %r12, %rsi
	jmp .Lmain_done_5
.Lmain_main.split9_141:
	movq %r13, %rsi
	jmp .Lmain_done_5

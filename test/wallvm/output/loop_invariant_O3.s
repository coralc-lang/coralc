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
	jmp .Lmain_preheader_33
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
.Lmain_preheader_33:
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000000, %r11
	movq %r11, -56(%rbp)
.Lmain__35:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_main.split0_126
.Lmain__36:
	movq -56(%rbp), %r11
	leaq 21(%r11), %r8
	leaq 1(%rsi), %rsi
	movq %rsi, %r9
	movq %r8, %r11
	movq %r11, -72(%rbp)
.Lmain__37:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split1_128
.Lmain__38:
	movq -72(%rbp), %r11
	leaq 21(%r11), %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %r11
	movq %r11, -88(%rbp)
.Lmain__39:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split2_130
.Lmain__40:
	movq -88(%rbp), %r11
	leaq 21(%r11), %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %r11
	movq %r11, -104(%rbp)
.Lmain__41:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split3_132
.Lmain__42:
	movq -104(%rbp), %r11
	leaq 21(%r11), %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %r14
.Lmain__43:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split4_134
.Lmain__44:
	leaq 21(%r14), %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %r15
.Lmain__45:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split5_136
.Lmain__46:
	leaq 21(%r15), %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %rdi
.Lmain__47:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split6_138
.Lmain__48:
	leaq 21(%rdi), %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %rbx
.Lmain__49:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split7_140
.Lmain__50:
	leaq 21(%rbx), %rsi
	leaq 1(%r9), %r9
	movq %r9, %r8
	movq %rsi, %r12
.Lmain__51:
	cmpq $0x000000000000000a, %r8
	jge .Lmain_main.split8_142
.Lmain__52:
	leaq 21(%r12), %rsi
	leaq 1(%r8), %r8
	movq %r8, %r9
	movq %rsi, %r13
.Lmain__53:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split9_144
.Lmain__54:
	leaq 21(%r13), %rsi
	leaq 1(%r9), %r9
	jmp .Lmain_done_5
.Lmain_main.split0_126:
	movq -56(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split1_128:
	movq -72(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split2_130:
	movq -88(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split3_132:
	movq -104(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split4_134:
	movq %r14, %rsi
	jmp .Lmain_done_5
.Lmain_main.split5_136:
	movq %r15, %rsi
	jmp .Lmain_done_5
.Lmain_main.split6_138:
	movq %rdi, %rsi
	jmp .Lmain_done_5
.Lmain_main.split7_140:
	movq %rbx, %rsi
	jmp .Lmain_done_5
.Lmain_main.split8_142:
	movq %r12, %rsi
	jmp .Lmain_done_5
.Lmain_main.split9_144:
	movq %r13, %rsi
	jmp .Lmain_done_5

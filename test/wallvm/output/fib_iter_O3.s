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
	subq $88, %rsp
.Lmain_entry_2:
	jmp .Lmain_preheader_34
.Lmain_done_5:
	movq %rsi, %rax
	addq $88, %rsp
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	leave
	ret
.Lmain_preheader_34:
	movq $0x0000000000000000, %rsi
	movq $0x0000000000000001, %rdi
	movq $0x0000000000000000, %r11
	movq %r11, -56(%rbp)
.Lmain__36:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_main.split0_137
.Lmain__37:
	addq -56(%rbp), %rdi
	leaq 1(%rsi), %rsi
	movq %rsi, %r9
	movq -56(%rbp), %rbx
	movq %rdi, %r11
	movq %r11, -72(%rbp)
.Lmain__38:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split1_139
.Lmain__39:
	addq -72(%rbp), %rbx
	leaq 1(%r9), %r9
	movq %r9, %rsi
	movq -72(%rbp), %rdi
	movq %rbx, %r11
	movq %r11, -88(%rbp)
.Lmain__40:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_main.split2_141
.Lmain__41:
	addq -88(%rbp), %rdi
	leaq 1(%rsi), %rsi
	movq %rsi, %r9
	movq -88(%rbp), %rbx
	movq %rdi, %r11
	movq %r11, -104(%rbp)
.Lmain__42:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split3_143
.Lmain__43:
	addq -104(%rbp), %rbx
	leaq 1(%r9), %r9
	movq %r9, %rsi
	movq -104(%rbp), %rdi
	movq %rbx, %r11
	movq %r11, -120(%rbp)
.Lmain__44:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_main.split4_145
.Lmain__45:
	addq -120(%rbp), %rdi
	leaq 1(%rsi), %rsi
	movq %rsi, %r9
	movq -120(%rbp), %rbx
	movq %rdi, %r8
.Lmain__46:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split5_147
.Lmain__47:
	addq %r8, %rbx
	leaq 1(%r9), %r9
	movq %r9, %rsi
	movq %r8, %rdi
	movq %rbx, %r12
.Lmain__48:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_main.split6_149
.Lmain__49:
	addq %r12, %rdi
	leaq 1(%rsi), %rsi
	movq %rsi, %r9
	movq %r12, %rbx
	movq %rdi, %r13
.Lmain__50:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split7_151
.Lmain__51:
	addq %r13, %rbx
	leaq 1(%r9), %r9
	movq %r9, %rsi
	movq %r13, %rdi
	movq %rbx, %r14
.Lmain__52:
	cmpq $0x000000000000000a, %rsi
	jge .Lmain_main.split8_153
.Lmain__53:
	addq %r14, %rdi
	leaq 1(%rsi), %rsi
	movq %rsi, %r9
	movq %r14, %rbx
	movq %rdi, %r15
.Lmain__54:
	cmpq $0x000000000000000a, %r9
	jge .Lmain_main.split9_155
.Lmain__55:
	addq %r15, %rbx
	leaq 1(%r9), %r9
	movq %rbx, %rsi
	jmp .Lmain_done_5
.Lmain_main.split0_137:
	movq -56(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split1_139:
	movq -72(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split2_141:
	movq -88(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split3_143:
	movq -104(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split4_145:
	movq -120(%rbp), %rsi
	jmp .Lmain_done_5
.Lmain_main.split5_147:
	movq %r8, %rsi
	jmp .Lmain_done_5
.Lmain_main.split6_149:
	movq %r12, %rsi
	jmp .Lmain_done_5
.Lmain_main.split7_151:
	movq %r13, %rsi
	jmp .Lmain_done_5
.Lmain_main.split8_153:
	movq %r14, %rsi
	jmp .Lmain_done_5
.Lmain_main.split9_155:
	movq %r15, %rsi
	jmp .Lmain_done_5

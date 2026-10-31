.section .text
.globl nest
.type nest, @function
nest:
	subq $8, %rsp
	movq %rdi, 0(%rsp)
	movq 0(%rsp), %rsi
	addq $8, %rsp
.Lnest_entry_3:
	jmp .Lnest_preheader_56
.Lnest_done_13:
	movq $0x000000000000000a, %rsi
	imulq %r8, %rsi
	addq %rdi, %rsi
	addq %r9, %rsi
	movq %rsi, %rax
	ret
.Lnest_preheader_56:
.Lnest__58:
.Lnest__59:
.Lnest__60:
.Lnest__61:
.Lnest__62:
.Lnest__63:
.Lnest__64:
.Lnest__65:
.Lnest__66:
.Lnest__67:
.Lnest__68:
.Lnest__69:
.Lnest__70:
.Lnest__71:
.Lnest__72:
.Lnest__73:
.Lnest__74:
.Lnest__75:
.globl main
.type main, @function
main:
.Lmain_entry_49:
	jmp .Lmain_inl53_4_80

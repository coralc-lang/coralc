	.att_syntax
	.file "muvm"

	.text
	.globl	main                            # -- Begin function main
	.p2align	4
	.type	main,@function
main:                                   # @main
	.cfi_startproc
.LBB3_4:
	leaq g(%rip), %r11
	movq $9, (%r11)
	movl $9, %eax
	.cfi_def_cfa %rsp, 8
	ret
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function

	.data
	.p2align	3, 0x0
	.type	g,@object
	.globl	g
g:
	.quad 3
	.size	g, .-g


	.section .note.GNU-stack,"",@progbits


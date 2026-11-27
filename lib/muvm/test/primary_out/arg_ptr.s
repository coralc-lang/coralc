	.att_syntax
	.file "muvm"

	.text
	.globl	write                           # -- Begin function write
	.p2align	4
	.type	write,@function
write:                                  # @write
	.cfi_startproc
.LBB1_4:
	movq %rsi, (%rdi)
	.cfi_def_cfa %rsp, 8
	ret
.Lfunc_end1:
	.size	write, .Lfunc_end1-write
	.cfi_endproc
                                        # -- End function

	.text
	.globl	main                            # -- Begin function main
	.p2align	4
	.type	main,@function
main:                                   # @main
	.cfi_startproc
.LBB7_8:
	movl $5, %eax
	.cfi_def_cfa %rsp, 8
	ret
.Lfunc_end7:
	.size	main, .Lfunc_end7-main
	.cfi_endproc
                                        # -- End function


	.section .note.GNU-stack,"",@progbits


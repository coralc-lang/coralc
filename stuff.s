	.att_syntax
	.file	"stuff.c"
	.text
	.globl	main                            # -- Begin function main
	.prefalign	4, .Lfunc_end0, nop
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	$0, -4(%rbp)
	movl	gx(%rip), %eax
	movl	%eax, -8(%rbp)
	movl	gy(%rip), %eax
	movl	%eax, -12(%rbp)
	movl	-8(%rbp), %eax
	cmpl	-12(%rbp), %eax
	sete	%al
	andb	$1, %al
	movb	%al, -13(%rbp)
	cmpb	$0, -13(%rbp)
	je	.LBB0_4
# %bb.1:
	movl	-8(%rbp), %eax
	cmpl	-12(%rbp), %eax
	sete	%al
	andb	$1, %al
	movb	%al, -14(%rbp)
	cmpb	$0, -14(%rbp)
	je	.LBB0_3
# %bb.2:
	movl	$1, -4(%rbp)
	jmp	.LBB0_5
.LBB0_3:
	jmp	.LBB0_5
.LBB0_4:
	movl	$2, -4(%rbp)
.LBB0_5:
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	gx,@object                      # @gx
	.data
	.globl	gx
	.p2align	2, 0x0
gx:
	.long	4                               # 0x4
	.size	gx, 4

	.type	gy,@object                      # @gy
	.globl	gy
	.p2align	2, 0x0
gy:
	.long	4                               # 0x4
	.size	gy, 4

	.ident	"clang version 23.1.3"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym gx
	.addrsig_sym gy

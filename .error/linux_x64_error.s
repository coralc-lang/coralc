	.att_syntax
	.file	"error.c"
	.text
	.globl	crl__lib__std__x86_64__linux__error___wr # -- Begin function crl__lib__std__x86_64__linux__error___wr
	.prefalign	4, .Lfunc_end0, nop
	.type	crl__lib__std__x86_64__linux__error___wr,@function
crl__lib__std__x86_64__linux__error___wr: # @crl__lib__std__x86_64__linux__error___wr
	.cfi_startproc
# %bb.0:
	jmp	write@PLT                       # TAILCALL
.Lfunc_end0:
	.size	crl__lib__std__x86_64__linux__error___wr, .Lfunc_end0-crl__lib__std__x86_64__linux__error___wr
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error___wrHex # -- Begin function crl__lib__std__x86_64__linux__error___wrHex
	.prefalign	4, .Lfunc_end1, nop
	.type	crl__lib__std__x86_64__linux__error___wrHex,@function
crl__lib__std__x86_64__linux__error___wrHex: # @crl__lib__std__x86_64__linux__error___wrHex
	.cfi_startproc
# %bb.0:
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	subq	$24, %rsp
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -24
	.cfi_offset %r14, -16
	movq	%rsi, %r14
	movl	%edi, %ebx
	movq	%fs:40, %rax
	movq	%rax, 16(%rsp)
	leaq	.L.str(%rip), %rsi
	movl	$2, %edx
	callq	write@PLT
	movq	%r14, %rax
	shrq	$60, %rax
	je	.LBB1_3
# %bb.1:
	movq	%r14, %rcx
	shrq	$61, %rcx
	leal	48(%rax), %edx
	addb	$87, %al
	cmpl	$5, %ecx
	movzbl	%dl, %ecx
	movzbl	%al, %eax
	cmovbl	%ecx, %eax
	movb	%al, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movq	%r14, %rax
	shrq	$56, %rax
	andl	$15, %eax
	jmp	.LBB1_2
.LBB1_3:
	movq	%r14, %rax
	shrq	$56, %rax
	je	.LBB1_4
.LBB1_2:
	leal	87(%rax), %ecx
	movl	%eax, %edx
	orb	$48, %dl
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movb	$1, %cl
.LBB1_5:
	movq	%r14, %rax
	shrq	$52, %rax
	andl	$15, %eax
	setne	%dl
	orb	%cl, %dl
	cmpb	$1, %dl
	jne	.LBB1_8
# %bb.6:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movq	%r14, %rax
	shrq	$48, %rax
	andl	$15, %eax
	jmp	.LBB1_7
.LBB1_8:
	movq	%r14, %rax
	shrq	$48, %rax
	andl	$15, %eax
	je	.LBB1_9
.LBB1_7:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movb	$1, %cl
.LBB1_10:
	movq	%r14, %rax
	shrq	$44, %rax
	andl	$15, %eax
	setne	%dl
	orb	%cl, %dl
	cmpb	$1, %dl
	jne	.LBB1_13
# %bb.11:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movq	%r14, %rax
	shrq	$40, %rax
	andl	$15, %eax
	jmp	.LBB1_12
.LBB1_13:
	movq	%r14, %rax
	shrq	$40, %rax
	andl	$15, %eax
	je	.LBB1_14
.LBB1_12:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movb	$1, %cl
.LBB1_15:
	movq	%r14, %rax
	shrq	$36, %rax
	andl	$15, %eax
	setne	%dl
	orb	%cl, %dl
	cmpb	$1, %dl
	jne	.LBB1_18
# %bb.16:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movq	%r14, %rax
	shrq	$32, %rax
	andl	$15, %eax
	jmp	.LBB1_17
.LBB1_18:
	movq	%r14, %rax
	shrq	$32, %rax
	andl	$15, %eax
	je	.LBB1_19
.LBB1_17:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movb	$1, %cl
.LBB1_20:
	movl	%r14d, %eax
	shrl	$28, %eax
	sete	%dl
	notb	%cl
	testb	%dl, %cl
	jne	.LBB1_22
# %bb.21:
	leal	87(%rax), %ecx
	orb	$48, %al
	cmpl	$-1610612736, %r14d             # imm = 0xA0000000
	movzbl	%al, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movl	%r14d, %eax
	shrl	$24, %eax
	andl	$15, %eax
	jmp	.LBB1_23
.LBB1_22:
	movl	%r14d, %eax
	shrl	$24, %eax
	andl	$15, %eax
	je	.LBB1_24
.LBB1_23:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movl	%r14d, %eax
	shrl	$20, %eax
	andl	$15, %eax
.LBB1_25:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movl	%r14d, %eax
	shrl	$16, %eax
	andl	$15, %eax
.LBB1_27:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movl	%r14d, %eax
	shrl	$12, %eax
	andl	$15, %eax
.LBB1_29:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movl	%r14d, %eax
	shrl	$8, %eax
	andl	$15, %eax
.LBB1_31:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movl	%r14d, %eax
	shrl	$4, %eax
	andl	$15, %eax
.LBB1_33:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
.LBB1_34:
	andl	$15, %r14d
	leal	87(%r14), %eax
	leal	48(%r14), %ecx
	cmpl	$10, %r14d
	movzbl	%cl, %ecx
	movzbl	%al, %eax
	cmovbl	%ecx, %eax
	movb	%al, 15(%rsp)
	leaq	15(%rsp), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movq	%fs:40, %rax
	cmpq	16(%rsp), %rax
	jne	.LBB1_36
# %bb.35:
	addq	$24, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.LBB1_9:
	.cfi_def_cfa_offset 48
	xorl	%ecx, %ecx
	jmp	.LBB1_10
.LBB1_14:
	xorl	%ecx, %ecx
	jmp	.LBB1_15
.LBB1_19:
	xorl	%ecx, %ecx
	jmp	.LBB1_20
.LBB1_24:
	movl	%r14d, %eax
	shrl	$20, %eax
	andl	$15, %eax
	jne	.LBB1_25
# %bb.26:
	movl	%r14d, %eax
	shrl	$16, %eax
	andl	$15, %eax
	jne	.LBB1_27
# %bb.28:
	movl	%r14d, %eax
	shrl	$12, %eax
	andl	$15, %eax
	jne	.LBB1_29
# %bb.30:
	movl	%r14d, %eax
	shrl	$8, %eax
	andl	$15, %eax
	jne	.LBB1_31
# %bb.32:
	movl	%r14d, %eax
	shrl	$4, %eax
	andl	$15, %eax
	jne	.LBB1_33
	jmp	.LBB1_34
.LBB1_4:
	xorl	%ecx, %ecx
	jmp	.LBB1_5
.LBB1_36:
	callq	__stack_chk_fail@PLT
.Lfunc_end1:
	.size	crl__lib__std__x86_64__linux__error___wrHex, .Lfunc_end1-crl__lib__std__x86_64__linux__error___wrHex
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error___wrDec # -- Begin function crl__lib__std__x86_64__linux__error___wrDec
	.prefalign	4, .Lfunc_end2, nop
	.type	crl__lib__std__x86_64__linux__error___wrDec,@function
crl__lib__std__x86_64__linux__error___wrDec: # @crl__lib__std__x86_64__linux__error___wrDec
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	subq	$56, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movl	%edi, %ebx
	movq	%fs:40, %rax
	movq	%rax, 48(%rsp)
	testq	%rsi, %rsi
	je	.LBB2_1
# %bb.3:
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 16(%rsp)
	movl	$0, 32(%rsp)
	movl	$1, %ebp
	leaq	15(%rsp), %r15
	movabsq	$-3689348814741910323, %rcx     # imm = 0xCCCCCCCCCCCCCCCD
	.p2align	4
.LBB2_4:                                # =>This Inner Loop Header: Depth=1
	movq	%rsi, %rax
	mulq	%rcx
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%esi, %edi
	subl	%eax, %edi
	orb	$48, %dil
	movb	%dil, 1(%r15)
	incq	%r15
	incl	%ebp
	cmpq	$9, %rsi
	movq	%rdx, %rsi
	ja	.LBB2_4
# %bb.5:
	leaq	15(%rsp), %r14
	.p2align	4
.LBB2_6:                                # =>This Inner Loop Header: Depth=1
	movzbl	(%r15), %eax
	movb	%al, 15(%rsp)
	movl	$1, %edx
	movl	%ebx, %edi
	movq	%r14, %rsi
	callq	write@PLT
	decl	%ebp
	decq	%r15
	cmpl	$1, %ebp
	jg	.LBB2_6
# %bb.7:
	movq	%fs:40, %rax
	cmpq	48(%rsp), %rax
	jne	.LBB2_9
# %bb.8:
	addq	$56, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB2_1:
	.cfi_def_cfa_offset 96
	movq	%fs:40, %rax
	cmpq	48(%rsp), %rax
	jne	.LBB2_9
# %bb.2:
	leaq	.L.str.1(%rip), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	addq	$56, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	jmp	write@PLT                       # TAILCALL
.LBB2_9:
	.cfi_def_cfa_offset 96
	callq	__stack_chk_fail@PLT
.Lfunc_end2:
	.size	crl__lib__std__x86_64__linux__error___wrDec, .Lfunc_end2-crl__lib__std__x86_64__linux__error___wrDec
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error___wrSigName # -- Begin function crl__lib__std__x86_64__linux__error___wrSigName
	.prefalign	4, .Lfunc_end3, nop
	.type	crl__lib__std__x86_64__linux__error___wrSigName,@function
crl__lib__std__x86_64__linux__error___wrSigName: # @crl__lib__std__x86_64__linux__error___wrSigName
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	subq	$56, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%fs:40, %rax
	movq	%rax, 48(%rsp)
	cmpl	crl__lib__std__x86_64__linux__error__SIGSEGV_(%rip), %esi
	jne	.LBB3_5
# %bb.1:
	movq	%fs:40, %rax
	cmpq	48(%rsp), %rax
	jne	.LBB3_26
# %bb.2:
	leaq	.L.str.2(%rip), %rsi
.LBB3_3:
	movl	$28, %edx
	jmp	.LBB3_4
.LBB3_5:
	cmpl	crl__lib__std__x86_64__linux__error__SIGBUS_(%rip), %esi
	jne	.LBB3_8
# %bb.6:
	movq	%fs:40, %rax
	cmpq	48(%rsp), %rax
	jne	.LBB3_26
# %bb.7:
	leaq	.L.str.3(%rip), %rsi
	movl	$18, %edx
.LBB3_4:
	addq	$56, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	jmp	write@PLT                       # TAILCALL
.LBB3_8:
	.cfi_def_cfa_offset 96
	cmpl	crl__lib__std__x86_64__linux__error__SIGILL_(%rip), %esi
	jne	.LBB3_11
# %bb.9:
	movq	%fs:40, %rax
	cmpq	48(%rsp), %rax
	jne	.LBB3_26
# %bb.10:
	leaq	.L.str.4(%rip), %rsi
	jmp	.LBB3_3
.LBB3_11:
	cmpl	crl__lib__std__x86_64__linux__error__SIGFPE_(%rip), %esi
	jne	.LBB3_14
# %bb.12:
	movq	%fs:40, %rax
	cmpq	48(%rsp), %rax
	jne	.LBB3_26
# %bb.13:
	leaq	.L.str.5(%rip), %rsi
	movl	$25, %edx
	jmp	.LBB3_4
.LBB3_14:
	cmpl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %esi
	jne	.LBB3_17
# %bb.15:
	movq	%fs:40, %rax
	cmpq	48(%rsp), %rax
	jne	.LBB3_26
# %bb.16:
	leaq	.L.str.6(%rip), %rsi
	movl	$15, %edx
	jmp	.LBB3_4
.LBB3_17:
	leaq	.L.str.7(%rip), %rax
	movl	$7, %edx
	movl	%edi, %ebx
	movl	%esi, %ebp
	movq	%rax, %rsi
	callq	write@PLT
	testl	%ebp, %ebp
	je	.LBB3_18
# %bb.20:
	movslq	%ebp, %rcx
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 16(%rsp)
	movl	$0, 32(%rsp)
	movl	$1, %ebp
	leaq	15(%rsp), %r15
	movabsq	$-3689348814741910323, %rsi     # imm = 0xCCCCCCCCCCCCCCCD
	.p2align	4
.LBB3_21:                               # =>This Inner Loop Header: Depth=1
	movq	%rcx, %rax
	mulq	%rsi
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%ecx, %edi
	subl	%eax, %edi
	orb	$48, %dil
	movb	%dil, 1(%r15)
	incq	%r15
	incl	%ebp
	cmpq	$9, %rcx
	movq	%rdx, %rcx
	ja	.LBB3_21
# %bb.22:
	leaq	15(%rsp), %r14
	.p2align	4
.LBB3_23:                               # =>This Inner Loop Header: Depth=1
	movzbl	(%r15), %eax
	movb	%al, 15(%rsp)
	movl	$1, %edx
	movl	%ebx, %edi
	movq	%r14, %rsi
	callq	write@PLT
	decl	%ebp
	decq	%r15
	cmpl	$1, %ebp
	jg	.LBB3_23
# %bb.24:
	movq	%fs:40, %rax
	cmpq	48(%rsp), %rax
	jne	.LBB3_26
# %bb.25:
	addq	$56, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB3_18:
	.cfi_def_cfa_offset 96
	movq	%fs:40, %rax
	cmpq	48(%rsp), %rax
	jne	.LBB3_26
# %bb.19:
	leaq	.L.str.1(%rip), %rsi
	movl	$1, %edx
	movl	%ebx, %edi
	jmp	.LBB3_4
.LBB3_26:
	callq	__stack_chk_fail@PLT
.Lfunc_end3:
	.size	crl__lib__std__x86_64__linux__error___wrSigName, .Lfunc_end3-crl__lib__std__x86_64__linux__error___wrSigName
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____backtraceTo # -- Begin function crl__lib__std__x86_64__linux__error____backtraceTo
	.prefalign	4, .Lfunc_end4, nop
	.type	crl__lib__std__x86_64__linux__error____backtraceTo,@function
crl__lib__std__x86_64__linux__error____backtraceTo: # @crl__lib__std__x86_64__linux__error____backtraceTo
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	subq	$264, %rsp                      # imm = 0x108
	.cfi_def_cfa_offset 288
	.cfi_offset %rbx, -24
	.cfi_offset %rbp, -16
	movl	%edi, %ebx
	movq	%fs:40, %rax
	movq	%rax, 256(%rsp)
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 240(%rsp)
	movaps	%xmm0, 224(%rsp)
	movaps	%xmm0, 208(%rsp)
	movaps	%xmm0, 192(%rsp)
	movaps	%xmm0, 176(%rsp)
	movaps	%xmm0, 160(%rsp)
	movaps	%xmm0, 144(%rsp)
	movaps	%xmm0, 128(%rsp)
	movaps	%xmm0, 112(%rsp)
	movaps	%xmm0, 96(%rsp)
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm0, 64(%rsp)
	movaps	%xmm0, 48(%rsp)
	movaps	%xmm0, 32(%rsp)
	movaps	%xmm0, 16(%rsp)
	movaps	%xmm0, (%rsp)
	movq	%rsp, %rdi
	movl	$32, %esi
	callq	backtrace@PLT
	testl	%eax, %eax
	jle	.LBB4_1
# %bb.2:
	movl	%eax, %ebp
	leaq	.L.str.9(%rip), %rsi
	movl	$9, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movq	%rsp, %rdi
	movl	%ebp, %esi
	movl	%ebx, %edx
	callq	backtrace_symbols_fd@PLT
	movq	%fs:40, %rax
	cmpq	256(%rsp), %rax
	jne	.LBB4_5
.LBB4_4:
	addq	$264, %rsp                      # imm = 0x108
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB4_1:
	.cfi_def_cfa_offset 288
	leaq	.L.str.8(%rip), %rsi
	movl	$14, %edx
	movl	%ebx, %edi
	callq	write@PLT
	movq	%fs:40, %rax
	cmpq	256(%rsp), %rax
	je	.LBB4_4
.LBB4_5:
	callq	__stack_chk_fail@PLT
.Lfunc_end4:
	.size	crl__lib__std__x86_64__linux__error____backtraceTo, .Lfunc_end4-crl__lib__std__x86_64__linux__error____backtraceTo
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____abortNow # -- Begin function crl__lib__std__x86_64__linux__error____abortNow
	.prefalign	4, .Lfunc_end5, nop
	.type	crl__lib__std__x86_64__linux__error____abortNow,@function
crl__lib__std__x86_64__linux__error____abortNow: # @crl__lib__std__x86_64__linux__error____abortNow
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	callq	raise@PLT
	movl	$134, %edi
	callq	_exit@PLT
.Lfunc_end5:
	.size	crl__lib__std__x86_64__linux__error____abortNow, .Lfunc_end5-crl__lib__std__x86_64__linux__error____abortNow
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____oomFatal # -- Begin function crl__lib__std__x86_64__linux__error____oomFatal
	.prefalign	4, .Lfunc_end6, nop
	.type	crl__lib__std__x86_64__linux__error____oomFatal,@function
crl__lib__std__x86_64__linux__error____oomFatal: # @crl__lib__std__x86_64__linux__error____oomFatal
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.10(%rip), %rsi
	movl	$21, %edx
	movl	$2, %edi
	callq	crl__lib__std__x86_64__linux__error___wr
	leaq	.L.str.11(%rip), %rsi
	movl	$69, %edx
	movl	$2, %edi
	callq	crl__lib__std__x86_64__linux__error___wr
	movl	$2, %edi
	callq	_exit@PLT
.Lfunc_end6:
	.size	crl__lib__std__x86_64__linux__error____oomFatal, .Lfunc_end6-crl__lib__std__x86_64__linux__error____oomFatal
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____report # -- Begin function crl__lib__std__x86_64__linux__error____report
	.prefalign	4, .Lfunc_end7, nop
	.type	crl__lib__std__x86_64__linux__error____report,@function
crl__lib__std__x86_64__linux__error____report: # @crl__lib__std__x86_64__linux__error____report
	.cfi_startproc
# %bb.0:
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	subq	$264, %rsp                      # imm = 0x108
	.cfi_def_cfa_offset 288
	.cfi_offset %rbx, -24
	.cfi_offset %r14, -16
	movq	%rsi, %rbx
	movq	%rdi, %r14
	movq	%fs:40, %rax
	movq	%rax, 256(%rsp)
	leaq	.L.str.12(%rip), %rsi
	movl	$15, %edx
	movl	$2, %edi
	callq	write@PLT
	movl	$2, %edi
	movq	%r14, %rsi
	movq	%rbx, %rdx
	callq	write@PLT
	leaq	.L.str.13(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 240(%rsp)
	movaps	%xmm0, 224(%rsp)
	movaps	%xmm0, 208(%rsp)
	movaps	%xmm0, 192(%rsp)
	movaps	%xmm0, 176(%rsp)
	movaps	%xmm0, 160(%rsp)
	movaps	%xmm0, 144(%rsp)
	movaps	%xmm0, 128(%rsp)
	movaps	%xmm0, 112(%rsp)
	movaps	%xmm0, 96(%rsp)
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm0, 64(%rsp)
	movaps	%xmm0, 48(%rsp)
	movaps	%xmm0, 32(%rsp)
	movaps	%xmm0, 16(%rsp)
	movaps	%xmm0, (%rsp)
	movq	%rsp, %rdi
	movl	$32, %esi
	callq	backtrace@PLT
	testl	%eax, %eax
	jle	.LBB7_1
# %bb.2:
	movl	%eax, %ebx
	leaq	.L.str.9(%rip), %rsi
	movl	$9, %edx
	movl	$2, %edi
	callq	write@PLT
	movq	%rsp, %rdi
	movl	%ebx, %esi
	movl	$2, %edx
	callq	backtrace_symbols_fd@PLT
	jmp	.LBB7_3
.LBB7_1:
	leaq	.L.str.8(%rip), %rsi
	movl	$14, %edx
	movl	$2, %edi
	callq	write@PLT
.LBB7_3:
	leaq	.L.str.13(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	movq	%fs:40, %rax
	cmpq	256(%rsp), %rax
	jne	.LBB7_5
# %bb.4:
	addq	$264, %rsp                      # imm = 0x108
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.LBB7_5:
	.cfi_def_cfa_offset 288
	callq	__stack_chk_fail@PLT
.Lfunc_end7:
	.size	crl__lib__std__x86_64__linux__error____report, .Lfunc_end7-crl__lib__std__x86_64__linux__error____report
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____reportHex # -- Begin function crl__lib__std__x86_64__linux__error____reportHex
	.prefalign	4, .Lfunc_end8, nop
	.type	crl__lib__std__x86_64__linux__error____reportHex,@function
crl__lib__std__x86_64__linux__error____reportHex: # @crl__lib__std__x86_64__linux__error____reportHex
	.cfi_startproc
# %bb.0:
	pushq	%r15
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	subq	$272, %rsp                      # imm = 0x110
	.cfi_def_cfa_offset 320
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %r15, -16
	movq	%r8, %rbx
	movq	%rcx, %r14
	movq	%rdx, %r15
	movq	%rsi, %r12
	movq	%rdi, %r13
	movq	%fs:40, %rax
	movq	%rax, 264(%rsp)
	leaq	.L.str.12(%rip), %rsi
	movl	$15, %edx
	movl	$2, %edi
	callq	write@PLT
	movl	$2, %edi
	movq	%r13, %rsi
	movq	%r12, %rdx
	callq	write@PLT
	leaq	.L.str.14(%rip), %rsi
	movl	$2, %edx
	movl	$2, %edi
	callq	write@PLT
	movl	$2, %edi
	movq	%r15, %rsi
	movq	%r14, %rdx
	callq	write@PLT
	leaq	.L.str.15(%rip), %rsi
	movl	$3, %edx
	movl	$2, %edi
	callq	write@PLT
	movl	$2, %edi
	movq	%rbx, %rsi
	callq	crl__lib__std__x86_64__linux__error___wrHex
	leaq	.L.str.16(%rip), %rsi
	movl	$2, %edx
	movl	$2, %edi
	callq	write@PLT
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 240(%rsp)
	movaps	%xmm0, 224(%rsp)
	movaps	%xmm0, 208(%rsp)
	movaps	%xmm0, 192(%rsp)
	movaps	%xmm0, 176(%rsp)
	movaps	%xmm0, 160(%rsp)
	movaps	%xmm0, 144(%rsp)
	movaps	%xmm0, 128(%rsp)
	movaps	%xmm0, 112(%rsp)
	movaps	%xmm0, 96(%rsp)
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm0, 64(%rsp)
	movaps	%xmm0, 48(%rsp)
	movaps	%xmm0, 32(%rsp)
	movaps	%xmm0, 16(%rsp)
	movaps	%xmm0, (%rsp)
	movq	%rsp, %rdi
	movl	$32, %esi
	callq	backtrace@PLT
	testl	%eax, %eax
	jle	.LBB8_1
# %bb.2:
	movl	%eax, %ebx
	leaq	.L.str.9(%rip), %rsi
	movl	$9, %edx
	movl	$2, %edi
	callq	write@PLT
	movq	%rsp, %rdi
	movl	%ebx, %esi
	movl	$2, %edx
	callq	backtrace_symbols_fd@PLT
	jmp	.LBB8_3
.LBB8_1:
	leaq	.L.str.8(%rip), %rsi
	movl	$14, %edx
	movl	$2, %edi
	callq	write@PLT
.LBB8_3:
	leaq	.L.str.13(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	movq	%fs:40, %rax
	cmpq	264(%rsp), %rax
	jne	.LBB8_5
# %bb.4:
	addq	$272, %rsp                      # imm = 0x110
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	retq
.LBB8_5:
	.cfi_def_cfa_offset 320
	callq	__stack_chk_fail@PLT
.Lfunc_end8:
	.size	crl__lib__std__x86_64__linux__error____reportHex, .Lfunc_end8-crl__lib__std__x86_64__linux__error____reportHex
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____panic # -- Begin function crl__lib__std__x86_64__linux__error____panic
	.prefalign	4, .Lfunc_end9, nop
	.type	crl__lib__std__x86_64__linux__error____panic,@function
crl__lib__std__x86_64__linux__error____panic: # @crl__lib__std__x86_64__linux__error____panic
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	callq	crl__lib__std__x86_64__linux__error____report
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	callq	raise@PLT
	movl	$134, %edi
	callq	_exit@PLT
.Lfunc_end9:
	.size	crl__lib__std__x86_64__linux__error____panic, .Lfunc_end9-crl__lib__std__x86_64__linux__error____panic
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____unreachable # -- Begin function crl__lib__std__x86_64__linux__error____unreachable
	.prefalign	4, .Lfunc_end10, nop
	.type	crl__lib__std__x86_64__linux__error____unreachable,@function
crl__lib__std__x86_64__linux__error____unreachable: # @crl__lib__std__x86_64__linux__error____unreachable
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	callq	crl__lib__std__x86_64__linux__error____report
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	callq	raise@PLT
	movl	$134, %edi
	callq	_exit@PLT
.Lfunc_end10:
	.size	crl__lib__std__x86_64__linux__error____unreachable, .Lfunc_end10-crl__lib__std__x86_64__linux__error____unreachable
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assert # -- Begin function crl__lib__std__x86_64__linux__error____assert
	.prefalign	4, .Lfunc_end11, nop
	.type	crl__lib__std__x86_64__linux__error____assert,@function
crl__lib__std__x86_64__linux__error____assert: # @crl__lib__std__x86_64__linux__error____assert
	.cfi_startproc
# %bb.0:
	testl	%edi, %edi
	je	.LBB11_2
# %bb.1:
	retq
.LBB11_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	leaq	.L.str.17(%rip), %rdi
	movl	$16, %esi
	callq	crl__lib__std__x86_64__linux__error____report
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	callq	raise@PLT
	movl	$134, %edi
	callq	_exit@PLT
.Lfunc_end11:
	.size	crl__lib__std__x86_64__linux__error____assert, .Lfunc_end11-crl__lib__std__x86_64__linux__error____assert
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertOut # -- Begin function crl__lib__std__x86_64__linux__error____assertOut
	.prefalign	4, .Lfunc_end12, nop
	.type	crl__lib__std__x86_64__linux__error____assertOut,@function
crl__lib__std__x86_64__linux__error____assertOut: # @crl__lib__std__x86_64__linux__error____assertOut
	.cfi_startproc
# %bb.0:
	testl	%edi, %edi
	je	.LBB12_2
# %bb.1:
	retq
.LBB12_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rsi, %rdi
	movq	%rdx, %rsi
	callq	crl__lib__std__x86_64__linux__error____report
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	callq	raise@PLT
	movl	$134, %edi
	callq	_exit@PLT
.Lfunc_end12:
	.size	crl__lib__std__x86_64__linux__error____assertOut, .Lfunc_end12-crl__lib__std__x86_64__linux__error____assertOut
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error___failCmp # -- Begin function crl__lib__std__x86_64__linux__error___failCmp
	.prefalign	4, .Lfunc_end13, nop
	.type	crl__lib__std__x86_64__linux__error___failCmp,@function
crl__lib__std__x86_64__linux__error___failCmp: # @crl__lib__std__x86_64__linux__error___failCmp
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$296, %rsp                      # imm = 0x128
	.cfi_def_cfa_offset 352
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%r9, %r12
	movq	%r8, 24(%rsp)                   # 8-byte Spill
	movq	%rcx, %r15
	movq	%rdx, %rbp
	movq	%rsi, %r14
	movq	%rdi, %r13
	leaq	.L.str.18(%rip), %rsi
	movl	$22, %edx
	movl	$2, %edi
	callq	write@PLT
	movl	$2, %edi
	movq	%r13, %rsi
	movq	%r14, %rdx
	callq	write@PLT
	leaq	.L.str.19(%rip), %rsi
	movl	$9, %edx
	movl	$2, %edi
	callq	write@PLT
	movabsq	$-3689348814741910323, %rbx     # imm = 0xCCCCCCCCCCCCCCCD
	testq	%rbp, %rbp
	jne	.LBB13_2
# %bb.1:
	leaq	.L.str.1(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	jmp	.LBB13_7
.LBB13_2:
	movq	%r14, 8(%rsp)                   # 8-byte Spill
	movq	%r12, 16(%rsp)                  # 8-byte Spill
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 32(%rsp)
	movl	$0, 48(%rsp)
	movl	$1, %r14d
	leaq	31(%rsp), %r12
	.p2align	4
.LBB13_3:                               # =>This Inner Loop Header: Depth=1
	movq	%rbp, %rax
	mulq	%rbx
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%ebp, %ecx
	subl	%eax, %ecx
	orb	$48, %cl
	movb	%cl, 1(%r12)
	incq	%r12
	incl	%r14d
	cmpq	$9, %rbp
	movq	%rdx, %rbp
	ja	.LBB13_3
# %bb.4:
	leaq	7(%rsp), %rbp
	.p2align	4
.LBB13_5:                               # =>This Inner Loop Header: Depth=1
	movzbl	(%r12), %eax
	movb	%al, 7(%rsp)
	movl	$1, %edx
	movl	$2, %edi
	movq	%rbp, %rsi
	callq	write@PLT
	decl	%r14d
	decq	%r12
	cmpl	$1, %r14d
	jg	.LBB13_5
# %bb.6:
	movq	16(%rsp), %r12                  # 8-byte Reload
	movq	8(%rsp), %r14                   # 8-byte Reload
.LBB13_7:
	leaq	.L.str.20(%rip), %rbp
	movl	$1, %edx
	movl	$2, %edi
	movq	%rbp, %rsi
	callq	write@PLT
	movl	$2, %edi
	movq	%r13, %rsi
	movq	%r14, %rdx
	callq	write@PLT
	movl	$1, %edx
	movl	$2, %edi
	movq	%rbp, %rsi
	callq	write@PLT
	testq	%r15, %r15
	jne	.LBB13_9
# %bb.8:
	leaq	.L.str.1(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	jmp	.LBB13_13
.LBB13_9:
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 32(%rsp)
	movl	$0, 48(%rsp)
	movl	$1, %ebp
	leaq	31(%rsp), %r14
	.p2align	4
.LBB13_10:                              # =>This Inner Loop Header: Depth=1
	movq	%r15, %rax
	mulq	%rbx
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%r15d, %ecx
	subl	%eax, %ecx
	orb	$48, %cl
	movb	%cl, 1(%r14)
	incq	%r14
	incl	%ebp
	cmpq	$9, %r15
	movq	%rdx, %r15
	ja	.LBB13_10
# %bb.11:
	leaq	7(%rsp), %r15
	.p2align	4
.LBB13_12:                              # =>This Inner Loop Header: Depth=1
	movzbl	(%r14), %eax
	movb	%al, 7(%rsp)
	movl	$1, %edx
	movl	$2, %edi
	movq	%r15, %rsi
	callq	write@PLT
	decl	%ebp
	decq	%r14
	cmpl	$1, %ebp
	jg	.LBB13_12
.LBB13_13:
	leaq	.L.str.21(%rip), %rsi
	movl	$2, %edx
	movl	$2, %edi
	callq	write@PLT
	movl	$2, %edi
	movq	24(%rsp), %rsi                  # 8-byte Reload
	movq	%r12, %rdx
	callq	write@PLT
	leaq	.L.str.13(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 272(%rsp)
	movaps	%xmm0, 256(%rsp)
	movaps	%xmm0, 240(%rsp)
	movaps	%xmm0, 224(%rsp)
	movaps	%xmm0, 208(%rsp)
	movaps	%xmm0, 192(%rsp)
	movaps	%xmm0, 176(%rsp)
	movaps	%xmm0, 160(%rsp)
	movaps	%xmm0, 144(%rsp)
	movaps	%xmm0, 128(%rsp)
	movaps	%xmm0, 112(%rsp)
	movaps	%xmm0, 96(%rsp)
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm0, 64(%rsp)
	movaps	%xmm0, 48(%rsp)
	movaps	%xmm0, 32(%rsp)
	leaq	32(%rsp), %rdi
	movl	$32, %esi
	callq	backtrace@PLT
	testl	%eax, %eax
	jg	.LBB13_15
# %bb.14:
	leaq	.L.str.8(%rip), %rsi
	movl	$14, %edx
	movl	$2, %edi
	callq	write@PLT
	jmp	.LBB13_16
.LBB13_15:
	movl	%eax, %ebx
	leaq	.L.str.9(%rip), %rsi
	movl	$9, %edx
	movl	$2, %edi
	callq	write@PLT
	leaq	32(%rsp), %rdi
	movl	%ebx, %esi
	movl	$2, %edx
	callq	backtrace_symbols_fd@PLT
.LBB13_16:
	leaq	.L.str.13(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	callq	raise@PLT
	movl	$134, %edi
	callq	_exit@PLT
.Lfunc_end13:
	.size	crl__lib__std__x86_64__linux__error___failCmp, .Lfunc_end13-crl__lib__std__x86_64__linux__error___failCmp
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertEq # -- Begin function crl__lib__std__x86_64__linux__error____assertEq
	.prefalign	4, .Lfunc_end14, nop
	.type	crl__lib__std__x86_64__linux__error____assertEq,@function
crl__lib__std__x86_64__linux__error____assertEq: # @crl__lib__std__x86_64__linux__error____assertEq
	.cfi_startproc
# %bb.0:
	cmpq	%rsi, %rdi
	jne	.LBB14_2
# %bb.1:
	retq
.LBB14_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rcx, %r9
	movq	%rdx, %r8
	movq	%rsi, %rdx
	movq	%rdi, %rcx
	leaq	.L.str.22(%rip), %rdi
	movl	$2, %esi
	callq	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end14:
	.size	crl__lib__std__x86_64__linux__error____assertEq, .Lfunc_end14-crl__lib__std__x86_64__linux__error____assertEq
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertNe # -- Begin function crl__lib__std__x86_64__linux__error____assertNe
	.prefalign	4, .Lfunc_end15, nop
	.type	crl__lib__std__x86_64__linux__error____assertNe,@function
crl__lib__std__x86_64__linux__error____assertNe: # @crl__lib__std__x86_64__linux__error____assertNe
	.cfi_startproc
# %bb.0:
	cmpq	%rsi, %rdi
	je	.LBB15_2
# %bb.1:
	retq
.LBB15_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rcx, %r9
	movq	%rdx, %r8
	movq	%rdi, %rcx
	leaq	.L.str.23(%rip), %rdi
	movl	$2, %esi
	movq	%rcx, %rdx
	callq	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end15:
	.size	crl__lib__std__x86_64__linux__error____assertNe, .Lfunc_end15-crl__lib__std__x86_64__linux__error____assertNe
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertLt # -- Begin function crl__lib__std__x86_64__linux__error____assertLt
	.prefalign	4, .Lfunc_end16, nop
	.type	crl__lib__std__x86_64__linux__error____assertLt,@function
crl__lib__std__x86_64__linux__error____assertLt: # @crl__lib__std__x86_64__linux__error____assertLt
	.cfi_startproc
# %bb.0:
	cmpq	%rsi, %rdi
	jae	.LBB16_2
# %bb.1:
	retq
.LBB16_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rcx, %r9
	movq	%rdx, %r8
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	leaq	.L.str.24(%rip), %rdi
	movl	$1, %esi
	callq	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end16:
	.size	crl__lib__std__x86_64__linux__error____assertLt, .Lfunc_end16-crl__lib__std__x86_64__linux__error____assertLt
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertLe # -- Begin function crl__lib__std__x86_64__linux__error____assertLe
	.prefalign	4, .Lfunc_end17, nop
	.type	crl__lib__std__x86_64__linux__error____assertLe,@function
crl__lib__std__x86_64__linux__error____assertLe: # @crl__lib__std__x86_64__linux__error____assertLe
	.cfi_startproc
# %bb.0:
	cmpq	%rsi, %rdi
	ja	.LBB17_2
# %bb.1:
	retq
.LBB17_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rcx, %r9
	movq	%rdx, %r8
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	leaq	.L.str.25(%rip), %rdi
	movl	$2, %esi
	callq	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end17:
	.size	crl__lib__std__x86_64__linux__error____assertLe, .Lfunc_end17-crl__lib__std__x86_64__linux__error____assertLe
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertGt # -- Begin function crl__lib__std__x86_64__linux__error____assertGt
	.prefalign	4, .Lfunc_end18, nop
	.type	crl__lib__std__x86_64__linux__error____assertGt,@function
crl__lib__std__x86_64__linux__error____assertGt: # @crl__lib__std__x86_64__linux__error____assertGt
	.cfi_startproc
# %bb.0:
	cmpq	%rsi, %rdi
	jbe	.LBB18_2
# %bb.1:
	retq
.LBB18_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rcx, %r9
	movq	%rdx, %r8
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	leaq	.L.str.26(%rip), %rdi
	movl	$1, %esi
	callq	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end18:
	.size	crl__lib__std__x86_64__linux__error____assertGt, .Lfunc_end18-crl__lib__std__x86_64__linux__error____assertGt
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertGe # -- Begin function crl__lib__std__x86_64__linux__error____assertGe
	.prefalign	4, .Lfunc_end19, nop
	.type	crl__lib__std__x86_64__linux__error____assertGe,@function
crl__lib__std__x86_64__linux__error____assertGe: # @crl__lib__std__x86_64__linux__error____assertGe
	.cfi_startproc
# %bb.0:
	cmpq	%rsi, %rdi
	jb	.LBB19_2
# %bb.1:
	retq
.LBB19_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rcx, %r9
	movq	%rdx, %r8
	movq	%rsi, %rcx
	movq	%rdi, %rdx
	leaq	.L.str.27(%rip), %rdi
	movl	$2, %esi
	callq	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end19:
	.size	crl__lib__std__x86_64__linux__error____assertGe, .Lfunc_end19-crl__lib__std__x86_64__linux__error____assertGe
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertRange # -- Begin function crl__lib__std__x86_64__linux__error____assertRange
	.prefalign	4, .Lfunc_end20, nop
	.type	crl__lib__std__x86_64__linux__error____assertRange,@function
crl__lib__std__x86_64__linux__error____assertRange: # @crl__lib__std__x86_64__linux__error____assertRange
	.cfi_startproc
# %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	subq	$280, %rsp                      # imm = 0x118
	.cfi_def_cfa_offset 336
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%fs:40, %rax
	movq	%rax, 272(%rsp)
	cmpq	%rsi, %rdi
	jae	.LBB20_1
# %bb.17:
	movq	%fs:40, %rax
	cmpq	272(%rsp), %rax
	jne	.LBB20_19
# %bb.18:
	addq	$280, %rsp                      # imm = 0x118
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB20_1:
	.cfi_def_cfa_offset 336
	movq	%rsi, %r13
	movq	%rdx, %r14
	movq	%rcx, (%rsp)                    # 8-byte Spill
	leaq	.L.str.28(%rip), %rsi
	movl	$21, %edx
	movq	%rdi, %rbx
	movl	$2, %edi
	callq	write@PLT
	movabsq	$-3689348814741910323, %r12     # imm = 0xCCCCCCCCCCCCCCCD
	testq	%rbx, %rbx
	jne	.LBB20_3
# %bb.2:
	leaq	.L.str.1(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	jmp	.LBB20_7
.LBB20_19:
	callq	__stack_chk_fail@PLT
.LBB20_3:
	movq	%rbx, %rcx
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 16(%rsp)
	movl	$0, 32(%rsp)
	movl	$1, %ebp
	leaq	15(%rsp), %rbx
	.p2align	4
.LBB20_4:                               # =>This Inner Loop Header: Depth=1
	movq	%rcx, %rax
	mulq	%r12
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%ecx, %esi
	subl	%eax, %esi
	orb	$48, %sil
	movb	%sil, 1(%rbx)
	incq	%rbx
	incl	%ebp
	cmpq	$9, %rcx
	movq	%rdx, %rcx
	ja	.LBB20_4
# %bb.5:
	leaq	15(%rsp), %r15
	.p2align	4
.LBB20_6:                               # =>This Inner Loop Header: Depth=1
	movzbl	(%rbx), %eax
	movb	%al, 15(%rsp)
	movl	$1, %edx
	movl	$2, %edi
	movq	%r15, %rsi
	callq	write@PLT
	decl	%ebp
	decq	%rbx
	cmpl	$1, %ebp
	jg	.LBB20_6
.LBB20_7:
	leaq	.L.str.29(%rip), %rsi
	movl	$26, %edx
	movl	$2, %edi
	callq	write@PLT
	testq	%r13, %r13
	jne	.LBB20_9
# %bb.8:
	leaq	.L.str.1(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	jmp	.LBB20_13
.LBB20_9:
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 16(%rsp)
	movl	$0, 32(%rsp)
	movl	$1, %ebp
	leaq	15(%rsp), %rbx
	movq	%r13, %rcx
	.p2align	4
.LBB20_10:                              # =>This Inner Loop Header: Depth=1
	movq	%rcx, %rax
	mulq	%r12
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%ecx, %esi
	subl	%eax, %esi
	orb	$48, %sil
	movb	%sil, 1(%rbx)
	incq	%rbx
	incl	%ebp
	cmpq	$9, %rcx
	movq	%rdx, %rcx
	ja	.LBB20_10
# %bb.11:
	leaq	15(%rsp), %r15
	.p2align	4
.LBB20_12:                              # =>This Inner Loop Header: Depth=1
	movzbl	(%rbx), %eax
	movb	%al, 15(%rsp)
	movl	$1, %edx
	movl	$2, %edi
	movq	%r15, %rsi
	callq	write@PLT
	decl	%ebp
	decq	%rbx
	cmpl	$1, %ebp
	jg	.LBB20_12
.LBB20_13:
	leaq	.L.str.21(%rip), %rsi
	movl	$2, %edx
	movl	$2, %edi
	callq	write@PLT
	movl	$2, %edi
	movq	%r14, %rsi
	movq	(%rsp), %rdx                    # 8-byte Reload
	callq	write@PLT
	leaq	.L.str.13(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 256(%rsp)
	movaps	%xmm0, 240(%rsp)
	movaps	%xmm0, 224(%rsp)
	movaps	%xmm0, 208(%rsp)
	movaps	%xmm0, 192(%rsp)
	movaps	%xmm0, 176(%rsp)
	movaps	%xmm0, 160(%rsp)
	movaps	%xmm0, 144(%rsp)
	movaps	%xmm0, 128(%rsp)
	movaps	%xmm0, 112(%rsp)
	movaps	%xmm0, 96(%rsp)
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm0, 64(%rsp)
	movaps	%xmm0, 48(%rsp)
	movaps	%xmm0, 32(%rsp)
	movaps	%xmm0, 16(%rsp)
	leaq	16(%rsp), %rdi
	movl	$32, %esi
	callq	backtrace@PLT
	testl	%eax, %eax
	jg	.LBB20_15
# %bb.14:
	leaq	.L.str.8(%rip), %rsi
	movl	$14, %edx
	movl	$2, %edi
	callq	write@PLT
	jmp	.LBB20_16
.LBB20_15:
	movl	%eax, %ebx
	leaq	.L.str.9(%rip), %rsi
	movl	$9, %edx
	movl	$2, %edi
	callq	write@PLT
	leaq	16(%rsp), %rdi
	movl	%ebx, %esi
	movl	$2, %edx
	callq	backtrace_symbols_fd@PLT
.LBB20_16:
	leaq	.L.str.13(%rip), %rsi
	movl	$1, %edx
	movl	$2, %edi
	callq	write@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	callq	raise@PLT
	movl	$134, %edi
	callq	_exit@PLT
.Lfunc_end20:
	.size	crl__lib__std__x86_64__linux__error____assertRange, .Lfunc_end20-crl__lib__std__x86_64__linux__error____assertRange
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertNonNull # -- Begin function crl__lib__std__x86_64__linux__error____assertNonNull
	.prefalign	4, .Lfunc_end21, nop
	.type	crl__lib__std__x86_64__linux__error____assertNonNull,@function
crl__lib__std__x86_64__linux__error____assertNonNull: # @crl__lib__std__x86_64__linux__error____assertNonNull
	.cfi_startproc
# %bb.0:
	testq	%rdi, %rdi
	je	.LBB21_2
# %bb.1:
	retq
.LBB21_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rsi, %rdi
	movq	%rdx, %rsi
	callq	crl__lib__std__x86_64__linux__error____report
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	callq	raise@PLT
	movl	$134, %edi
	callq	_exit@PLT
.Lfunc_end21:
	.size	crl__lib__std__x86_64__linux__error____assertNonNull, .Lfunc_end21-crl__lib__std__x86_64__linux__error____assertNonNull
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertAligned # -- Begin function crl__lib__std__x86_64__linux__error____assertAligned
	.prefalign	4, .Lfunc_end22, nop
	.type	crl__lib__std__x86_64__linux__error____assertAligned,@function
crl__lib__std__x86_64__linux__error____assertAligned: # @crl__lib__std__x86_64__linux__error____assertAligned
	.cfi_startproc
# %bb.0:
	decq	%rsi
	testq	%rdi, %rsi
	jne	.LBB22_2
# %bb.1:
	retq
.LBB22_2:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rdi, %r8
	leaq	.L.str.30(%rip), %rax
	movq	%rcx, %rsi
	movl	$7, %ecx
	movq	%rdx, %rdi
	movq	%rax, %rdx
	callq	crl__lib__std__x86_64__linux__error____reportHex
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGABRT_(%rip), %edi
	callq	raise@PLT
	movl	$134, %edi
	callq	_exit@PLT
.Lfunc_end22:
	.size	crl__lib__std__x86_64__linux__error____assertAligned, .Lfunc_end22-crl__lib__std__x86_64__linux__error____assertAligned
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error___fatalHandler # -- Begin function crl__lib__std__x86_64__linux__error___fatalHandler
	.prefalign	4, .Lfunc_end23, nop
	.type	crl__lib__std__x86_64__linux__error___fatalHandler,@function
crl__lib__std__x86_64__linux__error___fatalHandler: # @crl__lib__std__x86_64__linux__error___fatalHandler
	.cfi_startproc
# %bb.0:
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	pushq	%rax
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -24
	.cfi_offset %r14, -16
	cmpb	$1, crl__lib__std__x86_64__linux__error___handling(%rip)
	jne	.LBB23_2
# %bb.1:
	subl	$-128, %edi
	callq	_exit@PLT
.LBB23_2:
	movb	$1, crl__lib__std__x86_64__linux__error___handling(%rip)
	leaq	.L.str.31(%rip), %rsi
	movl	$15, %edx
	movl	%edi, %ebx
	movl	$2, %edi
	callq	crl__lib__std__x86_64__linux__error___wr
	movl	$2, %edi
	movl	%ebx, %esi
	callq	crl__lib__std__x86_64__linux__error___wrSigName
	leaq	.L.str.13(%rip), %r14
	movl	$1, %edx
	movl	$2, %edi
	movq	%r14, %rsi
	callq	crl__lib__std__x86_64__linux__error___wr
	movl	$2, %edi
	callq	crl__lib__std__x86_64__linux__error____backtraceTo
	movl	$1, %edx
	movl	$2, %edi
	movq	%r14, %rsi
	callq	crl__lib__std__x86_64__linux__error___wr
	movl	%ebx, %edi
	xorl	%esi, %esi
	callq	signal@PLT
	movl	%ebx, %edi
	callq	raise@PLT
	subl	$-128, %ebx
	movl	%ebx, %edi
	callq	_exit@PLT
.Lfunc_end23:
	.size	crl__lib__std__x86_64__linux__error___fatalHandler, .Lfunc_end23-crl__lib__std__x86_64__linux__error___fatalHandler
	.cfi_endproc
                                        # -- End function
	.globl	crl__lib__std__x86_64__linux__error____catchFatalSignals # -- Begin function crl__lib__std__x86_64__linux__error____catchFatalSignals
	.prefalign	4, .Lfunc_end24, nop
	.type	crl__lib__std__x86_64__linux__error____catchFatalSignals,@function
crl__lib__std__x86_64__linux__error____catchFatalSignals: # @crl__lib__std__x86_64__linux__error____catchFatalSignals
	.cfi_startproc
# %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	movl	crl__lib__std__x86_64__linux__error__SIGSEGV_(%rip), %edi
	leaq	crl__lib__std__x86_64__linux__error___fatalHandler(%rip), %rbx
	movq	%rbx, %rsi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGBUS_(%rip), %edi
	movq	%rbx, %rsi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGILL_(%rip), %edi
	movq	%rbx, %rsi
	callq	signal@PLT
	movl	crl__lib__std__x86_64__linux__error__SIGFPE_(%rip), %edi
	movq	%rbx, %rsi
	popq	%rbx
	.cfi_def_cfa_offset 8
	jmp	signal@PLT                      # TAILCALL
.Lfunc_end24:
	.size	crl__lib__std__x86_64__linux__error____catchFatalSignals, .Lfunc_end24-crl__lib__std__x86_64__linux__error____catchFatalSignals
	.cfi_endproc
                                        # -- End function
	.type	crl__lib__std__x86_64__linux__error__SIGABRT_,@object # @crl__lib__std__x86_64__linux__error__SIGABRT_
	.data
	.globl	crl__lib__std__x86_64__linux__error__SIGABRT_
	.p2align	2, 0x0
crl__lib__std__x86_64__linux__error__SIGABRT_:
	.long	6                               # 0x6
	.size	crl__lib__std__x86_64__linux__error__SIGABRT_, 4

	.type	crl__lib__std__x86_64__linux__error__SIGBUS_,@object # @crl__lib__std__x86_64__linux__error__SIGBUS_
	.globl	crl__lib__std__x86_64__linux__error__SIGBUS_
	.p2align	2, 0x0
crl__lib__std__x86_64__linux__error__SIGBUS_:
	.long	7                               # 0x7
	.size	crl__lib__std__x86_64__linux__error__SIGBUS_, 4

	.type	crl__lib__std__x86_64__linux__error__SIGFPE_,@object # @crl__lib__std__x86_64__linux__error__SIGFPE_
	.globl	crl__lib__std__x86_64__linux__error__SIGFPE_
	.p2align	2, 0x0
crl__lib__std__x86_64__linux__error__SIGFPE_:
	.long	8                               # 0x8
	.size	crl__lib__std__x86_64__linux__error__SIGFPE_, 4

	.type	crl__lib__std__x86_64__linux__error__SIGILL_,@object # @crl__lib__std__x86_64__linux__error__SIGILL_
	.globl	crl__lib__std__x86_64__linux__error__SIGILL_
	.p2align	2, 0x0
crl__lib__std__x86_64__linux__error__SIGILL_:
	.long	4                               # 0x4
	.size	crl__lib__std__x86_64__linux__error__SIGILL_, 4

	.type	crl__lib__std__x86_64__linux__error__SIGSEGV_,@object # @crl__lib__std__x86_64__linux__error__SIGSEGV_
	.globl	crl__lib__std__x86_64__linux__error__SIGSEGV_
	.p2align	2, 0x0
crl__lib__std__x86_64__linux__error__SIGSEGV_:
	.long	11                              # 0xb
	.size	crl__lib__std__x86_64__linux__error__SIGSEGV_, 4

	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"0x"
	.size	.L.str, 3

	.type	.L.str.1,@object                # @.str.1
.L.str.1:
	.asciz	"0"
	.size	.L.str.1, 2

	.type	.L.str.2,@object                # @.str.2
.L.str.2:
	.asciz	"SIGSEGV (segmentation fault)"
	.size	.L.str.2, 29

	.type	.L.str.3,@object                # @.str.3
.L.str.3:
	.asciz	"SIGBUS (bus error)"
	.size	.L.str.3, 19

	.type	.L.str.4,@object                # @.str.4
.L.str.4:
	.asciz	"SIGILL (illegal instruction)"
	.size	.L.str.4, 29

	.type	.L.str.5,@object                # @.str.5
.L.str.5:
	.asciz	"SIGFPE (arithmetic fault)"
	.size	.L.str.5, 26

	.type	.L.str.6,@object                # @.str.6
.L.str.6:
	.asciz	"SIGABRT (abort)"
	.size	.L.str.6, 16

	.type	.L.str.7,@object                # @.str.7
.L.str.7:
	.asciz	"signal "
	.size	.L.str.7, 8

	.type	.L.str.8,@object                # @.str.8
.L.str.8:
	.asciz	"  <no frames>\n"
	.size	.L.str.8, 15

	.type	.L.str.9,@object                # @.str.9
.L.str.9:
	.asciz	"  stack:\n"
	.size	.L.str.9, 10

	.type	.L.str.10,@object               # @.str.10
.L.str.10:
	.asciz	"coral: out of memory\n"
	.size	.L.str.10, 22

	.type	.L.str.11,@object               # @.str.11
.L.str.11:
	.asciz	"  the compiler could not allocate memory; try coralc --explain D0003\n"
	.size	.L.str.11, 70

	.type	.L.str.12,@object               # @.str.12
.L.str.12:
	.asciz	"\ncoral: error: "
	.size	.L.str.12, 16

	.type	.L.str.13,@object               # @.str.13
.L.str.13:
	.asciz	"\n"
	.size	.L.str.13, 2

	.type	.L.str.14,@object               # @.str.14
.L.str.14:
	.asciz	" ("
	.size	.L.str.14, 3

	.type	.L.str.15,@object               # @.str.15
.L.str.15:
	.asciz	" = "
	.size	.L.str.15, 4

	.type	.L.str.16,@object               # @.str.16
.L.str.16:
	.asciz	")\n"
	.size	.L.str.16, 3

	.type	.L.str.17,@object               # @.str.17
.L.str.17:
	.asciz	"assertion failed"
	.size	.L.str.17, 17

	.type	.L.str.18,@object               # @.str.18
.L.str.18:
	.asciz	"\ncoral: error: assert "
	.size	.L.str.18, 23

	.type	.L.str.19,@object               # @.str.19
.L.str.19:
	.asciz	" failed: "
	.size	.L.str.19, 10

	.type	.L.str.20,@object               # @.str.20
.L.str.20:
	.asciz	" "
	.size	.L.str.20, 2

	.type	.L.str.21,@object               # @.str.21
.L.str.21:
	.asciz	": "
	.size	.L.str.21, 3

	.type	.L.str.22,@object               # @.str.22
.L.str.22:
	.asciz	"=="
	.size	.L.str.22, 3

	.type	.L.str.23,@object               # @.str.23
.L.str.23:
	.asciz	"!="
	.size	.L.str.23, 3

	.type	.L.str.24,@object               # @.str.24
.L.str.24:
	.asciz	"<"
	.size	.L.str.24, 2

	.type	.L.str.25,@object               # @.str.25
.L.str.25:
	.asciz	"<="
	.size	.L.str.25, 3

	.type	.L.str.26,@object               # @.str.26
.L.str.26:
	.asciz	">"
	.size	.L.str.26, 2

	.type	.L.str.27,@object               # @.str.27
.L.str.27:
	.asciz	">="
	.size	.L.str.27, 3

	.type	.L.str.28,@object               # @.str.28
.L.str.28:
	.asciz	"\ncoral: error: index "
	.size	.L.str.28, 22

	.type	.L.str.29,@object               # @.str.29
.L.str.29:
	.asciz	" out of bounds for length "
	.size	.L.str.29, 27

	.type	.L.str.30,@object               # @.str.30
.L.str.30:
	.asciz	"pointer"
	.size	.L.str.30, 8

	.type	crl__lib__std__x86_64__linux__error___handling,@object # @crl__lib__std__x86_64__linux__error___handling
	.local	crl__lib__std__x86_64__linux__error___handling
	.comm	crl__lib__std__x86_64__linux__error___handling,1,1
	.type	.L.str.31,@object               # @.str.31
.L.str.31:
	.asciz	"\ncoral: fatal: "
	.size	.L.str.31, 16

	.ident	"clang version 23.1.3"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym crl__lib__std__x86_64__linux__error___fatalHandler
	.addrsig_sym __stack_chk_fail

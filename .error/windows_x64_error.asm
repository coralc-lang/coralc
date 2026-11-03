	.def	@feat.00;
	.scl	3;
	.type	0;
	.endef
	.globl	@feat.00
@feat.00 = 0
	.att_syntax
	.file	"error.c"
	.def	crl__lib__std__x86_64__windows__error___wr;
	.scl	2;
	.type	32;
	.endef
	.text
	.globl	crl__lib__std__x86_64__windows__error___wr # -- Begin function crl__lib__std__x86_64__windows__error___wr
	.p2align	4
crl__lib__std__x86_64__windows__error___wr: # @crl__lib__std__x86_64__windows__error___wr
# %bb.0:
	movq	(%rdx), %rax
	movq	8(%rdx), %r8
	movq	%rax, %rdx
	jmp	write                           # TAILCALL
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error___wrHex;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___wrHex # -- Begin function crl__lib__std__x86_64__windows__error___wrHex
	.p2align	4
crl__lib__std__x86_64__windows__error___wrHex: # @crl__lib__std__x86_64__windows__error___wrHex
.seh_proc crl__lib__std__x86_64__windows__error___wrHex
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	movq	%rdx, %rdi
	movl	%ecx, %esi
	leaq	"??_C@_02MDDDDAID@0x?$AA@"(%rip), %rdx
	movl	$2, %r8d
	callq	write
	movq	%rdi, %rax
	shrq	$60, %rax
	je	.LBB1_3
# %bb.1:
	movq	%rdi, %rcx
	shrq	$61, %rcx
	leal	48(%rax), %edx
	addb	$87, %al
	cmpl	$5, %ecx
	movzbl	%dl, %ecx
	movzbl	%al, %eax
	cmovbl	%ecx, %eax
	movb	%al, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movq	%rdi, %rax
	shrq	$56, %rax
	andl	$15, %eax
	jmp	.LBB1_2
.LBB1_3:
	movq	%rdi, %rax
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
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movb	$1, %cl
.LBB1_5:
	movq	%rdi, %rax
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
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movq	%rdi, %rax
	shrq	$48, %rax
	andl	$15, %eax
	jmp	.LBB1_7
.LBB1_8:
	movq	%rdi, %rax
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
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movb	$1, %cl
.LBB1_10:
	movq	%rdi, %rax
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
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movq	%rdi, %rax
	shrq	$40, %rax
	andl	$15, %eax
	jmp	.LBB1_12
.LBB1_13:
	movq	%rdi, %rax
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
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movb	$1, %cl
.LBB1_15:
	movq	%rdi, %rax
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
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movq	%rdi, %rax
	shrq	$32, %rax
	andl	$15, %eax
	jmp	.LBB1_17
.LBB1_18:
	movq	%rdi, %rax
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
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movb	$1, %cl
.LBB1_20:
	movl	%edi, %eax
	shrl	$28, %eax
	sete	%dl
	notb	%cl
	testb	%dl, %cl
	jne	.LBB1_22
# %bb.21:
	leal	87(%rax), %ecx
	orb	$48, %al
	cmpl	$-1610612736, %edi              # imm = 0xA0000000
	movzbl	%al, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movl	%edi, %eax
	shrl	$24, %eax
	andl	$15, %eax
	jmp	.LBB1_23
.LBB1_22:
	movl	%edi, %eax
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
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movl	%edi, %eax
	shrl	$20, %eax
	andl	$15, %eax
.LBB1_25:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movl	%edi, %eax
	shrl	$16, %eax
	andl	$15, %eax
.LBB1_27:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movl	%edi, %eax
	shrl	$12, %eax
	andl	$15, %eax
.LBB1_29:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movl	%edi, %eax
	shrl	$8, %eax
	andl	$15, %eax
.LBB1_31:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	movl	%edi, %eax
	shrl	$4, %eax
	andl	$15, %eax
.LBB1_33:
	leal	87(%rax), %ecx
	leal	48(%rax), %edx
	cmpl	$10, %eax
	movzbl	%dl, %eax
	movzbl	%cl, %ecx
	cmovbl	%eax, %ecx
	movb	%cl, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
.LBB1_34:
	andl	$15, %edi
	leal	87(%rdi), %eax
	leal	48(%rdi), %ecx
	cmpl	$10, %edi
	movzbl	%cl, %ecx
	movzbl	%al, %eax
	cmovbl	%ecx, %eax
	movb	%al, 39(%rsp)
	leaq	39(%rsp), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	callq	write
	nop
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	retq
.LBB1_9:
	xorl	%ecx, %ecx
	jmp	.LBB1_10
.LBB1_14:
	xorl	%ecx, %ecx
	jmp	.LBB1_15
.LBB1_19:
	xorl	%ecx, %ecx
	jmp	.LBB1_20
.LBB1_24:
	movl	%edi, %eax
	shrl	$20, %eax
	andl	$15, %eax
	jne	.LBB1_25
# %bb.26:
	movl	%edi, %eax
	shrl	$16, %eax
	andl	$15, %eax
	jne	.LBB1_27
# %bb.28:
	movl	%edi, %eax
	shrl	$12, %eax
	andl	$15, %eax
	jne	.LBB1_29
# %bb.30:
	movl	%edi, %eax
	shrl	$8, %eax
	andl	$15, %eax
	jne	.LBB1_31
# %bb.32:
	movl	%edi, %eax
	shrl	$4, %eax
	andl	$15, %eax
	jne	.LBB1_33
	jmp	.LBB1_34
.LBB1_4:
	xorl	%ecx, %ecx
	jmp	.LBB1_5
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error___wrDec;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___wrDec # -- Begin function crl__lib__std__x86_64__windows__error___wrDec
	.p2align	4
crl__lib__std__x86_64__windows__error___wrDec: # @crl__lib__std__x86_64__windows__error___wrDec
.seh_proc crl__lib__std__x86_64__windows__error___wrDec
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$80, %rsp
	.seh_stackalloc 80
	.seh_endprologue
	movl	%ecx, %esi
	testq	%rdx, %rdx
	je	.LBB2_7
# %bb.1:
	movq	%rdx, %r8
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 48(%rsp)
	movl	$0, 64(%rsp)
	xorl	%ecx, %ecx
	movabsq	$-3689348814741910323, %r9      # imm = 0xCCCCCCCCCCCCCCCD
	.p2align	4
.LBB2_2:                                # =>This Inner Loop Header: Depth=1
	movq	%r8, %rax
	mulq	%r9
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%r8d, %r10d
	subl	%eax, %r10d
	orb	$48, %r10b
	movslq	%ecx, %rcx
	movb	%r10b, 48(%rsp,%rcx)
	incl	%ecx
	cmpq	$10, %r8
	movq	%rdx, %r8
	jae	.LBB2_2
# %bb.3:
	leal	-1(%rcx), %eax
	cmpl	$2147483646, %eax               # imm = 0x7FFFFFFE
	ja	.LBB2_6
# %bb.4:
	movl	%ecx, %ebx
	incq	%rbx
	leaq	47(%rsp), %rdi
	.p2align	4
.LBB2_5:                                # =>This Inner Loop Header: Depth=1
	movzbl	46(%rsp,%rbx), %eax
	movb	%al, 47(%rsp)
	movl	$1, %r8d
	movl	%esi, %ecx
	movq	%rdi, %rdx
	callq	write
	decq	%rbx
	cmpq	$1, %rbx
	ja	.LBB2_5
.LBB2_6:
	.seh_startepilogue
	addq	$80, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	retq
.LBB2_7:
	leaq	"??_C@_01GBGANLPD@0?$AA@"(%rip), %rdx
	movl	$1, %r8d
	movl	%esi, %ecx
	.seh_startepilogue
	addq	$80, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	jmp	write                           # TAILCALL
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error___wrExcName;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___wrExcName # -- Begin function crl__lib__std__x86_64__windows__error___wrExcName
	.p2align	4
crl__lib__std__x86_64__windows__error___wrExcName: # @crl__lib__std__x86_64__windows__error___wrExcName
.seh_proc crl__lib__std__x86_64__windows__error___wrExcName
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	cmpl	crl__lib__std__x86_64__windows__error__EXC_ACCESS_VIOLATION(%rip), %edx
	jne	.LBB3_4
# %bb.1:
	leaq	"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@"(%rip), %rdx
.LBB3_2:
	movl	$16, %r8d
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	jmp	write                           # TAILCALL
.LBB3_4:
	cmpl	crl__lib__std__x86_64__windows__error__EXC_ILLEGAL_INSTRUCTION(%rip), %edx
	jne	.LBB3_6
# %bb.5:
	leaq	"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@"(%rip), %rdx
	movl	$19, %r8d
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	jmp	write                           # TAILCALL
.LBB3_6:
	cmpl	crl__lib__std__x86_64__windows__error__EXC_ARRAY_BOUNDS(%rip), %edx
	jne	.LBB3_9
# %bb.7:
	leaq	"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@"(%rip), %rdx
.LBB3_8:
	movl	$21, %r8d
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	jmp	write                           # TAILCALL
.LBB3_9:
	cmpl	crl__lib__std__x86_64__windows__error__EXC_FLT_DIVIDE_BY_ZERO(%rip), %edx
	jne	.LBB3_12
# %bb.10:
	leaq	"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@"(%rip), %rdx
.LBB3_11:
	movl	$18, %r8d
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	jmp	write                           # TAILCALL
.LBB3_12:
	cmpl	crl__lib__std__x86_64__windows__error__EXC_FLT_INVALID_OPERATION(%rip), %edx
	jne	.LBB3_14
# %bb.13:
	leaq	"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@"(%rip), %rdx
	jmp	.LBB3_8
.LBB3_14:
	cmpl	crl__lib__std__x86_64__windows__error__EXC_INT_DIVIDE_BY_ZERO(%rip), %edx
	jne	.LBB3_16
# %bb.15:
	leaq	"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@"(%rip), %rdx
	jmp	.LBB3_11
.LBB3_16:
	cmpl	crl__lib__std__x86_64__windows__error__EXC_INTEGER_OVERFLOW(%rip), %edx
	jne	.LBB3_18
# %bb.17:
	leaq	"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@"(%rip), %rdx
	jmp	.LBB3_2
.LBB3_18:
	cmpl	crl__lib__std__x86_64__windows__error__EXC_PRIVILEGED_INSTRUCTION(%rip), %edx
	jne	.LBB3_20
# %bb.19:
	leaq	"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@"(%rip), %rdx
	movl	$22, %r8d
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	jmp	write                           # TAILCALL
.LBB3_20:
	leaq	"??_C@_0L@PBPBANKG@exception?5?$AA@"(%rip), %rax
	movl	$10, %r8d
	movl	%ecx, %esi
	movl	%edx, %edi
	movq	%rax, %rdx
	callq	write
	movl	%edi, %edx
	movl	%esi, %ecx
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	jmp	crl__lib__std__x86_64__windows__error___wrHex # TAILCALL
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____backtraceTo;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____backtraceTo # -- Begin function crl__lib__std__x86_64__windows__error____backtraceTo
	.p2align	4
crl__lib__std__x86_64__windows__error____backtraceTo: # @crl__lib__std__x86_64__windows__error____backtraceTo
.seh_proc crl__lib__std__x86_64__windows__error____backtraceTo
# %bb.0:
	pushq	%r15
	.seh_pushreg %r15
	pushq	%r14
	.seh_pushreg %r14
	pushq	%r13
	.seh_pushreg %r13
	pushq	%r12
	.seh_pushreg %r12
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbp
	.seh_pushreg %rbp
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$360, %rsp                      # imm = 0x168
	.seh_stackalloc 360
	movaps	%xmm6, 336(%rsp)                # 16-byte Spill
	.seh_savexmm %xmm6, 336
	.seh_endprologue
	movl	%ecx, %esi
	xorps	%xmm6, %xmm6
	movaps	%xmm6, 320(%rsp)
	movaps	%xmm6, 304(%rsp)
	movaps	%xmm6, 288(%rsp)
	movaps	%xmm6, 272(%rsp)
	movaps	%xmm6, 256(%rsp)
	movaps	%xmm6, 240(%rsp)
	movaps	%xmm6, 224(%rsp)
	movaps	%xmm6, 208(%rsp)
	movaps	%xmm6, 192(%rsp)
	movaps	%xmm6, 176(%rsp)
	movaps	%xmm6, 160(%rsp)
	movaps	%xmm6, 144(%rsp)
	movaps	%xmm6, 128(%rsp)
	movaps	%xmm6, 112(%rsp)
	movaps	%xmm6, 96(%rsp)
	movaps	%xmm6, 80(%rsp)
	movl	$0, 44(%rsp)
	leaq	80(%rsp), %r8
	leaq	44(%rsp), %r9
	xorl	%ecx, %ecx
	movl	$32, %edx
	callq	CaptureStackBackTrace
	testl	%eax, %eax
	je	.LBB4_1
# %bb.2:
	movl	%eax, %edi
	leaq	"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@"(%rip), %rdx
	movl	$9, %r8d
	movl	%esi, %ecx
	callq	write
	movl	%edi, %r13d
	xorl	%ebp, %ebp
	leaq	"??_C@_01CLKCMJKC@?5?$AA@"(%rip), %r14
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %r15
	movabsq	$-3689348814741910323, %rbx     # imm = 0xCCCCCCCCCCCCCCCD
	leaq	43(%rsp), %r12
	jmp	.LBB4_3
	.p2align	4
.LBB4_4:                                #   in Loop: Header=BB4_3 Depth=1
	movl	$1, %r8d
	movl	%esi, %ecx
	leaq	"??_C@_01GBGANLPD@0?$AA@"(%rip), %rdx
	callq	write
.LBB4_5:                                #   in Loop: Header=BB4_3 Depth=1
	movl	$1, %r8d
	movl	%esi, %ecx
	movq	%r14, %rdx
	callq	write
	movq	80(%rsp,%rbp,8), %rdx
	movl	%esi, %ecx
	callq	crl__lib__std__x86_64__windows__error___wrHex
	movl	$1, %r8d
	movl	%esi, %ecx
	movq	%r15, %rdx
	callq	write
	incq	%rbp
	cmpq	%r13, %rbp
	je	.LBB4_6
.LBB4_3:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_11 Depth 2
                                        #     Child Loop BB4_9 Depth 2
	movl	$3, %r8d
	movl	%esi, %ecx
	leaq	"??_C@_03PIGNLOFM@?5?5?$CD?$AA@"(%rip), %rdx
	callq	write
	testq	%rbp, %rbp
	je	.LBB4_4
# %bb.10:                               #   in Loop: Header=BB4_3 Depth=1
	movaps	%xmm6, 48(%rsp)
	movl	$0, 64(%rsp)
	xorl	%r8d, %r8d
	movl	$1, %eax
	movq	%rbp, %rcx
	.p2align	4
.LBB4_11:                               #   Parent Loop BB4_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	%eax, %r9d
	movq	%rcx, %rax
	mulq	%rbx
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%ecx, %r10d
	subl	%eax, %r10d
	orb	$48, %r10b
	movslq	%r8d, %r8
	movb	%r10b, 48(%rsp,%r8)
	incl	%r8d
	leal	1(%r9), %eax
	cmpq	$10, %rcx
	movq	%rdx, %rcx
	jae	.LBB4_11
# %bb.7:                                #   in Loop: Header=BB4_3 Depth=1
	decl	%r8d
	cmpl	$2147483646, %r8d               # imm = 0x7FFFFFFE
	ja	.LBB4_5
# %bb.8:                                #   in Loop: Header=BB4_3 Depth=1
	movl	%r9d, %edi
	incq	%rdi
	.p2align	4
.LBB4_9:                                #   Parent Loop BB4_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movzbl	46(%rsp,%rdi), %eax
	movb	%al, 43(%rsp)
	movl	$1, %r8d
	movl	%esi, %ecx
	movq	%r12, %rdx
	callq	write
	decq	%rdi
	cmpq	$1, %rdi
	ja	.LBB4_9
	jmp	.LBB4_5
.LBB4_1:
	leaq	"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@"(%rip), %rdx
	movl	$14, %r8d
	movl	%esi, %ecx
	callq	write
.LBB4_6:
	movaps	336(%rsp), %xmm6                # 16-byte Reload
	.seh_startepilogue
	addq	$360, %rsp                      # imm = 0x168
	popq	%rbx
	popq	%rbp
	popq	%rdi
	popq	%rsi
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	.seh_endepilogue
	retq
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____abortNow;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____abortNow # -- Begin function crl__lib__std__x86_64__windows__error____abortNow
	.p2align	4
crl__lib__std__x86_64__windows__error____abortNow: # @crl__lib__std__x86_64__windows__error____abortNow
.seh_proc crl__lib__std__x86_64__windows__error____abortNow
# %bb.0:
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	leaq	GetCurrentProcess(%rip), %rcx
	movl	$134, %edx
	callq	TerminateProcess
	movl	$134, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____oomFatal;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____oomFatal # -- Begin function crl__lib__std__x86_64__windows__error____oomFatal
	.p2align	4
crl__lib__std__x86_64__windows__error____oomFatal: # @crl__lib__std__x86_64__windows__error____oomFatal
.seh_proc crl__lib__std__x86_64__windows__error____oomFatal
# %bb.0:
	subq	$56, %rsp
	.seh_stackalloc 56
	.seh_endprologue
	leaq	"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@"(%rip), %rax
	movq	%rax, 40(%rsp)
	movq	$21, 48(%rsp)
	leaq	40(%rsp), %rdx
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error___wr
	leaq	"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@"(%rip), %rax
	movq	%rax, 40(%rsp)
	movq	$69, 48(%rsp)
	leaq	40(%rsp), %rdx
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error___wr
	movl	$2, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____report;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____report # -- Begin function crl__lib__std__x86_64__windows__error____report
	.p2align	4
crl__lib__std__x86_64__windows__error____report: # @crl__lib__std__x86_64__windows__error____report
.seh_proc crl__lib__std__x86_64__windows__error____report
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	subq	$32, %rsp
	.seh_stackalloc 32
	.seh_endprologue
	movq	%rcx, %rsi
	leaq	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"(%rip), %rdx
	movl	$15, %r8d
	movl	$2, %ecx
	callq	write
	movq	(%rsi), %rdx
	movq	8(%rsi), %r8
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rsi
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	.seh_startepilogue
	addq	$32, %rsp
	popq	%rsi
	.seh_endepilogue
	jmp	write                           # TAILCALL
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____reportHex;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____reportHex # -- Begin function crl__lib__std__x86_64__windows__error____reportHex
	.p2align	4
crl__lib__std__x86_64__windows__error____reportHex: # @crl__lib__std__x86_64__windows__error____reportHex
.seh_proc crl__lib__std__x86_64__windows__error____reportHex
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$32, %rsp
	.seh_stackalloc 32
	.seh_endprologue
	movq	%r8, %rsi
	movq	%rdx, %rdi
	movq	%rcx, %rbx
	leaq	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"(%rip), %rdx
	movl	$15, %r8d
	movl	$2, %ecx
	callq	write
	movq	(%rbx), %rdx
	movq	8(%rbx), %r8
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_02GFKOMOKH@?5?$CI?$AA@"(%rip), %rdx
	movl	$2, %r8d
	movl	$2, %ecx
	callq	write
	movq	(%rdi), %rdx
	movq	8(%rdi), %r8
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_03MHLONNLM@?5?$DN?5?$AA@"(%rip), %rdx
	movl	$3, %r8d
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	crl__lib__std__x86_64__windows__error___wrHex
	leaq	"??_C@_02MNMNLDAI@?$CJ?6?$AA@"(%rip), %rdx
	movl	$2, %r8d
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rdx
	movl	$1, %r8d
	movl	$2, %ecx
	.seh_startepilogue
	addq	$32, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	jmp	write                           # TAILCALL
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____panic;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____panic # -- Begin function crl__lib__std__x86_64__windows__error____panic
	.p2align	4
crl__lib__std__x86_64__windows__error____panic: # @crl__lib__std__x86_64__windows__error____panic
.seh_proc crl__lib__std__x86_64__windows__error____panic
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	movq	(%rcx), %rsi
	movq	8(%rcx), %rdi
	leaq	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"(%rip), %rdx
	movl	$15, %r8d
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	movq	%rsi, %rdx
	movq	%rdi, %r8
	callq	write
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rsi
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	leaq	GetCurrentProcess(%rip), %rcx
	movl	$134, %edx
	callq	TerminateProcess
	movl	$134, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____unreachable;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____unreachable # -- Begin function crl__lib__std__x86_64__windows__error____unreachable
	.p2align	4
crl__lib__std__x86_64__windows__error____unreachable: # @crl__lib__std__x86_64__windows__error____unreachable
.seh_proc crl__lib__std__x86_64__windows__error____unreachable
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	movq	(%rcx), %rsi
	movq	8(%rcx), %rdi
	leaq	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"(%rip), %rdx
	movl	$15, %r8d
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	movq	%rsi, %rdx
	movq	%rdi, %r8
	callq	write
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rsi
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	leaq	GetCurrentProcess(%rip), %rcx
	movl	$134, %edx
	callq	TerminateProcess
	movl	$134, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assert;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assert # -- Begin function crl__lib__std__x86_64__windows__error____assert
	.p2align	4
crl__lib__std__x86_64__windows__error____assert: # @crl__lib__std__x86_64__windows__error____assert
.seh_proc crl__lib__std__x86_64__windows__error____assert
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	subq	$32, %rsp
	.seh_stackalloc 32
	.seh_endprologue
	testb	%cl, %cl
	je	.LBB11_2
# %bb.1:
	.seh_startepilogue
	addq	$32, %rsp
	popq	%rsi
	.seh_endepilogue
	retq
.LBB11_2:
	leaq	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"(%rip), %rdx
	movl	$15, %r8d
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@"(%rip), %rdx
	movl	$16, %r8d
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rsi
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	leaq	GetCurrentProcess(%rip), %rcx
	movl	$134, %edx
	callq	TerminateProcess
	movl	$134, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertOut;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertOut # -- Begin function crl__lib__std__x86_64__windows__error____assertOut
	.p2align	4
crl__lib__std__x86_64__windows__error____assertOut: # @crl__lib__std__x86_64__windows__error____assertOut
.seh_proc crl__lib__std__x86_64__windows__error____assertOut
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	testb	%cl, %cl
	je	.LBB12_2
# %bb.1:
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	retq
.LBB12_2:
	movq	(%rdx), %rsi
	movq	8(%rdx), %rdi
	leaq	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"(%rip), %rdx
	movl	$15, %r8d
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	movq	%rsi, %rdx
	movq	%rdi, %r8
	callq	write
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rsi
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	leaq	GetCurrentProcess(%rip), %rcx
	movl	$134, %edx
	callq	TerminateProcess
	movl	$134, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error___failCmp;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___failCmp # -- Begin function crl__lib__std__x86_64__windows__error___failCmp
	.p2align	4
crl__lib__std__x86_64__windows__error___failCmp: # @crl__lib__std__x86_64__windows__error___failCmp
.seh_proc crl__lib__std__x86_64__windows__error___failCmp
# %bb.0:
	pushq	%r15
	.seh_pushreg %r15
	pushq	%r14
	.seh_pushreg %r14
	pushq	%r12
	.seh_pushreg %r12
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$72, %rsp
	.seh_stackalloc 72
	.seh_endprologue
	movq	%r9, %rsi
	movq	%r8, %rdi
	movq	%rdx, %r14
	movq	%rcx, %rbx
	leaq	"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@"(%rip), %rdx
	movl	$22, %r8d
	movl	$2, %ecx
	callq	write
	movq	(%rbx), %rdx
	movq	8(%rbx), %r8
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_09FIOGNGMI@?5failed?3?5?$AA@"(%rip), %rdx
	movl	$9, %r8d
	movl	$2, %ecx
	callq	write
	movabsq	$-3689348814741910323, %r15     # imm = 0xCCCCCCCCCCCCCCCD
	testq	%r14, %r14
	jne	.LBB13_8
# %bb.1:
	leaq	"??_C@_01GBGANLPD@0?$AA@"(%rip), %rdx
	movl	$1, %r8d
	movl	$2, %ecx
	callq	write
	jmp	.LBB13_2
.LBB13_8:
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 48(%rsp)
	movl	$0, 64(%rsp)
	xorl	%ecx, %ecx
	.p2align	4
.LBB13_9:                               # =>This Inner Loop Header: Depth=1
	movq	%r14, %rax
	mulq	%r15
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%r14d, %r8d
	subl	%eax, %r8d
	orb	$48, %r8b
	movslq	%ecx, %rcx
	movb	%r8b, 48(%rsp,%rcx)
	incl	%ecx
	cmpq	$10, %r14
	movq	%rdx, %r14
	jae	.LBB13_9
# %bb.5:
	leal	-1(%rcx), %eax
	cmpl	$2147483646, %eax               # imm = 0x7FFFFFFE
	ja	.LBB13_2
# %bb.6:
	movl	%ecx, %r12d
	incq	%r12
	leaq	47(%rsp), %r14
	.p2align	4
.LBB13_7:                               # =>This Inner Loop Header: Depth=1
	movzbl	46(%rsp,%r12), %eax
	movb	%al, 47(%rsp)
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%r14, %rdx
	callq	write
	decq	%r12
	cmpq	$1, %r12
	ja	.LBB13_7
.LBB13_2:
	leaq	"??_C@_01CLKCMJKC@?5?$AA@"(%rip), %r14
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%r14, %rdx
	callq	write
	movq	(%rbx), %rdx
	movq	8(%rbx), %r8
	movl	$2, %ecx
	callq	write
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%r14, %rdx
	callq	write
	testq	%rdi, %rdi
	jne	.LBB13_13
# %bb.3:
	leaq	"??_C@_01GBGANLPD@0?$AA@"(%rip), %rdx
	movl	$1, %r8d
	movl	$2, %ecx
	callq	write
	jmp	.LBB13_4
.LBB13_13:
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 48(%rsp)
	movl	$0, 64(%rsp)
	xorl	%ecx, %ecx
	.p2align	4
.LBB13_14:                              # =>This Inner Loop Header: Depth=1
	movq	%rdi, %rax
	mulq	%r15
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%edi, %r8d
	subl	%eax, %r8d
	orb	$48, %r8b
	movslq	%ecx, %rcx
	movb	%r8b, 48(%rsp,%rcx)
	incl	%ecx
	cmpq	$10, %rdi
	movq	%rdx, %rdi
	jae	.LBB13_14
# %bb.10:
	leal	-1(%rcx), %eax
	cmpl	$2147483646, %eax               # imm = 0x7FFFFFFE
	ja	.LBB13_4
# %bb.11:
	movl	%ecx, %ebx
	incq	%rbx
	leaq	47(%rsp), %rdi
	.p2align	4
.LBB13_12:                              # =>This Inner Loop Header: Depth=1
	movzbl	46(%rsp,%rbx), %eax
	movb	%al, 47(%rsp)
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rdi, %rdx
	callq	write
	decq	%rbx
	cmpq	$1, %rbx
	ja	.LBB13_12
.LBB13_4:
	leaq	"??_C@_02LMMGGCAJ@?3?5?$AA@"(%rip), %rdx
	movl	$2, %r8d
	movl	$2, %ecx
	callq	write
	movq	(%rsi), %rdx
	movq	8(%rsi), %r8
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rsi
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	leaq	GetCurrentProcess(%rip), %rcx
	movl	$134, %edx
	callq	TerminateProcess
	movl	$134, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertEq;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertEq # -- Begin function crl__lib__std__x86_64__windows__error____assertEq
	.p2align	4
crl__lib__std__x86_64__windows__error____assertEq: # @crl__lib__std__x86_64__windows__error____assertEq
.seh_proc crl__lib__std__x86_64__windows__error____assertEq
# %bb.0:
	subq	$72, %rsp
	.seh_stackalloc 72
	.seh_endprologue
	cmpq	%rdx, %rcx
	jne	.LBB14_2
# %bb.1:
	.seh_startepilogue
	addq	$72, %rsp
	.seh_endepilogue
	retq
.LBB14_2:
	leaq	"??_C@_02EGOFBIJA@?$DN?$DN?$AA@"(%rip), %rax
	movq	%rax, 32(%rsp)
	movq	$2, 40(%rsp)
	movups	(%r8), %xmm0
	movaps	%xmm0, 48(%rsp)
	leaq	32(%rsp), %rax
	leaq	48(%rsp), %r9
	movq	%rcx, %r8
	movq	%rax, %rcx
	callq	crl__lib__std__x86_64__windows__error___failCmp
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertNe;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertNe # -- Begin function crl__lib__std__x86_64__windows__error____assertNe
	.p2align	4
crl__lib__std__x86_64__windows__error____assertNe: # @crl__lib__std__x86_64__windows__error____assertNe
.seh_proc crl__lib__std__x86_64__windows__error____assertNe
# %bb.0:
	subq	$72, %rsp
	.seh_stackalloc 72
	.seh_endprologue
	cmpq	%rdx, %rcx
	je	.LBB15_2
# %bb.1:
	.seh_startepilogue
	addq	$72, %rsp
	.seh_endepilogue
	retq
.LBB15_2:
	leaq	"??_C@_02FDNJECIE@?$CB?$DN?$AA@"(%rip), %rax
	movq	%rax, 32(%rsp)
	movq	$2, 40(%rsp)
	movups	(%r8), %xmm0
	movaps	%xmm0, 48(%rsp)
	leaq	32(%rsp), %rax
	leaq	48(%rsp), %r9
	movq	%rcx, %rdx
	movq	%rax, %rcx
	movq	%rdx, %r8
	callq	crl__lib__std__x86_64__windows__error___failCmp
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertLt;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertLt # -- Begin function crl__lib__std__x86_64__windows__error____assertLt
	.p2align	4
crl__lib__std__x86_64__windows__error____assertLt: # @crl__lib__std__x86_64__windows__error____assertLt
.seh_proc crl__lib__std__x86_64__windows__error____assertLt
# %bb.0:
	subq	$72, %rsp
	.seh_stackalloc 72
	.seh_endprologue
	movq	%rdx, %rax
	cmpq	%rdx, %rcx
	jae	.LBB16_2
# %bb.1:
	.seh_startepilogue
	addq	$72, %rsp
	.seh_endepilogue
	retq
.LBB16_2:
	movq	%rcx, %rdx
	leaq	"??_C@_01MNNFJEPP@?$DM?$AA@"(%rip), %rcx
	movq	%rcx, 32(%rsp)
	movq	$1, 40(%rsp)
	movups	(%r8), %xmm0
	movaps	%xmm0, 48(%rsp)
	leaq	32(%rsp), %rcx
	leaq	48(%rsp), %r9
	movq	%rax, %r8
	callq	crl__lib__std__x86_64__windows__error___failCmp
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertLe;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertLe # -- Begin function crl__lib__std__x86_64__windows__error____assertLe
	.p2align	4
crl__lib__std__x86_64__windows__error____assertLe: # @crl__lib__std__x86_64__windows__error____assertLe
.seh_proc crl__lib__std__x86_64__windows__error____assertLe
# %bb.0:
	subq	$72, %rsp
	.seh_stackalloc 72
	.seh_endprologue
	movq	%rdx, %rax
	cmpq	%rdx, %rcx
	ja	.LBB17_2
# %bb.1:
	.seh_startepilogue
	addq	$72, %rsp
	.seh_endepilogue
	retq
.LBB17_2:
	movq	%rcx, %rdx
	leaq	"??_C@_02EHCHHCKH@?$DM?$DN?$AA@"(%rip), %rcx
	movq	%rcx, 32(%rsp)
	movq	$2, 40(%rsp)
	movups	(%r8), %xmm0
	movaps	%xmm0, 48(%rsp)
	leaq	32(%rsp), %rcx
	leaq	48(%rsp), %r9
	movq	%rax, %r8
	callq	crl__lib__std__x86_64__windows__error___failCmp
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertGt;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertGt # -- Begin function crl__lib__std__x86_64__windows__error____assertGt
	.p2align	4
crl__lib__std__x86_64__windows__error____assertGt: # @crl__lib__std__x86_64__windows__error____assertGt
.seh_proc crl__lib__std__x86_64__windows__error____assertGt
# %bb.0:
	subq	$72, %rsp
	.seh_stackalloc 72
	.seh_endprologue
	movq	%rdx, %rax
	cmpq	%rdx, %rcx
	jbe	.LBB18_2
# %bb.1:
	.seh_startepilogue
	addq	$72, %rsp
	.seh_endepilogue
	retq
.LBB18_2:
	movq	%rcx, %rdx
	leaq	"??_C@_01PPODPGHN@?$DO?$AA@"(%rip), %rcx
	movq	%rcx, 32(%rsp)
	movq	$1, 40(%rsp)
	movups	(%r8), %xmm0
	movaps	%xmm0, 48(%rsp)
	leaq	32(%rsp), %rcx
	leaq	48(%rsp), %r9
	movq	%rax, %r8
	callq	crl__lib__std__x86_64__windows__error___failCmp
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertGe;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertGe # -- Begin function crl__lib__std__x86_64__windows__error____assertGe
	.p2align	4
crl__lib__std__x86_64__windows__error____assertGe: # @crl__lib__std__x86_64__windows__error____assertGe
.seh_proc crl__lib__std__x86_64__windows__error____assertGe
# %bb.0:
	subq	$72, %rsp
	.seh_stackalloc 72
	.seh_endprologue
	movq	%rdx, %rax
	cmpq	%rdx, %rcx
	jb	.LBB19_2
# %bb.1:
	.seh_startepilogue
	addq	$72, %rsp
	.seh_endepilogue
	retq
.LBB19_2:
	movq	%rcx, %rdx
	leaq	"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@"(%rip), %rcx
	movq	%rcx, 32(%rsp)
	movq	$2, 40(%rsp)
	movups	(%r8), %xmm0
	movaps	%xmm0, 48(%rsp)
	leaq	32(%rsp), %rcx
	leaq	48(%rsp), %r9
	movq	%rax, %r8
	callq	crl__lib__std__x86_64__windows__error___failCmp
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertRange;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertRange # -- Begin function crl__lib__std__x86_64__windows__error____assertRange
	.p2align	4
crl__lib__std__x86_64__windows__error____assertRange: # @crl__lib__std__x86_64__windows__error____assertRange
.seh_proc crl__lib__std__x86_64__windows__error____assertRange
# %bb.0:
	pushq	%r15
	.seh_pushreg %r15
	pushq	%r14
	.seh_pushreg %r14
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$80, %rsp
	.seh_stackalloc 80
	.seh_endprologue
	cmpq	%rdx, %rcx
	jae	.LBB20_1
# %bb.16:
	.seh_startepilogue
	addq	$80, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r14
	popq	%r15
	.seh_endepilogue
	retq
.LBB20_1:
	movq	%rdx, %r14
	movq	%r8, %rdi
	leaq	"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@"(%rip), %rdx
	movl	$21, %r8d
	movq	%rcx, %rsi
	movl	$2, %ecx
	callq	write
	movabsq	$-3689348814741910323, %rbx     # imm = 0xCCCCCCCCCCCCCCCD
	testq	%rsi, %rsi
	jne	.LBB20_9
# %bb.2:
	leaq	"??_C@_01GBGANLPD@0?$AA@"(%rip), %rdx
	movl	$1, %r8d
	movl	$2, %ecx
	callq	write
	jmp	.LBB20_3
.LBB20_9:
	movq	%rsi, %rcx
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 48(%rsp)
	movl	$0, 64(%rsp)
	xorl	%r8d, %r8d
	.p2align	4
.LBB20_10:                              # =>This Inner Loop Header: Depth=1
	movq	%rcx, %rax
	mulq	%rbx
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%ecx, %r9d
	subl	%eax, %r9d
	orb	$48, %r9b
	movslq	%r8d, %r8
	movb	%r9b, 48(%rsp,%r8)
	incl	%r8d
	cmpq	$10, %rcx
	movq	%rdx, %rcx
	jae	.LBB20_10
# %bb.6:
	leal	-1(%r8), %eax
	cmpl	$2147483646, %eax               # imm = 0x7FFFFFFE
	ja	.LBB20_3
# %bb.7:
	movl	%r8d, %r15d
	incq	%r15
	leaq	47(%rsp), %rsi
	.p2align	4
.LBB20_8:                               # =>This Inner Loop Header: Depth=1
	movzbl	46(%rsp,%r15), %eax
	movb	%al, 47(%rsp)
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	decq	%r15
	cmpq	$1, %r15
	ja	.LBB20_8
.LBB20_3:
	leaq	"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@"(%rip), %rdx
	movl	$26, %r8d
	movl	$2, %ecx
	callq	write
	testq	%r14, %r14
	jne	.LBB20_14
# %bb.4:
	leaq	"??_C@_01GBGANLPD@0?$AA@"(%rip), %rdx
	movl	$1, %r8d
	movl	$2, %ecx
	callq	write
	jmp	.LBB20_5
.LBB20_14:
	xorps	%xmm0, %xmm0
	movaps	%xmm0, 48(%rsp)
	movl	$0, 64(%rsp)
	xorl	%ecx, %ecx
	movq	%r14, %rax
	.p2align	4
.LBB20_15:                              # =>This Inner Loop Header: Depth=1
	movq	%rax, %r8
	mulq	%rbx
	shrq	$3, %rdx
	leal	(%rdx,%rdx), %eax
	leal	(%rax,%rax,4), %eax
	movl	%r8d, %r9d
	subl	%eax, %r9d
	orb	$48, %r9b
	movslq	%ecx, %rcx
	movb	%r9b, 48(%rsp,%rcx)
	incl	%ecx
	cmpq	$10, %r8
	movq	%rdx, %rax
	jae	.LBB20_15
# %bb.11:
	leal	-1(%rcx), %eax
	cmpl	$2147483646, %eax               # imm = 0x7FFFFFFE
	ja	.LBB20_5
# %bb.12:
	movl	%ecx, %ebx
	incq	%rbx
	leaq	47(%rsp), %rsi
	.p2align	4
.LBB20_13:                              # =>This Inner Loop Header: Depth=1
	movzbl	46(%rsp,%rbx), %eax
	movb	%al, 47(%rsp)
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	decq	%rbx
	cmpq	$1, %rbx
	ja	.LBB20_13
.LBB20_5:
	leaq	"??_C@_02LMMGGCAJ@?3?5?$AA@"(%rip), %rdx
	movl	$2, %r8d
	movl	$2, %ecx
	callq	write
	movq	(%rdi), %rdx
	movq	8(%rdi), %r8
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rsi
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	leaq	GetCurrentProcess(%rip), %rcx
	movl	$134, %edx
	callq	TerminateProcess
	movl	$134, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertNonNull;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertNonNull # -- Begin function crl__lib__std__x86_64__windows__error____assertNonNull
	.p2align	4
crl__lib__std__x86_64__windows__error____assertNonNull: # @crl__lib__std__x86_64__windows__error____assertNonNull
.seh_proc crl__lib__std__x86_64__windows__error____assertNonNull
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	testq	%rcx, %rcx
	je	.LBB21_2
# %bb.1:
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	retq
.LBB21_2:
	movq	(%rdx), %rsi
	movq	8(%rdx), %rdi
	leaq	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"(%rip), %rdx
	movl	$15, %r8d
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	movq	%rsi, %rdx
	movq	%rdi, %r8
	callq	write
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rsi
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	leaq	GetCurrentProcess(%rip), %rcx
	movl	$134, %edx
	callq	TerminateProcess
	movl	$134, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____assertAligned;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertAligned # -- Begin function crl__lib__std__x86_64__windows__error____assertAligned
	.p2align	4
crl__lib__std__x86_64__windows__error____assertAligned: # @crl__lib__std__x86_64__windows__error____assertAligned
.seh_proc crl__lib__std__x86_64__windows__error____assertAligned
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$32, %rsp
	.seh_stackalloc 32
	.seh_endprologue
	decq	%rdx
	testq	%rcx, %rdx
	jne	.LBB22_2
# %bb.1:
	.seh_startepilogue
	addq	$32, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	.seh_endepilogue
	retq
.LBB22_2:
	movq	(%r8), %rdi
	movq	8(%r8), %rbx
	leaq	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"(%rip), %rdx
	movl	$15, %r8d
	movq	%rcx, %rsi
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	movq	%rdi, %rdx
	movq	%rbx, %r8
	callq	write
	leaq	"??_C@_02GFKOMOKH@?5?$CI?$AA@"(%rip), %rdx
	movl	$2, %r8d
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_07PFMCDPMA@pointer?$AA@"(%rip), %rdx
	movl	$7, %r8d
	movl	$2, %ecx
	callq	write
	leaq	"??_C@_03MHLONNLM@?5?$DN?5?$AA@"(%rip), %rdx
	movl	$3, %r8d
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	crl__lib__std__x86_64__windows__error___wrHex
	leaq	"??_C@_02MNMNLDAI@?$CJ?6?$AA@"(%rip), %rdx
	movl	$2, %r8d
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rdx
	movl	$1, %r8d
	movl	$2, %ecx
	callq	write
	leaq	GetCurrentProcess(%rip), %rcx
	movl	$134, %edx
	callq	TerminateProcess
	movl	$134, %ecx
	callq	_exit
	int3
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error___excFilter;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___excFilter # -- Begin function crl__lib__std__x86_64__windows__error___excFilter
	.p2align	4
crl__lib__std__x86_64__windows__error___excFilter: # @crl__lib__std__x86_64__windows__error___excFilter
.seh_proc crl__lib__std__x86_64__windows__error___excFilter
# %bb.0:
	pushq	%rsi
	.seh_pushreg %rsi
	subq	$32, %rsp
	.seh_stackalloc 32
	.seh_endprologue
	cmpb	$0, crl__lib__std__x86_64__windows__error___handling(%rip)
	jne	.LBB23_2
# %bb.1:
	movb	$1, crl__lib__std__x86_64__windows__error___handling(%rip)
	movq	(%rcx), %rax
	movl	(%rax), %esi
	leaq	"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@"(%rip), %rdx
	movl	$15, %r8d
	movl	$2, %ecx
	callq	write
	movl	$2, %ecx
	movl	%esi, %edx
	callq	crl__lib__std__x86_64__windows__error___wrExcName
	leaq	"??_C@_01EEMJAFIK@?6?$AA@"(%rip), %rsi
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
	movl	$2, %ecx
	callq	crl__lib__std__x86_64__windows__error____backtraceTo
	movl	$1, %r8d
	movl	$2, %ecx
	movq	%rsi, %rdx
	callq	write
.LBB23_2:
	movl	crl__lib__std__x86_64__windows__error__EXC_CONTINUE_SEARCH(%rip), %eax
	.seh_startepilogue
	addq	$32, %rsp
	popq	%rsi
	.seh_endepilogue
	retq
	.seh_endproc
                                        # -- End function
	.def	crl__lib__std__x86_64__windows__error____catchFatalSignals;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____catchFatalSignals # -- Begin function crl__lib__std__x86_64__windows__error____catchFatalSignals
	.p2align	4
crl__lib__std__x86_64__windows__error____catchFatalSignals: # @crl__lib__std__x86_64__windows__error____catchFatalSignals
# %bb.0:
	leaq	crl__lib__std__x86_64__windows__error___excFilter(%rip), %rcx
	jmp	SetUnhandledExceptionFilter     # TAILCALL
                                        # -- End function
	.data
	.globl	crl__lib__std__x86_64__windows__error__EXC_ACCESS_VIOLATION # @crl__lib__std__x86_64__windows__error__EXC_ACCESS_VIOLATION
	.p2align	2, 0x0
crl__lib__std__x86_64__windows__error__EXC_ACCESS_VIOLATION:
	.long	3221225477                      # 0xc0000005

	.globl	crl__lib__std__x86_64__windows__error__EXC_ILLEGAL_INSTRUCTION # @crl__lib__std__x86_64__windows__error__EXC_ILLEGAL_INSTRUCTION
	.p2align	2, 0x0
crl__lib__std__x86_64__windows__error__EXC_ILLEGAL_INSTRUCTION:
	.long	3221225501                      # 0xc000001d

	.globl	crl__lib__std__x86_64__windows__error__EXC_ARRAY_BOUNDS # @crl__lib__std__x86_64__windows__error__EXC_ARRAY_BOUNDS
	.p2align	2, 0x0
crl__lib__std__x86_64__windows__error__EXC_ARRAY_BOUNDS:
	.long	3221225612                      # 0xc000008c

	.globl	crl__lib__std__x86_64__windows__error__EXC_FLT_DIVIDE_BY_ZERO # @crl__lib__std__x86_64__windows__error__EXC_FLT_DIVIDE_BY_ZERO
	.p2align	2, 0x0
crl__lib__std__x86_64__windows__error__EXC_FLT_DIVIDE_BY_ZERO:
	.long	3221225614                      # 0xc000008e

	.globl	crl__lib__std__x86_64__windows__error__EXC_FLT_INVALID_OPERATION # @crl__lib__std__x86_64__windows__error__EXC_FLT_INVALID_OPERATION
	.p2align	2, 0x0
crl__lib__std__x86_64__windows__error__EXC_FLT_INVALID_OPERATION:
	.long	3221225619                      # 0xc0000093

	.globl	crl__lib__std__x86_64__windows__error__EXC_INT_DIVIDE_BY_ZERO # @crl__lib__std__x86_64__windows__error__EXC_INT_DIVIDE_BY_ZERO
	.p2align	2, 0x0
crl__lib__std__x86_64__windows__error__EXC_INT_DIVIDE_BY_ZERO:
	.long	3221225620                      # 0xc0000094

	.globl	crl__lib__std__x86_64__windows__error__EXC_INTEGER_OVERFLOW # @crl__lib__std__x86_64__windows__error__EXC_INTEGER_OVERFLOW
	.p2align	2, 0x0
crl__lib__std__x86_64__windows__error__EXC_INTEGER_OVERFLOW:
	.long	3221225621                      # 0xc0000095

	.globl	crl__lib__std__x86_64__windows__error__EXC_PRIVILEGED_INSTRUCTION # @crl__lib__std__x86_64__windows__error__EXC_PRIVILEGED_INSTRUCTION
	.p2align	2, 0x0
crl__lib__std__x86_64__windows__error__EXC_PRIVILEGED_INSTRUCTION:
	.long	3221225510                      # 0xc0000026

	.bss
	.globl	crl__lib__std__x86_64__windows__error__EXC_CONTINUE_SEARCH # @crl__lib__std__x86_64__windows__error__EXC_CONTINUE_SEARCH
	.p2align	2, 0x0
crl__lib__std__x86_64__windows__error__EXC_CONTINUE_SEARCH:
	.long	0                               # 0x0

	.section	.rdata,"dr",discard,"??_C@_02MDDDDAID@0x?$AA@"
	.globl	"??_C@_02MDDDDAID@0x?$AA@"      # @"??_C@_02MDDDDAID@0x?$AA@"
	.p2align	2, 0x0
"??_C@_02MDDDDAID@0x?$AA@":
	.asciz	"0x"

	.section	.rdata,"dr",discard,"??_C@_01GBGANLPD@0?$AA@"
	.globl	"??_C@_01GBGANLPD@0?$AA@"       # @"??_C@_01GBGANLPD@0?$AA@"
	.p2align	2, 0x0
"??_C@_01GBGANLPD@0?$AA@":
	.asciz	"0"

	.section	.rdata,"dr",discard,"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@"
	.globl	"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@" # @"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@"
	.p2align	3, 0x0
"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@":
	.asciz	"ACCESS_VIOLATION"

	.section	.rdata,"dr",discard,"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@"
	.globl	"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@" # @"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@"
	.p2align	3, 0x0
"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@":
	.asciz	"ILLEGAL_INSTRUCTION"

	.section	.rdata,"dr",discard,"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@"
	.globl	"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@" # @"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@"
	.p2align	3, 0x0
"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@":
	.asciz	"ARRAY_BOUNDS_EXCEEDED"

	.section	.rdata,"dr",discard,"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@"
	.globl	"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@" # @"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@"
	.p2align	3, 0x0
"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@":
	.asciz	"FLT_DIVIDE_BY_ZERO"

	.section	.rdata,"dr",discard,"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@"
	.globl	"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@" # @"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@"
	.p2align	3, 0x0
"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@":
	.asciz	"FLT_INVALID_OPERATION"

	.section	.rdata,"dr",discard,"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@"
	.globl	"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@" # @"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@"
	.p2align	3, 0x0
"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@":
	.asciz	"INT_DIVIDE_BY_ZERO"

	.section	.rdata,"dr",discard,"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@"
	.globl	"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@" # @"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@"
	.p2align	3, 0x0
"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@":
	.asciz	"INTEGER_OVERFLOW"

	.section	.rdata,"dr",discard,"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@"
	.globl	"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@" # @"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@"
	.p2align	3, 0x0
"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@":
	.asciz	"PRIVILEGED_INSTRUCTION"

	.section	.rdata,"dr",discard,"??_C@_0L@PBPBANKG@exception?5?$AA@"
	.globl	"??_C@_0L@PBPBANKG@exception?5?$AA@" # @"??_C@_0L@PBPBANKG@exception?5?$AA@"
	.p2align	3, 0x0
"??_C@_0L@PBPBANKG@exception?5?$AA@":
	.asciz	"exception "

	.section	.rdata,"dr",discard,"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@"
	.globl	"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@" # @"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@"
	.p2align	3, 0x0
"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@":
	.asciz	"  <no frames>\n"

	.section	.rdata,"dr",discard,"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@"
	.globl	"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@" # @"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@"
	.p2align	3, 0x0
"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@":
	.asciz	"  stack:\n"

	.section	.rdata,"dr",discard,"??_C@_03PIGNLOFM@?5?5?$CD?$AA@"
	.globl	"??_C@_03PIGNLOFM@?5?5?$CD?$AA@" # @"??_C@_03PIGNLOFM@?5?5?$CD?$AA@"
	.p2align	2, 0x0
"??_C@_03PIGNLOFM@?5?5?$CD?$AA@":
	.asciz	"  #"

	.section	.rdata,"dr",discard,"??_C@_01CLKCMJKC@?5?$AA@"
	.globl	"??_C@_01CLKCMJKC@?5?$AA@"      # @"??_C@_01CLKCMJKC@?5?$AA@"
	.p2align	2, 0x0
"??_C@_01CLKCMJKC@?5?$AA@":
	.asciz	" "

	.section	.rdata,"dr",discard,"??_C@_01EEMJAFIK@?6?$AA@"
	.globl	"??_C@_01EEMJAFIK@?6?$AA@"      # @"??_C@_01EEMJAFIK@?6?$AA@"
	.p2align	2, 0x0
"??_C@_01EEMJAFIK@?6?$AA@":
	.asciz	"\n"

	.section	.rdata,"dr",discard,"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@"
	.globl	"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@" # @"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@"
	.p2align	3, 0x0
"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@":
	.asciz	"coral: out of memory\n"

	.section	.rdata,"dr",discard,"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@"
	.globl	"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@" # @"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@"
	.p2align	4, 0x0
"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@":
	.asciz	"  the compiler could not allocate memory; try coralc --explain D0003\n"

	.section	.rdata,"dr",discard,"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	.globl	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@" # @"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@":
	.asciz	"\ncoral: error: "

	.section	.rdata,"dr",discard,"??_C@_02GFKOMOKH@?5?$CI?$AA@"
	.globl	"??_C@_02GFKOMOKH@?5?$CI?$AA@"  # @"??_C@_02GFKOMOKH@?5?$CI?$AA@"
	.p2align	2, 0x0
"??_C@_02GFKOMOKH@?5?$CI?$AA@":
	.asciz	" ("

	.section	.rdata,"dr",discard,"??_C@_03MHLONNLM@?5?$DN?5?$AA@"
	.globl	"??_C@_03MHLONNLM@?5?$DN?5?$AA@" # @"??_C@_03MHLONNLM@?5?$DN?5?$AA@"
	.p2align	2, 0x0
"??_C@_03MHLONNLM@?5?$DN?5?$AA@":
	.asciz	" = "

	.section	.rdata,"dr",discard,"??_C@_02MNMNLDAI@?$CJ?6?$AA@"
	.globl	"??_C@_02MNMNLDAI@?$CJ?6?$AA@"  # @"??_C@_02MNMNLDAI@?$CJ?6?$AA@"
	.p2align	2, 0x0
"??_C@_02MNMNLDAI@?$CJ?6?$AA@":
	.asciz	")\n"

	.section	.rdata,"dr",discard,"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@"
	.globl	"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@" # @"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@"
	.p2align	3, 0x0
"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@":
	.asciz	"assertion failed"

	.section	.rdata,"dr",discard,"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@"
	.globl	"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@" # @"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@":
	.asciz	"\ncoral: error: assert "

	.section	.rdata,"dr",discard,"??_C@_09FIOGNGMI@?5failed?3?5?$AA@"
	.globl	"??_C@_09FIOGNGMI@?5failed?3?5?$AA@" # @"??_C@_09FIOGNGMI@?5failed?3?5?$AA@"
	.p2align	3, 0x0
"??_C@_09FIOGNGMI@?5failed?3?5?$AA@":
	.asciz	" failed: "

	.section	.rdata,"dr",discard,"??_C@_02LMMGGCAJ@?3?5?$AA@"
	.globl	"??_C@_02LMMGGCAJ@?3?5?$AA@"    # @"??_C@_02LMMGGCAJ@?3?5?$AA@"
	.p2align	2, 0x0
"??_C@_02LMMGGCAJ@?3?5?$AA@":
	.asciz	": "

	.section	.rdata,"dr",discard,"??_C@_02EGOFBIJA@?$DN?$DN?$AA@"
	.globl	"??_C@_02EGOFBIJA@?$DN?$DN?$AA@" # @"??_C@_02EGOFBIJA@?$DN?$DN?$AA@"
	.p2align	2, 0x0
"??_C@_02EGOFBIJA@?$DN?$DN?$AA@":
	.asciz	"=="

	.section	.rdata,"dr",discard,"??_C@_02FDNJECIE@?$CB?$DN?$AA@"
	.globl	"??_C@_02FDNJECIE@?$CB?$DN?$AA@" # @"??_C@_02FDNJECIE@?$CB?$DN?$AA@"
	.p2align	2, 0x0
"??_C@_02FDNJECIE@?$CB?$DN?$AA@":
	.asciz	"!="

	.section	.rdata,"dr",discard,"??_C@_01MNNFJEPP@?$DM?$AA@"
	.globl	"??_C@_01MNNFJEPP@?$DM?$AA@"    # @"??_C@_01MNNFJEPP@?$DM?$AA@"
	.p2align	2, 0x0
"??_C@_01MNNFJEPP@?$DM?$AA@":
	.asciz	"<"

	.section	.rdata,"dr",discard,"??_C@_02EHCHHCKH@?$DM?$DN?$AA@"
	.globl	"??_C@_02EHCHHCKH@?$DM?$DN?$AA@" # @"??_C@_02EHCHHCKH@?$DM?$DN?$AA@"
	.p2align	2, 0x0
"??_C@_02EHCHHCKH@?$DM?$DN?$AA@":
	.asciz	"<="

	.section	.rdata,"dr",discard,"??_C@_01PPODPGHN@?$DO?$AA@"
	.globl	"??_C@_01PPODPGHN@?$DO?$AA@"    # @"??_C@_01PPODPGHN@?$DO?$AA@"
	.p2align	2, 0x0
"??_C@_01PPODPGHN@?$DO?$AA@":
	.asciz	">"

	.section	.rdata,"dr",discard,"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@"
	.globl	"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@" # @"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@"
	.p2align	2, 0x0
"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@":
	.asciz	">="

	.section	.rdata,"dr",discard,"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@"
	.globl	"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@" # @"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@":
	.asciz	"\ncoral: error: index "

	.section	.rdata,"dr",discard,"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@"
	.globl	"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@" # @"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@":
	.asciz	" out of bounds for length "

	.section	.rdata,"dr",discard,"??_C@_07PFMCDPMA@pointer?$AA@"
	.globl	"??_C@_07PFMCDPMA@pointer?$AA@" # @"??_C@_07PFMCDPMA@pointer?$AA@"
	.p2align	3, 0x0
"??_C@_07PFMCDPMA@pointer?$AA@":
	.asciz	"pointer"

	.lcomm	crl__lib__std__x86_64__windows__error___handling,1 # @crl__lib__std__x86_64__windows__error___handling
	.section	.rdata,"dr",discard,"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@"
	.globl	"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@" # @"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@":
	.asciz	"\ncoral: fatal: "

	.section	.debug$S,"dr"
	.p2align	2, 0x0
	.long	4                               # Debug section magic
	.long	241
	.long	.Ltmp1-.Ltmp0                   # Subsection size
.Ltmp0:
	.short	.Ltmp3-.Ltmp2                   # Record length
.Ltmp2:
	.short	4353                            # Record kind: S_OBJNAME
	.long	0                               # Signature
	.byte	0                               # Object name
	.p2align	2, 0x0
.Ltmp3:
	.short	.Ltmp5-.Ltmp4                   # Record length
.Ltmp4:
	.short	4412                            # Record kind: S_COMPILE3
	.long	0                               # Flags and language
	.short	208                             # CPUType
	.short	23                              # Frontend version
	.short	1
	.short	3
	.short	0
	.short	23013                           # Backend version
	.short	0
	.short	0
	.short	0
	.asciz	"clang version 23.1.3"          # Null-terminated compiler version string
	.p2align	2, 0x0
.Ltmp5:
.Ltmp1:
	.p2align	2, 0x0
	.addrsig
	.addrsig_sym GetCurrentProcess
	.addrsig_sym crl__lib__std__x86_64__windows__error___excFilter

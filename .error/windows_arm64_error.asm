	.def	"@feat.00";
	.scl	3;
	.type	0;
	.endef
	.globl	"@feat.00"
"@feat.00" = 0
	.file	"error.c"
	.def	crl__lib__std__x86_64__windows__error___wr;
	.scl	2;
	.type	32;
	.endef
	.text
	.globl	crl__lib__std__x86_64__windows__error___wr // -- Begin function crl__lib__std__x86_64__windows__error___wr
	.p2align	2
crl__lib__std__x86_64__windows__error___wr: // @crl__lib__std__x86_64__windows__error___wr
// %bb.0:
	b	write
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error___wrHex;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___wrHex // -- Begin function crl__lib__std__x86_64__windows__error___wrHex
	.p2align	2
crl__lib__std__x86_64__windows__error___wrHex: // @crl__lib__std__x86_64__windows__error___wrHex
.seh_proc crl__lib__std__x86_64__windows__error___wrHex
// %bb.0:
	stp	x19, x20, [sp, #-48]!           // 16-byte Folded Spill
	.seh_save_regp_x	x19, 48
	stp	x21, x22, [sp, #16]             // 16-byte Folded Spill
	.seh_save_regp	x21, 16
	str	x30, [sp, #32]                  // 8-byte Spill
	.seh_save_reg	x30, 32
	.seh_endprologue
	mov	x20, x1
	adrp	x1, "??_C@_02MDDDDAID@0x?$AA@"
	add	x1, x1, :lo12:"??_C@_02MDDDDAID@0x?$AA@"
	mov	w2, #2                          // =0x2
	mov	w19, w0
	bl	write
	lsr	x21, x20, #60
	cbz	x21, .LBB1_2
// %bb.1:
	lsr	x8, x20, #61
	orr	w9, w21, #0x30
	add	w10, w21, #87
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	cmp	x8, #5
	csel	w8, w9, w10, lo
	strb	w8, [sp, #47]
	bl	write
.LBB1_2:
	lsr	x8, x20, #56
	cmp	x21, #0
	cset	w9, ne
	ands	w8, w8, #0xf
	csinc	w21, w9, wzr, eq
	cbnz	w21, .LBB1_18
// %bb.3:
	lsr	x8, x20, #52
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_19
.LBB1_4:
	lsr	x8, x20, #48
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_20
.LBB1_5:
	lsr	x8, x20, #44
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_21
.LBB1_6:
	lsr	x8, x20, #40
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_22
.LBB1_7:
	lsr	x8, x20, #36
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_23
.LBB1_8:
	lsr	x8, x20, #32
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_24
.LBB1_9:
	lsr	w8, w20, #28
	cmp	w8, #0
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_25
.LBB1_10:
	mov	w22, #15                        // =0xf
	ands	w8, w22, w20, lsr #24
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_26
.LBB1_11:
	ands	w8, w22, w20, lsr #20
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_27
.LBB1_12:
	mov	w22, #15                        // =0xf
	ands	w8, w22, w20, lsr #16
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_28
.LBB1_13:
	ands	w8, w22, w20, lsr #12
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_29
.LBB1_14:
	mov	w22, #15                        // =0xf
	ands	w8, w22, w20, lsr #8
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_30
.LBB1_15:
	ands	w8, w22, w20, lsr #4
	cset	w9, eq
	bic	w9, w9, w21
	tbnz	w9, #0, .LBB1_17
.LBB1_16:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
.LBB1_17:
	mov	w8, #48                         // =0x30
	and	w9, w20, #0xf
	add	x1, sp, #47
	bfxil	w8, w20, #0, #4
	add	w10, w9, #87
	cmp	w9, #10
	mov	w0, w19
	mov	w2, #1                          // =0x1
	csel	w8, w8, w10, lo
	strb	w8, [sp, #47]
	bl	write
	.seh_startepilogue
	ldr	x30, [sp, #32]                  // 8-byte Reload
	.seh_save_reg	x30, 32
	ldp	x21, x22, [sp, #16]             // 16-byte Folded Reload
	.seh_save_regp	x21, 16
	ldp	x19, x20, [sp], #48             // 16-byte Folded Reload
	.seh_save_regp_x	x19, 48
	.seh_endepilogue
	ret
.LBB1_18:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	lsr	x8, x20, #52
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_4
.LBB1_19:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	lsr	x8, x20, #48
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_5
.LBB1_20:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	lsr	x8, x20, #44
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_6
.LBB1_21:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	lsr	x8, x20, #40
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_7
.LBB1_22:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	lsr	x8, x20, #36
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_8
.LBB1_23:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	lsr	x8, x20, #32
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_9
.LBB1_24:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	lsr	w8, w20, #28
	cmp	w8, #0
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_10
.LBB1_25:
	lsr	w9, w20, #29
	orr	w10, w8, #0x30
	add	w8, w8, #87
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	cmp	w9, #5
	csel	w8, w10, w8, lo
	strb	w8, [sp, #47]
	bl	write
	mov	w22, #15                        // =0xf
	ands	w8, w22, w20, lsr #24
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_11
.LBB1_26:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	ands	w8, w22, w20, lsr #20
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_12
.LBB1_27:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	mov	w22, #15                        // =0xf
	ands	w8, w22, w20, lsr #16
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_13
.LBB1_28:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	ands	w8, w22, w20, lsr #12
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_14
.LBB1_29:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	mov	w22, #15                        // =0xf
	ands	w8, w22, w20, lsr #8
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_15
.LBB1_30:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #47
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #47]
	bl	write
	ands	w8, w22, w20, lsr #4
	cset	w9, eq
	bic	w9, w9, w21
	tbz	w9, #0, .LBB1_16
	b	.LBB1_17
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error___wrDec;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___wrDec // -- Begin function crl__lib__std__x86_64__windows__error___wrDec
	.p2align	2
crl__lib__std__x86_64__windows__error___wrDec: // @crl__lib__std__x86_64__windows__error___wrDec
.seh_proc crl__lib__std__x86_64__windows__error___wrDec
// %bb.0:
	sub	sp, sp, #64
	.seh_stackalloc	64
	stp	x19, x20, [sp, #32]             // 16-byte Folded Spill
	.seh_save_regp	x19, 32
	stp	x21, x30, [sp, #48]             // 16-byte Folded Spill
	.seh_save_lrpair	x21, 48
	.seh_endprologue
	mov	w19, w0
	cbz	x1, .LBB2_7
// %bb.1:
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	mov	w20, wzr
	mov	w9, #10                         // =0xa
	movk	x8, #52429
	add	x10, sp, #8
	stp	xzr, xzr, [sp, #8]
	str	wzr, [sp, #24]
.LBB2_2:                                // =>This Inner Loop Header: Depth=1
	umulh	x11, x1, x8
	cmp	x1, #10
	lsr	x11, x11, #3
	msub	w12, w11, w9, w1
	mov	x1, x11
	orr	w12, w12, #0x30
	strb	w12, [x10, w20, sxtw]
	add	w20, w20, #1
	b.hs	.LBB2_2
// %bb.3:
	sub	w8, w20, #1
	mov	w9, #2147483646                 // =0x7ffffffe
	cmp	w8, w9
	b.hi	.LBB2_6
// %bb.4:
	add	x8, sp, #8
	sub	x21, x8, #1
.LBB2_5:                                // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x21, x20]
	add	x1, sp, #7
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #7]
	bl	write
	subs	x20, x20, #1
	b.hi	.LBB2_5
.LBB2_6:
	.seh_startepilogue
	ldp	x21, x30, [sp, #48]             // 16-byte Folded Reload
	.seh_save_lrpair	x21, 48
	ldp	x19, x20, [sp, #32]             // 16-byte Folded Reload
	.seh_save_regp	x19, 32
	add	sp, sp, #64
	.seh_stackalloc	64
	.seh_endepilogue
	ret
.LBB2_7:
	adrp	x1, "??_C@_01GBGANLPD@0?$AA@"
	add	x1, x1, :lo12:"??_C@_01GBGANLPD@0?$AA@"
	mov	w0, w19
	mov	w2, #1                          // =0x1
	.seh_startepilogue
	ldp	x21, x30, [sp, #48]             // 16-byte Folded Reload
	.seh_save_lrpair	x21, 48
	ldp	x19, x20, [sp, #32]             // 16-byte Folded Reload
	.seh_save_regp	x19, 32
	add	sp, sp, #64
	.seh_stackalloc	64
	.seh_endepilogue
	b	write
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error___wrExcName;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___wrExcName // -- Begin function crl__lib__std__x86_64__windows__error___wrExcName
	.p2align	2
crl__lib__std__x86_64__windows__error___wrExcName: // @crl__lib__std__x86_64__windows__error___wrExcName
.seh_proc crl__lib__std__x86_64__windows__error___wrExcName
// %bb.0:
	stp	x19, x20, [sp, #-32]!           // 16-byte Folded Spill
	.seh_save_regp_x	x19, 32
	str	x30, [sp, #16]                  // 8-byte Spill
	.seh_save_reg	x30, 16
	.seh_endprologue
	adrp	x8, .L_MergedGlobals
	ldr	w8, [x8, :lo12:.L_MergedGlobals]
	cmp	w1, w8
	b.ne	.LBB3_3
// %bb.1:
	adrp	x1, "??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@"
	add	x1, x1, :lo12:"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@"
.LBB3_2:
	mov	w2, #16                         // =0x10
	b	.LBB3_12
.LBB3_3:
	adrp	x8, .L_MergedGlobals+4
	ldr	w8, [x8, :lo12:.L_MergedGlobals+4]
	cmp	w1, w8
	b.ne	.LBB3_5
// %bb.4:
	adrp	x1, "??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@"
	add	x1, x1, :lo12:"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@"
	mov	w2, #19                         // =0x13
	b	.LBB3_12
.LBB3_5:
	adrp	x8, .L_MergedGlobals+8
	ldr	w8, [x8, :lo12:.L_MergedGlobals+8]
	cmp	w1, w8
	b.ne	.LBB3_7
// %bb.6:
	adrp	x1, "??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@"
	add	x1, x1, :lo12:"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@"
	mov	w2, #21                         // =0x15
	b	.LBB3_12
.LBB3_7:
	adrp	x8, .L_MergedGlobals+12
	ldr	w8, [x8, :lo12:.L_MergedGlobals+12]
	cmp	w1, w8
	b.ne	.LBB3_10
// %bb.8:
	adrp	x1, "??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@"
	add	x1, x1, :lo12:"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@"
.LBB3_9:
	mov	w2, #18                         // =0x12
	b	.LBB3_12
.LBB3_10:
	adrp	x8, .L_MergedGlobals+16
	ldr	w8, [x8, :lo12:.L_MergedGlobals+16]
	cmp	w1, w8
	b.ne	.LBB3_13
// %bb.11:
	adrp	x1, "??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@"
	add	x1, x1, :lo12:"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@"
	mov	w2, #21                         // =0x15
.LBB3_12:
	.seh_startepilogue
	ldr	x30, [sp, #16]                  // 8-byte Reload
	.seh_save_reg	x30, 16
	ldp	x19, x20, [sp], #32             // 16-byte Folded Reload
	.seh_save_regp_x	x19, 32
	.seh_endepilogue
	b	write
.LBB3_13:
	adrp	x8, .L_MergedGlobals+20
	ldr	w8, [x8, :lo12:.L_MergedGlobals+20]
	cmp	w1, w8
	b.ne	.LBB3_15
// %bb.14:
	adrp	x1, "??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@"
	add	x1, x1, :lo12:"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@"
	b	.LBB3_9
.LBB3_15:
	adrp	x8, .L_MergedGlobals+24
	ldr	w8, [x8, :lo12:.L_MergedGlobals+24]
	cmp	w1, w8
	b.ne	.LBB3_17
// %bb.16:
	adrp	x1, "??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@"
	add	x1, x1, :lo12:"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@"
	b	.LBB3_2
.LBB3_17:
	adrp	x8, .L_MergedGlobals+28
	ldr	w8, [x8, :lo12:.L_MergedGlobals+28]
	cmp	w1, w8
	b.ne	.LBB3_19
// %bb.18:
	adrp	x1, "??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@"
	add	x1, x1, :lo12:"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@"
	mov	w2, #22                         // =0x16
	b	.LBB3_12
.LBB3_19:
	adrp	x8, "??_C@_0L@PBPBANKG@exception?5?$AA@"
	add	x8, x8, :lo12:"??_C@_0L@PBPBANKG@exception?5?$AA@"
	mov	w20, w1
	mov	x1, x8
	mov	w2, #10                         // =0xa
	mov	w19, w0
	bl	write
	mov	w1, w20
	mov	w0, w19
	.seh_startepilogue
	ldr	x30, [sp, #16]                  // 8-byte Reload
	.seh_save_reg	x30, 16
	ldp	x19, x20, [sp], #32             // 16-byte Folded Reload
	.seh_save_regp_x	x19, 32
	.seh_endepilogue
	b	crl__lib__std__x86_64__windows__error___wrHex
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____backtraceTo;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____backtraceTo // -- Begin function crl__lib__std__x86_64__windows__error____backtraceTo
	.p2align	2
crl__lib__std__x86_64__windows__error____backtraceTo: // @crl__lib__std__x86_64__windows__error____backtraceTo
.seh_proc crl__lib__std__x86_64__windows__error____backtraceTo
// %bb.0:
	sub	sp, sp, #400
	.seh_stackalloc	400
	stp	x19, x20, [sp, #304]            // 16-byte Folded Spill
	.seh_save_regp	x19, 304
	stp	x21, x22, [sp, #320]            // 16-byte Folded Spill
	.seh_save_regp	x21, 320
	stp	x23, x24, [sp, #336]            // 16-byte Folded Spill
	.seh_save_regp	x23, 336
	stp	x25, x26, [sp, #352]            // 16-byte Folded Spill
	.seh_save_regp	x25, 352
	stp	x27, x28, [sp, #368]            // 16-byte Folded Spill
	.seh_save_regp	x27, 368
	str	x30, [sp, #384]                 // 8-byte Spill
	.seh_save_reg	x30, 384
	.seh_endprologue
	movi	v0.2d, #0000000000000000
	mov	w19, w0
	add	x8, sp, #16
	add	x2, sp, #16
	add	x3, sp, #12
	mov	w0, wzr
	mov	w1, #32                         // =0x20
	str	wzr, [sp, #12]
	stp	q0, q0, [x8, #128]
	stp	q0, q0, [x8, #160]
	stp	q0, q0, [x8, #192]
	stp	q0, q0, [x8, #224]
	stp	q0, q0, [sp, #16]
	stp	q0, q0, [sp, #48]
	stp	q0, q0, [sp, #80]
	stp	q0, q0, [sp, #112]
	bl	CaptureStackBackTrace
	cbz	w0, .LBB4_46
// %bb.1:
	mov	w22, w0
	adrp	x1, "??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@"
	add	x1, x1, :lo12:"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@"
	mov	w0, w19
	mov	w2, #9                          // =0x9
	bl	write
	add	x21, sp, #280
	mov	x20, #-3689348814741910324      // =0xcccccccccccccccc
	mov	x27, xzr
	mov	w28, w22
	sub	x26, x21, #1
	movk	x20, #52429
	mov	w22, #10                        // =0xa
	b	.LBB4_4
.LBB4_2:                                //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	bl	write
.LBB4_3:                                //   in Loop: Header=BB4_4 Depth=1
	mov	w8, #48                         // =0x30
	and	w9, w23, #0xf
	add	x1, sp, #280
	bfxil	w8, w23, #0, #4
	add	w10, w9, #87
	cmp	w9, #10
	mov	w0, w19
	mov	w2, #1                          // =0x1
	csel	w8, w8, w10, lo
	strb	w8, [sp, #280]
	bl	write
	mov	w0, w19
	adrp	x1, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x1, x1, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w2, #1                          // =0x1
	bl	write
	add	x27, x27, #1
	cmp	x27, x28
	b.eq	.LBB4_47
.LBB4_4:                                // =>This Loop Header: Depth=1
                                        //     Child Loop BB4_6 Depth 2
                                        //     Child Loop BB4_8 Depth 2
	mov	w0, w19
	adrp	x1, "??_C@_03PIGNLOFM@?5?5?$CD?$AA@"
	add	x1, x1, :lo12:"??_C@_03PIGNLOFM@?5?5?$CD?$AA@"
	mov	w2, #3                          // =0x3
	bl	write
	cbz	x27, .LBB4_9
// %bb.5:                               //   in Loop: Header=BB4_4 Depth=1
	add	x8, sp, #16
	mov	w23, wzr
	str	wzr, [sp, #296]
	stp	xzr, xzr, [x8, #264]
	mov	x8, x27
.LBB4_6:                                //   Parent Loop BB4_4 Depth=1
                                        // =>  This Inner Loop Header: Depth=2
	umulh	x9, x8, x20
	cmp	x8, #10
	lsr	x9, x9, #3
	msub	w10, w9, w22, w8
	orr	w8, w10, #0x30
	strb	w8, [x21, w23, sxtw]
	add	w23, w23, #1
	mov	x8, x9
	b.hs	.LBB4_6
// %bb.7:                               //   in Loop: Header=BB4_4 Depth=1
	sub	w8, w23, #1
	mov	w9, #2147483646                 // =0x7ffffffe
	cmp	w8, w9
	b.hi	.LBB4_10
.LBB4_8:                                //   Parent Loop BB4_4 Depth=1
                                        // =>  This Inner Loop Header: Depth=2
	ldrb	w8, [x26, x23]
	add	x1, sp, #279
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #279]
	bl	write
	subs	x23, x23, #1
	b.hi	.LBB4_8
	b	.LBB4_10
.LBB4_9:                                //   in Loop: Header=BB4_4 Depth=1
	mov	w0, w19
	adrp	x1, "??_C@_01GBGANLPD@0?$AA@"
	add	x1, x1, :lo12:"??_C@_01GBGANLPD@0?$AA@"
	mov	w2, #1                          // =0x1
	bl	write
.LBB4_10:                               //   in Loop: Header=BB4_4 Depth=1
	mov	w0, w19
	adrp	x1, "??_C@_01CLKCMJKC@?5?$AA@"
	add	x1, x1, :lo12:"??_C@_01CLKCMJKC@?5?$AA@"
	mov	w2, #1                          // =0x1
	bl	write
	add	x8, sp, #16
	mov	w0, w19
	adrp	x1, "??_C@_02MDDDDAID@0x?$AA@"
	add	x1, x1, :lo12:"??_C@_02MDDDDAID@0x?$AA@"
	ldr	x23, [x8, x27, lsl #3]
	mov	w2, #2                          // =0x2
	bl	write
	lsr	x8, x23, #60
	cbz	x8, .LBB4_12
// %bb.11:                              //   in Loop: Header=BB4_4 Depth=1
	lsr	x9, x23, #61
	orr	w10, w8, #0x30
	add	w8, w8, #87
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	cmp	x9, #5
	csel	w8, w10, w8, lo
	strb	w8, [sp, #280]
	bl	write
	ubfx	x8, x23, #56, #4
                                        // kill: def $w8 killed $w8 killed $x8 def $x8
	b	.LBB4_13
.LBB4_12:                               //   in Loop: Header=BB4_4 Depth=1
	lsr	x8, x23, #56
	cbz	x8, .LBB4_17
.LBB4_13:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	mov	w25, #1                         // =0x1
	bl	write
	ubfx	x8, x23, #52, #4
	ubfx	x24, x23, #48, #4
	tbnz	w25, #0, .LBB4_18
.LBB4_14:                               //   in Loop: Header=BB4_4 Depth=1
	cbnz	w8, .LBB4_18
// %bb.15:                              //   in Loop: Header=BB4_4 Depth=1
	cbnz	w24, .LBB4_19
// %bb.16:                              //   in Loop: Header=BB4_4 Depth=1
	mov	w25, wzr
	ubfx	x8, x23, #44, #4
	ubfx	x24, x23, #40, #4
	tbz	w25, #0, .LBB4_20
	b	.LBB4_23
.LBB4_17:                               //   in Loop: Header=BB4_4 Depth=1
	mov	w25, wzr
	ubfx	x8, x23, #52, #4
	ubfx	x24, x23, #48, #4
	tbz	w25, #0, .LBB4_14
.LBB4_18:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	bl	write
.LBB4_19:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w8, w24, #0x30
	add	w9, w24, #87
	cmp	w24, #10
	csel	w8, w8, w9, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	mov	w25, #1                         // =0x1
	bl	write
	ubfx	x8, x23, #44, #4
	ubfx	x24, x23, #40, #4
	tbnz	w25, #0, .LBB4_23
.LBB4_20:                               //   in Loop: Header=BB4_4 Depth=1
	cbnz	w8, .LBB4_23
// %bb.21:                              //   in Loop: Header=BB4_4 Depth=1
	cbnz	w24, .LBB4_24
// %bb.22:                              //   in Loop: Header=BB4_4 Depth=1
	mov	w25, wzr
	ubfx	x8, x23, #36, #4
	ubfx	x24, x23, #32, #4
	tbz	w25, #0, .LBB4_25
	b	.LBB4_28
.LBB4_23:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	bl	write
.LBB4_24:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w8, w24, #0x30
	add	w9, w24, #87
	cmp	w24, #10
	csel	w8, w8, w9, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	mov	w25, #1                         // =0x1
	bl	write
	ubfx	x8, x23, #36, #4
	ubfx	x24, x23, #32, #4
	tbnz	w25, #0, .LBB4_28
.LBB4_25:                               //   in Loop: Header=BB4_4 Depth=1
	cbnz	w8, .LBB4_28
// %bb.26:                              //   in Loop: Header=BB4_4 Depth=1
	cbnz	w24, .LBB4_29
// %bb.27:                              //   in Loop: Header=BB4_4 Depth=1
	lsr	w8, w23, #28
	tbz	w24, #0, .LBB4_30
	b	.LBB4_33
.LBB4_28:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	bl	write
.LBB4_29:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w8, w24, #0x30
	add	w9, w24, #87
	cmp	w24, #10
	csel	w8, w8, w9, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	mov	w24, #1                         // =0x1
	bl	write
	lsr	w8, w23, #28
	tbnz	w24, #0, .LBB4_33
.LBB4_30:                               //   in Loop: Header=BB4_4 Depth=1
	cbnz	w8, .LBB4_33
// %bb.31:                              //   in Loop: Header=BB4_4 Depth=1
	ubfx	w8, w23, #24, #4
	cbnz	w8, .LBB4_34
// %bb.32:                              //   in Loop: Header=BB4_4 Depth=1
	mov	w24, wzr
	ubfx	w8, w23, #20, #4
	tbz	w24, #0, .LBB4_35
	b	.LBB4_38
.LBB4_33:                               //   in Loop: Header=BB4_4 Depth=1
	lsr	w9, w23, #29
	orr	w10, w8, #0x30
	add	w8, w8, #87
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	cmp	w9, #5
	csel	w8, w10, w8, lo
	strb	w8, [sp, #280]
	bl	write
	ubfx	w8, w23, #24, #4
.LBB4_34:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	mov	w24, #1                         // =0x1
	bl	write
	ubfx	w8, w23, #20, #4
	tbnz	w24, #0, .LBB4_38
.LBB4_35:                               //   in Loop: Header=BB4_4 Depth=1
	cbnz	w8, .LBB4_38
// %bb.36:                              //   in Loop: Header=BB4_4 Depth=1
	ubfx	w8, w23, #16, #4
	cbnz	w8, .LBB4_39
// %bb.37:                              //   in Loop: Header=BB4_4 Depth=1
	mov	w24, wzr
	ubfx	w8, w23, #12, #4
	tbz	w24, #0, .LBB4_40
	b	.LBB4_43
.LBB4_38:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	bl	write
	ubfx	w8, w23, #16, #4
.LBB4_39:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	mov	w24, #1                         // =0x1
	bl	write
	ubfx	w8, w23, #12, #4
	tbnz	w24, #0, .LBB4_43
.LBB4_40:                               //   in Loop: Header=BB4_4 Depth=1
	cbnz	w8, .LBB4_43
// %bb.41:                              //   in Loop: Header=BB4_4 Depth=1
	ubfx	w8, w23, #8, #4
	cbnz	w8, .LBB4_44
// %bb.42:                              //   in Loop: Header=BB4_4 Depth=1
	mov	w24, wzr
	ubfx	w8, w23, #4, #4
	tbz	w24, #0, .LBB4_45
	b	.LBB4_2
.LBB4_43:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	bl	write
	ubfx	w8, w23, #8, #4
.LBB4_44:                               //   in Loop: Header=BB4_4 Depth=1
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #280
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #280]
	mov	w24, #1                         // =0x1
	bl	write
	ubfx	w8, w23, #4, #4
	tbnz	w24, #0, .LBB4_2
.LBB4_45:                               //   in Loop: Header=BB4_4 Depth=1
	cbz	w8, .LBB4_3
	b	.LBB4_2
.LBB4_46:
	adrp	x1, "??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@"
	add	x1, x1, :lo12:"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@"
	mov	w0, w19
	mov	w2, #14                         // =0xe
	bl	write
.LBB4_47:
	.seh_startepilogue
	ldr	x30, [sp, #384]                 // 8-byte Reload
	.seh_save_reg	x30, 384
	ldp	x27, x28, [sp, #368]            // 16-byte Folded Reload
	.seh_save_regp	x27, 368
	ldp	x25, x26, [sp, #352]            // 16-byte Folded Reload
	.seh_save_regp	x25, 352
	ldp	x23, x24, [sp, #336]            // 16-byte Folded Reload
	.seh_save_regp	x23, 336
	ldp	x21, x22, [sp, #320]            // 16-byte Folded Reload
	.seh_save_regp	x21, 320
	ldp	x19, x20, [sp, #304]            // 16-byte Folded Reload
	.seh_save_regp	x19, 304
	add	sp, sp, #400
	.seh_stackalloc	400
	.seh_endepilogue
	ret
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____abortNow;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____abortNow // -- Begin function crl__lib__std__x86_64__windows__error____abortNow
	.p2align	2
crl__lib__std__x86_64__windows__error____abortNow: // @crl__lib__std__x86_64__windows__error____abortNow
.seh_proc crl__lib__std__x86_64__windows__error____abortNow
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.seh_save_reg_x	x30, 16
	.seh_endprologue
	adrp	x0, GetCurrentProcess
	add	x0, x0, :lo12:GetCurrentProcess
	mov	w1, #134                        // =0x86
	bl	TerminateProcess
	mov	w0, #134                        // =0x86
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____oomFatal;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____oomFatal // -- Begin function crl__lib__std__x86_64__windows__error____oomFatal
	.p2align	2
crl__lib__std__x86_64__windows__error____oomFatal: // @crl__lib__std__x86_64__windows__error____oomFatal
.seh_proc crl__lib__std__x86_64__windows__error____oomFatal
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.seh_save_reg_x	x30, 16
	.seh_endprologue
	adrp	x1, "??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@"
	add	x1, x1, :lo12:"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #21                         // =0x15
	bl	crl__lib__std__x86_64__windows__error___wr
	adrp	x1, "??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@"
	add	x1, x1, :lo12:"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@"
	mov	w0, #2                          // =0x2
	mov	w2, #69                         // =0x45
	bl	crl__lib__std__x86_64__windows__error___wr
	mov	w0, #2                          // =0x2
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____report;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____report // -- Begin function crl__lib__std__x86_64__windows__error____report
	.p2align	2
crl__lib__std__x86_64__windows__error____report: // @crl__lib__std__x86_64__windows__error____report
.seh_proc crl__lib__std__x86_64__windows__error____report
// %bb.0:
	stp	x19, x20, [sp, #-32]!           // 16-byte Folded Spill
	.seh_save_regp_x	x19, 32
	str	x30, [sp, #16]                  // 8-byte Spill
	.seh_save_reg	x30, 16
	.seh_endprologue
	mov	x19, x1
	mov	x20, x0
	adrp	x1, "??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	add	x1, x1, :lo12:"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #15                         // =0xf
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x20
	mov	x2, x19
	bl	write
	adrp	x19, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x19, x19, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	.seh_startepilogue
	ldr	x30, [sp, #16]                  // 8-byte Reload
	.seh_save_reg	x30, 16
	ldp	x19, x20, [sp], #32             // 16-byte Folded Reload
	.seh_save_regp_x	x19, 32
	.seh_endepilogue
	b	write
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____reportHex;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____reportHex // -- Begin function crl__lib__std__x86_64__windows__error____reportHex
	.p2align	2
crl__lib__std__x86_64__windows__error____reportHex: // @crl__lib__std__x86_64__windows__error____reportHex
.seh_proc crl__lib__std__x86_64__windows__error____reportHex
// %bb.0:
	sub	sp, sp, #64
	.seh_stackalloc	64
	stp	x19, x20, [sp, #16]             // 16-byte Folded Spill
	.seh_save_regp	x19, 16
	stp	x21, x22, [sp, #32]             // 16-byte Folded Spill
	.seh_save_regp	x21, 32
	stp	x23, x30, [sp, #48]             // 16-byte Folded Spill
	.seh_save_lrpair	x23, 48
	.seh_endprologue
	mov	x21, x2
	mov	x22, x1
	mov	x23, x0
	adrp	x1, "??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	add	x1, x1, :lo12:"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #15                         // =0xf
	mov	x19, x4
	mov	x20, x3
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x23
	mov	x2, x22
	bl	write
	adrp	x1, "??_C@_02GFKOMOKH@?5?$CI?$AA@"
	add	x1, x1, :lo12:"??_C@_02GFKOMOKH@?5?$CI?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x21
	mov	x2, x20
	bl	write
	adrp	x1, "??_C@_03MHLONNLM@?5?$DN?5?$AA@"
	add	x1, x1, :lo12:"??_C@_03MHLONNLM@?5?$DN?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #3                          // =0x3
	bl	write
	adrp	x1, "??_C@_02MDDDDAID@0x?$AA@"
	add	x1, x1, :lo12:"??_C@_02MDDDDAID@0x?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	lsr	x8, x19, #60
	cbz	x8, .LBB8_2
// %bb.1:
	lsr	x9, x19, #61
	orr	w10, w8, #0x30
	add	w8, w8, #87
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	cmp	x9, #5
	csel	w8, w10, w8, lo
	strb	w8, [sp, #15]
	bl	write
	ubfx	x8, x19, #56, #4
                                        // kill: def $w8 killed $w8 killed $x8 def $x8
	b	.LBB8_3
.LBB8_2:
	lsr	x8, x19, #56
	cbz	x8, .LBB8_5
.LBB8_3:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	mov	w20, #1                         // =0x1
	bl	write
	lsr	x8, x19, #52
	ands	w8, w8, #0xf
	csinc	w9, w20, wzr, eq
	cbz	w9, .LBB8_6
.LBB8_4:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	bl	write
	ubfx	x8, x19, #48, #4
                                        // kill: def $w8 killed $w8 killed $x8 def $x8
	b	.LBB8_7
.LBB8_5:
	mov	w20, wzr
	lsr	x8, x19, #52
	ands	w8, w8, #0xf
	csinc	w9, w20, wzr, eq
	cbnz	w9, .LBB8_4
.LBB8_6:
	ubfx	x8, x19, #48, #4
	cbz	w8, .LBB8_9
.LBB8_7:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	mov	w20, #1                         // =0x1
	bl	write
	lsr	x8, x19, #44
	ands	w8, w8, #0xf
	csinc	w9, w20, wzr, eq
	cbz	w9, .LBB8_10
.LBB8_8:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	bl	write
	ubfx	x8, x19, #40, #4
                                        // kill: def $w8 killed $w8 killed $x8 def $x8
	b	.LBB8_11
.LBB8_9:
	mov	w20, wzr
	lsr	x8, x19, #44
	ands	w8, w8, #0xf
	csinc	w9, w20, wzr, eq
	cbnz	w9, .LBB8_8
.LBB8_10:
	ubfx	x8, x19, #40, #4
	cbz	w8, .LBB8_13
.LBB8_11:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	mov	w20, #1                         // =0x1
	bl	write
	lsr	x8, x19, #36
	ands	w8, w8, #0xf
	csinc	w9, w20, wzr, eq
	cbz	w9, .LBB8_14
.LBB8_12:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	bl	write
	ubfx	x8, x19, #32, #4
                                        // kill: def $w8 killed $w8 killed $x8 def $x8
	b	.LBB8_15
.LBB8_13:
	mov	w20, wzr
	lsr	x8, x19, #36
	ands	w8, w8, #0xf
	csinc	w9, w20, wzr, eq
	cbnz	w9, .LBB8_12
.LBB8_14:
	ubfx	x8, x19, #32, #4
	cbz	w8, .LBB8_17
.LBB8_15:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	mov	w20, #1                         // =0x1
	bl	write
	lsr	w8, w19, #28
	cmp	w8, #0
	cset	w9, eq
	bic	w9, w9, w20
	tbnz	w9, #0, .LBB8_18
.LBB8_16:
	lsr	w9, w19, #29
	orr	w10, w8, #0x30
	add	w8, w8, #87
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	cmp	w9, #5
	csel	w8, w10, w8, lo
	strb	w8, [sp, #15]
	bl	write
	ubfx	w8, w19, #24, #4
	b	.LBB8_19
.LBB8_17:
	mov	w20, wzr
	lsr	w8, w19, #28
	cmp	w8, #0
	cset	w9, eq
	bic	w9, w9, w20
	tbz	w9, #0, .LBB8_16
.LBB8_18:
	ubfx	w8, w19, #24, #4
	cbz	w8, .LBB8_26
.LBB8_19:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	bl	write
	ubfx	w8, w19, #20, #4
.LBB8_20:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	bl	write
	ubfx	w8, w19, #16, #4
.LBB8_21:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	bl	write
	ubfx	w8, w19, #12, #4
.LBB8_22:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	bl	write
	ubfx	w8, w19, #8, #4
.LBB8_23:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	bl	write
	ubfx	w8, w19, #4, #4
.LBB8_24:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #15
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #15]
	bl	write
.LBB8_25:
	mov	w8, #48                         // =0x30
	and	w9, w19, #0xf
	add	x1, sp, #15
	bfxil	w8, w19, #0, #4
	add	w10, w9, #87
	cmp	w9, #10
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	csel	w8, w8, w10, lo
	strb	w8, [sp, #15]
	bl	write
	adrp	x1, "??_C@_02MNMNLDAI@?$CJ?6?$AA@"
	add	x1, x1, :lo12:"??_C@_02MNMNLDAI@?$CJ?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	adrp	x1, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x1, x1, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	.seh_startepilogue
	ldp	x23, x30, [sp, #48]             // 16-byte Folded Reload
	.seh_save_lrpair	x23, 48
	ldp	x21, x22, [sp, #32]             // 16-byte Folded Reload
	.seh_save_regp	x21, 32
	ldp	x19, x20, [sp, #16]             // 16-byte Folded Reload
	.seh_save_regp	x19, 16
	add	sp, sp, #64
	.seh_stackalloc	64
	.seh_endepilogue
	ret
.LBB8_26:
	ubfx	w8, w19, #20, #4
	cbnz	w8, .LBB8_20
// %bb.27:
	ubfx	w8, w19, #16, #4
	cbnz	w8, .LBB8_21
// %bb.28:
	ubfx	w8, w19, #12, #4
	cbnz	w8, .LBB8_22
// %bb.29:
	ubfx	w8, w19, #8, #4
	cbnz	w8, .LBB8_23
// %bb.30:
	ubfx	w8, w19, #4, #4
	cbnz	w8, .LBB8_24
	b	.LBB8_25
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____panic;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____panic // -- Begin function crl__lib__std__x86_64__windows__error____panic
	.p2align	2
crl__lib__std__x86_64__windows__error____panic: // @crl__lib__std__x86_64__windows__error____panic
.seh_proc crl__lib__std__x86_64__windows__error____panic
// %bb.0:
	stp	x19, x20, [sp, #-32]!           // 16-byte Folded Spill
	.seh_save_regp_x	x19, 32
	str	x30, [sp, #16]                  // 8-byte Spill
	.seh_save_reg	x30, 16
	.seh_endprologue
	mov	x19, x1
	mov	x20, x0
	adrp	x1, "??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	add	x1, x1, :lo12:"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #15                         // =0xf
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x20
	mov	x2, x19
	bl	write
	adrp	x19, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x19, x19, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x0, GetCurrentProcess
	add	x0, x0, :lo12:GetCurrentProcess
	mov	w1, #134                        // =0x86
	bl	TerminateProcess
	mov	w0, #134                        // =0x86
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____unreachable;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____unreachable // -- Begin function crl__lib__std__x86_64__windows__error____unreachable
	.p2align	2
crl__lib__std__x86_64__windows__error____unreachable: // @crl__lib__std__x86_64__windows__error____unreachable
.seh_proc crl__lib__std__x86_64__windows__error____unreachable
// %bb.0:
	stp	x19, x20, [sp, #-32]!           // 16-byte Folded Spill
	.seh_save_regp_x	x19, 32
	str	x30, [sp, #16]                  // 8-byte Spill
	.seh_save_reg	x30, 16
	.seh_endprologue
	mov	x19, x1
	mov	x20, x0
	adrp	x1, "??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	add	x1, x1, :lo12:"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #15                         // =0xf
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x20
	mov	x2, x19
	bl	write
	adrp	x19, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x19, x19, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x0, GetCurrentProcess
	add	x0, x0, :lo12:GetCurrentProcess
	mov	w1, #134                        // =0x86
	bl	TerminateProcess
	mov	w0, #134                        // =0x86
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assert;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assert // -- Begin function crl__lib__std__x86_64__windows__error____assert
	.p2align	2
crl__lib__std__x86_64__windows__error____assert: // @crl__lib__std__x86_64__windows__error____assert
.seh_proc crl__lib__std__x86_64__windows__error____assert
// %bb.0:
	sub	sp, sp, #16
	.seh_stackalloc	16
	stp	x19, x30, [sp]                  // 16-byte Folded Spill
	.seh_save_lrpair	x19, 0
	.seh_endprologue
	tbz	w0, #0, .LBB11_2
// %bb.1:
	.seh_startepilogue
	ldp	x19, x30, [sp]                  // 16-byte Folded Reload
	.seh_save_lrpair	x19, 0
	add	sp, sp, #16
	.seh_stackalloc	16
	.seh_endepilogue
	ret
.LBB11_2:
	adrp	x1, "??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	add	x1, x1, :lo12:"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #15                         // =0xf
	bl	write
	adrp	x1, "??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@"
	add	x1, x1, :lo12:"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #16                         // =0x10
	bl	write
	adrp	x19, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x19, x19, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x0, GetCurrentProcess
	add	x0, x0, :lo12:GetCurrentProcess
	mov	w1, #134                        // =0x86
	bl	TerminateProcess
	mov	w0, #134                        // =0x86
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertOut;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertOut // -- Begin function crl__lib__std__x86_64__windows__error____assertOut
	.p2align	2
crl__lib__std__x86_64__windows__error____assertOut: // @crl__lib__std__x86_64__windows__error____assertOut
.seh_proc crl__lib__std__x86_64__windows__error____assertOut
// %bb.0:
	stp	x19, x20, [sp, #-32]!           // 16-byte Folded Spill
	.seh_save_regp_x	x19, 32
	str	x30, [sp, #16]                  // 8-byte Spill
	.seh_save_reg	x30, 16
	.seh_endprologue
	tbz	w0, #0, .LBB12_2
// %bb.1:
	.seh_startepilogue
	ldr	x30, [sp, #16]                  // 8-byte Reload
	.seh_save_reg	x30, 16
	ldp	x19, x20, [sp], #32             // 16-byte Folded Reload
	.seh_save_regp_x	x19, 32
	.seh_endepilogue
	ret
.LBB12_2:
	adrp	x8, "??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	add	x8, x8, :lo12:"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	x19, x1
	mov	x1, x8
	mov	x20, x2
	mov	w2, #15                         // =0xf
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	x2, x20
	bl	write
	adrp	x19, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x19, x19, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x0, GetCurrentProcess
	add	x0, x0, :lo12:GetCurrentProcess
	mov	w1, #134                        // =0x86
	bl	TerminateProcess
	mov	w0, #134                        // =0x86
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error___failCmp;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___failCmp // -- Begin function crl__lib__std__x86_64__windows__error___failCmp
	.p2align	2
crl__lib__std__x86_64__windows__error___failCmp: // @crl__lib__std__x86_64__windows__error___failCmp
.seh_proc crl__lib__std__x86_64__windows__error___failCmp
// %bb.0:
	sub	sp, sp, #96
	.seh_stackalloc	96
	stp	x19, x20, [sp, #32]             // 16-byte Folded Spill
	.seh_save_regp	x19, 32
	stp	x21, x22, [sp, #48]             // 16-byte Folded Spill
	.seh_save_regp	x21, 48
	stp	x23, x24, [sp, #64]             // 16-byte Folded Spill
	.seh_save_regp	x23, 64
	stp	x25, x30, [sp, #80]             // 16-byte Folded Spill
	.seh_save_lrpair	x25, 80
	.seh_endprologue
	mov	x24, x2
	mov	x22, x1
	mov	x23, x0
	adrp	x1, "??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@"
	add	x1, x1, :lo12:"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #22                         // =0x16
	mov	x19, x5
	mov	x20, x4
	mov	x21, x3
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x23
	mov	x2, x22
	bl	write
	adrp	x1, "??_C@_09FIOGNGMI@?5failed?3?5?$AA@"
	add	x1, x1, :lo12:"??_C@_09FIOGNGMI@?5failed?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #9                          // =0x9
	bl	write
	cbnz	x24, .LBB13_2
// %bb.1:
	adrp	x1, "??_C@_01GBGANLPD@0?$AA@"
	add	x1, x1, :lo12:"??_C@_01GBGANLPD@0?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	b	.LBB13_7
.LBB13_2:
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	mov	w25, wzr
	mov	w9, #10                         // =0xa
	movk	x8, #52429
	add	x10, sp, #8
	stp	xzr, xzr, [sp, #8]
	str	wzr, [sp, #24]
.LBB13_3:                               // =>This Inner Loop Header: Depth=1
	umulh	x11, x24, x8
	cmp	x24, #10
	lsr	x11, x11, #3
	msub	w12, w11, w9, w24
	mov	x24, x11
	orr	w12, w12, #0x30
	strb	w12, [x10, w25, sxtw]
	add	w25, w25, #1
	b.hs	.LBB13_3
// %bb.4:
	sub	w8, w25, #1
	mov	w9, #2147483646                 // =0x7ffffffe
	cmp	w8, w9
	b.hi	.LBB13_7
// %bb.5:
	add	x8, sp, #8
	sub	x24, x8, #1
.LBB13_6:                               // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x24, x25]
	add	x1, sp, #7
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #7]
	bl	write
	subs	x25, x25, #1
	b.hi	.LBB13_6
.LBB13_7:
	adrp	x24, "??_C@_01CLKCMJKC@?5?$AA@"
	add	x24, x24, :lo12:"??_C@_01CLKCMJKC@?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x24
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x23
	mov	x2, x22
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x24
	mov	w2, #1                          // =0x1
	bl	write
	cbnz	x21, .LBB13_9
// %bb.8:
	adrp	x1, "??_C@_01GBGANLPD@0?$AA@"
	add	x1, x1, :lo12:"??_C@_01GBGANLPD@0?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	b	.LBB13_14
.LBB13_9:
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	mov	w22, wzr
	mov	w9, #10                         // =0xa
	movk	x8, #52429
	add	x10, sp, #8
	stp	xzr, xzr, [sp, #8]
	str	wzr, [sp, #24]
.LBB13_10:                              // =>This Inner Loop Header: Depth=1
	umulh	x11, x21, x8
	cmp	x21, #10
	lsr	x11, x11, #3
	msub	w12, w11, w9, w21
	mov	x21, x11
	orr	w12, w12, #0x30
	strb	w12, [x10, w22, sxtw]
	add	w22, w22, #1
	b.hs	.LBB13_10
// %bb.11:
	sub	w8, w22, #1
	mov	w9, #2147483646                 // =0x7ffffffe
	cmp	w8, w9
	b.hi	.LBB13_14
// %bb.12:
	add	x8, sp, #8
	sub	x21, x8, #1
.LBB13_13:                              // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x21, x22]
	add	x1, sp, #7
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #7]
	bl	write
	subs	x22, x22, #1
	b.hi	.LBB13_13
.LBB13_14:
	adrp	x1, "??_C@_02LMMGGCAJ@?3?5?$AA@"
	add	x1, x1, :lo12:"??_C@_02LMMGGCAJ@?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x20
	mov	x2, x19
	bl	write
	adrp	x19, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x19, x19, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x0, GetCurrentProcess
	add	x0, x0, :lo12:GetCurrentProcess
	mov	w1, #134                        // =0x86
	bl	TerminateProcess
	mov	w0, #134                        // =0x86
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertEq;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertEq // -- Begin function crl__lib__std__x86_64__windows__error____assertEq
	.p2align	2
crl__lib__std__x86_64__windows__error____assertEq: // @crl__lib__std__x86_64__windows__error____assertEq
.seh_proc crl__lib__std__x86_64__windows__error____assertEq
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.seh_save_reg_x	x30, 16
	.seh_endprologue
	cmp	x0, x1
	b.ne	.LBB14_2
// %bb.1:
	.seh_startepilogue
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	.seh_save_reg_x	x30, 16
	.seh_endepilogue
	ret
.LBB14_2:
	mov	x5, x3
	mov	x3, x0
	mov	x4, x2
	adrp	x0, "??_C@_02EGOFBIJA@?$DN?$DN?$AA@"
	add	x0, x0, :lo12:"??_C@_02EGOFBIJA@?$DN?$DN?$AA@"
	mov	x2, x1
	mov	w1, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error___failCmp
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertNe;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertNe // -- Begin function crl__lib__std__x86_64__windows__error____assertNe
	.p2align	2
crl__lib__std__x86_64__windows__error____assertNe: // @crl__lib__std__x86_64__windows__error____assertNe
.seh_proc crl__lib__std__x86_64__windows__error____assertNe
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.seh_save_reg_x	x30, 16
	.seh_endprologue
	cmp	x0, x1
	b.eq	.LBB15_2
// %bb.1:
	.seh_startepilogue
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	.seh_save_reg_x	x30, 16
	.seh_endepilogue
	ret
.LBB15_2:
	mov	x5, x3
	mov	x3, x0
	mov	x4, x2
	adrp	x0, "??_C@_02FDNJECIE@?$CB?$DN?$AA@"
	add	x0, x0, :lo12:"??_C@_02FDNJECIE@?$CB?$DN?$AA@"
	mov	w1, #2                          // =0x2
	mov	x2, x3
	bl	crl__lib__std__x86_64__windows__error___failCmp
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertLt;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertLt // -- Begin function crl__lib__std__x86_64__windows__error____assertLt
	.p2align	2
crl__lib__std__x86_64__windows__error____assertLt: // @crl__lib__std__x86_64__windows__error____assertLt
.seh_proc crl__lib__std__x86_64__windows__error____assertLt
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.seh_save_reg_x	x30, 16
	.seh_endprologue
	cmp	x0, x1
	b.hs	.LBB16_2
// %bb.1:
	.seh_startepilogue
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	.seh_save_reg_x	x30, 16
	.seh_endepilogue
	ret
.LBB16_2:
	adrp	x8, "??_C@_01MNNFJEPP@?$DM?$AA@"
	add	x8, x8, :lo12:"??_C@_01MNNFJEPP@?$DM?$AA@"
	mov	x5, x3
	mov	x3, x1
	mov	x4, x2
	mov	x2, x0
	mov	x0, x8
	mov	w1, #1                          // =0x1
	bl	crl__lib__std__x86_64__windows__error___failCmp
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertLe;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertLe // -- Begin function crl__lib__std__x86_64__windows__error____assertLe
	.p2align	2
crl__lib__std__x86_64__windows__error____assertLe: // @crl__lib__std__x86_64__windows__error____assertLe
.seh_proc crl__lib__std__x86_64__windows__error____assertLe
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.seh_save_reg_x	x30, 16
	.seh_endprologue
	cmp	x0, x1
	b.hi	.LBB17_2
// %bb.1:
	.seh_startepilogue
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	.seh_save_reg_x	x30, 16
	.seh_endepilogue
	ret
.LBB17_2:
	adrp	x8, "??_C@_02EHCHHCKH@?$DM?$DN?$AA@"
	add	x8, x8, :lo12:"??_C@_02EHCHHCKH@?$DM?$DN?$AA@"
	mov	x5, x3
	mov	x3, x1
	mov	x4, x2
	mov	x2, x0
	mov	x0, x8
	mov	w1, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error___failCmp
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertGt;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertGt // -- Begin function crl__lib__std__x86_64__windows__error____assertGt
	.p2align	2
crl__lib__std__x86_64__windows__error____assertGt: // @crl__lib__std__x86_64__windows__error____assertGt
.seh_proc crl__lib__std__x86_64__windows__error____assertGt
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.seh_save_reg_x	x30, 16
	.seh_endprologue
	cmp	x0, x1
	b.ls	.LBB18_2
// %bb.1:
	.seh_startepilogue
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	.seh_save_reg_x	x30, 16
	.seh_endepilogue
	ret
.LBB18_2:
	adrp	x8, "??_C@_01PPODPGHN@?$DO?$AA@"
	add	x8, x8, :lo12:"??_C@_01PPODPGHN@?$DO?$AA@"
	mov	x5, x3
	mov	x3, x1
	mov	x4, x2
	mov	x2, x0
	mov	x0, x8
	mov	w1, #1                          // =0x1
	bl	crl__lib__std__x86_64__windows__error___failCmp
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertGe;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertGe // -- Begin function crl__lib__std__x86_64__windows__error____assertGe
	.p2align	2
crl__lib__std__x86_64__windows__error____assertGe: // @crl__lib__std__x86_64__windows__error____assertGe
.seh_proc crl__lib__std__x86_64__windows__error____assertGe
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.seh_save_reg_x	x30, 16
	.seh_endprologue
	cmp	x0, x1
	b.lo	.LBB19_2
// %bb.1:
	.seh_startepilogue
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	.seh_save_reg_x	x30, 16
	.seh_endepilogue
	ret
.LBB19_2:
	adrp	x8, "??_C@_02EEKDKGMJ@?$DO?$DN?$AA@"
	add	x8, x8, :lo12:"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@"
	mov	x5, x3
	mov	x3, x1
	mov	x4, x2
	mov	x2, x0
	mov	x0, x8
	mov	w1, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error___failCmp
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertRange;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertRange // -- Begin function crl__lib__std__x86_64__windows__error____assertRange
	.p2align	2
crl__lib__std__x86_64__windows__error____assertRange: // @crl__lib__std__x86_64__windows__error____assertRange
.seh_proc crl__lib__std__x86_64__windows__error____assertRange
// %bb.0:
	sub	sp, sp, #80
	.seh_stackalloc	80
	stp	x19, x20, [sp, #48]             // 16-byte Folded Spill
	.seh_save_regp	x19, 48
	stp	x21, x30, [sp, #64]             // 16-byte Folded Spill
	.seh_save_lrpair	x21, 64
	.seh_endprologue
	cmp	x0, x1
	b.hs	.LBB20_2
// %bb.1:
	.seh_startepilogue
	ldp	x21, x30, [sp, #64]             // 16-byte Folded Reload
	.seh_save_lrpair	x21, 64
	ldp	x19, x20, [sp, #48]             // 16-byte Folded Reload
	.seh_save_regp	x19, 48
	add	sp, sp, #80
	.seh_stackalloc	80
	.seh_endepilogue
	ret
.LBB20_2:
	mov	x19, x1
	stp	x2, x3, [sp]                    // 16-byte Folded Spill
	adrp	x1, "??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@"
	add	x1, x1, :lo12:"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@"
	mov	x20, x0
	mov	w0, #2                          // =0x2
	mov	w2, #21                         // =0x15
	bl	write
	cbnz	x20, .LBB20_4
// %bb.3:
	adrp	x1, "??_C@_01GBGANLPD@0?$AA@"
	add	x1, x1, :lo12:"??_C@_01GBGANLPD@0?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	b	.LBB20_9
.LBB20_4:
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	mov	x11, x20
	mov	w20, wzr
	movk	x8, #52429
	mov	w9, #10                         // =0xa
	add	x10, sp, #24
	stp	xzr, xzr, [sp, #24]
	str	wzr, [sp, #40]
.LBB20_5:                               // =>This Inner Loop Header: Depth=1
	umulh	x12, x11, x8
	cmp	x11, #10
	lsr	x12, x12, #3
	msub	w13, w12, w9, w11
	orr	w11, w13, #0x30
	strb	w11, [x10, w20, sxtw]
	add	w20, w20, #1
	mov	x11, x12
	b.hs	.LBB20_5
// %bb.6:
	sub	w8, w20, #1
	mov	w9, #2147483646                 // =0x7ffffffe
	cmp	w8, w9
	b.hi	.LBB20_9
// %bb.7:
	add	x8, sp, #24
	sub	x21, x8, #1
.LBB20_8:                               // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x21, x20]
	add	x1, sp, #23
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #23]
	bl	write
	subs	x20, x20, #1
	b.hi	.LBB20_8
.LBB20_9:
	adrp	x1, "??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@"
	add	x1, x1, :lo12:"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #26                         // =0x1a
	bl	write
	cbnz	x19, .LBB20_11
// %bb.10:
	adrp	x1, "??_C@_01GBGANLPD@0?$AA@"
	add	x1, x1, :lo12:"??_C@_01GBGANLPD@0?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	b	.LBB20_16
.LBB20_11:
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	mov	w20, wzr
	mov	w9, #10                         // =0xa
	movk	x8, #52429
	add	x10, sp, #24
	stp	xzr, xzr, [sp, #24]
	str	wzr, [sp, #40]
.LBB20_12:                              // =>This Inner Loop Header: Depth=1
	umulh	x11, x19, x8
	cmp	x19, #10
	lsr	x11, x11, #3
	msub	w12, w11, w9, w19
	mov	x19, x11
	orr	w12, w12, #0x30
	strb	w12, [x10, w20, sxtw]
	add	w20, w20, #1
	b.hs	.LBB20_12
// %bb.13:
	sub	w8, w20, #1
	mov	w9, #2147483646                 // =0x7ffffffe
	cmp	w8, w9
	b.hi	.LBB20_16
// %bb.14:
	add	x8, sp, #24
	sub	x19, x8, #1
.LBB20_15:                              // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x19, x20]
	add	x1, sp, #23
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #23]
	bl	write
	subs	x20, x20, #1
	b.hi	.LBB20_15
.LBB20_16:
	adrp	x1, "??_C@_02LMMGGCAJ@?3?5?$AA@"
	add	x1, x1, :lo12:"??_C@_02LMMGGCAJ@?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	ldp	x1, x2, [sp]                    // 16-byte Folded Reload
	mov	w0, #2                          // =0x2
	bl	write
	adrp	x19, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x19, x19, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x0, GetCurrentProcess
	add	x0, x0, :lo12:GetCurrentProcess
	mov	w1, #134                        // =0x86
	bl	TerminateProcess
	mov	w0, #134                        // =0x86
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertNonNull;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertNonNull // -- Begin function crl__lib__std__x86_64__windows__error____assertNonNull
	.p2align	2
crl__lib__std__x86_64__windows__error____assertNonNull: // @crl__lib__std__x86_64__windows__error____assertNonNull
.seh_proc crl__lib__std__x86_64__windows__error____assertNonNull
// %bb.0:
	stp	x19, x20, [sp, #-32]!           // 16-byte Folded Spill
	.seh_save_regp_x	x19, 32
	str	x30, [sp, #16]                  // 8-byte Spill
	.seh_save_reg	x30, 16
	.seh_endprologue
	cbz	x0, .LBB21_2
// %bb.1:
	.seh_startepilogue
	ldr	x30, [sp, #16]                  // 8-byte Reload
	.seh_save_reg	x30, 16
	ldp	x19, x20, [sp], #32             // 16-byte Folded Reload
	.seh_save_regp_x	x19, 32
	.seh_endepilogue
	ret
.LBB21_2:
	adrp	x8, "??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	add	x8, x8, :lo12:"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	mov	w0, #2                          // =0x2
	mov	x19, x1
	mov	x1, x8
	mov	x20, x2
	mov	w2, #15                         // =0xf
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	x2, x20
	bl	write
	adrp	x19, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x19, x19, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x0, GetCurrentProcess
	add	x0, x0, :lo12:GetCurrentProcess
	mov	w1, #134                        // =0x86
	bl	TerminateProcess
	mov	w0, #134                        // =0x86
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____assertAligned;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____assertAligned // -- Begin function crl__lib__std__x86_64__windows__error____assertAligned
	.p2align	2
crl__lib__std__x86_64__windows__error____assertAligned: // @crl__lib__std__x86_64__windows__error____assertAligned
.seh_proc crl__lib__std__x86_64__windows__error____assertAligned
// %bb.0:
	str	x30, [sp, #-16]!                // 8-byte Folded Spill
	.seh_save_reg_x	x30, 16
	.seh_endprologue
	sub	x8, x1, #1
	tst	x8, x0
	b.ne	.LBB22_2
// %bb.1:
	.seh_startepilogue
	ldr	x30, [sp], #16                  // 8-byte Folded Reload
	.seh_save_reg_x	x30, 16
	.seh_endepilogue
	ret
.LBB22_2:
	adrp	x8, "??_C@_07PFMCDPMA@pointer?$AA@"
	add	x8, x8, :lo12:"??_C@_07PFMCDPMA@pointer?$AA@"
	mov	x4, x0
	mov	x0, x2
	mov	x1, x3
	mov	x2, x8
	mov	w3, #7                          // =0x7
	bl	crl__lib__std__x86_64__windows__error____reportHex
	adrp	x0, GetCurrentProcess
	add	x0, x0, :lo12:GetCurrentProcess
	mov	w1, #134                        // =0x86
	bl	TerminateProcess
	mov	w0, #134                        // =0x86
	bl	_exit
	brk	#0x1
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error___excFilter;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error___excFilter // -- Begin function crl__lib__std__x86_64__windows__error___excFilter
	.p2align	2
crl__lib__std__x86_64__windows__error___excFilter: // @crl__lib__std__x86_64__windows__error___excFilter
.seh_proc crl__lib__std__x86_64__windows__error___excFilter
// %bb.0:
	sub	sp, sp, #16
	.seh_stackalloc	16
	stp	x19, x30, [sp]                  // 16-byte Folded Spill
	.seh_save_lrpair	x19, 0
	.seh_endprologue
	adrp	x8, .L_MergedGlobals.1
	ldrb	w9, [x8, :lo12:.L_MergedGlobals.1]
	tbnz	w9, #0, .LBB23_2
// %bb.1:
	mov	w9, #1                          // =0x1
	adrp	x1, "??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@"
	add	x1, x1, :lo12:"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@"
	strb	w9, [x8, :lo12:.L_MergedGlobals.1]
	mov	w2, #15                         // =0xf
	ldr	x8, [x0]
	mov	w0, #2                          // =0x2
	ldr	w19, [x8]
	bl	write
	mov	w0, #2                          // =0x2
	mov	w1, w19
	bl	crl__lib__std__x86_64__windows__error___wrExcName
	adrp	x19, "??_C@_01EEMJAFIK@?6?$AA@"
	add	x19, x19, :lo12:"??_C@_01EEMJAFIK@?6?$AA@"
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__windows__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x19
	mov	w2, #1                          // =0x1
	bl	write
.LBB23_2:
	adrp	x8, .L_MergedGlobals.1+4
	ldr	w0, [x8, :lo12:.L_MergedGlobals.1+4]
	.seh_startepilogue
	ldp	x19, x30, [sp]                  // 16-byte Folded Reload
	.seh_save_lrpair	x19, 0
	add	sp, sp, #16
	.seh_stackalloc	16
	.seh_endepilogue
	ret
	.seh_endfunclet
	.seh_endproc
                                        // -- End function
	.def	crl__lib__std__x86_64__windows__error____catchFatalSignals;
	.scl	2;
	.type	32;
	.endef
	.globl	crl__lib__std__x86_64__windows__error____catchFatalSignals // -- Begin function crl__lib__std__x86_64__windows__error____catchFatalSignals
	.p2align	2
crl__lib__std__x86_64__windows__error____catchFatalSignals: // @crl__lib__std__x86_64__windows__error____catchFatalSignals
// %bb.0:
	adrp	x0, crl__lib__std__x86_64__windows__error___excFilter
	add	x0, x0, :lo12:crl__lib__std__x86_64__windows__error___excFilter
	b	SetUnhandledExceptionFilter
                                        // -- End function
	.section	.rdata,"dr",discard,"??_C@_02MDDDDAID@0x?$AA@"
	.globl	"??_C@_02MDDDDAID@0x?$AA@"      // @"??_C@_02MDDDDAID@0x?$AA@"
	.p2align	2, 0x0
"??_C@_02MDDDDAID@0x?$AA@":
	.asciz	"0x"

	.section	.rdata,"dr",discard,"??_C@_01GBGANLPD@0?$AA@"
	.globl	"??_C@_01GBGANLPD@0?$AA@"       // @"??_C@_01GBGANLPD@0?$AA@"
	.p2align	2, 0x0
"??_C@_01GBGANLPD@0?$AA@":
	.asciz	"0"

	.section	.rdata,"dr",discard,"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@"
	.globl	"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@" // @"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@"
	.p2align	3, 0x0
"??_C@_0BB@KOKDBDNI@ACCESS_VIOLATION?$AA@":
	.asciz	"ACCESS_VIOLATION"

	.section	.rdata,"dr",discard,"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@"
	.globl	"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@" // @"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@"
	.p2align	3, 0x0
"??_C@_0BE@PPPKHBFF@ILLEGAL_INSTRUCTION?$AA@":
	.asciz	"ILLEGAL_INSTRUCTION"

	.section	.rdata,"dr",discard,"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@"
	.globl	"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@" // @"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@"
	.p2align	3, 0x0
"??_C@_0BG@KDAKIDPK@ARRAY_BOUNDS_EXCEEDED?$AA@":
	.asciz	"ARRAY_BOUNDS_EXCEEDED"

	.section	.rdata,"dr",discard,"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@"
	.globl	"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@" // @"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@"
	.p2align	3, 0x0
"??_C@_0BD@NCECPCDC@FLT_DIVIDE_BY_ZERO?$AA@":
	.asciz	"FLT_DIVIDE_BY_ZERO"

	.section	.rdata,"dr",discard,"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@"
	.globl	"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@" // @"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@"
	.p2align	3, 0x0
"??_C@_0BG@KHLFFMKF@FLT_INVALID_OPERATION?$AA@":
	.asciz	"FLT_INVALID_OPERATION"

	.section	.rdata,"dr",discard,"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@"
	.globl	"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@" // @"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@"
	.p2align	3, 0x0
"??_C@_0BD@JEAJAPHP@INT_DIVIDE_BY_ZERO?$AA@":
	.asciz	"INT_DIVIDE_BY_ZERO"

	.section	.rdata,"dr",discard,"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@"
	.globl	"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@" // @"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@"
	.p2align	3, 0x0
"??_C@_0BB@IIEKJHHD@INTEGER_OVERFLOW?$AA@":
	.asciz	"INTEGER_OVERFLOW"

	.section	.rdata,"dr",discard,"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@"
	.globl	"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@" // @"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@"
	.p2align	3, 0x0
"??_C@_0BH@JOOBBLBE@PRIVILEGED_INSTRUCTION?$AA@":
	.asciz	"PRIVILEGED_INSTRUCTION"

	.section	.rdata,"dr",discard,"??_C@_0L@PBPBANKG@exception?5?$AA@"
	.globl	"??_C@_0L@PBPBANKG@exception?5?$AA@" // @"??_C@_0L@PBPBANKG@exception?5?$AA@"
	.p2align	3, 0x0
"??_C@_0L@PBPBANKG@exception?5?$AA@":
	.asciz	"exception "

	.section	.rdata,"dr",discard,"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@"
	.globl	"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@" // @"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@"
	.p2align	3, 0x0
"??_C@_0P@BJLJNCPL@?5?5?$DMno?5frames?$DO?6?$AA@":
	.asciz	"  <no frames>\n"

	.section	.rdata,"dr",discard,"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@"
	.globl	"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@" // @"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@"
	.p2align	3, 0x0
"??_C@_09MJCPFNBN@?5?5stack?3?6?$AA@":
	.asciz	"  stack:\n"

	.section	.rdata,"dr",discard,"??_C@_03PIGNLOFM@?5?5?$CD?$AA@"
	.globl	"??_C@_03PIGNLOFM@?5?5?$CD?$AA@" // @"??_C@_03PIGNLOFM@?5?5?$CD?$AA@"
	.p2align	2, 0x0
"??_C@_03PIGNLOFM@?5?5?$CD?$AA@":
	.asciz	"  #"

	.section	.rdata,"dr",discard,"??_C@_01CLKCMJKC@?5?$AA@"
	.globl	"??_C@_01CLKCMJKC@?5?$AA@"      // @"??_C@_01CLKCMJKC@?5?$AA@"
	.p2align	2, 0x0
"??_C@_01CLKCMJKC@?5?$AA@":
	.asciz	" "

	.section	.rdata,"dr",discard,"??_C@_01EEMJAFIK@?6?$AA@"
	.globl	"??_C@_01EEMJAFIK@?6?$AA@"      // @"??_C@_01EEMJAFIK@?6?$AA@"
	.p2align	2, 0x0
"??_C@_01EEMJAFIK@?6?$AA@":
	.asciz	"\n"

	.section	.rdata,"dr",discard,"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@"
	.globl	"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@" // @"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@"
	.p2align	3, 0x0
"??_C@_0BG@IHEBMHNB@coral?3?5out?5of?5memory?6?$AA@":
	.asciz	"coral: out of memory\n"

	.section	.rdata,"dr",discard,"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@"
	.globl	"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@" // @"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@"
	.p2align	4, 0x0
"??_C@_0EG@LMODAALG@?5?5the?5compiler?5could?5not?5allocat@":
	.asciz	"  the compiler could not allocate memory; try coralc --explain D0003\n"

	.section	.rdata,"dr",discard,"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	.globl	"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@" // @"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BA@GDHGGILO@?6coral?3?5error?3?5?$AA@":
	.asciz	"\ncoral: error: "

	.section	.rdata,"dr",discard,"??_C@_02GFKOMOKH@?5?$CI?$AA@"
	.globl	"??_C@_02GFKOMOKH@?5?$CI?$AA@"  // @"??_C@_02GFKOMOKH@?5?$CI?$AA@"
	.p2align	2, 0x0
"??_C@_02GFKOMOKH@?5?$CI?$AA@":
	.asciz	" ("

	.section	.rdata,"dr",discard,"??_C@_03MHLONNLM@?5?$DN?5?$AA@"
	.globl	"??_C@_03MHLONNLM@?5?$DN?5?$AA@" // @"??_C@_03MHLONNLM@?5?$DN?5?$AA@"
	.p2align	2, 0x0
"??_C@_03MHLONNLM@?5?$DN?5?$AA@":
	.asciz	" = "

	.section	.rdata,"dr",discard,"??_C@_02MNMNLDAI@?$CJ?6?$AA@"
	.globl	"??_C@_02MNMNLDAI@?$CJ?6?$AA@"  // @"??_C@_02MNMNLDAI@?$CJ?6?$AA@"
	.p2align	2, 0x0
"??_C@_02MNMNLDAI@?$CJ?6?$AA@":
	.asciz	")\n"

	.section	.rdata,"dr",discard,"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@"
	.globl	"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@" // @"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@"
	.p2align	3, 0x0
"??_C@_0BB@DBHFCHNO@assertion?5failed?$AA@":
	.asciz	"assertion failed"

	.section	.rdata,"dr",discard,"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@"
	.globl	"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@" // @"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BH@NBADJFLA@?6coral?3?5error?3?5assert?5?$AA@":
	.asciz	"\ncoral: error: assert "

	.section	.rdata,"dr",discard,"??_C@_09FIOGNGMI@?5failed?3?5?$AA@"
	.globl	"??_C@_09FIOGNGMI@?5failed?3?5?$AA@" // @"??_C@_09FIOGNGMI@?5failed?3?5?$AA@"
	.p2align	3, 0x0
"??_C@_09FIOGNGMI@?5failed?3?5?$AA@":
	.asciz	" failed: "

	.section	.rdata,"dr",discard,"??_C@_02LMMGGCAJ@?3?5?$AA@"
	.globl	"??_C@_02LMMGGCAJ@?3?5?$AA@"    // @"??_C@_02LMMGGCAJ@?3?5?$AA@"
	.p2align	2, 0x0
"??_C@_02LMMGGCAJ@?3?5?$AA@":
	.asciz	": "

	.section	.rdata,"dr",discard,"??_C@_02EGOFBIJA@?$DN?$DN?$AA@"
	.globl	"??_C@_02EGOFBIJA@?$DN?$DN?$AA@" // @"??_C@_02EGOFBIJA@?$DN?$DN?$AA@"
	.p2align	2, 0x0
"??_C@_02EGOFBIJA@?$DN?$DN?$AA@":
	.asciz	"=="

	.section	.rdata,"dr",discard,"??_C@_02FDNJECIE@?$CB?$DN?$AA@"
	.globl	"??_C@_02FDNJECIE@?$CB?$DN?$AA@" // @"??_C@_02FDNJECIE@?$CB?$DN?$AA@"
	.p2align	2, 0x0
"??_C@_02FDNJECIE@?$CB?$DN?$AA@":
	.asciz	"!="

	.section	.rdata,"dr",discard,"??_C@_01MNNFJEPP@?$DM?$AA@"
	.globl	"??_C@_01MNNFJEPP@?$DM?$AA@"    // @"??_C@_01MNNFJEPP@?$DM?$AA@"
	.p2align	2, 0x0
"??_C@_01MNNFJEPP@?$DM?$AA@":
	.asciz	"<"

	.section	.rdata,"dr",discard,"??_C@_02EHCHHCKH@?$DM?$DN?$AA@"
	.globl	"??_C@_02EHCHHCKH@?$DM?$DN?$AA@" // @"??_C@_02EHCHHCKH@?$DM?$DN?$AA@"
	.p2align	2, 0x0
"??_C@_02EHCHHCKH@?$DM?$DN?$AA@":
	.asciz	"<="

	.section	.rdata,"dr",discard,"??_C@_01PPODPGHN@?$DO?$AA@"
	.globl	"??_C@_01PPODPGHN@?$DO?$AA@"    // @"??_C@_01PPODPGHN@?$DO?$AA@"
	.p2align	2, 0x0
"??_C@_01PPODPGHN@?$DO?$AA@":
	.asciz	">"

	.section	.rdata,"dr",discard,"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@"
	.globl	"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@" // @"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@"
	.p2align	2, 0x0
"??_C@_02EEKDKGMJ@?$DO?$DN?$AA@":
	.asciz	">="

	.section	.rdata,"dr",discard,"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@"
	.globl	"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@" // @"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BG@OLLGIFK@?6coral?3?5error?3?5index?5?$AA@":
	.asciz	"\ncoral: error: index "

	.section	.rdata,"dr",discard,"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@"
	.globl	"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@" // @"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BL@CBNIJNCI@?5out?5of?5bounds?5for?5length?5?$AA@":
	.asciz	" out of bounds for length "

	.section	.rdata,"dr",discard,"??_C@_07PFMCDPMA@pointer?$AA@"
	.globl	"??_C@_07PFMCDPMA@pointer?$AA@" // @"??_C@_07PFMCDPMA@pointer?$AA@"
	.p2align	3, 0x0
"??_C@_07PFMCDPMA@pointer?$AA@":
	.asciz	"pointer"

	.section	.rdata,"dr",discard,"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@"
	.globl	"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@" // @"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@"
	.p2align	3, 0x0
"??_C@_0BA@GCGAJENO@?6coral?3?5fatal?3?5?$AA@":
	.asciz	"\ncoral: fatal: "

	.data
	.p2align	2, 0x0                          // @_MergedGlobals
.L_MergedGlobals:
	.word	3221225477                      // 0xc0000005
	.word	3221225501                      // 0xc000001d
	.word	3221225612                      // 0xc000008c
	.word	3221225614                      // 0xc000008e
	.word	3221225619                      // 0xc0000093
	.word	3221225620                      // 0xc0000094
	.word	3221225621                      // 0xc0000095
	.word	3221225510                      // 0xc0000026

	.lcomm	.L_MergedGlobals.1,8,4          // @_MergedGlobals.1
	.globl	crl__lib__std__x86_64__windows__error__EXC_ACCESS_VIOLATION
crl__lib__std__x86_64__windows__error__EXC_ACCESS_VIOLATION = .L_MergedGlobals
	.globl	crl__lib__std__x86_64__windows__error__EXC_ILLEGAL_INSTRUCTION
crl__lib__std__x86_64__windows__error__EXC_ILLEGAL_INSTRUCTION = .L_MergedGlobals+4
	.globl	crl__lib__std__x86_64__windows__error__EXC_ARRAY_BOUNDS
crl__lib__std__x86_64__windows__error__EXC_ARRAY_BOUNDS = .L_MergedGlobals+8
	.globl	crl__lib__std__x86_64__windows__error__EXC_FLT_DIVIDE_BY_ZERO
crl__lib__std__x86_64__windows__error__EXC_FLT_DIVIDE_BY_ZERO = .L_MergedGlobals+12
	.globl	crl__lib__std__x86_64__windows__error__EXC_FLT_INVALID_OPERATION
crl__lib__std__x86_64__windows__error__EXC_FLT_INVALID_OPERATION = .L_MergedGlobals+16
	.globl	crl__lib__std__x86_64__windows__error__EXC_INT_DIVIDE_BY_ZERO
crl__lib__std__x86_64__windows__error__EXC_INT_DIVIDE_BY_ZERO = .L_MergedGlobals+20
	.globl	crl__lib__std__x86_64__windows__error__EXC_INTEGER_OVERFLOW
crl__lib__std__x86_64__windows__error__EXC_INTEGER_OVERFLOW = .L_MergedGlobals+24
	.globl	crl__lib__std__x86_64__windows__error__EXC_PRIVILEGED_INSTRUCTION
crl__lib__std__x86_64__windows__error__EXC_PRIVILEGED_INSTRUCTION = .L_MergedGlobals+28
crl__lib__std__x86_64__windows__error___handling = .L_MergedGlobals.1
	.globl	crl__lib__std__x86_64__windows__error__EXC_CONTINUE_SEARCH
crl__lib__std__x86_64__windows__error__EXC_CONTINUE_SEARCH = .L_MergedGlobals.1+4
	.section	.debug$S,"dr"
	.p2align	2, 0x0
	.word	4                               // Debug section magic
	.word	241
	.word	.Ltmp1-.Ltmp0                   // Subsection size
.Ltmp0:
	.hword	.Ltmp3-.Ltmp2                   // Record length
.Ltmp2:
	.hword	4353                            // Record kind: S_OBJNAME
	.word	0                               // Signature
	.byte	0                               // Object name
	.p2align	2, 0x0
.Ltmp3:
	.hword	.Ltmp5-.Ltmp4                   // Record length
.Ltmp4:
	.hword	4412                            // Record kind: S_COMPILE3
	.word	16384                           // Flags and language
	.hword	246                             // CPUType
	.hword	23                              // Frontend version
	.hword	1
	.hword	3
	.hword	0
	.hword	23013                           // Backend version
	.hword	0
	.hword	0
	.hword	0
	.asciz	"clang version 23.1.3"          // Null-terminated compiler version string
	.p2align	2, 0x0
.Ltmp5:
.Ltmp1:
	.p2align	2, 0x0
	.addrsig
	.addrsig_sym GetCurrentProcess
	.addrsig_sym crl__lib__std__x86_64__windows__error___excFilter
	.addrsig_sym .L_MergedGlobals
	.addrsig_sym .L_MergedGlobals.1

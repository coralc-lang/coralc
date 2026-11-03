	.file	"error.c"
	.text
	.globl	crl__lib__std__x86_64__linux__error___wr // -- Begin function crl__lib__std__x86_64__linux__error___wr
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error___wr,@function
crl__lib__std__x86_64__linux__error___wr: // @crl__lib__std__x86_64__linux__error___wr
	.cfi_startproc
// %bb.0:
	b	write
.Lfunc_end0:
	.size	crl__lib__std__x86_64__linux__error___wr, .Lfunc_end0-crl__lib__std__x86_64__linux__error___wr
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error___wrHex // -- Begin function crl__lib__std__x86_64__linux__error___wrHex
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error___wrHex,@function
crl__lib__std__x86_64__linux__error___wrHex: // @crl__lib__std__x86_64__linux__error___wrHex
	.cfi_startproc
// %bb.0:
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x29, x30, [sp, #16]             // 16-byte Folded Spill
	stp	x22, x21, [sp, #32]             // 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             // 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 48
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -24
	.cfi_offset w22, -32
	.cfi_offset w30, -40
	.cfi_offset w29, -48
	.cfi_remember_state
	adrp	x8, :got:__stack_chk_guard
	mov	x20, x1
	adrp	x1, .L.str
	add	x1, x1, :lo12:.L.str
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	mov	w2, #2                          // =0x2
	mov	w19, w0
	ldr	x8, [x8]
	str	x8, [sp, #8]
	bl	write
	lsr	x21, x20, #60
	cbz	x21, .LBB1_2
// %bb.1:
	lsr	x8, x20, #61
	orr	w9, w21, #0x30
	add	w10, w21, #87
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	cmp	x8, #5
	csel	w8, w9, w10, lo
	strb	w8, [sp, #4]
	bl	write
.LBB1_2:
	lsr	x8, x20, #56
	cmp	x21, #0
	cset	w9, ne
	ands	w8, w8, #0xf
	csinc	w21, w9, wzr, eq
	cbnz	w21, .LBB1_19
// %bb.3:
	lsr	x8, x20, #52
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_20
.LBB1_4:
	lsr	x8, x20, #48
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_21
.LBB1_5:
	lsr	x8, x20, #44
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_22
.LBB1_6:
	lsr	x8, x20, #40
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_23
.LBB1_7:
	lsr	x8, x20, #36
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_24
.LBB1_8:
	lsr	x8, x20, #32
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_25
.LBB1_9:
	lsr	w8, w20, #28
	cmp	w8, #0
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_26
.LBB1_10:
	mov	w22, #15                        // =0xf
	ands	w8, w22, w20, lsr #24
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_27
.LBB1_11:
	ands	w8, w22, w20, lsr #20
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_28
.LBB1_12:
	ands	w8, w22, w20, lsr #16
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_29
.LBB1_13:
	ands	w8, w22, w20, lsr #12
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_30
.LBB1_14:
	ands	w8, w22, w20, lsr #8
	csinc	w21, w21, wzr, eq
	cbnz	w21, .LBB1_31
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
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
.LBB1_17:
	mov	w8, #48                         // =0x30
	and	w9, w20, #0xf
	add	x1, sp, #4
	bfxil	w8, w20, #0, #4
	add	w10, w9, #87
	cmp	w9, #10
	mov	w0, w19
	mov	w2, #1                          // =0x1
	csel	w8, w8, w10, lo
	strb	w8, [sp, #4]
	bl	write
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldr	x9, [sp, #8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB1_32
// %bb.18:
	.cfi_def_cfa wsp, 64
	ldp	x20, x19, [sp, #48]             // 16-byte Folded Reload
	ldp	x22, x21, [sp, #32]             // 16-byte Folded Reload
	ldp	x29, x30, [sp, #16]             // 16-byte Folded Reload
	add	sp, sp, #64
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB1_19:
	.cfi_restore_state
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	lsr	x8, x20, #52
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_4
.LBB1_20:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	lsr	x8, x20, #48
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_5
.LBB1_21:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	lsr	x8, x20, #44
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_6
.LBB1_22:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	lsr	x8, x20, #40
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_7
.LBB1_23:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	lsr	x8, x20, #36
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_8
.LBB1_24:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	lsr	x8, x20, #32
	ands	w8, w8, #0xf
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_9
.LBB1_25:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	lsr	w8, w20, #28
	cmp	w8, #0
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_10
.LBB1_26:
	lsr	w9, w20, #29
	orr	w10, w8, #0x30
	add	w8, w8, #87
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	cmp	w9, #5
	csel	w8, w10, w8, lo
	strb	w8, [sp, #4]
	bl	write
	mov	w22, #15                        // =0xf
	ands	w8, w22, w20, lsr #24
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_11
.LBB1_27:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	ands	w8, w22, w20, lsr #20
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_12
.LBB1_28:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	ands	w8, w22, w20, lsr #16
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_13
.LBB1_29:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	ands	w8, w22, w20, lsr #12
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_14
.LBB1_30:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	ands	w8, w22, w20, lsr #8
	csinc	w21, w21, wzr, eq
	cbz	w21, .LBB1_15
.LBB1_31:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	add	x1, sp, #4
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #4]
	bl	write
	ands	w8, w22, w20, lsr #4
	cset	w9, eq
	bic	w9, w9, w21
	tbz	w9, #0, .LBB1_16
	b	.LBB1_17
.LBB1_32:
	bl	__stack_chk_fail
.Lfunc_end1:
	.size	crl__lib__std__x86_64__linux__error___wrHex, .Lfunc_end1-crl__lib__std__x86_64__linux__error___wrHex
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error___wrDec // -- Begin function crl__lib__std__x86_64__linux__error___wrDec
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error___wrDec,@function
crl__lib__std__x86_64__linux__error___wrDec: // @crl__lib__std__x86_64__linux__error___wrDec
	.cfi_startproc
// %bb.0:
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x29, x30, [sp, #48]             // 16-byte Folded Spill
	str	x21, [sp, #64]                  // 8-byte Spill
	stp	x20, x19, [sp, #80]             // 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 48
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -32
	.cfi_offset w30, -40
	.cfi_offset w29, -48
	.cfi_remember_state
	adrp	x8, :got:__stack_chk_guard
	mov	w19, w0
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	cbz	x1, .LBB2_6
// %bb.1:
	add	x8, sp, #16
	mov	w20, #1                         // =0x1
	mov	w9, #10                         // =0xa
	sub	x21, x8, #1
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	stp	xzr, xzr, [sp, #16]
	movk	x8, #52429
	str	wzr, [sp, #32]
.LBB2_2:                                // =>This Inner Loop Header: Depth=1
	umulh	x10, x1, x8
	cmp	x1, #9
	add	w20, w20, #1
	lsr	x10, x10, #3
	msub	w11, w10, w9, w1
	mov	x1, x10
	orr	w11, w11, #0x30
	strb	w11, [x21, #1]!
	b.hi	.LBB2_2
.LBB2_3:                                // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x21], #-1
	add	x1, sp, #12
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #12]
	bl	write
	sub	w20, w20, #1
	cmp	w20, #1
	b.gt	.LBB2_3
// %bb.4:
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB2_8
// %bb.5:
	.cfi_def_cfa wsp, 96
	ldp	x20, x19, [sp, #80]             // 16-byte Folded Reload
	ldr	x21, [sp, #64]                  // 8-byte Reload
	ldp	x29, x30, [sp, #48]             // 16-byte Folded Reload
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB2_6:
	.cfi_restore_state
	.cfi_remember_state
	ldur	x9, [x29, #-8]
	cmp	x8, x9
	b.ne	.LBB2_8
// %bb.7:
	adrp	x1, .L.str.1
	add	x1, x1, :lo12:.L.str.1
	mov	w0, w19
	mov	w2, #1                          // =0x1
	.cfi_def_cfa wsp, 96
	ldp	x20, x19, [sp, #80]             // 16-byte Folded Reload
	ldr	x21, [sp, #64]                  // 8-byte Reload
	ldp	x29, x30, [sp, #48]             // 16-byte Folded Reload
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w30
	.cfi_restore w29
	b	write
.LBB2_8:
	.cfi_restore_state
	bl	__stack_chk_fail
.Lfunc_end2:
	.size	crl__lib__std__x86_64__linux__error___wrDec, .Lfunc_end2-crl__lib__std__x86_64__linux__error___wrDec
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error___wrSigName // -- Begin function crl__lib__std__x86_64__linux__error___wrSigName
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error___wrSigName,@function
crl__lib__std__x86_64__linux__error___wrSigName: // @crl__lib__std__x86_64__linux__error___wrSigName
	.cfi_startproc
// %bb.0:
	sub	sp, sp, #96
	.cfi_def_cfa_offset 96
	stp	x29, x30, [sp, #48]             // 16-byte Folded Spill
	str	x21, [sp, #64]                  // 8-byte Spill
	stp	x20, x19, [sp, #80]             // 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 48
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -32
	.cfi_offset w30, -40
	.cfi_offset w29, -48
	.cfi_remember_state
	adrp	x8, :got:__stack_chk_guard
                                        // kill: def $w1 killed $w1 def $x1
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	adrp	x8, .L_MergedGlobals+16
	ldr	w8, [x8, :lo12:.L_MergedGlobals+16]
	cmp	w1, w8
	b.ne	.LBB3_3
// %bb.1:
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB3_23
// %bb.2:
	adrp	x1, .L.str.2
	add	x1, x1, :lo12:.L.str.2
	mov	w2, #28                         // =0x1c
	.cfi_def_cfa wsp, 96
	ldp	x20, x19, [sp, #80]             // 16-byte Folded Reload
	ldr	x21, [sp, #64]                  // 8-byte Reload
	ldp	x29, x30, [sp, #48]             // 16-byte Folded Reload
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w30
	.cfi_restore w29
	b	write
.LBB3_3:
	.cfi_restore_state
	.cfi_remember_state
	adrp	x8, .L_MergedGlobals+4
	ldr	w8, [x8, :lo12:.L_MergedGlobals+4]
	cmp	w1, w8
	b.ne	.LBB3_6
// %bb.4:
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB3_23
// %bb.5:
	adrp	x1, .L.str.3
	add	x1, x1, :lo12:.L.str.3
	mov	w2, #18                         // =0x12
	.cfi_def_cfa wsp, 96
	ldp	x20, x19, [sp, #80]             // 16-byte Folded Reload
	ldr	x21, [sp, #64]                  // 8-byte Reload
	ldp	x29, x30, [sp, #48]             // 16-byte Folded Reload
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w30
	.cfi_restore w29
	b	write
.LBB3_6:
	.cfi_restore_state
	.cfi_remember_state
	adrp	x8, .L_MergedGlobals+12
	ldr	w8, [x8, :lo12:.L_MergedGlobals+12]
	cmp	w1, w8
	b.ne	.LBB3_9
// %bb.7:
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB3_23
// %bb.8:
	adrp	x1, .L.str.4
	add	x1, x1, :lo12:.L.str.4
	mov	w2, #28                         // =0x1c
	.cfi_def_cfa wsp, 96
	ldp	x20, x19, [sp, #80]             // 16-byte Folded Reload
	ldr	x21, [sp, #64]                  // 8-byte Reload
	ldp	x29, x30, [sp, #48]             // 16-byte Folded Reload
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w30
	.cfi_restore w29
	b	write
.LBB3_9:
	.cfi_restore_state
	.cfi_remember_state
	adrp	x8, .L_MergedGlobals+8
	ldr	w8, [x8, :lo12:.L_MergedGlobals+8]
	cmp	w1, w8
	b.ne	.LBB3_12
// %bb.10:
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB3_23
// %bb.11:
	adrp	x1, .L.str.5
	add	x1, x1, :lo12:.L.str.5
	mov	w2, #25                         // =0x19
	.cfi_def_cfa wsp, 96
	ldp	x20, x19, [sp, #80]             // 16-byte Folded Reload
	ldr	x21, [sp, #64]                  // 8-byte Reload
	ldp	x29, x30, [sp, #48]             // 16-byte Folded Reload
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w30
	.cfi_restore w29
	b	write
.LBB3_12:
	.cfi_restore_state
	.cfi_remember_state
	adrp	x8, .L_MergedGlobals
	ldr	w8, [x8, :lo12:.L_MergedGlobals]
	cmp	w1, w8
	b.ne	.LBB3_15
// %bb.13:
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB3_23
// %bb.14:
	adrp	x1, .L.str.6
	add	x1, x1, :lo12:.L.str.6
	mov	w2, #15                         // =0xf
	.cfi_def_cfa wsp, 96
	ldp	x20, x19, [sp, #80]             // 16-byte Folded Reload
	ldr	x21, [sp, #64]                  // 8-byte Reload
	ldp	x29, x30, [sp, #48]             // 16-byte Folded Reload
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w30
	.cfi_restore w29
	b	write
.LBB3_15:
	.cfi_restore_state
	.cfi_remember_state
	adrp	x8, .L.str.7
	add	x8, x8, :lo12:.L.str.7
	mov	x20, x1
	mov	x1, x8
	mov	w2, #7                          // =0x7
	mov	w19, w0
	bl	write
	mov	x8, x20
	cbz	w8, .LBB3_21
// %bb.16:
	add	x9, sp, #16
	sxtw	x8, w8
	mov	w20, #1                         // =0x1
	sub	x21, x9, #1
	mov	x9, #-3689348814741910324       // =0xcccccccccccccccc
	mov	w10, #10                        // =0xa
	movk	x9, #52429
	stp	xzr, xzr, [sp, #16]
	str	wzr, [sp, #32]
.LBB3_17:                               // =>This Inner Loop Header: Depth=1
	umulh	x11, x8, x9
	cmp	x8, #9
	add	w20, w20, #1
	lsr	x11, x11, #3
	msub	w12, w11, w10, w8
	mov	x8, x11
	orr	w12, w12, #0x30
	strb	w12, [x21, #1]!
	b.hi	.LBB3_17
.LBB3_18:                               // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x21], #-1
	add	x1, sp, #12
	mov	w0, w19
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #12]
	bl	write
	sub	w20, w20, #1
	cmp	w20, #1
	b.gt	.LBB3_18
// %bb.19:
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB3_23
// %bb.20:
	.cfi_def_cfa wsp, 96
	ldp	x20, x19, [sp, #80]             // 16-byte Folded Reload
	ldr	x21, [sp, #64]                  // 8-byte Reload
	ldp	x29, x30, [sp, #48]             // 16-byte Folded Reload
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB3_21:
	.cfi_restore_state
	.cfi_remember_state
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB3_23
// %bb.22:
	adrp	x1, .L.str.1
	add	x1, x1, :lo12:.L.str.1
	mov	w0, w19
	mov	w2, #1                          // =0x1
	.cfi_def_cfa wsp, 96
	ldp	x20, x19, [sp, #80]             // 16-byte Folded Reload
	ldr	x21, [sp, #64]                  // 8-byte Reload
	ldp	x29, x30, [sp, #48]             // 16-byte Folded Reload
	add	sp, sp, #96
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w30
	.cfi_restore w29
	b	write
.LBB3_23:
	.cfi_restore_state
	bl	__stack_chk_fail
.Lfunc_end3:
	.size	crl__lib__std__x86_64__linux__error___wrSigName, .Lfunc_end3-crl__lib__std__x86_64__linux__error___wrSigName
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____backtraceTo // -- Begin function crl__lib__std__x86_64__linux__error____backtraceTo
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____backtraceTo,@function
crl__lib__std__x86_64__linux__error____backtraceTo: // @crl__lib__std__x86_64__linux__error____backtraceTo
	.cfi_startproc
// %bb.0:
	sub	sp, sp, #320
	.cfi_def_cfa_offset 320
	stp	x29, x30, [sp, #272]            // 16-byte Folded Spill
	str	x28, [sp, #288]                 // 8-byte Spill
	stp	x20, x19, [sp, #304]            // 16-byte Folded Spill
	add	x29, sp, #272
	.cfi_def_cfa w29, 48
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w28, -32
	.cfi_offset w30, -40
	.cfi_offset w29, -48
	.cfi_remember_state
	adrp	x8, :got:__stack_chk_guard
	movi	v0.2d, #0000000000000000
	mov	w19, w0
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	mov	x0, sp
	mov	w1, #32                         // =0x20
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	stp	q0, q0, [sp]
	stp	q0, q0, [sp, #32]
	stp	q0, q0, [sp, #64]
	stp	q0, q0, [sp, #96]
	stp	q0, q0, [sp, #128]
	stp	q0, q0, [sp, #160]
	stp	q0, q0, [sp, #192]
	stp	q0, q0, [sp, #224]
	bl	backtrace
	cmp	w0, #0
	b.le	.LBB4_3
// %bb.1:
	mov	w20, w0
	adrp	x1, .L.str.9
	add	x1, x1, :lo12:.L.str.9
	mov	w0, w19
	mov	w2, #9                          // =0x9
	bl	write
	mov	x0, sp
	mov	w1, w20
	mov	w2, w19
	bl	backtrace_symbols_fd
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB4_4
.LBB4_2:
	.cfi_def_cfa wsp, 320
	ldp	x20, x19, [sp, #304]            // 16-byte Folded Reload
	ldr	x28, [sp, #288]                 // 8-byte Reload
	ldp	x29, x30, [sp, #272]            // 16-byte Folded Reload
	add	sp, sp, #320
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w28
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB4_3:
	.cfi_restore_state
	adrp	x1, .L.str.8
	add	x1, x1, :lo12:.L.str.8
	mov	w0, w19
	mov	w2, #14                         // =0xe
	bl	write
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.eq	.LBB4_2
.LBB4_4:
	bl	__stack_chk_fail
.Lfunc_end4:
	.size	crl__lib__std__x86_64__linux__error____backtraceTo, .Lfunc_end4-crl__lib__std__x86_64__linux__error____backtraceTo
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____abortNow // -- Begin function crl__lib__std__x86_64__linux__error____abortNow
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____abortNow,@function
crl__lib__std__x86_64__linux__error____abortNow: // @crl__lib__std__x86_64__linux__error____abortNow
	.cfi_startproc
// %bb.0:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	str	x19, [sp, #16]                  // 8-byte Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w19, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	adrp	x19, .L_MergedGlobals
	mov	x1, xzr
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	signal
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	raise
	mov	w0, #134                        // =0x86
	bl	_exit
.Lfunc_end5:
	.size	crl__lib__std__x86_64__linux__error____abortNow, .Lfunc_end5-crl__lib__std__x86_64__linux__error____abortNow
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____oomFatal // -- Begin function crl__lib__std__x86_64__linux__error____oomFatal
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____oomFatal,@function
crl__lib__std__x86_64__linux__error____oomFatal: // @crl__lib__std__x86_64__linux__error____oomFatal
	.cfi_startproc
// %bb.0:
	stp	x29, x30, [sp, #-16]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x1, .L.str.10
	add	x1, x1, :lo12:.L.str.10
	mov	w0, #2                          // =0x2
	mov	w2, #21                         // =0x15
	bl	crl__lib__std__x86_64__linux__error___wr
	adrp	x1, .L.str.11
	add	x1, x1, :lo12:.L.str.11
	mov	w0, #2                          // =0x2
	mov	w2, #69                         // =0x45
	bl	crl__lib__std__x86_64__linux__error___wr
	mov	w0, #2                          // =0x2
	bl	_exit
.Lfunc_end6:
	.size	crl__lib__std__x86_64__linux__error____oomFatal, .Lfunc_end6-crl__lib__std__x86_64__linux__error____oomFatal
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____report // -- Begin function crl__lib__std__x86_64__linux__error____report
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____report,@function
crl__lib__std__x86_64__linux__error____report: // @crl__lib__std__x86_64__linux__error____report
	.cfi_startproc
// %bb.0:
	sub	sp, sp, #320
	.cfi_def_cfa_offset 320
	stp	x29, x30, [sp, #272]            // 16-byte Folded Spill
	str	x28, [sp, #288]                 // 8-byte Spill
	stp	x20, x19, [sp, #304]            // 16-byte Folded Spill
	add	x29, sp, #272
	.cfi_def_cfa w29, 48
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w28, -32
	.cfi_offset w30, -40
	.cfi_offset w29, -48
	.cfi_remember_state
	adrp	x8, :got:__stack_chk_guard
	mov	x19, x1
	mov	x20, x0
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	adrp	x1, .L.str.12
	add	x1, x1, :lo12:.L.str.12
	mov	w0, #2                          // =0x2
	mov	w2, #15                         // =0xf
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x20
	mov	x2, x19
	bl	write
	adrp	x1, .L.str.13
	add	x1, x1, :lo12:.L.str.13
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	movi	v0.2d, #0000000000000000
	mov	x0, sp
	mov	w1, #32                         // =0x20
	stp	q0, q0, [sp]
	stp	q0, q0, [sp, #32]
	stp	q0, q0, [sp, #64]
	stp	q0, q0, [sp, #96]
	stp	q0, q0, [sp, #128]
	stp	q0, q0, [sp, #160]
	stp	q0, q0, [sp, #192]
	stp	q0, q0, [sp, #224]
	bl	backtrace
	cmp	w0, #0
	b.le	.LBB7_2
// %bb.1:
	mov	w19, w0
	adrp	x1, .L.str.9
	add	x1, x1, :lo12:.L.str.9
	mov	w0, #2                          // =0x2
	mov	w2, #9                          // =0x9
	bl	write
	mov	x0, sp
	mov	w1, w19
	mov	w2, #2                          // =0x2
	bl	backtrace_symbols_fd
	b	.LBB7_3
.LBB7_2:
	adrp	x1, .L.str.8
	add	x1, x1, :lo12:.L.str.8
	mov	w0, #2                          // =0x2
	mov	w2, #14                         // =0xe
	bl	write
.LBB7_3:
	adrp	x1, .L.str.13
	add	x1, x1, :lo12:.L.str.13
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB7_5
// %bb.4:
	.cfi_def_cfa wsp, 320
	ldp	x20, x19, [sp, #304]            // 16-byte Folded Reload
	ldr	x28, [sp, #288]                 // 8-byte Reload
	ldp	x29, x30, [sp, #272]            // 16-byte Folded Reload
	add	sp, sp, #320
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w28
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB7_5:
	.cfi_restore_state
	bl	__stack_chk_fail
.Lfunc_end7:
	.size	crl__lib__std__x86_64__linux__error____report, .Lfunc_end7-crl__lib__std__x86_64__linux__error____report
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____reportHex // -- Begin function crl__lib__std__x86_64__linux__error____reportHex
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____reportHex,@function
crl__lib__std__x86_64__linux__error____reportHex: // @crl__lib__std__x86_64__linux__error____reportHex
	.cfi_startproc
// %bb.0:
	sub	sp, sp, #336
	.cfi_def_cfa_offset 336
	stp	x29, x30, [sp, #272]            // 16-byte Folded Spill
	stp	x28, x23, [sp, #288]            // 16-byte Folded Spill
	stp	x22, x21, [sp, #304]            // 16-byte Folded Spill
	stp	x20, x19, [sp, #320]            // 16-byte Folded Spill
	add	x29, sp, #272
	.cfi_def_cfa w29, 64
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -24
	.cfi_offset w22, -32
	.cfi_offset w23, -40
	.cfi_offset w28, -48
	.cfi_offset w30, -56
	.cfi_offset w29, -64
	.cfi_remember_state
	adrp	x8, :got:__stack_chk_guard
	mov	x21, x2
	mov	x22, x1
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	mov	x23, x0
	adrp	x1, .L.str.12
	add	x1, x1, :lo12:.L.str.12
	mov	w0, #2                          // =0x2
	mov	w2, #15                         // =0xf
	ldr	x8, [x8]
	mov	x19, x4
	mov	x20, x3
	stur	x8, [x29, #-8]
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x23
	mov	x2, x22
	bl	write
	adrp	x1, .L.str.14
	add	x1, x1, :lo12:.L.str.14
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x21
	mov	x2, x20
	bl	write
	adrp	x1, .L.str.15
	add	x1, x1, :lo12:.L.str.15
	mov	w0, #2                          // =0x2
	mov	w2, #3                          // =0x3
	bl	write
	adrp	x1, .L.str
	add	x1, x1, :lo12:.L.str
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	lsr	x8, x19, #60
	cbz	x8, .LBB8_2
// %bb.1:
	lsr	x9, x19, #61
	orr	w10, w8, #0x30
	add	w8, w8, #87
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	cmp	x9, #5
	csel	w8, w10, w8, lo
	strb	w8, [sp]
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
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
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
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
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
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
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
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
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
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
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
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
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
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
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
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	cmp	w9, #5
	csel	w8, w10, w8, lo
	strb	w8, [sp]
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
	cbz	w8, .LBB8_30
.LBB8_19:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
	bl	write
	ubfx	w8, w19, #20, #4
.LBB8_20:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
	bl	write
	ubfx	w8, w19, #16, #4
.LBB8_21:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
	bl	write
	ubfx	w8, w19, #12, #4
.LBB8_22:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
	bl	write
	ubfx	w8, w19, #8, #4
.LBB8_23:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
	bl	write
	ubfx	w8, w19, #4, #4
.LBB8_24:
	orr	w9, w8, #0x30
	add	w10, w8, #87
	cmp	w8, #10
	csel	w8, w9, w10, lo
	mov	x1, sp
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp]
	bl	write
.LBB8_25:
	mov	w8, #48                         // =0x30
	and	w9, w19, #0xf
	mov	x1, sp
	bfxil	w8, w19, #0, #4
	add	w10, w9, #87
	cmp	w9, #10
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	csel	w8, w8, w10, lo
	strb	w8, [sp]
	bl	write
	adrp	x1, .L.str.16
	add	x1, x1, :lo12:.L.str.16
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	movi	v0.2d, #0000000000000000
	mov	x0, sp
	mov	w1, #32                         // =0x20
	stp	q0, q0, [sp]
	stp	q0, q0, [sp, #32]
	stp	q0, q0, [sp, #64]
	stp	q0, q0, [sp, #96]
	stp	q0, q0, [sp, #128]
	stp	q0, q0, [sp, #160]
	stp	q0, q0, [sp, #192]
	stp	q0, q0, [sp, #224]
	bl	backtrace
	cmp	w0, #0
	b.le	.LBB8_27
// %bb.26:
	mov	w19, w0
	adrp	x1, .L.str.9
	add	x1, x1, :lo12:.L.str.9
	mov	w0, #2                          // =0x2
	mov	w2, #9                          // =0x9
	bl	write
	mov	x0, sp
	mov	w1, w19
	mov	w2, #2                          // =0x2
	bl	backtrace_symbols_fd
	b	.LBB8_28
.LBB8_27:
	adrp	x1, .L.str.8
	add	x1, x1, :lo12:.L.str.8
	mov	w0, #2                          // =0x2
	mov	w2, #14                         // =0xe
	bl	write
.LBB8_28:
	adrp	x1, .L.str.13
	add	x1, x1, :lo12:.L.str.13
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldur	x9, [x29, #-8]
	ldr	x8, [x8]
	cmp	x8, x9
	b.ne	.LBB8_35
// %bb.29:
	.cfi_def_cfa wsp, 336
	ldp	x20, x19, [sp, #320]            // 16-byte Folded Reload
	ldp	x22, x21, [sp, #304]            // 16-byte Folded Reload
	ldp	x28, x23, [sp, #288]            // 16-byte Folded Reload
	ldp	x29, x30, [sp, #272]            // 16-byte Folded Reload
	add	sp, sp, #336
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w22
	.cfi_restore w23
	.cfi_restore w28
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB8_30:
	.cfi_restore_state
	ubfx	w8, w19, #20, #4
	cbnz	w8, .LBB8_20
// %bb.31:
	ubfx	w8, w19, #16, #4
	cbnz	w8, .LBB8_21
// %bb.32:
	ubfx	w8, w19, #12, #4
	cbnz	w8, .LBB8_22
// %bb.33:
	ubfx	w8, w19, #8, #4
	cbnz	w8, .LBB8_23
// %bb.34:
	ubfx	w8, w19, #4, #4
	cbnz	w8, .LBB8_24
	b	.LBB8_25
.LBB8_35:
	bl	__stack_chk_fail
.Lfunc_end8:
	.size	crl__lib__std__x86_64__linux__error____reportHex, .Lfunc_end8-crl__lib__std__x86_64__linux__error____reportHex
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____panic // -- Begin function crl__lib__std__x86_64__linux__error____panic
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____panic,@function
crl__lib__std__x86_64__linux__error____panic: // @crl__lib__std__x86_64__linux__error____panic
	.cfi_startproc
// %bb.0:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	str	x19, [sp, #16]                  // 8-byte Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w19, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	bl	crl__lib__std__x86_64__linux__error____report
	adrp	x19, .L_MergedGlobals
	mov	x1, xzr
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	signal
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	raise
	mov	w0, #134                        // =0x86
	bl	_exit
.Lfunc_end9:
	.size	crl__lib__std__x86_64__linux__error____panic, .Lfunc_end9-crl__lib__std__x86_64__linux__error____panic
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____unreachable // -- Begin function crl__lib__std__x86_64__linux__error____unreachable
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____unreachable,@function
crl__lib__std__x86_64__linux__error____unreachable: // @crl__lib__std__x86_64__linux__error____unreachable
	.cfi_startproc
// %bb.0:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	str	x19, [sp, #16]                  // 8-byte Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w19, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	bl	crl__lib__std__x86_64__linux__error____report
	adrp	x19, .L_MergedGlobals
	mov	x1, xzr
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	signal
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	raise
	mov	w0, #134                        // =0x86
	bl	_exit
.Lfunc_end10:
	.size	crl__lib__std__x86_64__linux__error____unreachable, .Lfunc_end10-crl__lib__std__x86_64__linux__error____unreachable
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assert // -- Begin function crl__lib__std__x86_64__linux__error____assert
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assert,@function
crl__lib__std__x86_64__linux__error____assert: // @crl__lib__std__x86_64__linux__error____assert
	.cfi_startproc
// %bb.0:
	tbz	w0, #0, .LBB11_2
// %bb.1:
	ret
.LBB11_2:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	str	x19, [sp, #16]                  // 8-byte Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w19, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	adrp	x0, .L.str.17
	add	x0, x0, :lo12:.L.str.17
	mov	w1, #16                         // =0x10
	bl	crl__lib__std__x86_64__linux__error____report
	adrp	x19, .L_MergedGlobals
	mov	x1, xzr
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	signal
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	raise
	mov	w0, #134                        // =0x86
	bl	_exit
.Lfunc_end11:
	.size	crl__lib__std__x86_64__linux__error____assert, .Lfunc_end11-crl__lib__std__x86_64__linux__error____assert
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertOut // -- Begin function crl__lib__std__x86_64__linux__error____assertOut
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertOut,@function
crl__lib__std__x86_64__linux__error____assertOut: // @crl__lib__std__x86_64__linux__error____assertOut
	.cfi_startproc
// %bb.0:
	tbz	w0, #0, .LBB12_2
// %bb.1:
	ret
.LBB12_2:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	str	x19, [sp, #16]                  // 8-byte Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w19, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	mov	x0, x1
	mov	x1, x2
	bl	crl__lib__std__x86_64__linux__error____report
	adrp	x19, .L_MergedGlobals
	mov	x1, xzr
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	signal
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	raise
	mov	w0, #134                        // =0x86
	bl	_exit
.Lfunc_end12:
	.size	crl__lib__std__x86_64__linux__error____assertOut, .Lfunc_end12-crl__lib__std__x86_64__linux__error____assertOut
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error___failCmp // -- Begin function crl__lib__std__x86_64__linux__error___failCmp
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error___failCmp,@function
crl__lib__std__x86_64__linux__error___failCmp: // @crl__lib__std__x86_64__linux__error___failCmp
	.cfi_startproc
// %bb.0:
	sub	sp, sp, #368
	.cfi_def_cfa_offset 368
	stp	x29, x30, [sp, #272]            // 16-byte Folded Spill
	stp	x28, x27, [sp, #288]            // 16-byte Folded Spill
	stp	x26, x25, [sp, #304]            // 16-byte Folded Spill
	stp	x24, x23, [sp, #320]            // 16-byte Folded Spill
	stp	x22, x21, [sp, #336]            // 16-byte Folded Spill
	stp	x20, x19, [sp, #352]            // 16-byte Folded Spill
	add	x29, sp, #272
	.cfi_def_cfa w29, 96
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -24
	.cfi_offset w22, -32
	.cfi_offset w23, -40
	.cfi_offset w24, -48
	.cfi_offset w25, -56
	.cfi_offset w26, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	.cfi_offset w30, -88
	.cfi_offset w29, -96
	mov	x24, x2
	mov	x22, x1
	mov	x23, x0
	adrp	x1, .L.str.18
	add	x1, x1, :lo12:.L.str.18
	mov	w0, #2                          // =0x2
	mov	w2, #22                         // =0x16
	mov	x19, x5
	mov	x20, x4
	mov	x21, x3
	add	x25, sp, #16
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x23
	mov	x2, x22
	bl	write
	adrp	x1, .L.str.19
	add	x1, x1, :lo12:.L.str.19
	mov	w0, #2                          // =0x2
	mov	w2, #9                          // =0x9
	bl	write
	cbnz	x24, .LBB13_2
// %bb.1:
	adrp	x1, .L.str.1
	add	x1, x1, :lo12:.L.str.1
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	b	.LBB13_5
.LBB13_2:
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	sub	x26, x25, #1
	mov	w27, #1                         // =0x1
	movk	x8, #52429
	mov	w9, #10                         // =0xa
	stp	xzr, xzr, [sp, #16]
	str	wzr, [sp, #32]
.LBB13_3:                               // =>This Inner Loop Header: Depth=1
	umulh	x10, x24, x8
	cmp	x24, #9
	add	w27, w27, #1
	lsr	x10, x10, #3
	msub	w11, w10, w9, w24
	mov	x24, x10
	orr	w11, w11, #0x30
	strb	w11, [x26, #1]!
	b.hi	.LBB13_3
.LBB13_4:                               // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x26], #-1
	add	x1, sp, #12
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #12]
	bl	write
	sub	w27, w27, #1
	cmp	w27, #1
	b.gt	.LBB13_4
.LBB13_5:
	adrp	x24, .L.str.20
	add	x24, x24, :lo12:.L.str.20
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
	cbnz	x21, .LBB13_7
// %bb.6:
	adrp	x1, .L.str.1
	add	x1, x1, :lo12:.L.str.1
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	b	.LBB13_10
.LBB13_7:
	add	x8, sp, #16
	mov	w22, #1                         // =0x1
	mov	w9, #10                         // =0xa
	sub	x23, x8, #1
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	stp	xzr, xzr, [sp, #16]
	movk	x8, #52429
	str	wzr, [sp, #32]
.LBB13_8:                               // =>This Inner Loop Header: Depth=1
	umulh	x10, x21, x8
	cmp	x21, #9
	add	w22, w22, #1
	lsr	x10, x10, #3
	msub	w11, w10, w9, w21
	mov	x21, x10
	orr	w11, w11, #0x30
	strb	w11, [x23, #1]!
	b.hi	.LBB13_8
.LBB13_9:                               // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x23], #-1
	add	x1, sp, #12
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #12]
	bl	write
	sub	w22, w22, #1
	cmp	w22, #1
	b.gt	.LBB13_9
.LBB13_10:
	adrp	x1, .L.str.21
	add	x1, x1, :lo12:.L.str.21
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	mov	w0, #2                          // =0x2
	mov	x1, x20
	mov	x2, x19
	bl	write
	adrp	x1, .L.str.13
	add	x1, x1, :lo12:.L.str.13
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	movi	v0.2d, #0000000000000000
	add	x0, sp, #16
	mov	w1, #32                         // =0x20
	stp	q0, q0, [x25, #128]
	stp	q0, q0, [x25, #160]
	stp	q0, q0, [x25, #192]
	stp	q0, q0, [x25, #224]
	stp	q0, q0, [sp, #16]
	stp	q0, q0, [sp, #48]
	stp	q0, q0, [sp, #80]
	stp	q0, q0, [sp, #112]
	bl	backtrace
	cmp	w0, #0
	b.gt	.LBB13_12
// %bb.11:
	adrp	x1, .L.str.8
	add	x1, x1, :lo12:.L.str.8
	mov	w0, #2                          // =0x2
	mov	w2, #14                         // =0xe
	bl	write
	b	.LBB13_13
.LBB13_12:
	mov	w19, w0
	adrp	x1, .L.str.9
	add	x1, x1, :lo12:.L.str.9
	mov	w0, #2                          // =0x2
	mov	w2, #9                          // =0x9
	bl	write
	add	x0, sp, #16
	mov	w1, w19
	mov	w2, #2                          // =0x2
	bl	backtrace_symbols_fd
.LBB13_13:
	adrp	x1, .L.str.13
	add	x1, x1, :lo12:.L.str.13
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x19, .L_MergedGlobals
	mov	x1, xzr
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	signal
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	raise
	mov	w0, #134                        // =0x86
	bl	_exit
.Lfunc_end13:
	.size	crl__lib__std__x86_64__linux__error___failCmp, .Lfunc_end13-crl__lib__std__x86_64__linux__error___failCmp
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertEq // -- Begin function crl__lib__std__x86_64__linux__error____assertEq
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertEq,@function
crl__lib__std__x86_64__linux__error____assertEq: // @crl__lib__std__x86_64__linux__error____assertEq
	.cfi_startproc
// %bb.0:
	cmp	x0, x1
	b.ne	.LBB14_2
// %bb.1:
	ret
.LBB14_2:
	stp	x29, x30, [sp, #-16]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x5, x3
	mov	x3, x0
	mov	x4, x2
	adrp	x0, .L.str.22
	add	x0, x0, :lo12:.L.str.22
	mov	x2, x1
	mov	w1, #2                          // =0x2
	bl	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end14:
	.size	crl__lib__std__x86_64__linux__error____assertEq, .Lfunc_end14-crl__lib__std__x86_64__linux__error____assertEq
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertNe // -- Begin function crl__lib__std__x86_64__linux__error____assertNe
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertNe,@function
crl__lib__std__x86_64__linux__error____assertNe: // @crl__lib__std__x86_64__linux__error____assertNe
	.cfi_startproc
// %bb.0:
	cmp	x0, x1
	b.eq	.LBB15_2
// %bb.1:
	ret
.LBB15_2:
	stp	x29, x30, [sp, #-16]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x5, x3
	mov	x3, x0
	mov	x4, x2
	adrp	x0, .L.str.23
	add	x0, x0, :lo12:.L.str.23
	mov	w1, #2                          // =0x2
	mov	x2, x3
	bl	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end15:
	.size	crl__lib__std__x86_64__linux__error____assertNe, .Lfunc_end15-crl__lib__std__x86_64__linux__error____assertNe
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertLt // -- Begin function crl__lib__std__x86_64__linux__error____assertLt
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertLt,@function
crl__lib__std__x86_64__linux__error____assertLt: // @crl__lib__std__x86_64__linux__error____assertLt
	.cfi_startproc
// %bb.0:
	cmp	x0, x1
	b.hs	.LBB16_2
// %bb.1:
	ret
.LBB16_2:
	stp	x29, x30, [sp, #-16]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, .L.str.24
	add	x8, x8, :lo12:.L.str.24
	mov	x5, x3
	mov	x3, x1
	mov	x4, x2
	mov	x2, x0
	mov	x0, x8
	mov	w1, #1                          // =0x1
	bl	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end16:
	.size	crl__lib__std__x86_64__linux__error____assertLt, .Lfunc_end16-crl__lib__std__x86_64__linux__error____assertLt
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertLe // -- Begin function crl__lib__std__x86_64__linux__error____assertLe
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertLe,@function
crl__lib__std__x86_64__linux__error____assertLe: // @crl__lib__std__x86_64__linux__error____assertLe
	.cfi_startproc
// %bb.0:
	cmp	x0, x1
	b.hi	.LBB17_2
// %bb.1:
	ret
.LBB17_2:
	stp	x29, x30, [sp, #-16]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, .L.str.25
	add	x8, x8, :lo12:.L.str.25
	mov	x5, x3
	mov	x3, x1
	mov	x4, x2
	mov	x2, x0
	mov	x0, x8
	mov	w1, #2                          // =0x2
	bl	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end17:
	.size	crl__lib__std__x86_64__linux__error____assertLe, .Lfunc_end17-crl__lib__std__x86_64__linux__error____assertLe
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertGt // -- Begin function crl__lib__std__x86_64__linux__error____assertGt
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertGt,@function
crl__lib__std__x86_64__linux__error____assertGt: // @crl__lib__std__x86_64__linux__error____assertGt
	.cfi_startproc
// %bb.0:
	cmp	x0, x1
	b.ls	.LBB18_2
// %bb.1:
	ret
.LBB18_2:
	stp	x29, x30, [sp, #-16]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, .L.str.26
	add	x8, x8, :lo12:.L.str.26
	mov	x5, x3
	mov	x3, x1
	mov	x4, x2
	mov	x2, x0
	mov	x0, x8
	mov	w1, #1                          // =0x1
	bl	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end18:
	.size	crl__lib__std__x86_64__linux__error____assertGt, .Lfunc_end18-crl__lib__std__x86_64__linux__error____assertGt
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertGe // -- Begin function crl__lib__std__x86_64__linux__error____assertGe
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertGe,@function
crl__lib__std__x86_64__linux__error____assertGe: // @crl__lib__std__x86_64__linux__error____assertGe
	.cfi_startproc
// %bb.0:
	cmp	x0, x1
	b.lo	.LBB19_2
// %bb.1:
	ret
.LBB19_2:
	stp	x29, x30, [sp, #-16]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 16
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, .L.str.27
	add	x8, x8, :lo12:.L.str.27
	mov	x5, x3
	mov	x3, x1
	mov	x4, x2
	mov	x2, x0
	mov	x0, x8
	mov	w1, #2                          // =0x2
	bl	crl__lib__std__x86_64__linux__error___failCmp
.Lfunc_end19:
	.size	crl__lib__std__x86_64__linux__error____assertGe, .Lfunc_end19-crl__lib__std__x86_64__linux__error____assertGe
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertRange // -- Begin function crl__lib__std__x86_64__linux__error____assertRange
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertRange,@function
crl__lib__std__x86_64__linux__error____assertRange: // @crl__lib__std__x86_64__linux__error____assertRange
	.cfi_startproc
// %bb.0:
	sub	sp, sp, #352
	.cfi_def_cfa_offset 352
	stp	x29, x30, [sp, #304]            // 16-byte Folded Spill
	stp	x28, x21, [sp, #320]            // 16-byte Folded Spill
	stp	x20, x19, [sp, #336]            // 16-byte Folded Spill
	add	x29, sp, #304
	.cfi_def_cfa w29, 48
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -24
	.cfi_offset w28, -32
	.cfi_offset w30, -40
	.cfi_offset w29, -48
	.cfi_remember_state
	adrp	x8, :got:__stack_chk_guard
	cmp	x0, x1
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	b.hs	.LBB20_3
// %bb.1:
	ldur	x9, [x29, #-8]
	cmp	x8, x9
	b.ne	.LBB20_5
// %bb.2:
	.cfi_def_cfa wsp, 352
	ldp	x20, x19, [sp, #336]            // 16-byte Folded Reload
	ldp	x28, x21, [sp, #320]            // 16-byte Folded Reload
	ldp	x29, x30, [sp, #304]            // 16-byte Folded Reload
	add	sp, sp, #352
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w21
	.cfi_restore w28
	.cfi_restore w30
	.cfi_restore w29
	ret
.LBB20_3:
	.cfi_restore_state
	stp	x3, x1, [sp, #8]                // 16-byte Folded Spill
	adrp	x1, .L.str.28
	add	x1, x1, :lo12:.L.str.28
	str	x2, [sp]                        // 8-byte Spill
	mov	x19, x0
	mov	w0, #2                          // =0x2
	mov	w2, #21                         // =0x15
	bl	write
	cbnz	x19, .LBB20_6
// %bb.4:
	adrp	x1, .L.str.1
	add	x1, x1, :lo12:.L.str.1
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	b	.LBB20_9
.LBB20_5:
	bl	__stack_chk_fail
.LBB20_6:
	add	x8, sp, #32
	mov	x10, x19
	mov	w19, #1                         // =0x1
	sub	x20, x8, #1
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	mov	w9, #10                         // =0xa
	movk	x8, #52429
	stp	xzr, xzr, [sp, #32]
	str	wzr, [sp, #48]
.LBB20_7:                               // =>This Inner Loop Header: Depth=1
	umulh	x11, x10, x8
	cmp	x10, #9
	add	w19, w19, #1
	lsr	x11, x11, #3
	msub	w12, w11, w9, w10
	mov	x10, x11
	orr	w12, w12, #0x30
	strb	w12, [x20, #1]!
	b.hi	.LBB20_7
.LBB20_8:                               // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x20], #-1
	add	x1, sp, #28
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #28]
	bl	write
	sub	w19, w19, #1
	cmp	w19, #1
	b.gt	.LBB20_8
.LBB20_9:
	adrp	x1, .L.str.29
	add	x1, x1, :lo12:.L.str.29
	mov	w0, #2                          // =0x2
	mov	w2, #26                         // =0x1a
	add	x19, sp, #32
	bl	write
	ldr	x8, [sp, #16]                   // 8-byte Reload
	cbnz	x8, .LBB20_11
// %bb.10:
	adrp	x1, .L.str.1
	add	x1, x1, :lo12:.L.str.1
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	b	.LBB20_14
.LBB20_11:
	add	x8, sp, #32
	ldr	x10, [sp, #16]                  // 8-byte Reload
	mov	w20, #1                         // =0x1
	sub	x21, x8, #1
	mov	x8, #-3689348814741910324       // =0xcccccccccccccccc
	mov	w9, #10                         // =0xa
	movk	x8, #52429
	stp	xzr, xzr, [sp, #32]
	str	wzr, [sp, #48]
.LBB20_12:                              // =>This Inner Loop Header: Depth=1
	umulh	x11, x10, x8
	cmp	x10, #9
	add	w20, w20, #1
	lsr	x11, x11, #3
	msub	w12, w11, w9, w10
	mov	x10, x11
	orr	w12, w12, #0x30
	strb	w12, [x21, #1]!
	b.hi	.LBB20_12
.LBB20_13:                              // =>This Inner Loop Header: Depth=1
	ldrb	w8, [x21], #-1
	add	x1, sp, #28
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	strb	w8, [sp, #28]
	bl	write
	sub	w20, w20, #1
	cmp	w20, #1
	b.gt	.LBB20_13
.LBB20_14:
	adrp	x1, .L.str.21
	add	x1, x1, :lo12:.L.str.21
	mov	w0, #2                          // =0x2
	mov	w2, #2                          // =0x2
	bl	write
	ldp	x1, x2, [sp]                    // 16-byte Folded Reload
	mov	w0, #2                          // =0x2
	bl	write
	adrp	x1, .L.str.13
	add	x1, x1, :lo12:.L.str.13
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	movi	v0.2d, #0000000000000000
	add	x0, sp, #32
	mov	w1, #32                         // =0x20
	stp	q0, q0, [x19, #128]
	stp	q0, q0, [x19, #160]
	stp	q0, q0, [x19, #192]
	stp	q0, q0, [x19, #224]
	stp	q0, q0, [sp, #32]
	stp	q0, q0, [sp, #64]
	stp	q0, q0, [sp, #96]
	stp	q0, q0, [sp, #128]
	bl	backtrace
	cmp	w0, #0
	b.gt	.LBB20_16
// %bb.15:
	adrp	x1, .L.str.8
	add	x1, x1, :lo12:.L.str.8
	mov	w0, #2                          // =0x2
	mov	w2, #14                         // =0xe
	bl	write
	b	.LBB20_17
.LBB20_16:
	mov	w19, w0
	adrp	x1, .L.str.9
	add	x1, x1, :lo12:.L.str.9
	mov	w0, #2                          // =0x2
	mov	w2, #9                          // =0x9
	bl	write
	add	x0, sp, #32
	mov	w1, w19
	mov	w2, #2                          // =0x2
	bl	backtrace_symbols_fd
.LBB20_17:
	adrp	x1, .L.str.13
	add	x1, x1, :lo12:.L.str.13
	mov	w0, #2                          // =0x2
	mov	w2, #1                          // =0x1
	bl	write
	adrp	x19, .L_MergedGlobals
	mov	x1, xzr
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	signal
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	raise
	mov	w0, #134                        // =0x86
	bl	_exit
.Lfunc_end20:
	.size	crl__lib__std__x86_64__linux__error____assertRange, .Lfunc_end20-crl__lib__std__x86_64__linux__error____assertRange
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertNonNull // -- Begin function crl__lib__std__x86_64__linux__error____assertNonNull
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertNonNull,@function
crl__lib__std__x86_64__linux__error____assertNonNull: // @crl__lib__std__x86_64__linux__error____assertNonNull
	.cfi_startproc
// %bb.0:
	cbz	x0, .LBB21_2
// %bb.1:
	ret
.LBB21_2:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	str	x19, [sp, #16]                  // 8-byte Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w19, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	mov	x0, x1
	mov	x1, x2
	bl	crl__lib__std__x86_64__linux__error____report
	adrp	x19, .L_MergedGlobals
	mov	x1, xzr
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	signal
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	raise
	mov	w0, #134                        // =0x86
	bl	_exit
.Lfunc_end21:
	.size	crl__lib__std__x86_64__linux__error____assertNonNull, .Lfunc_end21-crl__lib__std__x86_64__linux__error____assertNonNull
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____assertAligned // -- Begin function crl__lib__std__x86_64__linux__error____assertAligned
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____assertAligned,@function
crl__lib__std__x86_64__linux__error____assertAligned: // @crl__lib__std__x86_64__linux__error____assertAligned
	.cfi_startproc
// %bb.0:
	sub	x8, x1, #1
	tst	x8, x0
	b.ne	.LBB22_2
// %bb.1:
	ret
.LBB22_2:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	str	x19, [sp, #16]                  // 8-byte Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w19, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	adrp	x8, .L.str.30
	add	x8, x8, :lo12:.L.str.30
	mov	x4, x0
	mov	x0, x2
	mov	x1, x3
	mov	x2, x8
	mov	w3, #7                          // =0x7
	bl	crl__lib__std__x86_64__linux__error____reportHex
	adrp	x19, .L_MergedGlobals
	mov	x1, xzr
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	signal
	ldr	w0, [x19, :lo12:.L_MergedGlobals]
	bl	raise
	mov	w0, #134                        // =0x86
	bl	_exit
.Lfunc_end22:
	.size	crl__lib__std__x86_64__linux__error____assertAligned, .Lfunc_end22-crl__lib__std__x86_64__linux__error____assertAligned
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error___fatalHandler // -- Begin function crl__lib__std__x86_64__linux__error___fatalHandler
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error___fatalHandler,@function
crl__lib__std__x86_64__linux__error___fatalHandler: // @crl__lib__std__x86_64__linux__error___fatalHandler
	.cfi_startproc
// %bb.0:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	stp	x20, x19, [sp, #16]             // 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	adrp	x8, crl__lib__std__x86_64__linux__error___handling
	mov	w19, w0
	ldrb	w9, [x8, :lo12:crl__lib__std__x86_64__linux__error___handling]
	cbz	w9, .LBB23_2
// %bb.1:
	add	w0, w19, #128
	bl	_exit
.LBB23_2:
	mov	w9, #1                          // =0x1
	adrp	x1, .L.str.31
	add	x1, x1, :lo12:.L.str.31
	mov	w0, #2                          // =0x2
	mov	w2, #15                         // =0xf
	strb	w9, [x8, :lo12:crl__lib__std__x86_64__linux__error___handling]
	bl	crl__lib__std__x86_64__linux__error___wr
	mov	w0, #2                          // =0x2
	mov	w1, w19
	bl	crl__lib__std__x86_64__linux__error___wrSigName
	adrp	x20, .L.str.13
	add	x20, x20, :lo12:.L.str.13
	mov	w0, #2                          // =0x2
	mov	x1, x20
	mov	w2, #1                          // =0x1
	bl	crl__lib__std__x86_64__linux__error___wr
	mov	w0, #2                          // =0x2
	bl	crl__lib__std__x86_64__linux__error____backtraceTo
	mov	w0, #2                          // =0x2
	mov	x1, x20
	mov	w2, #1                          // =0x1
	bl	crl__lib__std__x86_64__linux__error___wr
	mov	w0, w19
	mov	x1, xzr
	bl	signal
	mov	w0, w19
	bl	raise
	add	w0, w19, #128
	bl	_exit
.Lfunc_end23:
	.size	crl__lib__std__x86_64__linux__error___fatalHandler, .Lfunc_end23-crl__lib__std__x86_64__linux__error___fatalHandler
	.cfi_endproc
                                        // -- End function
	.globl	crl__lib__std__x86_64__linux__error____catchFatalSignals // -- Begin function crl__lib__std__x86_64__linux__error____catchFatalSignals
	.p2align	2
	.type	crl__lib__std__x86_64__linux__error____catchFatalSignals,@function
crl__lib__std__x86_64__linux__error____catchFatalSignals: // @crl__lib__std__x86_64__linux__error____catchFatalSignals
	.cfi_startproc
// %bb.0:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	stp	x20, x19, [sp, #16]             // 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	adrp	x20, .L_MergedGlobals+4
	add	x20, x20, :lo12:.L_MergedGlobals+4
	adrp	x19, crl__lib__std__x86_64__linux__error___fatalHandler
	add	x19, x19, :lo12:crl__lib__std__x86_64__linux__error___fatalHandler
	ldr	w0, [x20, #12]
	mov	x1, x19
	bl	signal
	ldr	w0, [x20]
	mov	x1, x19
	bl	signal
	ldr	w0, [x20, #8]
	mov	x1, x19
	bl	signal
	ldr	w0, [x20, #4]
	mov	x1, x19
	.cfi_def_cfa wsp, 32
	ldp	x20, x19, [sp, #16]             // 16-byte Folded Reload
	ldp	x29, x30, [sp], #32             // 16-byte Folded Reload
	.cfi_def_cfa_offset 0
	.cfi_restore w19
	.cfi_restore w20
	.cfi_restore w30
	.cfi_restore w29
	b	signal
.Lfunc_end24:
	.size	crl__lib__std__x86_64__linux__error____catchFatalSignals, .Lfunc_end24-crl__lib__std__x86_64__linux__error____catchFatalSignals
	.cfi_endproc
                                        // -- End function
	.type	.L.str,@object                  // @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"0x"
	.size	.L.str, 3

	.type	.L.str.1,@object                // @.str.1
.L.str.1:
	.asciz	"0"
	.size	.L.str.1, 2

	.type	.L.str.2,@object                // @.str.2
.L.str.2:
	.asciz	"SIGSEGV (segmentation fault)"
	.size	.L.str.2, 29

	.type	.L.str.3,@object                // @.str.3
.L.str.3:
	.asciz	"SIGBUS (bus error)"
	.size	.L.str.3, 19

	.type	.L.str.4,@object                // @.str.4
.L.str.4:
	.asciz	"SIGILL (illegal instruction)"
	.size	.L.str.4, 29

	.type	.L.str.5,@object                // @.str.5
.L.str.5:
	.asciz	"SIGFPE (arithmetic fault)"
	.size	.L.str.5, 26

	.type	.L.str.6,@object                // @.str.6
.L.str.6:
	.asciz	"SIGABRT (abort)"
	.size	.L.str.6, 16

	.type	.L.str.7,@object                // @.str.7
.L.str.7:
	.asciz	"signal "
	.size	.L.str.7, 8

	.type	.L.str.8,@object                // @.str.8
.L.str.8:
	.asciz	"  <no frames>\n"
	.size	.L.str.8, 15

	.type	.L.str.9,@object                // @.str.9
.L.str.9:
	.asciz	"  stack:\n"
	.size	.L.str.9, 10

	.type	.L.str.10,@object               // @.str.10
.L.str.10:
	.asciz	"coral: out of memory\n"
	.size	.L.str.10, 22

	.type	.L.str.11,@object               // @.str.11
.L.str.11:
	.asciz	"  the compiler could not allocate memory; try coralc --explain D0003\n"
	.size	.L.str.11, 70

	.type	.L.str.12,@object               // @.str.12
.L.str.12:
	.asciz	"\ncoral: error: "
	.size	.L.str.12, 16

	.type	.L.str.13,@object               // @.str.13
.L.str.13:
	.asciz	"\n"
	.size	.L.str.13, 2

	.type	.L.str.14,@object               // @.str.14
.L.str.14:
	.asciz	" ("
	.size	.L.str.14, 3

	.type	.L.str.15,@object               // @.str.15
.L.str.15:
	.asciz	" = "
	.size	.L.str.15, 4

	.type	.L.str.16,@object               // @.str.16
.L.str.16:
	.asciz	")\n"
	.size	.L.str.16, 3

	.type	.L.str.17,@object               // @.str.17
.L.str.17:
	.asciz	"assertion failed"
	.size	.L.str.17, 17

	.type	.L.str.18,@object               // @.str.18
.L.str.18:
	.asciz	"\ncoral: error: assert "
	.size	.L.str.18, 23

	.type	.L.str.19,@object               // @.str.19
.L.str.19:
	.asciz	" failed: "
	.size	.L.str.19, 10

	.type	.L.str.20,@object               // @.str.20
.L.str.20:
	.asciz	" "
	.size	.L.str.20, 2

	.type	.L.str.21,@object               // @.str.21
.L.str.21:
	.asciz	": "
	.size	.L.str.21, 3

	.type	.L.str.22,@object               // @.str.22
.L.str.22:
	.asciz	"=="
	.size	.L.str.22, 3

	.type	.L.str.23,@object               // @.str.23
.L.str.23:
	.asciz	"!="
	.size	.L.str.23, 3

	.type	.L.str.24,@object               // @.str.24
.L.str.24:
	.asciz	"<"
	.size	.L.str.24, 2

	.type	.L.str.25,@object               // @.str.25
.L.str.25:
	.asciz	"<="
	.size	.L.str.25, 3

	.type	.L.str.26,@object               // @.str.26
.L.str.26:
	.asciz	">"
	.size	.L.str.26, 2

	.type	.L.str.27,@object               // @.str.27
.L.str.27:
	.asciz	">="
	.size	.L.str.27, 3

	.type	.L.str.28,@object               // @.str.28
.L.str.28:
	.asciz	"\ncoral: error: index "
	.size	.L.str.28, 22

	.type	.L.str.29,@object               // @.str.29
.L.str.29:
	.asciz	" out of bounds for length "
	.size	.L.str.29, 27

	.type	.L.str.30,@object               // @.str.30
.L.str.30:
	.asciz	"pointer"
	.size	.L.str.30, 8

	.type	crl__lib__std__x86_64__linux__error___handling,@object // @crl__lib__std__x86_64__linux__error___handling
	.local	crl__lib__std__x86_64__linux__error___handling
	.comm	crl__lib__std__x86_64__linux__error___handling,1,4
	.type	.L.str.31,@object               // @.str.31
.L.str.31:
	.asciz	"\ncoral: fatal: "
	.size	.L.str.31, 16

	.type	.L_MergedGlobals,@object        // @_MergedGlobals
	.data
	.p2align	2, 0x0
.L_MergedGlobals:
	.word	6                               // 0x6
	.word	7                               // 0x7
	.word	8                               // 0x8
	.word	4                               // 0x4
	.word	11                              // 0xb
	.size	.L_MergedGlobals, 20

	.globl	crl__lib__std__x86_64__linux__error__SIGABRT_
crl__lib__std__x86_64__linux__error__SIGABRT_ = .L_MergedGlobals
	.size	crl__lib__std__x86_64__linux__error__SIGABRT_, 4
	.globl	crl__lib__std__x86_64__linux__error__SIGBUS_
crl__lib__std__x86_64__linux__error__SIGBUS_ = .L_MergedGlobals+4
	.size	crl__lib__std__x86_64__linux__error__SIGBUS_, 4
	.globl	crl__lib__std__x86_64__linux__error__SIGFPE_
crl__lib__std__x86_64__linux__error__SIGFPE_ = .L_MergedGlobals+8
	.size	crl__lib__std__x86_64__linux__error__SIGFPE_, 4
	.globl	crl__lib__std__x86_64__linux__error__SIGILL_
crl__lib__std__x86_64__linux__error__SIGILL_ = .L_MergedGlobals+12
	.size	crl__lib__std__x86_64__linux__error__SIGILL_, 4
	.globl	crl__lib__std__x86_64__linux__error__SIGSEGV_
crl__lib__std__x86_64__linux__error__SIGSEGV_ = .L_MergedGlobals+16
	.size	crl__lib__std__x86_64__linux__error__SIGSEGV_, 4
	.ident	"clang version 23.1.3"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym crl__lib__std__x86_64__linux__error___fatalHandler
	.addrsig_sym .L_MergedGlobals

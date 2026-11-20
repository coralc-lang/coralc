# ========================================================
# Module: strings_esc
# Target: AArch64 / AAPCS64
# ========================================================

# ---- String Constants ----
    .section .rodata
    .align 1
msg:
    .asciz "a\"b\\c\nd\001\377"

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 432 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #432
.Lmain_BB3:
    adrp x9, msg
    add x9, x9, :lo12:msg
    str x9, [sp, #136]
    adrp x9, msg
    add x9, x9, :lo12:msg
    add x9, x9, #1
    str x9, [sp, #144]
    adrp x9, msg
    add x9, x9, :lo12:msg
    add x9, x9, #2
    str x9, [sp, #152]
    adrp x9, msg
    add x9, x9, :lo12:msg
    add x9, x9, #3
    str x9, [sp, #160]
    adrp x9, msg
    add x9, x9, :lo12:msg
    add x9, x9, #4
    str x9, [sp, #168]
    adrp x9, msg
    add x9, x9, :lo12:msg
    add x9, x9, #5
    str x9, [sp, #176]
    adrp x9, msg
    add x9, x9, :lo12:msg
    add x9, x9, #6
    str x9, [sp, #184]
    adrp x9, msg
    add x9, x9, :lo12:msg
    add x9, x9, #7
    str x9, [sp, #192]
    adrp x9, msg
    add x9, x9, :lo12:msg
    add x9, x9, #8
    str x9, [sp, #200]
    ldr x9, [sp, #136]
    ldrb w10, [x9]
    str x10, [sp, #208]
    ldr x9, [sp, #144]
    ldrb w10, [x9]
    str x10, [sp, #216]
    ldr x9, [sp, #152]
    ldrb w10, [x9]
    str x10, [sp, #224]
    ldr x9, [sp, #160]
    ldrb w10, [x9]
    str x10, [sp, #232]
    ldr x9, [sp, #168]
    ldrb w10, [x9]
    str x10, [sp, #240]
    ldr x9, [sp, #176]
    ldrb w10, [x9]
    str x10, [sp, #248]
    ldr x9, [sp, #184]
    ldrb w10, [x9]
    str x10, [sp, #256]
    ldr x9, [sp, #192]
    ldrb w10, [x9]
    str x10, [sp, #264]
    ldr x9, [sp, #200]
    ldrb w10, [x9]
    str x10, [sp, #272]
    ldr x9, [sp, #208]
    and x9, x9, #255
    str x9, [sp, #280]
    ldr x9, [sp, #216]
    and x9, x9, #255
    str x9, [sp, #288]
    ldr x9, [sp, #224]
    and x9, x9, #255
    str x9, [sp, #296]
    ldr x9, [sp, #232]
    and x9, x9, #255
    str x9, [sp, #304]
    ldr x9, [sp, #240]
    and x9, x9, #255
    str x9, [sp, #312]
    ldr x9, [sp, #248]
    and x9, x9, #255
    str x9, [sp, #320]
    ldr x9, [sp, #256]
    and x9, x9, #255
    str x9, [sp, #328]
    ldr x9, [sp, #264]
    and x9, x9, #255
    str x9, [sp, #336]
    ldr x9, [sp, #272]
    and x9, x9, #255
    str x9, [sp, #344]
    ldr x9, [sp, #280]
    ldr x10, [sp, #288]
    eor x9, x9, x10
    str x9, [sp, #352]
    ldr x9, [sp, #352]
    ldr x10, [sp, #296]
    eor x9, x9, x10
    str x9, [sp, #360]
    ldr x9, [sp, #360]
    ldr x10, [sp, #304]
    eor x9, x9, x10
    str x9, [sp, #368]
    ldr x9, [sp, #368]
    ldr x10, [sp, #312]
    eor x9, x9, x10
    str x9, [sp, #376]
    ldr x9, [sp, #376]
    ldr x10, [sp, #320]
    eor x9, x9, x10
    str x9, [sp, #384]
    ldr x9, [sp, #384]
    ldr x10, [sp, #328]
    eor x9, x9, x10
    str x9, [sp, #392]
    ldr x9, [sp, #392]
    ldr x10, [sp, #336]
    eor x9, x9, x10
    str x9, [sp, #400]
    ldr x9, [sp, #400]
    ldr x10, [sp, #344]
    eor x9, x9, x10
    str x9, [sp, #408]
    ldr x9, [sp, #408]
    str x9, [sp, #416]
    ldr x0, [sp, #416]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #432
    ldp x29, x30, [sp], #16
    ret



# ========================================================
# Module: dist_swap
# Target: AArch64 / AAPCS64
# ========================================================

# ========================================================
# Function: @main
# ABI: AAPCS64 (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 512 bytes
# ========================================================
    .text
.globl main
main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #512
.Lmain_BB2:
    add x9, sp, #136
    str x9, [sp, #128]
    add x9, sp, #168
    str x9, [sp, #160]
    add x9, sp, #200
    str x9, [sp, #192]
    add x9, sp, #232
    str x9, [sp, #224]
    ldr x9, [sp, #128]
    str x9, [sp, #264]
    movz x9, #10
    ldr x10, [sp, #264]
    str x9, [x10]
    ldr x9, [sp, #128]
    add x9, x9, #8
    str x9, [sp, #272]
    movz x9, #20
    ldr x10, [sp, #272]
    str x9, [x10]
    ldr x9, [sp, #160]
    str x9, [sp, #280]
    movz x9, #1
    ldr x10, [sp, #280]
    str x9, [x10]
    ldr x9, [sp, #160]
    add x9, x9, #8
    str x9, [sp, #288]
    movz x9, #2
    ldr x10, [sp, #288]
    str x9, [x10]
    mov x9, xzr
    str x9, [sp, #296]
    b .Lmain_BB3
.Lmain_BB3:
    ldr x9, [sp, #296]
    movz x10, #2
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #304]
    ldr x9, [sp, #128]
    ldr x10, [sp, #296]
    movz x11, #8
    mul x10, x10, x11
    add x9, x9, x10
    str x9, [sp, #312]
    ldr x9, [sp, #160]
    ldr x10, [sp, #296]
    movz x11, #8
    mul x10, x10, x11
    add x9, x9, x10
    str x9, [sp, #320]
    ldr x9, [sp, #312]
    ldr x10, [x9]
    str x10, [sp, #328]
    ldr x9, [sp, #320]
    ldr x10, [x9]
    str x10, [sp, #336]
    ldr x9, [sp, #328]
    ldr x10, [sp, #320]
    str x9, [x10]
    ldr x9, [sp, #336]
    ldr x10, [sp, #312]
    str x9, [x10]
    ldr x9, [sp, #304]
    cbz x9, .Lmain_cse_35
    b .Lmain_BB4
.Lmain_cse_35:
    mov x9, xzr
    str x9, [sp, #352]
    b .Lmain_BB6
.Lmain_BB4:
    ldr x9, [sp, #296]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #344]
    ldr x9, [sp, #344]
    str x9, [sp, #296]
    b .Lmain_BB3
.Lmain_BB6:
    ldr x9, [sp, #352]
    movz x10, #2
    cmp x9, x10
    cset w9, lt
    str x9, [sp, #360]
    ldr x9, [sp, #128]
    ldr x10, [sp, #352]
    movz x11, #8
    mul x10, x10, x11
    add x9, x9, x10
    str x9, [sp, #368]
    ldr x9, [sp, #368]
    ldr x10, [x9]
    str x10, [sp, #376]
    ldr x9, [sp, #376]
    movz x10, #10
    add x9, x9, x10
    str x9, [sp, #384]
    ldr x9, [sp, #192]
    ldr x10, [sp, #352]
    movz x11, #8
    mul x10, x10, x11
    add x9, x9, x10
    str x9, [sp, #392]
    ldr x9, [sp, #384]
    ldr x10, [sp, #392]
    str x9, [x10]
    ldr x9, [sp, #160]
    ldr x10, [sp, #352]
    movz x11, #8
    mul x10, x10, x11
    add x9, x9, x10
    str x9, [sp, #400]
    ldr x9, [sp, #400]
    ldr x10, [x9]
    str x10, [sp, #408]
    ldr x9, [sp, #408]
    movz x10, #20
    add x9, x9, x10
    str x9, [sp, #416]
    ldr x9, [sp, #224]
    ldr x10, [sp, #352]
    movz x11, #8
    mul x10, x10, x11
    add x9, x9, x10
    str x9, [sp, #424]
    ldr x9, [sp, #416]
    ldr x10, [sp, #424]
    str x9, [x10]
    ldr x9, [sp, #360]
    cbz x9, .Lmain_cse_51
    b .Lmain_BB7
.Lmain_cse_51:
    b .Lmain_BB8
.Lmain_BB7:
    ldr x9, [sp, #352]
    movz x10, #1
    add x9, x9, x10
    str x9, [sp, #432]
    ldr x9, [sp, #432]
    str x9, [sp, #352]
    b .Lmain_BB6
.Lmain_BB8:
    ldr x9, [sp, #128]
    add x9, x9, #8
    str x9, [sp, #440]
    ldr x9, [sp, #440]
    ldr x10, [x9]
    str x10, [sp, #448]
    ldr x9, [sp, #192]
    add x9, x9, #8
    str x9, [sp, #456]
    ldr x9, [sp, #456]
    ldr x10, [x9]
    str x10, [sp, #464]
    ldr x9, [sp, #224]
    add x9, x9, #8
    str x9, [sp, #472]
    ldr x9, [sp, #472]
    ldr x10, [x9]
    str x10, [sp, #480]
    ldr x9, [sp, #448]
    ldr x10, [sp, #464]
    add x9, x9, x10
    str x9, [sp, #488]
    ldr x9, [sp, #488]
    ldr x10, [sp, #480]
    add x9, x9, x10
    str x9, [sp, #496]
    ldr x9, [sp, #496]
    str x9, [sp, #504]
    ldr x0, [sp, #504]
    b .Lmain_epilogue
.Lmain_epilogue:
    add sp, sp, #512
    ldp x29, x30, [sp], #16
    ret



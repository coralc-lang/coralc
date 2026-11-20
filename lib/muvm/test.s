# ========================================================
# Module: bigmodule
# Target OS: Linux / Unix (SystemV ABI)
# ========================================================

f64 pow(f64 base, f64 exponent) {
    f64 count = 1;
    for (count < exponent) {
        
    }
}
# ---- Global Variables ----
    .data
    .align 8
.globl g
g:
    .quad 3

# ========================================================
# Function: @square
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 32 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl square
.type square, @function
square:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    movq %rdi, -8(%rbp)
.Lsquare_entry:
    movq -8(%rbp), %rax
    movq -8(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -16(%rbp)
    movq -16(%rbp), %rax
    jmp .Lsquare_epilogue
.Lsquare_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @cube
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 32 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl cube
.type cube, @function
cube:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    movq %rdi, -8(%rbp)
.Lcube_entry:
    movq -8(%rbp), %rax
    movq -8(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -16(%rbp)
    movq -16(%rbp), %rax
    movq -8(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -24(%rbp)
    movq -24(%rbp), %rax
    jmp .Lcube_epilogue
.Lcube_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @sum_to
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 64 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl sum_to
.type sum_to, @function
sum_to:
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp
    movq %rdi, -8(%rbp)
.Lsum_to_entry:
    jmp .Lsum_to_loop
.Lsum_to_loop:
    movq -16(%rbp), %rax
    movq -8(%rbp), %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -32(%rbp)
    movq -32(%rbp), %rax
    testq %rax, %rax
    jne .Lsum_to_body
    jmp .Lsum_to_done
.Lsum_to_body:
    movq -24(%rbp), %rax
    movq -16(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -40(%rbp)
    movq -16(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -48(%rbp)
    jmp .Lsum_to_loop
.Lsum_to_done:
    movq -24(%rbp), %rax
    jmp .Lsum_to_epilogue
.Lsum_to_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @collatz
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 96 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl collatz
.type collatz, @function
collatz:
    pushq %rbp
    movq %rsp, %rbp
    subq $96, %rsp
    movq %rdi, -8(%rbp)
.Lcollatz_entry:
    jmp .Lcollatz_loop
.Lcollatz_loop:
    movq -16(%rbp), %rax
    movabsq $1, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -32(%rbp)
    movq -32(%rbp), %rax
    testq %rax, %rax
    jne .Lcollatz_done
    jmp .Lcollatz_body
.Lcollatz_body:
    movq -16(%rbp), %rax
    movabsq $1, %rcx
    andq %rcx, %rax
    movq %rax, -40(%rbp)
    movq -16(%rbp), %rax
    movabsq $1, %rcx
    shrq %cl, %rax
    movq %rax, -48(%rbp)
    movq -16(%rbp), %rax
    movabsq $3, %rcx
    imulq %rcx, %rax
    movq %rax, -56(%rbp)
    movq -56(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -64(%rbp)
    movq -40(%rbp), %rax
    movabsq $1, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -72(%rbp)
    movq -24(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -88(%rbp)
    jmp .Lcollatz_loop
.Lcollatz_done:
    movq -24(%rbp), %rax
    jmp .Lcollatz_epilogue
.Lcollatz_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @fib
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 64 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl fib
.type fib, @function
fib:
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp
    movq %rdi, -8(%rbp)
.Lfib_entry:
    jmp .Lfib_loop
.Lfib_loop:
    movq -16(%rbp), %rax
    movq -8(%rbp), %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    testq %rax, %rax
    jne .Lfib_body
    jmp .Lfib_done
.Lfib_body:
    movq -24(%rbp), %rax
    movq -32(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -48(%rbp)
    movq -16(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -56(%rbp)
    jmp .Lfib_loop
.Lfib_done:
    movq -24(%rbp), %rax
    jmp .Lfib_epilogue
.Lfib_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @sum_squares_range
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 80 bytes
#   arg[0] -> -8(%rbp)
#   arg[1] -> -16(%rbp)
# ========================================================
    .text
.globl sum_squares_range
.type sum_squares_range, @function
sum_squares_range:
    pushq %rbp
    movq %rsp, %rbp
    subq $80, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
.Lsum_squares_range_entry:
    jmp .Lsum_squares_range_loop
.Lsum_squares_range_loop:
    movq -24(%rbp), %rax
    movq -16(%rbp), %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    testq %rax, %rax
    jne .Lsum_squares_range_body
    jmp .Lsum_squares_range_done
.Lsum_squares_range_body:
    movq -24(%rbp), %rax
    movq -24(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -48(%rbp)
    movq -32(%rbp), %rax
    movq -48(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -56(%rbp)
    movq -24(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -64(%rbp)
    jmp .Lsum_squares_range_loop
.Lsum_squares_range_done:
    movq -32(%rbp), %rax
    jmp .Lsum_squares_range_epilogue
.Lsum_squares_range_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @fact
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 64 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl fact
.type fact, @function
fact:
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp
    movq %rdi, -8(%rbp)
.Lfact_entry:
    jmp .Lfact_loop
.Lfact_loop:
    movq -16(%rbp), %rax
    movq -8(%rbp), %rcx
    cmpq %rcx, %rax
    setle %al
    movzbq %al, %rax
    movq %rax, -32(%rbp)
    movq -32(%rbp), %rax
    testq %rax, %rax
    jne .Lfact_body
    jmp .Lfact_done
.Lfact_body:
    movq -24(%rbp), %rax
    movq -16(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -40(%rbp)
    movq -16(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -48(%rbp)
    jmp .Lfact_loop
.Lfact_done:
    movq -24(%rbp), %rax
    jmp .Lfact_epilogue
.Lfact_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @gcd
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 64 bytes
#   arg[0] -> -8(%rbp)
#   arg[1] -> -16(%rbp)
# ========================================================
    .text
.globl gcd
.type gcd, @function
gcd:
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
.Lgcd_entry:
    jmp .Lgcd_loop
.Lgcd_loop:
    movq -32(%rbp), %rax
    movabsq $0, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    testq %rax, %rax
    jne .Lgcd_done
    jmp .Lgcd_body
.Lgcd_body:
    movq -24(%rbp), %rax
    movq -32(%rbp), %rcx
    cqto
    idivq %rcx
    movq %rdx, -48(%rbp)
    jmp .Lgcd_loop
.Lgcd_done:
    movq -24(%rbp), %rax
    jmp .Lgcd_epilogue
.Lgcd_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @count_bits
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 64 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl count_bits
.type count_bits, @function
count_bits:
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp
    movq %rdi, -8(%rbp)
.Lcount_bits_entry:
    jmp .Lcount_bits_loop
.Lcount_bits_loop:
    movq -16(%rbp), %rax
    movabsq $0, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -32(%rbp)
    movq -32(%rbp), %rax
    testq %rax, %rax
    jne .Lcount_bits_done
    jmp .Lcount_bits_body
.Lcount_bits_body:
    movq -16(%rbp), %rax
    movabsq $1, %rcx
    andq %rcx, %rax
    movq %rax, -40(%rbp)
    movq -24(%rbp), %rax
    movq -40(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -48(%rbp)
    movq -16(%rbp), %rax
    movabsq $1, %rcx
    shrq %cl, %rax
    movq %rax, -56(%rbp)
    jmp .Lcount_bits_loop
.Lcount_bits_done:
    movq -24(%rbp), %rax
    jmp .Lcount_bits_epilogue
.Lcount_bits_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @poly
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 64 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl poly
.type poly, @function
poly:
    pushq %rbp
    movq %rsp, %rbp
    subq $64, %rsp
    movq %rdi, -8(%rbp)
.Lpoly_entry:
    movq -8(%rbp), %rax
    movq -8(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -16(%rbp)
    movq -8(%rbp), %rax
    movabsq $1, %rcx
    shlq %cl, %rax
    movq %rax, -24(%rbp)
    movq -16(%rbp), %rax
    movq -24(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -32(%rbp)
    movq -32(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    movq -40(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -48(%rbp)
    movq -48(%rbp), %rax
    jmp .Lpoly_epilogue
.Lpoly_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @invar_loop
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 80 bytes
#   arg[0] -> -8(%rbp)
#   arg[1] -> -16(%rbp)
# ========================================================
    .text
.globl invar_loop
.type invar_loop, @function
invar_loop:
    pushq %rbp
    movq %rsp, %rbp
    subq $80, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
.Linvar_loop_entry:
    movq -16(%rbp), %rax
    movabsq $7, %rcx
    imulq %rcx, %rax
    movq %rax, -24(%rbp)
    jmp .Linvar_loop_loop
.Linvar_loop_loop:
    movq -32(%rbp), %rax
    movq -8(%rbp), %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -48(%rbp)
    movq -48(%rbp), %rax
    testq %rax, %rax
    jne .Linvar_loop_body
    jmp .Linvar_loop_done
.Linvar_loop_body:
    movq -40(%rbp), %rax
    movq -24(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -56(%rbp)
    movq -32(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -64(%rbp)
    jmp .Linvar_loop_loop
.Linvar_loop_done:
    movq -40(%rbp), %rax
    jmp .Linvar_loop_epilogue
.Linvar_loop_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @big_switch
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 176 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl big_switch
.type big_switch, @function
big_switch:
    pushq %rbp
    movq %rsp, %rbp
    subq $176, %rsp
    movq %rdi, -8(%rbp)
.Lbig_switch_entry:
    movq -8(%rbp), %rax
    movabsq $0, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -16(%rbp)
    movq -16(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case0
    jmp .Lbig_switch_n1
.Lbig_switch_n1:
    movq -8(%rbp), %rax
    movabsq $1, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -24(%rbp)
    movq -24(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case1
    jmp .Lbig_switch_n2
.Lbig_switch_n2:
    movq -8(%rbp), %rax
    movabsq $2, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -32(%rbp)
    movq -32(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case2
    jmp .Lbig_switch_n3
.Lbig_switch_n3:
    movq -8(%rbp), %rax
    movabsq $3, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case3
    jmp .Lbig_switch_n4
.Lbig_switch_n4:
    movq -8(%rbp), %rax
    movabsq $4, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -48(%rbp)
    movq -48(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case4
    jmp .Lbig_switch_n5
.Lbig_switch_n5:
    movq -8(%rbp), %rax
    movabsq $5, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -56(%rbp)
    movq -56(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case5
    jmp .Lbig_switch_n6
.Lbig_switch_n6:
    movq -8(%rbp), %rax
    movabsq $6, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -64(%rbp)
    movq -64(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case6
    jmp .Lbig_switch_n7
.Lbig_switch_n7:
    movq -8(%rbp), %rax
    movabsq $7, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -72(%rbp)
    movq -72(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case7
    jmp .Lbig_switch_n8
.Lbig_switch_n8:
    movq -8(%rbp), %rax
    movabsq $8, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -80(%rbp)
    movq -80(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case8
    jmp .Lbig_switch_n9
.Lbig_switch_n9:
    movq -8(%rbp), %rax
    movabsq $9, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -88(%rbp)
    movq -88(%rbp), %rax
    testq %rax, %rax
    jne .Lbig_switch_case9
    jmp .Lbig_switch_case10
.Lbig_switch_case0:
    movabsq $1, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case1:
    movabsq $2, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case2:
    movabsq $4, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case3:
    movabsq $8, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case4:
    movabsq $16, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case5:
    movabsq $32, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case6:
    movabsq $64, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case7:
    movabsq $128, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case8:
    movabsq $256, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case9:
    movabsq $512, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_case10:
    movabsq $1024, %rax
    jmp .Lbig_switch_epilogue
.Lbig_switch_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @const_chain
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 16 bytes
# ========================================================
    .text
.globl const_chain
.type const_chain, @function
const_chain:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp
.Lconst_chain_entry:
    movabsq $245, %rax
    jmp .Lconst_chain_epilogue
.Lconst_chain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @redundant
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 16 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl redundant
.type redundant, @function
redundant:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp
    movq %rdi, -8(%rbp)
.Lredundant_entry:
    movabsq $42, %rax
    jmp .Lredundant_epilogue
.Lredundant_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @xor_self
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 16 bytes
#   arg[0] -> -8(%rbp)
# ========================================================
    .text
.globl xor_self
.type xor_self, @function
xor_self:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp
    movq %rdi, -8(%rbp)
.Lxor_self_entry:
    movabsq $0, %rax
    jmp .Lxor_self_epilogue
.Lxor_self_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @select_real
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 48 bytes
#   arg[0] -> -8(%rbp)
#   arg[1] -> -16(%rbp)
# ========================================================
    .text
.globl select_real
.type select_real, @function
select_real:
    pushq %rbp
    movq %rsp, %rbp
    subq $48, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
.Lselect_real_entry:
    movq -8(%rbp), %rax
    movq -16(%rbp), %rcx
    cmpq %rcx, %rax
    setg %al
    movzbq %al, %rax
    movq %rax, -24(%rbp)
    movq -32(%rbp), %rax
    jmp .Lselect_real_epilogue
.Lselect_real_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @phi_const_combo
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 48 bytes
#   arg[0] -> -8(%rbp)
#   arg[1] -> -16(%rbp)
# ========================================================
    .text
.globl phi_const_combo
.type phi_const_combo, @function
phi_const_combo:
    pushq %rbp
    movq %rsp, %rbp
    subq $48, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
.Lphi_const_combo_entry:
    movq -8(%rbp), %rax
    movq -16(%rbp), %rcx
    cmpq %rcx, %rax
    setg %al
    movzbq %al, %rax
    movq %rax, -24(%rbp)
    movq -24(%rbp), %rax
    testq %rax, %rax
    jne .Lphi_const_combo_merge
    jmp .Lphi_const_combo_merge
.Lphi_const_combo_merge:
    movq -32(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -40(%rbp)
    movq -40(%rbp), %rax
    jmp .Lphi_const_combo_epilogue
.Lphi_const_combo_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @same_pick
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 48 bytes
#   arg[0] -> -8(%rbp)
#   arg[1] -> -16(%rbp)
#   arg[2] -> -24(%rbp)
# ========================================================
    .text
.globl same_pick
.type same_pick, @function
same_pick:
    pushq %rbp
    movq %rsp, %rbp
    subq $48, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
    movq %rdx, -24(%rbp)
.Lsame_pick_entry:
    movq -32(%rbp), %rax
    jmp .Lsame_pick_epilogue
.Lsame_pick_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @select_same
# ABI: SystemV (Linux/Unix)
# Attributes: [ leaf ]
# Stack Frame: 32 bytes
#   arg[0] -> -8(%rbp)
#   arg[1] -> -16(%rbp)
# ========================================================
    .text
.globl select_same
.type select_same, @function
select_same:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    movq %rdi, -8(%rbp)
    movq %rsi, -16(%rbp)
.Lselect_same_entry:
    movq -24(%rbp), %rax
    jmp .Lselect_same_epilogue
.Lselect_same_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq

# ========================================================
# Function: @main
# ABI: SystemV (Linux/Unix)
# Attributes: [ ]
# Stack Frame: 496 bytes
# ========================================================
    .text
.globl main
.type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $496, %rsp
.Lmain_entry:
    leaq g(%rip), %rax
    movq (%rax), %rcx
    movq %rcx, -8(%rbp)
    movq -8(%rbp), %rax
    movq -8(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -16(%rbp)
    movq -16(%rbp), %rax
    movq -8(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -24(%rbp)
    jmp .Lmain___inl.body.6
.Lmain___inl.body.6:
    movq -32(%rbp), %rax
    movabsq $8, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -48(%rbp)
    movq -48(%rbp), %rax
    testq %rax, %rax
    jne .Lmain___inl.body.7
    jmp .Lmain___inl.body.11
.Lmain___inl.body.7:
    movq -40(%rbp), %rax
    movq -32(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -56(%rbp)
    movq -32(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -64(%rbp)
    jmp .Lmain___inl.body.6
.Lmain___inl.body.11:
    movq -72(%rbp), %rax
    movabsq $10, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -96(%rbp)
    movq -96(%rbp), %rax
    testq %rax, %rax
    jne .Lmain___inl.body.12
    jmp .Lmain___inl.body.16
.Lmain___inl.body.12:
    movq -80(%rbp), %rax
    movq -88(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -104(%rbp)
    movq -72(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -112(%rbp)
    jmp .Lmain___inl.body.11
.Lmain___inl.body.16:
    movq -120(%rbp), %rax
    movabsq $8, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -136(%rbp)
    movq -136(%rbp), %rax
    testq %rax, %rax
    jne .Lmain___inl.body.17
    jmp .Lmain___inl.body.21
.Lmain___inl.body.17:
    movq -120(%rbp), %rax
    movq -120(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -144(%rbp)
    movq -128(%rbp), %rax
    movq -144(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -152(%rbp)
    movq -120(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -160(%rbp)
    jmp .Lmain___inl.body.16
.Lmain___inl.body.21:
    movq -168(%rbp), %rax
    movabsq $5, %rcx
    cmpq %rcx, %rax
    setle %al
    movzbq %al, %rax
    movq %rax, -184(%rbp)
    movq -184(%rbp), %rax
    testq %rax, %rax
    jne .Lmain___inl.body.22
    jmp .Lmain___inl.body.26
.Lmain___inl.body.22:
    movq -176(%rbp), %rax
    movq -168(%rbp), %rcx
    imulq %rcx, %rax
    movq %rax, -192(%rbp)
    movq -168(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -200(%rbp)
    jmp .Lmain___inl.body.21
.Lmain___inl.body.26:
    movq -216(%rbp), %rax
    movabsq $0, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -224(%rbp)
    movq -224(%rbp), %rax
    testq %rax, %rax
    jne .Lmain___inl.body.31
    jmp .Lmain___inl.body.27
.Lmain___inl.body.27:
    movq -208(%rbp), %rax
    movq -216(%rbp), %rcx
    cqto
    idivq %rcx
    movq %rdx, -232(%rbp)
    jmp .Lmain___inl.body.26
.Lmain___inl.body.31:
    movq -240(%rbp), %rax
    movabsq $0, %rcx
    cmpq %rcx, %rax
    sete %al
    movzbq %al, %rax
    movq %rax, -256(%rbp)
    movq -256(%rbp), %rax
    testq %rax, %rax
    jne .Lmain___inl.body.38
    jmp .Lmain___inl.body.32
.Lmain___inl.body.32:
    movq -240(%rbp), %rax
    movabsq $1, %rcx
    andq %rcx, %rax
    movq %rax, -264(%rbp)
    movq -248(%rbp), %rax
    movq -264(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -272(%rbp)
    movq -240(%rbp), %rax
    movabsq $1, %rcx
    shrq %cl, %rax
    movq %rax, -280(%rbp)
    jmp .Lmain___inl.body.31
.Lmain___inl.body.38:
    movq -288(%rbp), %rax
    movabsq $4, %rcx
    cmpq %rcx, %rax
    setl %al
    movzbq %al, %rax
    movq %rax, -304(%rbp)
    movq -304(%rbp), %rax
    testq %rax, %rax
    jne .Lmain___inl.body.39
    jmp .Lmain___inl.cont.36
.Lmain___inl.body.39:
    movq -296(%rbp), %rax
    movabsq $35, %rcx
    addq %rcx, %rax
    movq %rax, -312(%rbp)
    movq -288(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -320(%rbp)
    jmp .Lmain___inl.body.38
.Lmain___inl.cont.36:
    movabsq $7, %rdi
    call big_switch
    movq %rax, -328(%rbp)
    jmp .Lmain___inl.body.55
.Lmain___inl.body.55:
    movq -336(%rbp), %rax
    movabsq $1, %rcx
    addq %rcx, %rax
    movq %rax, -344(%rbp)
    jmp .Lmain___inl.cont.53
.Lmain___inl.cont.53:
    movq -16(%rbp), %rax
    movq -24(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -352(%rbp)
    movq -352(%rbp), %rax
    movq -40(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -360(%rbp)
    movq -360(%rbp), %rax
    movq -80(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -368(%rbp)
    movq -368(%rbp), %rax
    movq -128(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -376(%rbp)
    movq -376(%rbp), %rax
    movq -176(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -384(%rbp)
    movq -384(%rbp), %rax
    movq -208(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -392(%rbp)
    movq -392(%rbp), %rax
    movq -248(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -400(%rbp)
    movq -400(%rbp), %rax
    movabsq $32, %rcx
    addq %rcx, %rax
    movq %rax, -408(%rbp)
    movq -408(%rbp), %rax
    movq -296(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -416(%rbp)
    movq -416(%rbp), %rax
    movq -328(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -424(%rbp)
    movq -424(%rbp), %rax
    movabsq $245, %rcx
    addq %rcx, %rax
    movq %rax, -432(%rbp)
    movq -432(%rbp), %rax
    movabsq $42, %rcx
    addq %rcx, %rax
    movq %rax, -440(%rbp)
    movq -440(%rbp), %rax
    movabsq $20, %rcx
    addq %rcx, %rax
    movq %rax, -448(%rbp)
    movq -448(%rbp), %rax
    movabsq $7, %rcx
    addq %rcx, %rax
    movq %rax, -456(%rbp)
    movq -456(%rbp), %rax
    movabsq $99, %rcx
    addq %rcx, %rax
    movq %rax, -464(%rbp)
    movq -464(%rbp), %rax
    movq -344(%rbp), %rcx
    addq %rcx, %rax
    movq %rax, -472(%rbp)
    movq -472(%rbp), %rax
    movabsq $255, %rcx
    andq %rcx, %rax
    movq %rax, -480(%rbp)
    movq -488(%rbp), %rax
    jmp .Lmain_epilogue
.Lmain_epilogue:
    movq %rbp, %rsp
    popq %rbp
    retq



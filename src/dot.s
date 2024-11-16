.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1
    blt a2, t0, error_terminate
    blt a3, t0, error_terminate
    blt a4, t0, error_terminate

    li a5, 0                # target number from array 1
    mv t2, a0               # target address from array 1
    li a6, 0                # target number from array 2
    mv t3, a1               # target address from array 2 
    
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s1, 4(sp)

    li a7, 0                # counter i
    li s1, 0                # product sum

loop_start:
    beq a7, a2, loop_end

    lw a5, 0(t2)            # load element from array 0
    lw a6, 0(t3)            # load element from array 1
    
    addi sp, sp, -8
    sw a5, 0(sp)
    sw a6, 4(sp)

    li t4, 0
    mv t0, a5
    mv t1, a6

    jal ra, opt
    jal ra, mult
    jal ra, signed
    
    addi a7, a7, 1          # i += 1
    add s1, s1, t4          # product sum += multiple result
    
    # compute i * stride0
    mv t0, a7
    mv t1, a3
    li t4, 0
    jal ra, mult
    slli t4, t4, 2
    add t2, a0, t4

    # compute i * stride1
    mv t0, a7
    mv t1, a4
    li t4, 0
    jal ra, mult
    slli t4, t4, 2
    add t3, a1, t4

    lw a5, 0(sp)
    lw a6, 4(sp)
    addi sp, sp, 8

    j loop_start

loop_end:
    mv a0, s1

    lw ra, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8

    jr ra

# =======================================================

opt:
    # t0 = abs(t0)
    srai t5, t0, 31
    xor t0, t0, t5
    sub t0, t0, t5
    
    # t1 = abs(t1)
    srai t5, t1, 31
    xor t1, t1, t5
    sub t1, t1, t5
    jr ra

# =======================================================

mult:
    # compute t0*t1
    beq t1, zero, mult_end
loop_mul:
    andi t5, t1, 0x1
    beq t5, zero, loop_mult_end
    add t4, t4, t0
loop_mult_end:
    slli t0, t0, 1
    srli t1, t1, 1
    j mult
mult_end:
    jr ra

# =======================================================

signed:
    lw t0, 0(sp)
    lw t1, 4(sp)

    slt t0, t0, zero        # check sign of t0
    slt t1, t1, zero        # check sign of t1
    beq t0, t1, signed_end
    xori t4, t4, 0xFFFFFFFF
    addi t4, t4, 1
signed_end:
    jr ra

# =======================================================

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
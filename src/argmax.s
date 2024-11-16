.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t5, 1
    blt a1, t5, handle_error

    lw t0, 0(a0)

    li t1, 0    # array index
    li t2, 0    # maximum value
    li t3, 0    # maximum value index

loop_start:
    bge t1, a1, loop_end
    lw t4, 0(a0)            # load element from array
    bge t2, t4, loop_next
    mv t2, t4               # record maximum
    mv t3, t1               # record maximum index

loop_next:
    addi t1, t1, 1
    addi a0, a0, 4
    j loop_start

loop_end:
    mv a0, t3               # set target index to a0
    jr ra
    
handle_error:
    li a0, 36
    j exit

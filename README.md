# Assignment 2: Classify
contributed by: < `NeedToDebugMyLife` (劉孟璋) >

## task I - abs

### `Requirement`

$abs(a) = |a|$   

Transforms any integer into its absolute (non-negative) value by modifying the original value through pointer dereferencing.

> Ex:  
> (1) input: 5 ⟶ output: 5  
> (2) input: -5 ⟶ output: 5

<br>

### `Implement`
$y = x \gg 31$ <br>
$|x|=(x \oplus y) - y$

<br>

### `Code`
```ass=
abs:
    # Prologue
    ebreak
    
    # Load number from memory
    lw t0, 0(a0)
    bge t0, zero, done

    srai t1, t0, 31
    xor t0, t0, t1
    sub t0, t0, t1

    sw t0, 0(a0)

done:
    # Epilogue
    jr ra
```

<br>

### `Test Result`
```
test_abs_minus_one (__main__.TestAbs) ... ok
test_abs_one (__main__.TestAbs) ... ok
test_abs_zero (__main__.TestAbs) ... ok
----------------------------------------------------------------------
Ran 3 tests in 2.323s

OK
```


<br><br>

## task II - relu

### `Requirement`
Input an array, for each element x in array: x = max(0, x), then output result array

<br>

### `Implement`
1. Use loop to traverse the input array and check elements.  
  (1) If element greater equal than zero, then skip  
  (2) If element less than zero, then set element to zero  
2. Use `lw` to get the element from array
3. Use `sw` to set the element to zero

> Ex:  
> Input:  [-2, 0, 3, -1, 5 ] ⟶ Result: [ 0, 0, 3, 0, 5 ]

<br>

### `Code`

```ass=
relu:
    li t0, 1
    blt a1, t0, error     
    li t1, 0    # array index

loop_start:
    bge t1, a1, loop_end
    
    lw t3, 0(a0)            # Load element from array
    bge t3, x0, loop_next
    
    sw x0, 0(a0)            # Set element to 0
loop_next:
    addi t1, t1, 1
    addi a0, a0, 4
    j loop_start

loop_end:
    jr ra
```

<br>

### `Test Result`
```
test_relu_invalid_n (__main__.TestRelu) ... ok
test_relu_length_1 (__main__.TestRelu) ... ok
test_relu_standard (__main__.TestRelu) ... ok

----------------------------------------------------------------------
Ran 3 tests in 2.504s

OK
```

<br><br>

## task III - argmax

### `Requirement`
Traverse the input integer array , then find its maximum value and returns the position of its first occurrence. If multiple elements share the maximum value, returns the smallest index.

<br>

### `Implement`
1. Use loop to traverse the input array and check elements  
    (1) if checked element is greater than the current maximum value ~(init~ ~0)~,  
    &emsp;&nbsp; then update the maximum value and index  
    (2) if checked element is less equal than the current maximum value, then skip
2. Use `lw` to get the element from array
3. return the index of maximum value
 
<br>

### `Code`
```ass=
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
```
<br>

### `Test Result`
```
test_argmax_invalid_n (__main__.TestArgmax) ... ok
test_argmax_length_1 (__main__.TestArgmax) ... ok
test_argmax_standard (__main__.TestArgmax) ... ok

----------------------------------------------------------------------
Ran 3 tests in 2.398s

OK
```

<br><br>

## task IV - dot product

### `Requirement`
$dot(a, b)=\displaystyle\sum_{i=0}^{n-1}(a_i \cdot b_i)$  

Calculates sum(arr0[i * stride0] * arr1[i * stride1]),  
where i ranges from 0 to (element_count - 1)

<br>

### `Multiplier`
Consist of three parts, `opt`, `mult`, and `signed`

#### opt
Use the way from [task I](#task-I---abs) to take the absolute values of the multiplier and the multiplicand
```ass=
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
```

<br>

#### mult
1. Check whether muliplier equals to 0 or not.  
   (1) If multiplier equals to 0, then end checking  
   (2) If multiplier dosen't equal to 0, then keep checking
2. Check the last bit of multiplier  
   (1) If the last bit equals to 0, then accumulate multiplier to the result  
   (2) If the last bit equals to 1, then skip
3.  Right shift muliplicand with one bit 
4.  Left shift muliplier with one bit
5.  Back step 1 and keep checking
 
```ass=
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
```

<br>

#### signed
1. Use `lw` to get the original multiplier and multiplicand
2. Check the sign of multiplier and multiplicand  
   (1) If multiplier and multiplicand have the same sign, then skip  
   (2) If multiplier and multiplicand have different sign,  
&emsp;&nbsp; then take the 2's complement of multiple result.

```ass=
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
```


<br>

### `Implement`
1. Use loop to traverse the input array and check elements  
2. Use multiplier to compute the result of $a(i)\times b(i)$ and accumulate with previous product result
3. Use stride to get the next $a(i)$ and $b(i)$
4. Use `lw` to get the element from array
5. return the index of maximum value

<br>

### `Code`
```ass=
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
```

<br>

### `Test Result`
```
test_dot_length_1 (__main__.TestDot) ... ok
test_dot_length_error (__main__.TestDot) ... ok
test_dot_length_error2 (__main__.TestDot) ... ok
test_dot_standard (__main__.TestDot) ... ok
test_dot_stride (__main__.TestDot) ... ok
test_dot_stride_error1 (__main__.TestDot) ... ok
test_dot_stride_error2 (__main__.TestDot) ... ok

----------------------------------------------------------------------
Ran 7 tests in 6.396s

OK
```

<br><br>

## task V - matrix multiplication

### `Requirement`
$D = M_0 × M_1$, where  
$M_0$ is a (rows0 × cols0) matrix  
$M_1$ is a (rows1 × cols1) matrix  
$D$ is a (rows0 × cols1) matrix  

Input two matrix (in 1-D array format), return result matrix (in 1-D array format)

<br>

### `Implement`
1. Use nested-loop to traverse the two input array and check elements  
   (1) outer loop traverses each row of input array 1
   (2) inner loop traverses each column of input array 2
2. Use dot to compute the dot product result
3. Use stride of input array 2 to get the next column 
4. Use stride of input array 1 to get the next row 
5. return the multiplication result of two input matrices

<br>

### `Code`
```ass=
matmul:
    # Error checks
    li t0 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)
    
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    
    li s0, 0 # outer loop counter
    li s1, 0 # inner loop counter
    mv s2, a6 # incrementing result matrix pointer
    mv s3, a0 # incrementing matrix A pointer, increments durring outer loop
    mv s4, a3 # incrementing matrix B pointer, increments during inner loop 
    
outer_loop_start:
    # s0 is going to be the loop counter for the rows in A
    li s1, 0
    mv s4, a3
    blt s0, a1, inner_loop_start

    j outer_loop_end
    
inner_loop_start:
# HELPER FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use = number of columns of A, or number of rows of B
#   a3 (int)  is the stride of arr0 = for A, stride = 1
#   a4 (int)  is the stride of arr1 = for B, stride = len(rows) - 1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
    beq s1, a5, inner_loop_end

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    
    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B
    
    jal dot
    
    mv t0, a0 # storing result of the dot product into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24
    
    sw t0, 0(s2)
    addi s2, s2, 4 # Incrememtning pointer for result matrix
    
    li t1, 4
    add s4, s4, t1 # incrememtning the column on Matrix B
    
    addi s1, s1, 1
    j inner_loop_start
    
inner_loop_end:
    mv t1, a2
    slli t1, t1, 2
    add s3, s3, t1

    addi s0, s0, 1
    j outer_loop_start

outer_loop_end:
    lw ra, 0(sp) 
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    jr ra
```

<br>

### `Test Result`
```
test_matmul_incorrect_check (__main__.TestMatmul) ... ok
test_matmul_length_1 (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul) ... ok
test_matmul_square (__main__.TestMatmul) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul) ... ok

----------------------------------------------------------------------
Ran 13 tests in 12.320s

OK
```

<br><br>

## task VI - read matrix

### `Requirement`
Replace `mul` with the customized multiplier
:::       info
contain only the part of the replacement of `mul` instruction
:::


<br>

### `Implement`
Use the multiplier from [task IV](#Multiplier) to implement the multiple function

<br>

### `Code`
```ass=
# mul s1, t1, t2
    li s1, 0
mult:
    beq t2, zero, mult_end
loop_mul:
    andi t3, t2, 0x1
    beq t3, zero, loop_mult_end
    add s1, s1, t1
loop_mult_end:
    slli t1, t1, 1
    srli t2, t2, 1
    j mult
mult_end:
```

<br>

### `Test Result`
```
test_read_1 (__main__.TestReadMatrix) ... ok
test_read_2 (__main__.TestReadMatrix) ... ok
test_read_3 (__main__.TestReadMatrix) ... ok
test_read_fail_fclose (__main__.TestReadMatrix) ... ok
test_read_fail_fopen (__main__.TestReadMatrix) ... ok
test_read_fail_fread (__main__.TestReadMatrix) ... ok
test_read_fail_malloc (__main__.TestReadMatrix) ... ok

----------------------------------------------------------------------
Ran 7 tests in 6.093s

OK
```


<br><br>

## task VII - write matrix

### `Requirement`
Replace `mul` with the customized multiplier
:::       info
contain only the part of the replacement of `mul` instruction
:::


<br>

### `Implement`
Use the multiplier from [task IV](#Multiplier) to implement the multiple function

<br>

### `Code`
```ass=
# mul s4, s2, s3
    li s4, 0
mult:
    beq s3, zero, mult_end
loop_mul:
    andi t3, s3, 0x1
    beq t3, zero, loop_mult_end
    add s4, s4, s2
loop_mult_end:
    slli s2, s2, 1
    srli s3, s3, 1
    j mult
mult_end:
```

<br>

### `Test Result`
```
test_write_1 (__main__.TestWriteMatrix) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix) ... ok

----------------------------------------------------------------------
Ran 4 tests in 3.425s

OK
```

<br><br>

## task VIII - classify

### `Requirement`
Replace `mul` with the customized multiplier
:::       info
contain only the part of the replacement of `mul` instruction
:::


<br>

### `Implement`
Use the multiplier from [task IV
](#Multiplier) to implement the multiple function

<br>

### `Code`
```ass=
# replacement 1 - mul a0, t0, t1
addi sp, sp, -8
sw t0, 0(sp)
sw t1, 4(sp)
li t4, 0

jal opt
jal mult
jal signed

mv a0, t4

lw t0, 0(sp)
lw t1, 4(sp)
addi sp, sp, 8
```

```ass=
# replacement 2 - mul a1, t0, t1 
# length of h array and set it as second argument
addi sp, sp, -8
sw t0, 0(sp)
sw t1, 4(sp)
li t4, 0

jal opt
jal mult
jal signed

mv a1, t4

lw t0, 0(sp)
lw t1, 4(sp)
addi sp, sp, 8
```

```ass=
# replacement 3 - mul a0, t0, t1
addi sp, sp, -8
sw t0, 0(sp)
sw t1, 4(sp)
li t4, 0

jal opt
jal mult
jal signed

mv a0, t4

lw t0, 0(sp)
lw t1, 4(sp)
addi sp, sp, 8
```

```ass=
# replacement 4 - mul a1, t0, t1
# load length of array into second arg
addi sp, sp, -8
sw t0, 0(sp)
sw t1, 4(sp)
li t4, 0

jal opt
jal mult
jal signed

mv a1, t4

lw t0, 0(sp)
lw t1, 4(sp)
addi sp, sp, 8
```

<br>

### `Test Result`
```
test_classify_1_silent (__main__.TestClassify) ... ok
test_classify_2_print (__main__.TestClassify) ... ok
test_classify_3_print (__main__.TestClassify) ... ok
test_classify_fail_malloc (__main__.TestClassify) ... ok
test_classify_not_enough_args (__main__.TestClassify) ... ok

----------------------------------------------------------------------
Ran 5 tests in 6.290s

OK
```

<br><br>

## task IX - Run All

### `Test Result`
```
test_abs_minus_one (__main__.TestAbs) ... ok
test_abs_one (__main__.TestAbs) ... ok
test_abs_zero (__main__.TestAbs) ... ok
test_argmax_invalid_n (__main__.TestArgmax) ... ok
test_argmax_length_1 (__main__.TestArgmax) ... ok
test_argmax_standard (__main__.TestArgmax) ... ok
test_chain_1 (__main__.TestChain) ... ok
test_classify_1_silent (__main__.TestClassify) ... ok
test_classify_2_print (__main__.TestClassify) ... ok
test_classify_3_print (__main__.TestClassify) ... ok
test_classify_fail_malloc (__main__.TestClassify) ... ok
test_classify_not_enough_args (__main__.TestClassify) ... ok
test_dot_length_1 (__main__.TestDot) ... ok
test_dot_length_error (__main__.TestDot) ... ok
test_dot_length_error2 (__main__.TestDot) ... ok
test_dot_standard (__main__.TestDot) ... ok
test_dot_stride (__main__.TestDot) ... ok
test_dot_stride_error1 (__main__.TestDot) ... ok
test_dot_stride_error2 (__main__.TestDot) ... ok
test_matmul_incorrect_check (__main__.TestMatmul) ... ok
test_matmul_length_1 (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul) ... ok
test_matmul_square (__main__.TestMatmul) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul) ... ok
test_read_1 (__main__.TestReadMatrix) ... ok
test_read_2 (__main__.TestReadMatrix) ... ok
test_read_3 (__main__.TestReadMatrix) ... ok
test_read_fail_fclose (__main__.TestReadMatrix) ... ok
test_read_fail_fopen (__main__.TestReadMatrix) ... ok
test_read_fail_fread (__main__.TestReadMatrix) ... ok
test_read_fail_malloc (__main__.TestReadMatrix) ... ok
test_relu_invalid_n (__main__.TestRelu) ... ok
test_relu_length_1 (__main__.TestRelu) ... ok
test_relu_standard (__main__.TestRelu) ... ok
test_write_1 (__main__.TestWriteMatrix) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix) ... ok

----------------------------------------------------------------------
Ran 46 tests in 107.689s

OK

```

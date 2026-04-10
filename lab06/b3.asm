.data
    A: .word -2, 6, -1, 3, 4, -2

.text
main:
    la a0, A
    li a1, 6
    j mspfx

continue:
exit:
    li a7, 10
    ecall

#-----------------------------------------------------------------
# Procedure mspfx
#-----------------------------------------------------------------
mspfx:
    li s0, 0            # initialize length of prefix-sum in s0 to 0
    li s1, 0x80000000   # initialize max prefix-sum in s1 to smallest int
    li t0, 0            # initialize index for loop i in t0 to 0
    li t1, 0            # initialize running sum in t1 to 0

loop:
    slli t2, t0, 2      # t2 = i * 4 (thay cho 2 l?n add t2, t0)
    add t3, t2, a0      # t3 = address of A[i]
    lw t4, 0(t3)        # load A[i]
    add t1, t1, t4      # t1 = running sum
    
    blt s1, t1, mdfy    # if (s1 < t1) modify results
    j next

mdfy:
    addi s0, t0, 1      # s0 = length (i + 1)
    mv s1, t1           # s1 = new max sum (dùng mv thay cho addi s1, t1, 0)

next:
    addi t0, t0, 1      # i++
    blt t0, a1, loop    # if (i < n) repeat
done:
    j continue
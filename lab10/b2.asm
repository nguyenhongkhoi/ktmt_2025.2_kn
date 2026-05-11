.eqv MONITOR_SCREEN 0x10010000   
.eqv WARM_BROWN     0x00DAA06D   # Màu nâu sáng
.eqv BROWN          0x008B4513   # Màu nâu ??m
.text
main:
    li a0, MONITOR_SCREEN         # a0 l?u ??a ch? g?c
    li a1, 0                      # a1 = 0: ch? s? hàng b?t ??u t? 0
    li t6, 8                      # t6 = 8

loop_hang:
    beq a1, t6, exit             # N?u a1 == 8 thì ?ã v? xong t?t c? hàng ? thoát
    li a2, 0                     # a2 = 0: b?t ??u t? c?t ??u tiên

loop_cot:
beq a2, t6, next_row      # N?u a2 == 8 thì ?ã v? xong hàng ? sang hàng ti?p theo

    # Tính ??a ch? theo công th?c: (row * 8 + col) * 4
    li t0, 8                     # t0 = 8 (s? c?t m?i hàng)
    mul t1, a1, t0               # t1 = a1 * 8 
    add t1, t1, a2               # t1 = t1 + a2 (ch? s? ô hi?n t?i)
    slli t1, t1, 2               # t1 = t1 * 4

    add t2, a0, t1               # t2 = ??a ch? ô c?n tô màu

    # Tính (a1 + a2) % 2 ?? xen k? màu
    add t3, a1, a2              
    andi t3, t3, 1               # t3 = (a1 + a2) & 1 (n?u ch?n: 0, l?: 1)

    beqz t3, is_brown            # N?u t3 == 0 (ch?n), tô màu nâu ??m (BROWN)
    li t4, WARM_BROWN            # Ng??c l?i, tô màu nâu sáng
    sw t4, 0(t2)                
    j next_col                   # Chuy?n sang ô ti?p theo

is_brown:
    li t4, BROWN                
    sw t4, 0(t2)                 

next_col:
    addi a2, a2, 1               # T?ng 1 c?t
    j loop_cot                   

next_row:
    addi a1, a1, 1               # T?ng 1 hàng
    j loop_hang                  

exit:
    li a7, 10                    
    ecall                       

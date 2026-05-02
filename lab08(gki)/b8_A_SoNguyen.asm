
.data
    prompt:     .asciz "Nhap so nguyen duong N:  "
    res_msg:    .asciz "Chu so lon nhat la: "
    buffer:     .space 100   

.text
main:
    #nhap chuoi N
    li a7, 4           
    la a0, prompt
    ecall

    li a7, 8            # doc chuoi
    la a0, buffer       # Dia chi bo nho dem
    li a1, 100          # Do dai toi da
    ecall

    #khoi tao
    la t0, buffer       # t0 tro den ky tu dau tien
    lb t1, 0(t0)        # t1 giu chu so lon nhat hien tai (tam thoi la ki tu dau tien)
    
    # kiem tra rong
    beqz t1, end_program

loop:
    addi t0, t0, 1      # Chuyen den ky tu tiep theo
    lb t2, 0(t0)        # Doc ky tu hien tai vao t2

    # kiem tra ket thuc
    li t3, 10           # ktra ki tu xuong dong, neu la \n thi end chuoi
    beq t2, t3, print_result
    beqz t2, print_result

    #so sanh
    ble t2, t1, loop    # Neu t2 <= t1 thi tiep tuc lap
    mv t1, t2           # Neu t2 > t1 thi cap nhat t1 = t2
    j loop

print_result:
    #kqua
    li a7, 4            # In thong bao ket qua
    la a0, res_msg
    ecall

    li a7, 11           # In ki tu max
    mv a0, t1
    ecall

end_program:
    li a7, 10           
    ecall
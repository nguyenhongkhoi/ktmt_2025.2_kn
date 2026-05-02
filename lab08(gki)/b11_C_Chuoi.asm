.data
    prompt:     .asciz "Nhap xau ky tu: "
    res_msg:    .asciz "Ket qua sau khi doi: "
    buffer:     .space 100    

.text
main:
    # nhap xau ky tu
    li a7, 4            # in tb
    la a0, prompt
    ecall

    li a7, 8            # nhap xau tu ban phim
    la a0, buffer
    li a1, 100
    ecall

    #duyet tung ky tu va kiem tra bien doi
    la t0, buffer       # t0 tr? vào buffer

loop:
    lb t1, 0(t0)        # load ky tu hien tai vao t1
    
    # kiem tra ket thuc chuoi(\n)
    beqz t1, print_result
    li t2, 10           
    beq t1, t2, print_result

    # kiem tra neu la chu HOA (ma ascii la 65 - 90)
    li t2, 65           # A
    li t3, 90           # Z
    blt t1, t2, check_lower  # neu < 65 co the la chu thuong hoac ky tu khac
    bgt t1, t3, check_lower  # neu > 90 kiem tra tiep chu thuong
    
    # Neu la chu HOA -> cong them 32 de thanh chu thuong
    addi t1, t1, 32
    sb t1, 0(t0)        # luu lai
    j next_char

check_lower:
    # Kiem tra neu la chu thuong (97 den 122)
    li t2, 97           # a
    li t3, 122          # z
    blt t1, t2, next_char    # Neu < 97, la ky tu khac -> Giu nguyen
    bgt t1, t3, next_char    # Neu > 122, la ky tu khac -> Giu nguyen
    
    # Neu la chu thuong -> tru di 32
    addi t1, t1, -32
    sb t1, 0(t0)        # luu lai

next_char:
    addi t0, t0, 1      # chuyen sang ki tu tiep theo
    j loop

print_result:
    # print kq
    li a7, 4
    la a0, res_msg
    ecall

    li a7, 4
    la a0, buffer       # xau da doi
    ecall

    li a7, 10           # Thoat
    ecall
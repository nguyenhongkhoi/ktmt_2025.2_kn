.data
    prompt_n:   .asciz "Nhap so luong phan tu n: "
    prompt_val: .asciz "Nhap phan tu: "
    res_msg:    .asciz "Cap phan tu lien ke co tong nho nhat la: "
    and_msg:    .asciz " va "
    array:      .word 0:100   

.text
main:
    #nhap so luong phan tu n
    li a7, 4            # In thong bao nhap n
    la a0, prompt_n
    ecall
    
    li a7, 5            # Doc so nguyen n
    ecall
    mv s0, a0           # s0 = n (gan so phan tu vao s0)

    #nhap mang
    la s1, array        # s1 = dia chi base cua mang
    li t0, 0            # t0 = i (bien dem)
input_loop:
    bge t0, s0, process # Neu i >= n thi chuyen sang xu ly
    
    li a7, 4            # tbao nhap ptu mang
    la a0, prompt_val
    ecall
    
    li a7, 5            # Doc so nguyen
    ecall
    
    slli t1, t0, 2      # t1 = i * 4(moi so nguyen 4 byte)
    add t1, s1, t1      # t1 = dia chi mang[i]
    sw a0, 0(t1)        # Luu gia tri vao mang
    
    addi t0, t0, 1      # i++
    j input_loop

process:
    #Tim cap co tong nho nhat
    # Khoi tao: lay cap 2 ptu dau tien cua mang la a[0] va a[1] bat dau chayj thuat toan
    lw t2, 0(s1)        # t2 = array[0]
    lw t3, 4(s1)        # t3 = array[1]
    add t4, t2, t3      # t4 = tong nho nhat hien tai (minSum)
    
    mv s2, t2           # s2 = so thu nhat cua cap min
    mv s3, t3           # s3 = so thu hai cua cap min(s2,s3 luu gia tri cap nho nhat khi do)
    
    li t0, 1            # t0 = i (bat dau tu phan tu thu 2 de xet cap i, i+1)
    addi t5, s0, -1     # end vong

find_min_loop:
    bge t0, t5, print_result
    
    slli t1, t0, 2      # t1 = i * 4
    add t1, s1, t1      # t1 = dia chi array[i]
    
    lw t2, 0(t1)        # t2 = a[i]
    lw t3, 4(t1)        # t3 = a[i+1]
    add t6, t2, t3      # t6 = tong hien tai
    
    bge t6, t4, next_iter # Neu t6tong dg xet) >= t4(min sum hien tai) thi bo qua
    
    mv t4, t6           # Cap nhat tong min moi
    mv s2, t2           # Cap nhat phan tu 1
    mv s3, t3           # Cap nhat phan tu 2

next_iter:
    addi t0, t0, 1      # i++
    j find_min_loop

print_result:
    # in ket qua
    li a7, 4
    la a0, res_msg
    ecall
    
    li a7, 1            # In so thu nhat (s2)
    mv a0, s2
    ecall
    
    li a7, 4            # In chu "va"
    la a0, and_msg
    ecall
    
    li a7, 1            # In so thu hai (s3)
    mv a0, s3
    ecall

    li a7, 10           
    ecall
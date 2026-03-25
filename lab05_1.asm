.data
    string:   .space 50
    message1: .asciz "Nhap xau: "
    message2: .asciz "Do dai xau la: "

.text
.globl main

main:
get_string:
    # S? d?ng syscall 54 (InputString) trong RARS/Mars
    li a7, 54
    la a0, message1    # Hi?n th? thông báo nh?p
    la a1, string      # Ð?a ch? vùng nh? lýu chu?i
    li a2, 50          # Ð? dài t?i ða
    ecall

get_length:
    la a0, string      # a0 = ð?a ch? cõ s? c?a chu?i
    li t0, 0           # t0 = i = 0 (bi?n ð?m ð? dài)
    li x1, 10          # ASCII c?a '\n' là 10

check_char:
    add t1, a0, t0     # t1 = ð?a ch? c?a string[i]
    lb  t2, 0(t1)      # t2 = giá tr? k? t? t?i string[i]

    # Ki?m tra ði?u ki?n d?ng
    beq t2, zero, end_of_str    # N?u là k? t? NULL (0) -> K?t thúc
    beq t2, x1, end_of_str      # N?u là k? t? \n -> K?t thúc

    addi t0, t0, 1     # t0 = t0 + 1 (tãng ð? dài)
    j check_char       # L?p l?i

end_of_str:
print_length:
    # S? d?ng syscall 56 (MessageDialogInt) ð? in thông báo kèm s? nguyên
    li a7, 56
    la a0, message2    # Chu?i thông báo
    mv a1, t0          # Giá tr? ð? dài c?n in
    ecall

exit:
    # K?t thúc chýõng tr?nh
    li a7, 10
    ecall
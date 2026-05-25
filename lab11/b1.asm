.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012     # ??a ch? ghi hàng ?? quét phím
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014    # ??a ch? ??c giá tr? phím ???c nh?n
.data
space: .asciz "\n"
.text
main:
    li t1, IN_ADDRESS_HEXA_KEYBOARD          # (1) Gán ??a ch? IN
    li t2, OUT_ADDRESS_HEXA_KEYBOARD         # (2) Gán ??a ch? OUT

polling:
    li s0, 0x01                               # (3) B?t ??u t? hàng ??u tiên
    li t4, 0x10                               # (4) Gi?i h?n hàng là 0x10
scan_loop:
    sb s0, 0(t1)                              # (5) Ghi hàng vào IN ?? quét
    lb a0, 0(t2)                              # (6) ??c mã phím t? OUT

    beq a0, zero, next_row                    # (7) Không có phím ? chuy?n hàng
    li a7, 34                                           # (8) In mã phím d?ng hex
    ecall
    li a7, 4
    la a0, space
    ecall

    li a0, 100                                # (9) Ng? 100ms
    li a7, 32
    ecall

next_row:
    slli s0, s0, 1                            # (10) Sang hàng ti?p theo
    blt s0, t4, scan_loop                     # (11) N?u ch?a h?t hàng ? l?p l?i

    j polling                                 # (12) Quét l?i t? ??u

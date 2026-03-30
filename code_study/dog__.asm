.text
main:
    li t0, 15       # t0 = 15
    li t1, 25       # t1 = 25
    add t2, t0, t0  # t2 = t0 + t1 (40)

    # In k?t qu? ra màn h?nh
    li a7, 1        # M? d?ch v? s? 1: In s? nguyên (Print Integer)
    add a0, zero, t2 # Ðýa k?t qu? t2 vào a0 ð? in
    ecall           # Th?c hi?n l?nh in

    # Thoát chýõng tr?nh
    li a7, 10       # M? d?ch v? s? 10: Exit
    ecall
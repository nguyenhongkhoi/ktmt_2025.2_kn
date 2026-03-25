# Laboratory Exercise 2, Assignment 6
.data # Kh?i t?o bi?n (declare memory)
X: .word 5 # Bi?n X, ki?u word (4 bytes), giá tr? kh?i t?o = 5
Y: .word -1 # Bi?n Y, ki?u word (4 bytes), giá tr? kh?i t?o = -1
Z: .word 0 # Bi?n Z, ki?u word (4 bytes), giá tr? kh?i t?o = 0
.text # Kh?i t?o l?nh (declare instruction)
# N?p giá tr? X và Y vào các thanh ghi
la t5, X # L?y ð?a ch? c?a X trong vùng nh? ch?a d? li?u
la t6, Y # L?y ð?a ch? c?a Y
lw t1, 0(t5) # t1 = X
lw t2, 0(t6) # t2 = Y
# Tính bi?u th?c Z = 2X + Y v?i các thanh ghi
add s0, t1, t1
add s0, s0, t2
# Lýu k?t qu? t? thanh ghi vào b? nh?
la t4, Z # L?y ð?a ch? c?a Z
sw s0, 0(t4) # Lýu giá tr? c?a Z t? thanh ghi vào b? nh?
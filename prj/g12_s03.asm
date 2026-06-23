# ============================================================
# Bai 3: May tinh bo tui - RISC-V Assembly (RARS 1.6)
# Ngoai vi: Digital Lab Sim -> Connect to Program
#
# MMIO (base = 0xFFFF0000 = -65536 dang signed):
#   sb val, 16(rx) -> 0xFFFF0010 : LED phai (don vi)
#   sb val, 17(rx) -> 0xFFFF0011 : LED trai  (chuc)
#   sb val, 18(rx) -> 0xFFFF0012 : Keypad row select
#   lb val, 20(rx) -> 0xFFFF0014 : Keypad col read
#
# Keypad (col o bit 4-7):
#   row=1 -> [0][1][2][3]
#   row=2 -> [4][5][6][7]
#   row=4 -> [8][9][a][b]
#   row=8 -> [c][d][e][f]
#
# Phim: 0-9=chu so, a=+, b=-, c=*, d=/, e=%, f==
# ============================================================

# =======================
# VUNG DU LIEU (.data)
# =======================
.data

# Bang ma 7-doan: moi byte la to hop bit bat/tat 7 thanh LED
# tuong ung voi chu so 0-9
# bit0=a(tren), bit1=b(phai tren), bit2=c(phai duoi),
# bit3=d(duoi), bit4=e(trai duoi), bit5=f(trai tren), bit6=g(giua)
seg7:
    .byte 63    # chu so 0: bat thanh a b c d e f     = 0b00111111
    .byte 6     # chu so 1: bat thanh b c             = 0b00000110
    .byte 91    # chu so 2: bat thanh a b d e g       = 0b01011011
    .byte 79    # chu so 3: bat thanh a b c d g       = 0b01001111
    .byte 102   # chu so 4: bat thanh b c f g         = 0b01100110
    .byte 109   # chu so 5: bat thanh a c d f g       = 0b01101101
    .byte 125   # chu so 6: bat thanh a c d e f g     = 0b01111101
    .byte 7     # chu so 7: bat thanh a b c           = 0b00000111
    .byte 127   # chu so 8: bat tat ca 7 thanh        = 0b01111111
    .byte 111   # chu so 9: bat thanh a b c d f g     = 0b01101111

op1:    .word 0     # con số đầu tiên của phép tính (khi bấm + - * / thì cur -> op1)
op2:    .word 0     # toan hang thu hai  (luu khi nguoi dung nhan dau =)
opr:    .word 0     # toan tu hien tai (ma ASCII: 43=+ 45=- 42=* 47=/ 37=%)
res:    .word 0     # ket qua cua phep tinh gan nhat
cur:    .word 0     # so dang duoc nhap (tich luy tung chu so)
state:  .word 0     # trang thai may tinh: 0=nhap so1, 1=nhap so2, 2=hien KQ
pkey:   .word 255   # ma phim lan quet truoc (debounce); 255 = chua co phim

# =======================
# VUNG LENH (.text)
# =======================
.text
.globl main     # khai bao main la diem vao chuong trinh

# ============================================================
# MAIN: Khoi tao toan bo bien roi vao vong lap chinh
# ============================================================
main:
    la   t0, op1        # t0 = dia chi cua bien op1 trong bo nho
    sw   zero, 0(t0)    # op1 = 0 (chua co toan hang 1)

    la   t0, op2        # t0 = dia chi cua bien op2
    sw   zero, 0(t0)    # op2 = 0 (chua co toan hang 2)

    la   t0, opr        # t0 = dia chi cua bien opr
    sw   zero, 0(t0)    # opr = 0 (chua co toan tu)

    la   t0, res        # t0 = dia chi cua bien res
    sw   zero, 0(t0)    # res = 0 (chua co ket qua)

    la   t0, cur        # t0 = dia chi cua bien cur
    sw   zero, 0(t0)    # cur = 0 (chua nhap chu so nao)

    la   t0, state      # t0 = dia chi cua bien state
    sw   zero, 0(t0)    # state = 0 (trang thai ban dau: dang nhap so thu nhat)

    la   t0, pkey       # t0 = dia chi cua bien pkey
    li   t1, 255        # t1 = 255 (gia tri sentinel: "chua co phim nao")
    sw   t1, 0(t0)      # pkey = 255 (khong dung 0 vi phim '0' co ma = 0)

    li   a0, 0          # truyen doi so 0 vao fn_display
    call fn_display     # hien thi "00" len LED luc khoi dong

# ------ Vong lap chinh ------
main_loop:
    li   t0, 2000       # nap gia tri dem xuong 2000 cho vong delay
delay_loop:
    addi t0, t0, -1     # dem xuong 1
    bnez t0, delay_loop # lap lai cho den khi t0 = 0 (delay ~2000 chu ky)
                        # muc dich: tranh truy cap MMIO lien tuc gay crash

    call fn_scan        # quet keypad, ket qua tra ve trong a0
    li   t0, -1         # t0 = -1 (gia tri bieu thi "khong co phim")
    beq  a0, t0, main_loop  # neu a0 == -1: khong co phim moi -> quet tiep
    call fn_process     # co phim moi: xu ly phim (a0 = 0..15)
    j    main_loop      # quay lai vong lap chinh


# ============================================================
# fn_scan: Quet keypad 4x4 theo phuong phap ma tran hang-cot
# Output: a0 = 0..15 neu co phim moi, -1 neu khong co hoac phim trung
#
# Nguyen ly: lan luot kich hoat tung hang bang row_mask = 1,2,4,8
# roi doc ket qua cot. Digital Lab Sim tra cot o bit 4-7.
# ============================================================
fn_scan:
    addi sp, sp, -24    # mo stack frame 24 byte (luu 6 register x 4 byte)
    sw   ra,  0(sp)     # luu return address (vi fn_scan khong goi ham khac nhung can bao toan)
    sw   s0,  4(sp)     # luu s0 (se dung lam row_mask)
    sw   s1,  8(sp)     # luu s1 (se dung lam row_index)
    sw   s2, 12(sp)     # luu s2 (se dung lam col_index)
    sw   s3, 16(sp)     # luu s3 (se dung luu gia tri cot doc ve)
    sw   s4, 20(sp)     # luu s4 (se dung luu dia chi MMIO co so)

    li   s4, -65536     # s4 = 0xFFFF0000 (dia chi quan ly thiet bi ngoai vi)
    li   s0, 1          # s0 = row_mask bat dau = 1 (hang 0)
    li   s1, 0          # s1 = row_index bat dau = 0

# ------ Vong lap quet tung hang ------
scan_row:
    sb   s0, 18(s4)     # ghi row_mask vao 0xFFFF0012 -> kich hoat hang can quet
    nop                 # cho phần cứng keypad kip phan hoi (can it nhat ~5 nop)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lb   s3, 20(s4)     # doc ket qua cot tu 0xFFFF0014 vao s3
    andi s3, s3, 255    # mask de dam bao chi lay 8 bit thap (unsigned)

    li   s2, 0          # s2 = col_index bat dau = 0

# ------ Vong lap kiem tra tung cot trong hang hien tai ------
scan_col:
    addi t0, s2, 4      # t0 = 4 + col_index (vi keypad tra cot o bit 4-7)
    li   t1, 1          # t1 = 1 (chuan bi tao mask)
    sll  t1, t1, t0     # t1 = 1 << (4 + col_index) = mask kiem tra bit cot
    and  t2, s3, t1     # t2 = s3 AND mask (kiem tra bit cot do co bat khong)
    beqz t2, scan_next_col  # neu bit = 0: cot nay khong co phim -> sang cot ke

    # Tim thay phim tai (row_index, col_index)
    slli a0, s1, 2      # a0 = row_index * 4 (dich trai 2 bit = nhan 4, nhanh hon mul)
    add  a0, a0, s2     # a0 = row_index * 4 + col_index = ma phim (0..15)

    # Kiem tra debounce: bo qua neu trung voi phim lan truoc
    la   t0, pkey       # t0 = dia chi bien pkey
    lw   t1, 0(t0)      # t1 = gia tri pkey (ma phim lan truoc)
    beq  a0, t1, scan_dup   # neu ma phim == pkey: phim cu, bo qua
    sw   a0, 0(t0)      # phim moi: cap nhat pkey = ma phim hien tai
    j    scan_done      # nhay den cuoi, tra ve ma phim hop le

scan_dup:
    li   a0, -1         # phim trung voi lan truoc -> tra ve -1 (bo qua)
    j    scan_done

scan_next_col:
    addi s2, s2, 1      # col_index++
    li   t0, 4          # t0 = 4 (so cot toi da)
    blt  s2, t0, scan_col  # neu col_index < 4: tiep tuc quet cot ke

    # Het cot, chuyen sang hang tiep theo
    slli s0, s0, 1      # row_mask <<= 1 (1 -> 2 -> 4 -> 8)
    addi s1, s1, 1      # row_index++
    li   t0, 4          # t0 = 4 (so hang toi da)
    blt  s1, t0, scan_row   # neu row_index < 4: tiep tuc quet hang ke

    # Quet het 4 hang x 4 cot, khong tim thay phim nao
    la   t0, pkey       # t0 = dia chi bien pkey
    li   t1, 255        # t1 = 255 (sentinel: khong co phim)
    sw   t1, 0(t0)      # reset pkey = 255 de san sang nhan phim tiep theo
    li   a0, -1         # tra ve -1: khong co phim

scan_done:
    sb   zero, 18(s4)   # ghi 0 vao row select -> xoa kich hoat, tat hang

    # Phuc hoi cac register da luu
    lw   ra,  0(sp)     # phuc hoi return address
    lw   s0,  4(sp)     # phuc hoi s0
    lw   s1,  8(sp)     # phuc hoi s1
    lw   s2, 12(sp)     # phuc hoi s2
    lw   s3, 16(sp)     # phuc hoi s3
    lw   s4, 20(sp)     # phuc hoi s4
    addi sp, sp, 24     # dong stack frame, tra lai con tro stack
    ret                 # tra ve (a0 chua ma phim 0..15 hoac -1)


# ============================================================
# fn_process: Phan loai phim va goi ham xu ly tuong ung
# Input: a0 = ma phim (0..15)
# ============================================================
fn_process:
    addi sp, sp, -4     # mo stack frame 4 byte (chi can luu ra)
    sw   ra, 0(sp)      # luu return address (vi ham nay goi cac ham khac)

    li   t0, 10         # t0 = 10 (nguong phan biet so va toan tu)
    blt  a0, t0, fp_digit   # neu a0 < 10: la phim so (0-9) -> fp_digit

    # Phan loai phim toan tu (a0 = 10..15)
    li   t0, 10
    beq  a0, t0, fp_add # a0 == 10 (phim 'a') -> phep cong
    li   t0, 11
    beq  a0, t0, fp_sub # a0 == 11 (phim 'b') -> phep tru
    li   t0, 12
    beq  a0, t0, fp_mul # a0 == 12 (phim 'c') -> phep nhan
    li   t0, 13
    beq  a0, t0, fp_div # a0 == 13 (phim 'd') -> phep chia
    li   t0, 14
    beq  a0, t0, fp_mod # a0 == 14 (phim 'e') -> phep lay du
    # Con lai: a0 == 15 (phim 'f') -> dau bang
    call fn_equals      # goi xu ly dau =
    j    fp_done

fp_digit:
    call fn_digit       # goi xu ly phim so (a0 van chua gia tri 0..9)
    j    fp_done

fp_add:
    li   a0, 43         # a0 = 43 = ma ASCII cua '+'
    call fn_oper        # goi xu ly toan tu voi toan tu la '+'
    j    fp_done

fp_sub:
    li   a0, 45         # a0 = 45 = ma ASCII cua '-'
    call fn_oper        # goi xu ly toan tu voi toan tu la '-'
    j    fp_done

fp_mul:
    li   a0, 42         # a0 = 42 = ma ASCII cua '*'
    call fn_oper        # goi xu ly toan tu voi toan tu la '*'
    j    fp_done

fp_div:
    li   a0, 47         # a0 = 47 = ma ASCII cua '/'
    call fn_oper        # goi xu ly toan tu voi toan tu la '/'
    j    fp_done

fp_mod:
    li   a0, 37         # a0 = 37 = ma ASCII cua '%'
    call fn_oper        # goi xu ly toan tu voi toan tu la '%'
    # khong can j fp_done vi fp_done la dong tiep theo

fp_done:
    lw   ra, 0(sp)      # phuc hoi return address
    addi sp, sp, 4      # dong stack frame
    ret                 # tra ve main_loop


# ============================================================
# fn_digit: Xu ly phim so 0-9
# Input: a0 = gia tri so (0..9)
# Tich luy chu so vao cur theo cong thuc: cur = cur*10 + digit
# ============================================================
fn_digit:
    addi sp, sp, -8     # mo stack frame 8 byte (luu ra va s0)
    sw   ra, 0(sp)      # luu return address
    sw   s0, 4(sp)      # luu s0 (se dung de giu gia tri digit)
    mv   s0, a0         # s0 = digit (luu lai truoc khi a0 bi ghi de)

    la   t0, state      # t0 = dia chi bien state
    lw   t1, 0(t0)      # t1 = gia tri state hien tai
    li   t2, 2          # t2 = 2 (gia tri state "dang hien thi KQ")
    bne  t1, t2, fd_accum  # neu state != 2: tiep tuc tich luy binh thuong

    # state == 2: vua hien thi ket qua, nguoi dung bat dau tinh toan moi
    sw   zero, 0(t0)    # state = 0 (reset ve trang thai nhap so dau)
    la   t0, cur
    sw   zero, 0(t0)    # cur = 0 (xoa so dang nhap)
    la   t0, opr
    sw   zero, 0(t0)    # opr = 0 (xoa toan tu cu)
    la   t0, op1
    sw   zero, 0(t0)    # op1 = 0 (xoa toan hang 1 cu)
    la   t0, op2
    sw   zero, 0(t0)    # op2 = 0 (xoa toan hang 2 cu)

fd_accum:
    # Tich luy chu so: cur = cur * 10 + digit
    la   t0, cur        # t0 = dia chi bien cur
    lw   t1, 0(t0)      # t1 = gia tri cur hien tai
    li   t2, 10         # t2 = 10
    mul  t1, t1, t2     # t1 = cur * 10 (dich cac chu so cu sang trai 1 hang)
    add  t1, t1, s0     # t1 = cur * 10 + digit (chen chu so moi vao hang don vi)
    sw   t1, 0(t0)      # cap nhat cur = gia tri moi

    mv   a0, t1         # truyen cur vao fn_display
    call fn_display     # hien thi cur len LED (chi hien 2 chu so cuoi)

    lw   ra, 0(sp)      # phuc hoi return address
    lw   s0, 4(sp)      # phuc hoi s0
    addi sp, sp, 8      # dong stack frame
    ret                 # tra ve fn_process


# ============================================================
# fn_oper: Xu ly phim toan tu (+, -, *, /, %)
# Input: a0 = ma ASCII cua toan tu (43/45/42/47/37)
# Ho tro tinh toan lien tiep (chained calculation)
# ============================================================
fn_oper:
    addi sp, sp, -8     # mo stack frame 8 byte
    sw   ra, 0(sp)      # luu return address
    sw   s0, 4(sp)      # luu s0 (se dung de giu ma ASCII toan tu)
    mv   s0, a0         # s0 = ma ASCII toan tu (luu lai truoc khi a0 bi ghi de)

    la   t0, state      # t0 = dia chi bien state
    lw   t1, 0(t0)      # t1 = gia tri state hien tai

    li   t2, 2
    beq  t1, t2, fo_from_res   # neu state == 2: vua hien KQ, lay result lam op1 moi

    li   t2, 1
    beq  t1, t2, fo_state1     # neu state == 1: dang o giua phep tinh, xu ly tiep

    # state == 0: lan dau nhan toan tu sau khi nhap so dau tien
    la   t0, cur        # t0 = dia chi bien cur
    lw   t2, 0(t0)      # t2 = gia tri cur (so vua nhap)
    la   t0, op1        # t0 = dia chi bien op1
    sw   t2, 0(t0)      # op1 = cur (luu so thu nhat)
    la   t0, cur        # t0 = dia chi bien cur
    sw   zero, 0(t0)    # cur = 0 (reset de chuan bi nhan so thu hai)
    j    fo_set         # nhay den luu toan tu va cap nhat state

fo_state1:
    # state == 1: da co op1 va opr, kiem tra xem da nhap so thu hai chua
    la   t0, cur        # t0 = dia chi bien cur
    lw   t2, 0(t0)      # t2 = gia tri cur
    beqz t2, fo_change_op   # neu cur == 0: chua nhap so moi, chi doi toan tu

    # cur != 0: da nhap so thu hai, tinh trung gian truoc roi dat toan tu moi
    la   t0, op2        # t0 = dia chi bien op2
    sw   t2, 0(t0)      # op2 = cur (luu so thu hai)
    la   t0, cur        # t0 = dia chi bien cur
    sw   zero, 0(t0)    # cur = 0 (reset cho so tiep theo)
    call fn_calc        # tinh op1 [opr] op2 -> res
    la   t0, res        # t0 = dia chi bien res
    lw   t2, 0(t0)      # t2 = ket qua vua tinh
    la   t0, op1        # t0 = dia chi bien op1
    sw   t2, 0(t0)      # op1 = ket qua (lam toan hang thu nhat cho phep tinh tiep)
    mv   a0, t2         # truyen ket qua vao fn_display
    call fn_display     # hien thi ket qua trung gian len LED
    j    fo_set         # nhay den luu toan tu moi va giu state = 1

fo_from_res:
    # state == 2: nguoi dung nhan toan tu sau khi da co ket qua
    la   t0, res        # t0 = dia chi bien res
    lw   t2, 0(t0)      # t2 = ket qua cua phep tinh truoc
    la   t0, op1        # t0 = dia chi bien op1
    sw   t2, 0(t0)      # op1 = result (tiep tuc tinh tu ket qua)
    la   t0, cur        # t0 = dia chi bien cur
    sw   zero, 0(t0)    # cur = 0 (reset cho so moi)
    j    fo_set         # nhay den luu toan tu moi

fo_change_op:
    # Truong hop dac biet: nguoi dung doi toan tu khi chua nhap so thu hai
    la   t0, opr        # t0 = dia chi bien opr
    sw   s0, 0(t0)      # opr = toan tu moi (chi thay doi toan tu, khong lam gi khac)
    j    fo_done        # khong thay doi state

fo_set:
    # Luu toan tu moi va chuyen state = 1
    la   t0, opr        # t0 = dia chi bien opr
    sw   s0, 0(t0)      # opr = toan tu moi (ma ASCII)
    la   t0, state      # t0 = dia chi bien state
    li   t2, 1          # t2 = 1
    sw   t2, 0(t0)      # state = 1 (dang cho nhap so thu hai)

fo_done:
    lw   ra, 0(sp)      # phuc hoi return address
    lw   s0, 4(sp)      # phuc hoi s0
    addi sp, sp, 8      # dong stack frame
    ret                 # tra ve fn_process


# ============================================================
# fn_equals: Xu ly phim f (dau bang =)
# Lay cur lam op2, tinh op1 [opr] op2, hien thi ket qua
# ============================================================
fn_equals:
    addi sp, sp, -4     # mo stack frame 4 byte
    sw   ra, 0(sp)      # luu return address (vi goi fn_calc va fn_display)

    la   t0, cur        # t0 = dia chi bien cur
    lw   t1, 0(t0)      # t1 = gia tri cur (so thu hai vua nhap)
    la   t0, op2        # t0 = dia chi bien op2
    sw   t1, 0(t0)      # op2 = cur (luu so thu hai cho phep tinh)

    call fn_calc        # tinh op1 [opr] op2, luu vao res

    la   t0, res        # t0 = dia chi bien res
    lw   a0, 0(t0)      # a0 = ket qua (chuan bi truyen vao fn_display)
    call fn_display     # hien thi ket qua len LED

    la   t0, state      # t0 = dia chi bien state
    li   t1, 2          # t1 = 2
    sw   t1, 0(t0)      # state = 2 (dang hien thi ket qua)

    la   t0, cur        # t0 = dia chi bien cur
    sw   zero, 0(t0)    # cur = 0 (reset so dang nhap)

    lw   ra, 0(sp)      # phuc hoi return address
    addi sp, sp, 4      # dong stack frame
    ret                 # tra ve fn_process


# ============================================================
# fn_calc: Thuc hien phep tinh op1 [opr] op2, luu ket qua vao res
# Khong nhan doi so, doc truc tiep tu bien toan cuc
# ============================================================
fn_calc:
    addi sp, sp, -20    # mo stack frame 20 byte (luu 5 register x 4 byte)
    sw   ra,  0(sp)     # luu return address
    sw   s0,  4(sp)     # luu s0 (se dung lam op1)
    sw   s1,  8(sp)     # luu s1 (se dung lam op2)
    sw   s2, 12(sp)     # luu s2 (se dung lam opr)
    sw   s3, 16(sp)     # luu s3 (se dung lam ket qua tam)

    la   t0, op1        # t0 = dia chi bien op1
    lw   s0, 0(t0)      # s0 = op1 (toan hang thu nhat)
    la   t0, op2        # t0 = dia chi bien op2
    lw   s1, 0(t0)      # s1 = op2 (toan hang thu hai)
    la   t0, opr        # t0 = dia chi bien opr
    lw   s2, 0(t0)      # s2 = opr (ma ASCII cua toan tu)

    # Phan nhanh theo toan tu
    li   t0, 43
    beq  s2, t0, fc_add # opr == '+' (43) -> nhay den cong
    li   t0, 45
    beq  s2, t0, fc_sub # opr == '-' (45) -> nhay den tru
    li   t0, 42
    beq  s2, t0, fc_mul # opr == '*' (42) -> nhay den nhan
    li   t0, 47
    beq  s2, t0, fc_div # opr == '/' (47) -> nhay den chia
    li   t0, 37
    beq  s2, t0, fc_mod # opr == '%' (37) -> nhay den lay du

    # Khong co toan tu hop le: tra ve op1 nguyen ven
    mv   s3, s0         # s3 = op1
    j    fc_store       # nhay den luu ket qua

fc_add:
    add  s3, s0, s1     # s3 = op1 + op2
    j    fc_store

fc_sub:
    sub  s3, s0, s1     # s3 = op1 - op2
    j    fc_store

fc_mul:
    mul  s3, s0, s1     # s3 = op1 * op2
    j    fc_store

fc_div:
    beqz s1, fc_err     # neu op2 == 0: chia cho 0, nhay den xu ly loi
    div  s3, s0, s1     # s3 = op1 / op2 (chia nguyen co dau)
    j    fc_store

fc_mod:
    beqz s1, fc_err     # neu op2 == 0: lay du cho 0, nhay den xu ly loi
    rem  s3, s0, s1     # s3 = op1 % op2 (phan du co dau)
    j    fc_store

fc_err:
    li   s3, 0          # loi chia cho 0: tra ve 0 thay vi gay crash

fc_store:
    la   t0, res        # t0 = dia chi bien res
    sw   s3, 0(t0)      # res = s3 (luu ket qua vao bien toan cuc)

    # Phuc hoi cac register
    lw   ra,  0(sp)     # phuc hoi return address
    lw   s0,  4(sp)     # phuc hoi s0
    lw   s1,  8(sp)     # phuc hoi s1
    lw   s2, 12(sp)     # phuc hoi s2
    lw   s3, 16(sp)     # phuc hoi s3
    addi sp, sp, 20     # dong stack frame
    ret                 # tra ve fn_equals hoac fn_oper


# ============================================================
# fn_display: Hien thi 2 chu so cuoi cua a0 len 2 LED 7-doan
# Input: a0 = so nguyen bat ky (signed)
# LED trai (0xFFFF0011) = hang chuc, LED phai (0xFFFF0010) = hang don vi
# ============================================================
fn_display:
    addi sp, sp, -8     # mo stack frame 8 byte
    sw   ra, 0(sp)      # luu return address
    sw   s0, 4(sp)      # luu s0 (se dung luu gia tri can hien thi)
    mv   s0, a0         # s0 = a0 (luu lai de xu ly)

    bgez s0, fd_pos     # neu s0 >= 0: khong can xu ly dau am, nhay qua
    neg  s0, s0         # s0 am: doi thanh duong (lay gia tri tuyet doi)

fd_pos:
    li   t0, 100        # t0 = 100
    rem  s0, s0, t0     # s0 = s0 % 100 (chi lay 2 chu so cuoi, ket qua 0..99)

    li   s1, -65536     # s1 = 0xFFFF0000 (dia chi co so MMIO)

    # Hien thi hang don vi (LED phai - 0xFFFF0010)
    li   t0, 10         # t0 = 10
    rem  t1, s0, t0     # t1 = s0 % 10 = chu so hang don vi (0..9)
    la   t2, seg7       # t2 = dia chi dau bang seg7
    add  t2, t2, t1     # t2 = dia chi cua seg7[chu_so_don_vi]
    lbu  t3, 0(t2)      # t3 = ma 7-doan cua chu so hang don vi (load byte unsigned)
    sb   t3, 16(s1)     # ghi ma 7-doan vao 0xFFFF0010 (LED phai)

    # Hien thi hang chuc (LED trai - 0xFFFF0011)
    div  t1, s0, t0     # t1 = s0 / 10 = chu so hang chuc (0..9)
    la   t2, seg7       # t2 = dia chi dau bang seg7
    add  t2, t2, t1     # t2 = dia chi cua seg7[chu_so_hang_chuc]
    lbu  t3, 0(t2)      # t3 = ma 7-doan cua chu so hang chuc
    sb   t3, 17(s1)     # ghi ma 7-doan vao 0xFFFF0011 (LED trai)

    lw   ra, 0(sp)      # phuc hoi return address
    lw   s0, 4(sp)      # phuc hoi s0
    addi sp, sp, 8      # dong stack frame
    ret                 # tra ve ham goi

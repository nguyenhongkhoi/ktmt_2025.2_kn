.eqv SEVENSEG_LEFT    0xFFFF0011   # Dia chi cua den led 7 doan trai
.eqv SEVENSEG_RIGHT   0xFFFF0010   # Dia chi cua den led 7 doan phai

.text
main:
    li    a0, 0x6D                # Ma Hex hien thi so 5
    jal   SHOW_7SEG_LEFT          # Show so 5 ben trai
    
    li    a0, 0x7D                # Ma Hex hien thi so 6
    jal   SHOW_7SEG_RIGHT         # Show so 6 ben phai

exit:
    li    a7, 10
    ecall
end_main:

# ---------------------------------------------------------------
# Function SHOW_7SEG_LEFT : turn on/off the 7seg
# param[in] a0 value to shown
# remark t0 changed
# ---------------------------------------------------------------
SHOW_7SEG_LEFT:
    li    t0, SEVENSEG_LEFT       # assign port's address
    sb    a0, 0(t0)               # assign new value
    jr    ra

# ---------------------------------------------------------------
# Function SHOW_7SEG_RIGHT : turn on/off the 7seg
# param[in] a0 value to shown
# remark t0 changed
# ---------------------------------------------------------------
SHOW_7SEG_RIGHT:
    li    t0, SEVENSEG_RIGHT      # assign port's address
    sb    a0, 0(t0)               # assign new value
    jr    ra
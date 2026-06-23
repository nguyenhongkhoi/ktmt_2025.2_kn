.eqv SEVENSEG_LEFT	0xFFFF0011
.eqv SEVENSEG_RIGHT	0xFFFF0010
.eqv IN_ADDRESS_HEXA_KEYBOARD       0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD      0xFFFF0014
.eqv CODE_0							0x11
.eqv CODE_1							0x21
.eqv CODE_2							0x41
.eqv CODE_3							0x81
.eqv CODE_4							0x12
.eqv CODE_5							0x22
.eqv CODE_6							0x42
.eqv CODE_7							0x82
.eqv CODE_8							0x14
.eqv CODE_9							0x24
.eqv CODE_ADD						0x44
.eqv CODE_SUB						0x84
.eqv CODE_MUL						0x18
.eqv CODE_DIV						0x28
.eqv CODE_MOD						0x48
.eqv CODE_EQL						0x88

.data
NUMS_OF_7SEG:	.word		0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
str:    .asciiz "Ban nhap dau '=' khi chua nhap toan hang, hay thu lai \n "

.text
main:
    li      t1,             IN_ADDRESS_HEXA_KEYBOARD
    li      t2,             OUT_ADDRESS_HEXA_KEYBOARD
start:
    li      s0,             0                                                                               
    li      s1,             0                                                                               
    li      s2,             0                                                                               
    li      s3,             0                                                                               
    li      s4,             0                                                                               
    li      s5,             0                                                                               
    li      s6,             0                                                                               

polling:
check_row_1:
    li      t3,             0x01                                                                            
    sb      t3,             0(t1)                                                                           
    lbu     a0,             0(t2)                                                                           
    beq     a0,             zero,                       check_row_2         
    bne     a0,             s0,                         code_processing     
    beq     a0,             s0,                         back_to_polling     
check_row_2:
    li      t3,             0x02                                                                            
    sb      t3,             0(t1)                                                                           
    lbu     a0,             0(t2)                                                                           
    beq     a0,             zero,                       check_row_3
    bne     a0,             s0,                         code_processing
    beq     a0,             s0,                         back_to_polling
check_row_3:
    li      t3,             0x04                                                                            
    sb      t3,             0(t1)                                                                           
    lbu     a0,             0(t2)                                                                           
    beq     a0,             zero,                       check_row_4
    bne     a0,             s0,                         code_processing
    beq     a0,             s0,                         back_to_polling
check_row_4:
    li      t3,             0x08                                                                            
    sb      t3,             0(t1)                                                                           
    lbu     a0,             0(t2)                                                                           
    beq     a0,             zero,                       code_processing
    bne     a0,             s0,                         code_processing
    beq     a0,             s0,                         back_to_polling

code_processing:
    mv      s0,             a0
    beq     s0,             zero,                       back_to_polling
    li      t0,             CODE_0
    beq     s0,             t0,                         process_code_0
    li      t0,             CODE_1
    beq     s0,             t0,                         process_code_1
    li      t0,             CODE_2
    beq     s0,             t0,                         process_code_2
    li      t0,             CODE_3
    beq     s0,             t0,                         process_code_3
    li      t0,             CODE_4
    beq     s0,             t0,                         process_code_4
    li      t0,             CODE_5
    beq     s0,             t0,                         process_code_5
    li      t0,             CODE_6
    beq     s0,             t0,                         process_code_6
    li      t0,             CODE_7
    beq     s0,             t0,                         process_code_7
    li      t0,             CODE_8
    beq     s0,             t0,                         process_code_8
    li      t0,             CODE_9
    beq     s0,             t0,                         process_code_9
    li      t0,             CODE_ADD
    beq     s0,             t0,                         process_code_add
    li      t0,             CODE_SUB
    beq     s0,             t0,                         process_code_sub
    li      t0,             CODE_MUL
    beq     s0,             t0,                         process_code_mul
    li      t0,             CODE_DIV
    beq     s0,             t0,                         process_code_div
    li      t0,             CODE_MOD
    beq     s0,             t0,                         process_code_mod
    li      t0,             CODE_EQL
    beq     s0,             t0,                         process_code_eql

process_code_0:
    li      s1,             0
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_1:
    li      s1,             1
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_2:
    li      s1,             2
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_3:
    li      s1,             3
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_4:
    li      s1,             4
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_5:
    li      s1,             5
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_6:
    li      s1,             6
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_7:
    li      s1,             7
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_8:
    li      s1,             8
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_9:
    li      s1,             9
    li      s2,             1
    li      s6,             1  
    j       after_processing_code
process_code_add:
    li      s1,             10
    li      s2,             2
    j       after_processing_code
process_code_sub:
    li      s1,             11
    li      s2,             2
    j       after_processing_code
process_code_mul:
    li      s1,             12
    li      s2,             2
    j       after_processing_code
process_code_div:
    li      s1,             13
    li      s2,             2
    j       after_processing_code
process_code_mod:
    li      s1,             14
    li      s2,             2
    j       after_processing_code
process_code_eql:
    li      s1,             15
    li      s2,             3
    j       after_processing_code

after_processing_code:
    li      t0,             1
    beq     s2,             t0,                         case1
    li      t0,             2
    beq     s2,             t0,                         case2
    li      t0,             3
    beq     s2,             t0,                         case3

case1:
    li      t0,             15
    beq     s4,             t0,                         case1_1
    j       case1_2
case1_1:
    li      s3,             0                                                                               
    li      s4,             0                                                                               
    li      s5,             0                                                                               
case1_2:
    li      t0,             10
    mul     s3,             s3,                         t0                                                  
    add     s3,             s3,                         s1                                                  
    mv      a0,             s1                                                                              
    li      a7,             1
    ecall 
    mv      a0,             s3                                                                              
    jal     ra,             render                                                                          
    j       sleep

case2:
    beq     s6,             zero,                       sleep
    beq     s4,             zero,                       case2_save_first_operand
    li      t0,             15
    beq     s4,             t0,                         case2_save_first_operand
    li      t0,             10
    beq     s4,             t0,                         case2_chain_add
    li      t0,             11
    beq     s4,             t0,                         case2_chain_sub
    li      t0,             12
    beq     s4,             t0,                         case2_chain_mul
    li      t0,             13
    beq     s4,             t0,                         case2_chain_div
    li      t0,             14
    beq     s4,             t0,                         case2_chain_mod
    j       case2_update_op

case2_chain_add:
    add     s5,             s5,                         s3
    j       case2_update_op
case2_chain_sub:
    sub     s5,             s5,                         s3
    j       case2_update_op
case2_chain_mul:
    mul     s5,             s5,                         s3
    j       case2_update_op
case2_chain_div:
    div     s5,             s5,                         s3
    j       case2_update_op
case2_chain_mod:
    rem     s5,             s5,                         s3
    j       case2_update_op

case2_save_first_operand:
    mv      s5,             s3

case2_update_op:
    mv      s4,             s1
    mv      a0,             s5
    jal     ra,             render

    li      t0,             10
    beq     s1,             t0,                         case2_p_add
    li      t0,             11
    beq     s1,             t0,                         case2_p_sub
    li      t0,             12
    beq     s1,             t0,                         case2_p_mul
    li      t0,             13
    beq     s1,             t0,                         case2_p_div
    li      t0,             14
    beq     s1,             t0,                         case2_p_mod

case2_done:
    li      s3,             0
    li      s6,             0
    j       sleep

case2_p_add:
    li      a0,             '+'
    li      a7,             11
    ecall
    j       case2_done
case2_p_sub:
    li      a0,             '-'
    li      a7,             11
    ecall
    j       case2_done
case2_p_mul:
    li      a0,             '*'
    li      a7,             11
    ecall
    j       case2_done
case2_p_div:
    li      a0,             '/'
    li      a7,             11
    ecall
    j       case2_done
case2_p_mod:
    li      a0,             '%'
    li      a7,             11
    ecall
    j       case2_done

case3:
    beq     s6,             zero,                       error_no_operand   
    li      t0,             10
    beq     s4,             t0,                         compu_add
    li      t0,             11
    beq     s4,             t0,                         compu_sub
    li      t0,             12
    beq     s4,             t0,                         compu_mul
    li      t0,             13
    beq     s4,             t0,                         compu_div
    li      t0,             14
    beq     s4,             t0,                         compu_mod
    li      t0,             15
    beq     s4,             t0,                         compu_eql
compu_add:
    add     s5,             s5,                         s3
    j       after_compu
compu_sub:
    sub     s5,             s5,                         s3
    j       after_compu
compu_mul:
    mul     s5,             s5,                         s3
    j       after_compu
compu_div:
    div     s5,             s5,                         s3
    j       after_compu
compu_mod:
    rem     s5,             s5,                         s3
    j       after_compu
compu_eql:
    j       after_compu
after_compu:
    li      s4,             15                                                                              
    mv      s3,             s5                                                                              
    li      a0,             '='                                                                             
    li      a7,             11
    ecall
    mv      a0,             s5                                                                              
    li      a7,             1
    ecall 
    jal     ra,             render                                                                          
    j       sleep
sleep:
    #li      a0,             100                                                                            
    #li      a7,             32
    #ecall 
back_to_polling:
    j       polling                                                                                         

render:
render_store:
    addi    sp,     sp,     -24             
    sw      ra,     20(sp)                  
    sw      s0,     16(sp)                  
    sw      a0,     12(sp)              
    sw      a1,     8(sp)              
    sw      t0,     4(sp)              
    sw      t1,     0(sp)              
render_do:
    li      t0,     10                  
    mv      t1,     a0         
    rem     a0,     t1,     t0                                         
    li      a1,     SEVENSEG_RIGHT      
    jal     ra,     show_digit                  
    div     t1,     t1,     t0                                         
    rem     a0,     t1,     t0                                         
    li      a1,     SEVENSEG_LEFT       
    jal     ra,     show_digit                  

render_load:
    lw      t1,             0(sp)                                                                           
    lw      t0,             4(sp)                                                                           
    lw      a1,             8(sp)                                                                           
    lw      a0,             12(sp)                                                                          
    lw      s0,             16(sp)                                                                          
    lw      ra,             20(sp)                                                                          
    addi    sp,             sp,       24                                                                    
    jr      ra

show_digit:
show_digit_store:
    addi    sp,     sp,     -12         
    sw      ra,     8(sp)              
    sw      t0,     4(sp)              
    sw      t1,     0(sp)              

show_digit_do:
    la      t0,     NUMS_OF_7SEG        
    slli    t1,     a0,     2           
    add     t0,     t0,     t1         
    lw      t0,     0(t0)              
    sb      t0,     0(a1)              

show_digit_load:
    lw      t1,     0(sp)              
    lw      t0,     4(sp)              
    lw      ra,     8(sp)              
    addi    sp,     sp,     12         
    jr      ra                                                         

error_no_operand:
    la      a0,             str    
    li      a7,             4
    ecall
    j       sleep

.text 
 li t0,20  	
 li t1,8   	
 li t2,1  	
 li s0,0 
loop:  	 	# V?ng l?p ð?m s? m? 
beq t2,t1,exit 	# t2=t1 nh?y ð?n exit 
add t2,t2,t2  	# t2=t2*2 
addi s0,s0,1  	# s0 là s? m? c?a 2, m?i l?n l?p tãng 1 
j loop exit: 
sll s1,t0,s0 

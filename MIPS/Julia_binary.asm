		.data
output: 		.asciiz "output.bmp"
input: 			.asciiz "in1.bmp"
header:			.space 54
descriptor:		.word 1
width:			.word 1
height:			.word 1
size:			.word 1
begin_file:		.word 1
begin_table:		.word 1
padding:		.word 1
colour:			.word 1
scale: 			.word 30 50 70
error_msg1:		.asciiz "Cannot open 'in1.bmp' file. Closing program."
error_msg2:		.asciiz	"Cannot load header of the file. Closing program."
string_get_iterations:	.asciiz "\nIterations: "
string_info:		.asciiz "Enter real and imaginary part of constant:"
string_get_real:	.asciiz "\nReal part:		"
string_get_imaginary:	.asciiz "Imaginary part:		"

	.text
	.globl main

main:
opening_the_header:

	li $v0, 13		#13 -opening the file
	la $a0, input
	syscall
	bltz $v0, error1	#if we cannot open the file end program
	sw $v0, descriptor
	
loading_the_header:

	li $v0, 14		#14 - reading from file
	lw $a0, descriptor
	la $a1, header		#where we want to store the header
	li $a2, 54		#how many bytes we want to load
	syscall
	blez $v0, error2
	
saving_the_sizes:

	ulw $t0, 2($a1)		#size of the picture
	sw $t0, size 
	
	ulw $t0, 18($a1)
	sw $t0, width		# width of the picture

	ulw $t0, 22($a1)
	sw $t0, height		# height of the picture

closing_the_header:

	li $v0, 16
	lw $a0, descriptor
	syscall
	
memory_allocation:

	lw $a0, size
	li $v0, 9
	syscall
	sw $v0, begin_file	#this is our pointer to allocated memory
	
opening_file_to_read:

	li $v0, 13		
	la $a0, input   	
	la $a1, 0   		
	la $a2, 0   		
	syscall
	bltz $v0, error1
	sw $v0, descriptor
	
loading_all_data:

	li $v0, 14
	lw $a0, descriptor
	lw $a1, begin_file	#we want to load all of the data	
	lw $a2, size
	syscall
	blez $v0, error2
	
closing_file_after_reading:

	li $v0, 16
	lw $a0, descriptor
	syscall

calculating_the_padding:
	
	lw $a0, width
	andi $a0, $a0, 3
	sw $a0, padding

calculating_beginning_of_the_table:

	lw $a0, begin_file
	addiu $a0, $a0, 54
	sw $a0, begin_table

getting_data:
	
	li $v0, 4 		#getting number of iterations
	la $a0, string_get_iterations
	syscall
	
	li $v0, 5		#storing data in s0 register ---> number of iterations
	syscall
	move $s0, $v0
	
	li $v0, 4 		# getting real part of our constant
	la $a0, string_info
	syscall
	
	li $v0, 4 		# getting real part of our constant
	la $a0, string_get_real
	syscall
	
	li $v0, 5		#storing data in s1 saved register ---> real part of complex number
	syscall
	move $s1, $v0
	
	li $v0, 4		#getting imaginary part of our constant
	la $a0, string_get_imaginary
	syscall
	
	li $v0,  5		#storing data in s2 saved register ---> imaginary part of complex number
	syscall 
	move $s2, $v0 
	
begin:
	lw $s4, width		#width
	lw $s5, height		#height
	
	lw $s3, begin_table

## 8 cyfr dla całkowitych, 24 dla ułamka! 

calculating_re_per_pixel:
	
	li $t1,33554432		#dwójka w naszym kodzie
	div $t1,$t1,$s4
	mflo $s6

calculating_im_per_pixel:
	
	li $t1,33554432
	div $t1,$t1,$s5
	mflo $s7

##################################################
	#$s0 - NUMBER OF ITERATIONS
	#$s1 - RE PART OF CONSTANT
	#$s2 - IM PART OF CONSTANT
	#$s3 - POINTER FOR ALLOCATED MEMORY
	#$s4 - WIDTH OF PICTURES IN PIXELS
	#$s5 - HEIGHT OF PICTURES IN PIXELS
	#$s6 - RE PER PIXEL
	#$s7 - IM PER PIXEL
##################################################

init_loop:

	li $t1, 0		#iterator for columns
	li $t2, 0		#iterator for rows

iterate_pixel:

	#$t6 ~ Re of actual complex
	#$t7 ~Im of actual complex

	li $t0, 0		#number of current iteration

	#CALCULATUING THE VALUE OF RE(Z)
	mul $t6,$s6,$t1		#Re per pixel * actual pixel ---> Re value for this pixel
	mul $t7,$s7,$t2		#Im per pixel * actual pixel ---> Im value for this pixel
	
	srl $t3,$s4,1
	srl $t4,$s5,1
	
	mul $t3,$t3,$s6
	mul $t4,$t4,$s7	
	
	sub $t6,$t6,$t3
	sub $t7,$t7,$t4
	
	
julia_loop:			#zn=zn^2 +c
	
	#Re^2
	
	 mult $t6, $t6
	 mfhi $t4
	 mflo $t5
	 sll $t4,$t4, 8
	 srl $t5, $t5, 24
	 or $t4, $t4, $t5

	#Im^2
	
	mult $t7, $t7
	mfhi $t5
	mflo $t8
	sll $t5, $t5, 8
	srl $t8, $t8, 24
	or $t5, $t5, $t8
	
	#Re^2 - Im^2
	
	subu $t4,$t4,$t5
	
	#xy
	
	mult $t6, $t7,
	mfhi $t9
	sll $t9, $t9, 8
	
	mflo  $t8
	srl $t8, $t8, 24
	or $t9, $t9, $t8
	
	sll $t9,$t9,1 		#2xy
	
	move $t6, $t4 		# new Re(z)
	move $t7, $t9		# new Im(z)
	
	#Adding constant given by user
	
	addu $t6, $t6, $s1
	addu $t7, $t7, $s2
	
	#Calculating mod
	#check if zn is out of range ------> |zn|<2
	
	#Re^2
	
	 mult $t6, $t6
	 mfhi $t4
	 mflo $t5
	 sll $t4,$t4, 8
	 srl $t5, $t5, 24
	 or $t4, $t4, $t5
	 
	 #Im^2
	 
	mult $t7, $t7
	mfhi $t5
	mflo $t8
	sll $t5, $t5, 8
	srl $t8, $t8, 24
	or $t5, $t5, $t8

	addu $t4, $t4, $t5	#xn^2+yn^2
	
	#|zn|<2 == sqrt(xn^2+yn^2)<2
	#xn^2+yn^2<4
	bge $t4, 67108864 ,colouring  #|zn|<2
	
	addi $t0, $t0, 1	#next iteration
	
	bge $t0, $s0, colouring	#if current number of iterations < user number of iterations
	b julia_loop 
colouring:
	
	lw $t9, colour
	
	##RED
	mult $t0, $t9
	mflo $t8
	
	li $a0, 256
	div $t8, $a0
	mfhi $t8
	
	sb $t8, ($s3)
	
	##GREEN
	mult $t0, $t9
	mflo $t8
	addiu $t8, $t8,1
	
	div $t8, $a0
	mfhi $t8
	
	sb $t8, 1($s3)
	
	##BLUE
	mult $t0, $t9
	mflo $t8
	addiu $t8, $t8,2
	
	div $t8, $a0
	mfhi $t8
	
	sb $t8, 2($s3)
	
	addiu $t9, $t9, 1
	sw $t9, colour
	#WRITING TO MEMORY
	addiu $s3, $s3, 3
	#NEXT PIXEL
	addiu $t1, $t1, 1
	blt $t1, $s4, iterate_pixel
add_padding:

	lw $a0, padding
	addu $s3, $s3,$a0
	li $t1, 0
	
increment_height:

	addi $t2, $t2, 1
	blt $t2, $s5, iterate_pixel

opening_file_to_save_data:

	li $v0, 13				
	la $a0, output   			
	li $a1, 1
	li $a2, 0
	syscall
	sw $v0, descriptor

saving_the_data:

	li $v0, 15
	lw $a0, descriptor
	lw $a1, begin_file		#storing all of the allocated memory
	lw $a2, size
	syscall


closing_the_file:

	li $v0, 16
	lw $a0, descriptor
	syscall
	b exit

error1:
	li $v0, 4
	la $a0, error_msg1
	syscall 
	b exit

error2:
	li $v0, 4
	la $a0, error_msg2
	syscall
	b exit

exit:
	li $v0, 10
	syscall

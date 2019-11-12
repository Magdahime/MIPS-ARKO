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
scale: 			.word 40 30 10
error_msg1:		.asciiz "Cannot open 'in.bmp' file. Closing program."
error_msg2:		.asciiz	"Cannot load header of the file. Closing program."
string_get_iterations:	.asciiz "\nIterations: "
string_info:		.asciiz "Enter in format:	0.0000"
string_get_real:	.asciiz "\nReal part:		0."
string_get_imaginary:	.asciiz "Imaginary part:		0."

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
	
	li $t1, 0		#pixel x
	li $t2, 0		#pixel y
	li $s6, 10000		#limit

iterate_pixel:

	li $t0, 0		#number of current iteration
	
	mult $t1, $s6
	mflo $t6
	div $t6, $s4
	mflo $t6		#Real value of pixel
	
	mult $t2, $s6
	mflo $t7
	div $t7, $s5
	mflo $t7		#Imaginary value of pixel
	
julia_loop:			#zn=zn^2 +c
	
	mult $t6, $t7		#xy
	mflo $t9
	div $t9, $t9, 10000
	mflo $t9
	
	sll $t9, $t9, 1		#2xy -----> new imaginary part
	
	#zn^2
	mult $t6, $t6 		#xn^2
	mflo $t6
	div $t6, $t6, 10000
	
	mult $t7, $t7		#(iyn)^2 == -yn^2
	mflo $t7
	div $t7, $t7,10000
	
	subu $t6, $t6, $t7	# xn^2 -yn^2 ----> the real part of new number
	move $t7, $t9		#moving new imaginary part
	
	#zn + c
	
	addu $t6, $t6, $s1	#adding xn+xc
	addu $t7, $t7, $s2	#adding yn +yc
	
	#check if zn is out of range ------> |zn|<2
	
	mult $t6, $t6		#xn^2
	mflo $t8
	div $t8, $t8, 10
	mult $t7, $t7		#yn^2
	mflo $t9
	
	div $t9, $t9, 10
	add $t8, $t8, $t9	#xn^2+yn^2
	#|zn|<2 == sqrt(xn^2+yn^2)<2
	#xn^2+yn^2<4
	bge $t8, 40000000,colouring  #|zn|<2
	
	addi $t0, $t0, 1	#next iteration
	
	bge $t0, $s0, colouring	#if current number of iterations < user number of iterations
	b julia_loop 

colouring:

	##RED
	la $t9, scale
	lw $t9, ($t9)
	mult $t0, $t9
	mflo $t8
	
	li $a0, 256
	div $t8, $a0
	mfhi $t8
	
	sb $t8, ($s3)
	
	##GREEN
	la $t9, scale
	lw $t9, 4($t9)
	mult $t0, $t9
	mflo $t8
	
	div $t8, $a0
	mfhi $t8
	
	sb $t8, 1($s3)
	
	##BLUE
	la $t9, scale 
	lw $t9, 8($t9)
	mult $t0, $t9
	mflo $t8
	
	div $t8, $a0
	mfhi $t8
	
	sb $t8, 2($s3)
	
	#WRITING TO MEMORY
	addiu $s3, $s3, 3
	#NEXT PIXEL
	addiu $t1, $t1, 1
	blt $t1, $s4, iterate_pixel
	li $t1, 0
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

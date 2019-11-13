	.data
prompt:	.asciiz "Enter a string with digits: \n"
result:	.asciiz "This is your string but with reversed order of digits: \n"
buf:	.space 1000
numbuf:	.space 1000
	.text
	.globl main
main:
	li $v0, 4 
	la $a0, prompt
	syscall
	
	li $v0, 8
	la $a0, buf
	li $a1, 1000
	syscall
	
	la $t0, buf		#adress to the first byte of the string
	la $t1, ($t0)		#static adress to the beginnig of the string
	lb $t2, ($t0)		#first byte
	la $t3, numbuf		#adress to our numbuf when we will save each number in the string 
	beqz $t2, end
	
loop1: 
	blt $t2, '0', next
	bgt $t2, '9', next
	sb $t2, ($t3)
	addi $t3, $t3, 1
	addi $t0, $t0, 1
	lb $t2, ($t0)
	bnez $t2, loop1
	beqz $t2, reverse

next:
	addi $t0, $t0, 1
	lb $t2, ($t0)
	bnez $t2,loop1

reverse:
	la $t0, ($t1)
	lb $t2, ($t0)
	subu $t3, $t3, 1

loop2:
	blt $t2, '0', next2
	bgt $t2, '9', next2
	lb $t1, ($t3)
	sb  $t1, ($t0)
	addi $t0, $t0, 1
	subu $t3, $t3, 1
	lb $t2, ($t0)
	bnez $t2, loop2
	beqz $t2, end
next2:
	addi $t0, $t0, 1
	lb $t2, ($t0)
	bnez $t2,loop2


end: 	
	li $v0, 4 
	la $a0, result
	syscall
	 
	li $v0, 4 
	la $a0, buf
	syscall
	
	li $v0, 10
	syscall
	
	
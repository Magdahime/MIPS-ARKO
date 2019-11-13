	.data
prompt:	.asciiz "Enter a digit:\n"
result:	.asciiz "The supplement of integer to 9 is: \n"
	.text
	.globl main
	
main:
	li $v0, 4 			#printing
	la $a0, prompt
	syscall
	
	li $v0,	5			#getting integer
	syscall
	
	li $t0, 9			#getting supplement to 9
	subu $t0, $t0, $v0
	
end:	li $v0, 4 			#printing
	la $a0, result
	syscall
	
	li $v0,	1
	la $a0 ,($t0)
	syscall
	
	li $v0,10
	syscall
	
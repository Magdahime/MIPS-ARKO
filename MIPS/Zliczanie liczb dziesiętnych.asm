	.data
prompt:	.asciiz "Enter the string with numbers: "
result: .asciiz "Numbers: "
buf:	.space 1000
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
	
	la $t0, buf
	la $t1, ($t0)
	lb $t2, ($t0)
	li $t3, 0		#how many numbers are there?
	beqz $t2, end

loop:
	blt $t2, '0', next
	bgt $t2, '9', next
	addi $t3, $t3, 1

in_num:	
	addi $t0, $t0, 1
	lb $t2, ($t0)
	beqz $t2, end
	blt $t2, '0', loop 	# after one digit we get the letter
	bgt $t2, '9', loop 
	b in_num 		# we are still inside a number 	
	
next:
	addi $t0, $t0, 1
	lb $t2, ($t0)
	bnez $t2, loop
	
end:
	li $v0, 4
	la $a0, result
	syscall
	
	li $v0, 1
	la $a0, ($t3)
	syscall
	
	li $v0, 10
	syscall
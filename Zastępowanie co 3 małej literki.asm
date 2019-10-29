	.data
prompt: .asciiz "Enter the string: "
result: .asciiz "The third letter is now big! : "
buf:	.space 1001
	.text
	.globl main
main:
	li $v0, 4
	la $a0, prompt 
	syscall
	
	li $v0, 8
	la $a0, buf
	la $a1, 1000
	syscall
	
	la $t0, buf		# iterator
	la $t1, ($t0)		# static adress of our string
	lb $t2, ($t0)		# first byte of string
	li $t3, 0x20 		# the difference in ASCII table between big and small letter
	li $t4, 0		# counter to 3
	beqz $t2, end
loop:
	blt $t2, 'a', next
	bgt $t2, 'z', next 	# now we know it's a small letter 
	beq $t4, 2, change	# if it's the third small letter we must change it to big
	addi $t4, $t4, 1
	b next
change:
	li $t4, 0
	subu $t2, $t2, $t3 
	sb $t2, ($t0)
next:
	addi $t0, $t0, 1
	lb $t2, ($t0)
	bnez $t2, loop	
end:
	li $v0, 4 
	la $a0, result
	syscall
	
	li $v0, 4
	la $a0, buf
	syscall
	
	li $v0, 10
	syscall
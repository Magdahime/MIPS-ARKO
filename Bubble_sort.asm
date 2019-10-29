	.data
msg1:	.asciiz "Enter the string to sort: "
buf:	.space 1000
	.text
	.globl main
main:
	li $v0, 4
	la $a0, msg1
	syscall 
	
	li $v0, 8
	la $a0, buf
	li $a1, 1000
	syscall 
	
loop_i:
	li $t1, 0
	li $t2, 1 #iterators
	li $t3, 0 #swapped
	lb $t4, buf($t1)
	lb $t5, buf($t2)
loop_j:
	ble  $t4, $t5 next
	lb $t6, buf($t1) #swap
	sb $t5, buf($t1)
	sb $t6, buf($t2)
	li $t3, 1 #we swapped the elements
next:
	addi $t1, $t1, 1
	addi $t2, $t2, 1
	lb $t4, buf($t1)
	lb $t5, buf($t2)
	bnez $t5, loop_j #we are at the end of our string
	bnez $t3, loop_i #we swapped elements == it means its not really sorted
end:
	li $v0, 4
	la $a0, buf
	syscall
	li $v0, 10
	syscall

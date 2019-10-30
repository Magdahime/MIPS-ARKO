	.data
prompt:	.asciiz "Enter the string: "
result: .asciiz "This is your string without digits: "
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
	beqz $t2, end
	
loop:
	blt $t2, 'A', delete				
	bgt $t2, 'z', delete
	addi $t0, $t0, 1
	la $t1, ($t0)
	lb $t2, ($t0)
	beqz $t2, end
	bnez $t2, loop
	
after_deleting:
	blt $t2, 'A', delete
	bgt $t2, 'z', delete #tutaj przechodzimy do kolejnej literki
	sb $t2, ($t1)
	sb $zero, ($t0)
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	lb $t2, ($t0)
	bnez $t2, after_deleting
	beqz $t2, end

delete:
	sb $zero, ($t0)
	addi $t0, $t0, 1
	lb $t2, ($t0)
	bnez $t2, after_deleting
	
end:
	li $v0, 4
	la $a0, result
	syscall
	
	li $v0, 4
	la $a0, buf
	syscall
	
	li $v0, 10
	syscall

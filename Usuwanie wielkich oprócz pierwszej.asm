	.data
buf:	.space 1000
prompt:	.asciiz "Enter a string with big letters: "
result:	.asciiz "This is your string without big letters except the first one : \n"
	.text
	.globl main
main:
	li $v0,4 
	la $a0, prompt
	syscall
	
	li $v0, 8
	la $a0, buf
	li $a1, 998
	syscall
	
	la $t0, buf
	lb $t2, ($t0)

check_first_big:
	blt $t2, 'A', next
	bgt $t2, 'Z', next #teraz już na pewno wiemy, że to duża literka
	addiu $t0, $t0,1
	lb $t2, ($t0)
	beqz $t2, end
check_second_big:

	blt $t2, 'A', next
	bgt $t2, 'Z', next #teraz już na pewno wiemy, że to druga duża literka
	la $t1, ($t0)
	sb $zero, ($t0)
	addiu $t0, $t0, 1
	lb $t2, ($t0)
	beqz $t2, end
	
after_deleting_inside:
	blt $t2, 'A', shift 
	bgt $t2, 'Z', shift
	sb $zero, ($t0)
	addiu $t0, $t0, 1
	lb $t2, ($t0)
	beqz $t2, end
	bnez $t2, after_deleting_inside

after_deleting_outside:
	blt $t2, 'A', shift 
	bgt $t2, 'Z', shift #wiemy tutaj że to pierwsza duża literka w kolejnym ciągu
	sb $t2, ($t1)
	sb $zero, ($t0)
	addiu $t1, $t1, 1
	addiu $t0, $t0, 1
	lb $t2, ($t0)
	b after_deleting_inside
shift:
	sb $t2, ($t1)
	sb $zero, ($t0)
	addiu $t1, $t1, 1
	addiu $t0, $t0, 1
	lb $t2, ($t0)
	bnez $t2, after_deleting_outside
	beqz $t2, end
next: 	
	addiu $t0, $t0,1
	lb $t2, ($t0)
	bnez $t2, check_first_big
end:
	li $v0, 4
	la $a0, result
	syscall
	
	li $v0, 4
	la $a0, buf
	syscall
	
	li $v0, 10
	syscall
	
	

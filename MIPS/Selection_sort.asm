	.data
prompt:	.asciiz "Enter the string to sort: "
result: .asciiz "Sorted string: "
buf:	.space 1000
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

	la $t0, buf 		# iterator
	la $t1,-1($t0)		# statyczny adres do początku granicy
outer_loop:
	addiu $t1, $t1, 1 
	la $t3, ($t1)		# adres najmniejszego elementu 
	lb $t4, ($t3)		# wartość najmniejszego elementu
	beqz $t4, end		# jeżeli dojechaliśmy z granicą do końca to znaczy wszystko posortowane
	la $t0, ($t1)
inner_loop:
	addiu $t0, $t0, 1
	lb $t2, ($t0)
	beqz  $t2, swap
	bgt $t2, $t4,inner_loop	#jeżeli to na co wskazuje uterator jest większe od najmniejszego idź dalej
	la $t3, ($t0)		#tutaj już wiemy że mamy coś mniejszego, więc ściągamy nowy adres 
	lb $t4, ($t3)		#a tutaj nową wartość
	b inner_loop
swap: 
	lb $t6, ($t1)		#zachowujemy starą wartość
	lb $t7, ($t3)
	sb $t7, ($t1)
	sb $t6, ($t3)
	b outer_loop
end:
	
	li $v0, 4
	la $a0, result
	syscall
	
	li $v0, 4
	la $a0, buf
	syscall
	
	li $v0, 10
	syscall
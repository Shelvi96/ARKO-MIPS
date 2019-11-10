	.data
buf:	.space	100
	.text
	.globl	main
main:
	la	$a0, buf
	li	$a1, 100
	li	$v0, 8
	syscall
	la	$t0, buf # pt1
	la	$t1, buf # pt2
	
findEnd:	#Ustawia t1 na koniec napisu
	addiu	$t1, $t1, 1
	lbu	$t2, ($t1)
	bgtu	$t2, ' ', findEnd
	
foundEnd:	#Znaleziono koniec napisu, t1 ustawione na koniec
	subiu	$t1, $t1, 1
	
swap:
	lbu	$t2, ($t0)
	lbu	$t3, ($t1)
	sb	$t2, ($t1)
	sb	$t3, ($t0)
	addiu	$t0, $t0, 1
	subiu	$t1, $t1, 1
	bgeu	$t1, $t0, swap	# Po zamianie szukamy kolejnej pary
	
fin:				
	la	$a0, buf
	li	$v0, 4
	syscall
	li	$v0, 10
	syscall

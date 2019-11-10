	.data  
fin:	.asciiz "file.txt"      # nazwa pliku wejsciowego
buf:	.space 128		# bufor przechowujacy plik wejsciowy
last:	.space 128		# bufor przechowujacy ostatnia liczbe z pliku wejsciowego
endl:	.asciiz "\n"

	.text
# Otwieranie pliku
	li	$v0, 13       	
	la	$a0, fin     	
	li	$a1, 0        	# read-only 
	li	$a2, 0        	
	syscall            	
	move	$s0, $v0      	# file descriptor - potrzebny potem do pracy z plikiem

# Odczytywanie z pliku
	li	$v0, 14       	
	move	$a0, $s0      	# file descriptor
	la	$a1, buf   	
	li	$a2, 127	
	syscall			

	# wypisanie zawartosci pliku
	li	$v0, 4		
	la	$a0, buf	
	syscall			
	la	$a0, endl	
	syscall
	#
	
# Szukamy ostatniej liczby w pliku i zapisujemy ja do bufora 'last'
	la	$t0, buf	# wskaznik na zawartosc pliku
	move	$t1, $t0	# wskaznik na poczatek zawartosci pliku

findLast:			# przechodzimy wskaznikiem na koniec,
	addiu	$t0, $t0, 1	# bedziemy potem szukac pierwszej liczby od konca
	lbu	$t2, ($t0)
	bne	$t2, $zero, findLast
	
	# wypelniamy bufor zerem - wartosc wyjsciowa, gdyby nie bylo liczby na wejsciu
	la	$t5, last
	li	$t2, '0'
	sb	$t2, ($t5)
	addiu	$t5, $t5, 1
	sb	$zero, ($t5)
	#

findLastNum:			# cofamy sie po buforze poki nie napotkamy cyfry
	beq	$t0, $t1, done
	subiu	$t0, $t0, 1
	
	lbu	$t2, ($t0)
	bltu	$t2, '0', findLastNum
	bgtu	$t2, '9', findLastNum
	
	la	$t5, last	# tu bedziemy przechowywac ostatnia liczbe
	subiu	$t1, $t1, 1
	
loadLastNum:			# ladujemy do buforu "last" wszystkie poprzedzajace cyfry
	sb	$t2, ($t5)
	addiu	$t5, $t5, 1
	subiu	$t0, $t0, 1
	lbu	$t2, ($t0)
	bltu	$t2, '0', numLoaded
	bgtu	$t2, '9', numLoaded
	bne	$t0, $t1, loadLastNum
	
numLoaded:			# zaladowano wszystkie cyfry, konczymy ciag znakow zerem
	sb	$zero, ($t5)
	
done:
	la	$t6, last	# kontrolne wypisanie znalezionej liczby,
	move	$a0, $t6	# kolejnosc cyfr jest odwrocona
	li	$v0, 4
	syscall
	
	la	$a0, endl
	syscall
	
# w buforze 'last' mamy zapisana w odwrotnej kolejnosci ostatnia liczbe,
# teraz dodamy do niej "pisemnie" 1
					# w $t6 wskaznik na nasza liczbe
	move	$t4, $zero		# nadmiar
	lbu	$t0, ($t6)		# ladujemy ostatnia cyfre
	addiu	$t0, $t0, 1		# zwiekszamy ja o jeden
	# sprawdzamy czy nie powstal nadmiar
nextDigit:
	beq	$t0, $zero, increased	# doszlismy do konca liczby, przerywamy
	beq	$t4, $zero, noOverflow	# sprawdzamy czy jest nadmiar z poprzedniej operacji
	addiu	$t0, $t0, 1		# jesli jest nadmiar, to uwzgledniamy go i zerujemy
	move	$t4, $zero
noOverflow:
	bleu	$t0, '9', noOverflow2	# sprawdzamy czy nie powstal nowy nadmiar
	subiu	$t0, $t0, 10		# jesli tak, to robimy z nim porzadek
	addiu	$t4, $t4, 1
noOverflow2:
	sb	$t0, ($t6)		# zapisujemy zmodyfikowana cyfre
	addiu	$t6, $t6, 1
	lbu	$t0, ($t6)
	b	nextDigit		# wczytujemy nastepna cyfre i powtarzamy proces
increased:
	beq	$t4, $zero, noOverflow3	# sprawdzamy czy po calej operacji zostal nadmiar
	li	$t0, '1'
	sb	$t0, ($t6)		# jesli tak, to na poczatek dorzucamy jeszcze jedynke
	addiu	$t6, $t6, 1
	sb	$zero, ($t6)
noOverflow3:
	la	$t6, last		# proces zakonoczony, wypisujemy gotowa, odwrocona liczbe
	move	$a0, $t6
	li	$v0, 4
	syscall	

# Odwracamy liczbe
	la	$t0, last
	move	$t1, $t0
	li	$t4, 0			# zliczymy dlugosc napisu, przyda sie potem
findEnd:	
	addiu	$t1, $t1, 1
	addiu	$t4, $t4, 1
	lbu	$t2, ($t1)
	bgtu	$t2, ' ', findEnd
	
	subiu	$t1, $t1, 1
	
swap:
	lbu	$t2, ($t0)
	lbu	$t3, ($t1)
	sb	$t2, ($t1)
	sb	$t3, ($t0)
	addiu	$t0, $t0, 1
	subiu	$t1, $t1, 1
	bgeu	$t1, $t0, swap
	
# sprawdzamy czy sie dobrze odwrocilo
	la	$t6, endl
	move	$a0, $t6
	syscall
	la	$t6, last
	move	$a0, $t6
	li	$v0, 4
	syscall	

# Zamykanie pliku
	li	$v0, 16
	move	$a0, $s0
	syscall
	
# Otwieranie pliku
	li	$v0, 13       	
	la	$a0, fin
	li	$a1, 9			# write-only with create and append
	li	$a2, 0
	syscall            	
	move	$s0, $v0      		# file descriptor - potrzebny potem do pracy z plikiem
	
# Zapisywanie do pliku
	# najpierw przechodzimy do nowej linii
	li	$v0, 15
	move	$a0, $s0
	la	$t7, endl
	move	$a1, $t7
	li	$t8, 1
	move	$a2, $t8
	syscall
	# nastepnie wpisujemy tam liczbe
	li	$v0, 15
	move	$a0, $s0
	move	$a1, $t6
	move	$a2, $t4
	syscall
	
# Zamykanie pliku
	li	$v0, 16
	move	$a0, $s0
	syscall
	
# Konczenie dzialania programu
	li      $v0, 10
	syscall
	

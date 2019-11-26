	.data
fin:	.asciiz "file.txt"      # nazwa pliku wejsciowego
buf:	.space 64
lnum:	.space 64
endl:	.asciiz "\n"
	
	.text
# Otwieranie pliku
	li	$v0, 13       	
	la	$a0, fin     	
	li	$a1, 0        	# read-only 
	li	$a2, 0        	
	syscall            	
	move	$s0, $v0      	# file descriptor - potrzebny potem do pracy z plikiem
	move	$t0, $v0
	
# Przygotowania do szukania ostatniej liczby w pliku
	li	$s1, 1		# ustawiamy wartosci poczatkowe tak, by po pierwszym
	li	$s2, 0		# 	skoku do getc wczytano dane do bufora
	
	la	$t3, lnum	# wypelniam lnum zerem, gdyby sie okazalo,
	li	$t4, '0'	# 	ze w pliku nie ma liczb
	sb	$t4, ($t3)
	addiu	$t3, $t3, 1
	sb	$zero, ($t3)
	
# Poszukiwanie ostatniej liczby w pliku	
preFind:
	la	$t3, lnum		# jesli pojawi sie nowa liczba to bedzie zapisywana od poczatku bufora
	li	$t7, 0
findNum:
	jal	getc			# w t1 pojawia mi sie kolejny znak z pliku
	bgtu	$t7, 0, endOfFile	# sprawdzamy czy to juz koniec pliku
	bgtu	$t1, '9', preFind	# to nie cyfra - szukam liczby od nowa
	bltu	$t1, '0', preFind	# to nie cyfra - szukam liczby od nowa
	sb	$t1, ($t3)		# zapamietuje kolejna cyfre aktualnie ostatniego numeru
	addiu	$t3, $t3, 1
	sb	$zero, ($t3)		# koncze liczbe gdyby nie bylo juz wiecej cyfr, ale jesli
	b	findNum			#	pojawia sie jeszcze cyfry, to nadpisza to zero
	
# Doszlismy do konca pliku, w buforze lnum znajduje sie ostatnia liczba
endOfFile:
	li	$v0, 16
	move	$a0, $s0
	syscall				# Zamykanie pliku
	
	li	$v0, 4
	la	$a0, lnum
	syscall				# wypisanie liczby przed dodawaniem 1
	li	$v0, 4
	la	$a0, endl
	syscall			
	
# Teraz dodamy do naszej liczby "pisemnie" 1
	jal	swap			# najpierw ja odwracamy
	li	$t7, 0			# tu bedziemy zliczac przy okazji dlugosc liczby po dodaniu 1
# W buforze 'lnum' mamy zapisana w odwrotnej kolejnosci ostatnia liczbe,
	la	$t6, lnum		# w $t6 wskaznik na nasza liczbe
	move	$t4, $zero		# nadmiar
	lbu	$t0, ($t6)		# ladujemy ostatnia cyfre
	addiu	$t0, $t0, 1		# zwiekszamy ja o jeden
# sprawdzamy czy nie powstal nadmiar i przesuwamy go az do skutku
nextDigit:
	beq	$t0, $zero, increased	# doszlismy do konca liczby, przerywamy
	addiu	$t7, $t7, 1		
	beq	$t4, $zero, noOverflow	# sprawdzamy czy jest nadmiar z poprzedniej operacji
	addiu	$t0, $t0, 1		# jesli jest nadmiar, to uwzgledniamy go
	move	$t4, $zero		# i zaznaczamy ze juz go nie ma
noOverflow:
	bleu	$t0, '9', noOverflow2	# sprawdzamy czy nie powstal nowy nadmiar ( po dodaniu 1 z poprzedniego nadmiaru)
	subiu	$t0, $t0, 10		# jesli tak, to 
	addiu	$t4, $t4, 1		#	robimy z nim porzadek
noOverflow2:
	sb	$t0, ($t6)		# zapisujemy zmodyfikowana cyfre
	addiu	$t6, $t6, 1
	lbu	$t0, ($t6)
	b	nextDigit		# wczytujemy nastepna cyfre i powtarzamy proces
increased:
	beq	$t4, $zero, noOverflow3	# sprawdzamy czy po calej operacji zostal nadmiar
	addiu	$t7, $t7, 1
	li	$t0, '1'
	sb	$t0, ($t6)		# jesli tak, to na poczatek dorzucamy jeszcze jedynke
	addiu	$t6, $t6, 1
	sb	$zero, ($t6)
noOverflow3:
	jal 	swap			# odwracamy ponownie liczbe
	li 	$v0, 4
	la 	$a0, lnum
	syscall				# wypisujemy liczbe po zakonczonym procesie pisemnego dodawania 1
# Liczba zostala zwiekszona o 1
	
# Dlugosc liczby znajduje sie w t7

# Pozostalo zapisac liczbe do pliku
# Otwieranie pliku
	li	$v0, 13       	
	la	$a0, fin
	li	$a1, 9		# write-only with create and append
	li	$a2, 0
	syscall            	
	move	$s0, $v0      	# file descriptor - potrzebny potem do pracy z plikiem
	
# Zapisywanie do pliku
	# najpierw przechodzimy do nowej linii
	li	$v0, 15
	move	$a0, $s0
	la	$a1, endl
	li	$a2, 1
	syscall
	# nastepnie wpisujemy tam liczbe
	li	$v0, 15
	move	$a0, $s0
	la	$a1, lnum
	move	$a2, $t7
	syscall
	
# Zamykanie pliku
	li	$v0, 16
	move	$a0, $s0
	syscall
	
# Konczenie dzialania programu
	li      $v0, 10
	syscall	

###########################################

# funkcja do wczytywania pojedynczego znaku
getc:
	bltz	$v0, end
	bgtu	$s1, $s2, readNext	# doszlismy do konca bufora - trzeba wczytac kolejny fragment
	lbu	$t1, buf($s1)		# t1 - ostatnio odczytana literka
	addiu	$s1, $s1, 1		# przesuwam sie do nastepnej literki
end:
	jr	$ra			# skok ze sladem - wracamy
readNext:
	la	$t2, buf
	li	$v0, 14		# czytaj z pliku
	move	$a0, $t0	# skad wczytac
	la	$a1, ($t2)	# dokad wczytac
	li	$a2, 4		# wielkosc bufora
	syscall
	bnez	$v0, keepReading
	addiu	$t7, $t7, 1	# zaznaczamy flage konca pliku
keepReading:
	lbu	$t1, ($t2)
	la	$s2, ($v0)	# zapamietujemy dlugosc aktualnego bufora,
	subiu	$s2, $s2, 1	# 	jesli to koniec, to w s2 bedzie wartosc -1
	li	$s1, 0		# zerujemy iteratorek	
	b	getc		# wracamy do czytania - bufor znow zawiera kolejne znaki!
	
# funkcja do odwracania stringa znajdujacego sie w lnum
swap:
	la	$t0, lnum
	la	$t1, lnum
gotoend:
	addiu	$t1, $t1, 1
	lbu	$t2, ($t1)
	bnez	$t2, gotoend
	subiu	$t1, $t1, 1
swapp:
	lbu	$t2, ($t0)
	lbu	$t3, ($t1)
	sb	$t2, ($t1)
	sb	$t3, ($t0)
	addiu	$t0, $t0, 1
	subiu	$t1, $t1, 1
	bgeu	$t1, $t0, swapp
	jr	$ra

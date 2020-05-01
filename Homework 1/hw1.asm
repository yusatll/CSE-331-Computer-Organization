#ahmet yusa telli
#151044092

	.data
fout:	.asciiz "homework.txt"
buffer: .space 256
buf1:	.asciiz ""
ask:	.asciiz "enter filename (max 20 chars) : "

zero:	.asciiz "zero"
one:	.asciiz "one"
two:	.asciiz "two"
three:	.asciiz "three"
four:	.asciiz "four"
five:	.asciiz "five"
six:	.asciiz "six"
seven:	.asciiz "seven"
eight:	.asciiz "eight"
nine:	.asciiz "nine"

zeroUp:	.asciiz "Zero"
oneUp:	.asciiz "One"
twoUp:	.asciiz "Two"
threeUp:.asciiz "Three"
fourUp:	.asciiz "Four"
fiveUp:	.asciiz "Five"
sixUp:	.asciiz "Six"
sevenUp:.asciiz "Seven"
eightUp:.asciiz "Eight"
nineUp:	.asciiz "Nine"
	.text

main:

#ASK FILENAME
	li 	$v0, 4 			# 4 print string
	la 	$a0, ask		# ask file name
	syscall


#TAKE FILENAME
	li 	$v0, 8			# read string
	la	$a0, buf1		# load byte space into address	buff = ""
	li	$a1, 256		# allot the byte space for string
	syscall				# isim burdan sonra yazýlcak

# KULLANICIDAN FÝLE ÝSMÝ ALIRKEN STRÝNG SONUNA \n DE ALINIYOR.
# ONU ENGELLEMEK ÝÇÝN \n YERÝNE NULL KUYUYORUZ.
readingLoop:	
	lb	$t9, 0($a0)
	beq	$t9, 10, NULL
	add	$a0, $a0, 1
	j 	readingLoop
	
NULL:	sb	$zero, 0($a0)	


# OPEN FILE	
# $a0 = address of null-terminated string containing filename
# $a1 = flags
# $a2 = mode
	li 	$v0, 13			# 13 open
	la	$a0, buf1		# file name
	li 	$a1, 0			# write: 1 read: 0
	li 	$a2, 0			#
	syscall
	move 	$s6, $v0		#add $s6, $zero, $v0	file descriptor save
			
	
# READING FROM FILE just opened
# $a0 = file descriptor
# $a1 = address of input buffer
# $a2 = maximum number of characters to read
	li   	$v0, 14        		# system call for reading from file
	move 	$a0, $s6       		# file descriptor 
	la   	$a1, buffer    		# address of buffer from which to read	ilk satiri a1 e aldýk.
	li   	$a2, 256  	    	# hardcoded buffer length  
	syscall             		# read from file
	#move	$s7, $a1		# address change


#PRINT FILE (STRING)	
	li	$t1, 0
	la	$t0, buffer($t1) 	# ilk char sayý degil ise ekrana basýlacak.
	lb	$s2, ($t0)
	
	sle	$t0, $s2, 57		# sayi degýlse ilk char basýlcak.sayýysa büyük basýlcak go Upper
	beq	$t0, 1, Upper		# t0 1 olursa fileda ilk charda sayý vardýr. upper olmasý gerekir
	li	$v0, 11			# print char
	la	$a0, ($s2)
	syscall	
	li 	$t1, 0
start:					#ilk baþtaki sayýyý yazdýktan sonra devam edecek
loop:	li	$v0, 11			# print char
	la	$t0, buffer($t1) 	# ilk char sayý degil ise ekrana basýlacak.
	lb	$s1, ($t0)		# byte olarak file dakileri tek tek alýyoruz.
	add	$t1, $t1, 1		# file içindeki bi sonraki elemaný byte olarak alýyoruz.
	la	$t0, buffer($t1)
	lb	$s2, ($t0)
	add	$t1, $t1, 1
	la	$t0, buffer($t1)
	lb	$s3, ($t0)
	
	la	$a0, ($s2)		# print etmek için a0 a o anki elemaný alýyoruz.
	jal 	procedure		# call procedure
backUPPER:			
cont:	
	beq	$s1, $zero, exit	# file sonuna gelince cikar 
	syscall
	sub 	$t1, $t1, 1
	j loop
	
procedure:
	beq	$s1, 32, func		#ilk deðer boþluk mu. boþluksa procedure git
	jr $ra

		
go:	ble  	$s2, 57, go1		# aldýgýmýz byte 57den kucukse go1	deðilse geri dön
	j cont		

func:
	bge 	$s2, 48, go		# aldýgýmýz byte 48 den buyuk mu
	j cont				# buyukse 57 den kucuk mu kontrol etmemiz gerekir. degýlse geri donulcek

contRight:
	sle  	$t3 ,$s3, 57		# saðdaki byte sayý olup olmadýðýný kontrol ediyoruz.
	and 	$t3, $t3, $t4		
	beq 	$t3, 1, cont
	
	bne	$s3, 46, contR		#sayý deðilse boþluk mu nokta mý ona bakýcaz
	addi	$t8, $t1, 1
	la	$t5, buffer($t8)	#saðda nokta varsa noktanýn bir yanýna daha bakmamýz gerekiyor.
	lb	$s7, ($t5)		# çünkü noktalý sayý girilmiþ olabilir.
	beq	$s7, 32, contR		# onlarý deðiþtirmiyoruz.
	j cont				#noktadan sonra boþluk varsa deðiþtiriyoruz
	
		
go1:	and	$t7, $zero, $zero	# t7 ye 0 alýyoruz. ne olur ne olmaz diye.
	sge	$t4, $s3, 48		# sayýnýn sað tarafýnda boþluk varsa devam edecek. yoksa geri dönecek.
	j	contRight
	
	
contR:	addi	$s5, $t1, -3		# saðda boþluk varsa. 2 önceki yere bakmamýz lazým. nokta konrolü
	la	$t6, buffer($s5)	# 
	lb	$s4, ($t6)
	
	seq 	$t7,$s4,46		# sayýnýn iki öncesi NOKTA MI DEÐÝL MÝ? 	46 = '.' nokta ise t7 = 1, deðilise 0
	beq  	$t7, 1, Upper		# nokta deðilse büyük harfle baþlamasý lazým
	
	li	$v0, 4
	beq	$s2, 48, zerop	
	beq	$s2, 49, onep	
	beq	$s2, 50, twop
	beq	$s2, 51, threep
	beq	$s2, 52, fourp
	beq	$s2, 53, fivep
	beq	$s2, 54, sixp
	beq	$s2, 55, sevenp
	beq	$s2, 56, eightp
	beq	$s2, 57, ninep	
		
	j cont
	
zerop:	la	$a0, zero
	j sys
onep:	la	$a0, one	
	j sys
twop:	la	$a0, two
	j sys
threep:	la	$a0, three
	j sys
fourp:	la	$a0, four
	j sys
fivep:	la	$a0, five
	j sys
sixp:	la	$a0, six
	j sys
sevenp:	la	$a0, seven
	j sys
eightp:	la	$a0, eight
	j sys
ninep:	la	$a0, nine
	
sys:		
	jr $ra

	# SAYI BÜYÜK HARFLE BAÞLAMASI GEREKÝYORSAA BURAYA GÝRECEK
Upper:
	li	$v0, 4
	beq	$s2, 48, zeroPU	
	beq	$s2, 49, onePU	
	beq	$s2, 50, twoPU
	beq	$s2, 51, threePU
	beq	$s2, 52, fourPU
	beq	$s2, 53, fivePU
	beq	$s2, 54, sixPU
	beq	$s2, 55, sevenPU
	beq	$s2, 56, eightPU
	beq	$s2, 57, ninePU
		
	jr $ra
	
zeroPU:	la	$a0, zeroUp
	
	j goB
onePU:	la	$a0, oneUp	
	
	j goB
twoPU:	la	$a0, twoUp
	
	j goB
threePU:la	$a0, threeUp
	
	j goB
fourPU:	la	$a0, fourUp
	
	j goB
fivePU:	la	$a0, fiveUp
	
	j goB
sixPU:	la	$a0, sixUp
	
	j goB
sevenPU:la	$a0, sevenUp
	
	j goB
eightPU:la	$a0, eightUp
	
	j goB
ninePU:	la	$a0, nineUp
	
	j goB	

goB:
	beq 	$t7, 0, start		#t7 1 se '.' vardýr.0 sa nokta yoktur. baþlangýçtayýz
	j 	backUPPER
	jr 	$ra
	
	
	
# CLOSE FILE
exit:	
	li   	$v0, 16       		# system call for close file
	move 	$a0, $s6      		# file descriptor to close
	syscall            		# close file	
	
# END PROGRAM	
	li	$v0, 10			# system call code for exit = 10
		syscall			# call operating sys	

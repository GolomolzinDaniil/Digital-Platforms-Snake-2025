# Data from Logism
	asect 0xf3
Move: # Gives the address 0xf3 the symbolic name IOReg

	asect 0xb4
PrevMove:

	asect 0xb1
Res:

    asect 0xb5
Tale:

	asect 0xf5
Head:				

	asect 0xf6
Apple:

    asect 0xff
Delete:

# End of data

# ЯЧЕЙКА КОНЦА.
	asect 0xf8
Ending:


 	asect 0x00
start:
	setsp 0xf0 			# sets the initial value of SP to 0xf0
	
	ldi r1, 0b00000010 
	push r1
	
    ldi r1, Tale
    ldi r0, 0x88
    st r1, r0           # Здесь должны быть начальные координаты хвоста, хз какие :()

	ldi r0, Ending
	ld r0, r0
Main:
		ldi r0, Head
		ld r0, r0		

		ldi r1, Res			# новое положение головы
		st r1, r0
		
		ldi r0, Move
		ld r0 ,r0
		
		ldi r1, PrevMove
		ld r1, r2
		st r1, r0 # PrevMove записываю Move
		
		if 
			cmp r2, r0
		is z # двигаемся в том же направлении
		
			ldsp r3
			
			ld r3, r1
			inc r1 		# увеличиваем длину первого изгиба на 1
			st r3, r1
		
		else # новый изгиб
			#r0 - new napvravlenie 
			
			# 000000xx -> xx000000
			shl r0
			shl r0
			shl r0
			shl r0
			shl r0
			shl r0
			inc r0 		# xx000001 - new segment
			inc r0 		# xx000002 - new segment for tale calcution

			# уменьшаю "второй" сегмент на 1, т.к теперь у нового длина 2.
			# т.е угловой пиксель относится к сегменту ближе к голове
			ldsp r3
			ld r3, r1 
			dec r1
			st r3, r1 

			push r0			
		fi
		
		# проверка на яблоко
		ldi r0, Apple
		ld r0, r0
		if
			tst r0
		is z			# если не съели
        
			ldi r0, 0xef
			ld r0, r1
			dec r1 		# уменьшаем длину последнего изгиба на 1
			st r0, r1
			

			# проверка на нулевую длину сегмента
			if
				ldi r0, 0b00111111
				and r0, r1
			is z
				ldsp r0         # адрес самого "левого" сегмента
				ldi r1, 0xf0    # адрес "конца" стека
			
				sub r0, r1      # количество ячеек стека
				neg r1 
			
				pop r2          # получаем "левый" сегмент + изменяем SP
				inc r0          # перехожу к следующей ячейке

				tst r1
				while
				stays nz
					ld r0, r3   # получаю новый сегмент
					st r0, r2   # на его место записываю предыдущий
				
					inc r0
					move r3, r2 # перекидываю  новый сегмент в r2
					dec r1      # уменьшаю счётчик
				wend
			
				st r0, r2       # закидываю последний сегмент （￣▽￣）d　
			fi
			
			# сдвигаем хвостик
			ldi r0, Tale
			ld  r0, r1          # получаю координаты хвоста
			ldi r3, Delete
			ld  r3, r3
			ldi r3, Res
			st  r3, r1			# "удаляю" старый хвостик

			# изменяю координаты хвоста, в соответсвии с последнем сегментом
			ldi r3, 0xef
			ld  r3, r3
			ldi r2, 0b11000000
			and r3, r2      	# направление в r2
			shr r2
			shr r2
			shr r2
			shr r2
			shr r2
			shr r2
			if
				tst r2   
			is  z   # up
				ldi r3, 1
			else
				if
					ldi r3, 1
					cmp r2, r3
				is z    # down
					ldi r3, 0b11111111
				else
					if
						inc r3
						cmp r2, r3
					is z    # left
						ldi r3, 0b11110000

					else    # right
						ldi r3, 0b00010000
					fi
				fi
					
			fi
			ldi r1, Tale
			ld r1, r2
			add r3, r2		# изменяю координаты хвоста
			st r1, r2		# Соханяю в памяти
		fi
		
		
		ldi r0, Ending  
		ld r0, r0		# поднятие флажка окончания цикла
						
	br Main           # go back to the start of the main loop
	end	
	
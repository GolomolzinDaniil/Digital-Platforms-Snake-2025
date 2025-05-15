# Data from Logism
	asect 0xf3
Move: # Gives the address 0xf3 the symbolic name IOReg

	asect 0xb4
PrevMove:

	asect 0xb0
Cords:				# for function

	asect 0xb1
Res:

	asect 0xf5
Head:				# for input

	asect 0xf6
Apple:

	asect 0xf7
Vivod:

	asect 0xb3
Output:
# End of data

# ЯЧЕЙКА КОНЦА.
	asect 0xf8
Ending:
# Процессор будет обращатеться к ней в конце каждого Main loop`a
# Можно использовать для синхронизации процессора и логизма


 	asect 0x00
start:
	setsp 0xf0 			# sets the initial value of SP to 0xf0
	
	ldi r1, 0b00000010 
	push r1
	
	ldi r0, Ending
	ld r0, r0
Main:
		ldi r0, Head
		ld r0, r0		
		ldi r1, Cords
		st r1, r0
		ldi r1, Res			# иначе, он будет выводить "удалённый" пиксель
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
		fi
		
		ldi r0, Vivod    # начало вывода
		ld r0, r0
		
		ldsp r3
		# вывод пикселей 
		while
			ldi r0, 0xf0
			cmp r0, r3
		stays nz
			ldi r0, Output # сохраняю текущий адрес
			ld r3, r1
			inc r3
			st r0, r3
			
			jsr changeCords
			
			ldi r3, Output # считываю адрес
			ld r3, r3
		wend
		
	
		ldi r0, Ending  
		ld r0, r0		# поднятие флажка окончания цикла
						
	br Main           # go back to the start of the main loop
	
# up - 0 
# down - 1 
# left - 2 
# right - 3
# r1 - segment
changeCords:
	ldi r0, Cords   # ячейка с координатами
	ld r0, r0       # значение координат
	ldi r2, Res
	st r2, r0    	# координаты на вывод

	move r1, r2	    # копирую сегмент в r2
	
	ldi r0, 0b11000000
	and r0, r1 		# получаю направление в r1
	shr r1
	shr r1
	shr r1
	shr r1
	shr r1
	shr r1	
	
	ldi r0, 0b00111111  
	and r2, r0			# получаю длину в r0
	ldi r2, 1
	# проверка в какую сторону движемся
	# в r2 будет константа для изменения координаты
		if
			tst r1
		is z 
		# up
		neg r2 		  # -1 for X cord
 		else 
			if 
				cmp	r1, r2
			is z
				# down
				# совпадает с текущим значением r2
			else 
				if
					inc r2
					cmp r1, r2
				is z
					# left
					ldi r2, 0b00010000    # +1 for y cord
					
				else
					#right
					ldi r2, 0b11110000    # -1 for y cord
				fi
			fi
		fi
	# r0 -length, r2 - constanta
	tst r0
	while
	stays nz
		ldi r3, Cords	
		ld r3, r1
		add r2, r1	  # изменённые координаты в r1
		
		st r3, r1     # сохраняем изменённые координаты 
	
		dec r0
		if
		is nz
			ldi r3, Res
			st r3,  r1
		fi
	wend
	rts
	
	end	

	asect 0xf3
IOReg: 

	asect 0x00
start:
	setsp 0xf0 
	
	ldi r0, IOReg
MainLoop:
	ld r0,r1		
	br MainLoop 
end	


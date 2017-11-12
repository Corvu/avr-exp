		.include "m8def.inc"	; Using ATMega8
		 
		.def seconds = R20
		.def minutes = R21
		.def hours = R22
		.def ovld0 = R18
		.def ovld1 = R19
		.def temp = R16
		.def temp2 = R17


; RAM =========================================================================
		.DSEG			; RAM segment

; FLASH =======================================================================
		.CSEG			; Code segment

;--constants-----------------------------------------------------------
		.org $060
numbers:
		.db 0b1000000
		.db 0b1111001
		.db 0b0100100
		.db 0b0110000
		.db 0b0011001
		.db 0b0010010
		.db 0b0000010
		.db 0b1111000
		.db 0b0000000
		.db 0b0010000
		
		LDI temp,0b1000000	
		STS $060,temp
;---------------------------------------------------------------------

;--Interrupt Vector Table---------------------------------------------
		.ORG $000
		RJMP start

		.ORG $012
		RJMP TOVL ;overload of TIMER_COUNTER_0
;---------------------------------------------------------------------

;--Main code----------------------------------------------------------
		.ORG $100
start:	
		LDI temp,Low(RAMEND)	;load stack pointer
		OUT SPL,temp		; Obligatory!!!
		LDI temp,High(RAMEND)
		OUT SPH,temp
		ldi temp,1<<ACD
		out ACSR,temp	;disable analog comparator
		SEI	;enable all interrupts

		LDI seconds,0	;reset values
		LDI minutes,0
		LDI hours,0

		LDI ovld0,16
		LDI ovld1,1

		LDI temp,0b11111111
		OUT DDRD,temp	;configure port D for output
		LDI temp,4	;launch timer, prescaler = 256
		OUT TCCR0,temp
		LDI temp,0

		LDI temp,1
		OUT TIMSK,temp
		LDI temp,0

		LDI temp,$70
		OUT PORTD,temp

		loop:
		WDR
		rjmp loop
;---------------------------------------------------------------------

;--timer overload-----------------------------------------------------
tovl:
		DEC ovld0
		BRNE tovlend
		DEC ovld1
		BRNE tovlend
		INC seconds

		LDI ovld0,16
		LDI ovld1,1
		LDI temp,10
		CP seconds,temp
		BRNE outnum
		LDI seconds,0
		RJMP outnum

		;INC minutes
		;LDI temp,60
		;CP minutes,temp
		;BRNE tovlend
		;LDI minutes,0
		;INC hours

tovlend:
		RETI

outnum:	;check which byte need to output
		CLR R27
		LDI R26,numbers
		ADD R26,seconds
		LD temp,X
		RJMP setoutnum
		
setoutnum:
		OUT portD,temp
		rjmp tovlend
;-------------------------------------------------------------------

;--Moving constants CODE->DATA--------------------------------------
		

;-------------------------------------------------------------------

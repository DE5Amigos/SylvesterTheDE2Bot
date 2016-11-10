;
; Register-to-Register Operations
;
; This is example code demonstrating the usage of register-to-register
; operations in SCOMP.
;
; Harrison Statham
;

org 0

RegisterToRegister:
	
	load 	One
	

	; movr
	;
	; Move data from one register to another. 
	; 
	; movr 	<destination>, <source>
	;
	; <destination> := <source>
	;
	movr 	r1, r0 		; r0 = AC!
	movr 	r2, r1	 	; r2 = r1
	
	movr 	r0, r0 		; doesnt do anything, but still valid.
	
	; etc...
	
	
	; addr
	;
	; Add the contents of two registers and store in the accumulator (or r0).
	;
	; addr <registerA>, <registerB>
	;
	; AC := <registerA> + <registerB>
	;
	
	addr 	r1, r1 		; valid - doubles.
	addr 	r0, r1 		; r0 = r0 + r1
	
	addr 	r2, r1 		
	movr 	r3, r0 		; r3 = r2 + r1
	
	; etc...
	
	
	; subr
	;
	; Subtract the contents of two registers and store in the accumulator (or r0).
	;
	; subr 	<registerA>, <registerB>
	;
	; AC := <registerA> - <registerB>
	;
	
	subr 	r1, r1 		; valid - zero.
	subr 	r0, r1 		; r0 = r0 - r1
	
	subr 	r2, r1 		
	movr 	r3, r0 		; r3 = r2 - r1
	
	; etc...
	
	
	
	; cmp
	;
	; Compare the contents and store some value in the accumulator
	; depending on whether the data is LT, EQ, or GT.
	;
	; cmp 	<registerA>, <registerB>
	;
	; AC := -1 	if <registerA> is less than <registerB>
	; 		 0 	if <registerA> is equal to <registerB>
	; 		 1 	if <registerA> is greater than <registerB>
	;
	
	; Load some data just for example.
	load 	One
	movr 	r1, r0
	
	load 	Two
	movr 	r2, r0
	
	; r1 = 1
	; r2 = 2
	
	cmp 	r1, r1 		; valid - always returns zero.
						; AC := 0
	
	; Less than operation					
	cmp 	r1, r2		; r1 < r2 -> true so AC := -1 		
	jneg 	SomeLabelHere
	
	
	; Equal operation
	cmp 	r1, r2
	jzero 	SomeLabelHere
	
	
	; Greater than operation
	cmp 	r1, r2
	jpos 	SomeLabelHere
	
	
	; Less than or equal to
	cmp 	r1, r2
	jneg 	SomeLabelHere
	jzero 	SomeLabelHere
	
	
	; Greater than or equal to
	cmp 	r1, r2
	jzero 	SomeLabelHere
	jpos 	SomeLabelHere
	
	
	; etc...
	
	
	
SomeLabelHere: jump SomeLabelHere	
	
	
	
; Some test data.	
	
One: 	DW 	&H01
Two: 	DW 	&H02




;***************************************************************
; Register Specific Constants
;
; NOTE: Copy all of these to the bottom of your assembly code.
;		Using these makes your code more descriptive. 
;***************************************************************

r0: 	EQU 	&H00
r1: 	EQU 	&H01
r2: 	EQU 	&H02
r3: 	EQU 	&H03
r4: 	EQU 	&H04
r5: 	EQU 	&H05
r6: 	EQU 	&H06
r7: 	EQU 	&H07
r8: 	EQU 	&H08
r9: 	EQU 	&H09
r10: 	EQU 	&H0A
r11: 	EQU 	&H0B
r12: 	EQU 	&H0C
r13: 	EQU 	&H0D
r14: 	EQU 	&H0E
r15: 	EQU 	&H0F
r16: 	EQU 	&H10
r17: 	EQU 	&H11
r18: 	EQU 	&H12
r19: 	EQU 	&H13
r20: 	EQU 	&H14
r21: 	EQU 	&H15
r22: 	EQU 	&H16
r23: 	EQU 	&H17
r24: 	EQU 	&H18
r25: 	EQU 	&H19
r26: 	EQU 	&H1A
r27: 	EQU 	&H1B
r28: 	EQU 	&H1C
r29: 	EQU 	&H1D
r30: 	EQU 	&H1E
r31: 	EQU 	&H1F
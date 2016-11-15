;
; Cosine
;
; Implement the cosine using a taylor series expansion.
;
;      x^2 	   x^4     x^6     x^8
; 1 - ----- + ----- - ----- + ----- + ... (how many more terms?...)
;       2!      4!      6!      8!
;
; Harrison Statham
;
; Yeah, a LUT would probably be much better...
; 
;

; Find the cosine of a given value.
;
; Inputs:
; 	
; r4 = x
;
; Outputs:
;
; r2 = cos(x)

Cosine:
	
	; Calculate x^2 / 2

	loadi 	2
	movr 	r5, r0
	call 	Pow

	movr 	r0, r2
	shift 	-2 		; shift right by two i.e. divide by 2.
	movr 	r8, r0 	; store for later.


	; Calculate x^4 / 4!. 4! = 24.

	loadi 	4
	movr 	r5, r0
	call 	Pow

	loadi 	24
	store			; Write to the division input.
	movr 	r0, r2 	; Prepare input to division.
	store  			; Write to the division input.
	call 	Div16s 	; Call the division routine.

	movr 	r9, r0 	; Store the result for later.


	; Calculate x^6 / 6!
	; 6! = 720 




Cosine6Fact: 	DW 	720
; Cosine8Fact: 	DW  40320

CosineXsq: 	DW 	&H00

; Pow
; 
; Raise a number to the power of n.
; 
; r4 = x
; r5 = n
;
; r2 = x^n
;

Pow:
	
	; A couple of cases to consider for x^n.
	;
	; 1. x = 0, and n >= 0. - okay
	; 1. x = 0, and n = -1. - bad!
	; 2. x != 0, and n > 1. - okay
	; 3. x != 0, and n < 1. - okay

	movr 	r0, r4
	jzero 	PowXIsZero


	loadi 	0
	cmp 	r5, r0 		; Compare the power n to 0.
	jneg 	PowNIsNeg 	; Handle negative exponents.
	jpos 	PowNIsPos 	; Handle positive exponents.
	jzero 	PowNIsZero 	; Handle n = 0. i.e. just return 1.



PowXIsZero:
	
	; Check to see if n >= 0.
	loadi 	0			; r0 = 0.
	cmp 	r5, r0 		; compare r5 with r0.	
	jzero 	PowZero
	jpos 	PowZero 

	; If we reach this point we gotta a big problem!!
	; What to do with this?...
	; Most times we would generate an exception but
	; thats not going to happen here!

	; For now we will just jump to zero.
	; This isnt the correct operation. We really should ERROR out.
	jump 	PowZero


	; Compare the power to 0.
	; If the power is 0 then we return 1.
	movr 	r0, r5
	jzero 	PowOne

	; Compare x to 0.
	; Obviously if x is 0 then we just return 0.
	movr 	r0, r4
	jzero 	PowZero

	; Determine if the power, n, is a negative number.
	; If so, cowardly refuse, and return 0.
	loadi 	0
	cmp 	r5, r0
	jneg 	PowZero



PowNIsPos:
	
	; Handle the case where the power is positive.

	; int temp = x;
	;
	; while(n > 0) {
	;	temp = temp*x;
	; 	// temp *= x;
	; }

	movr 	r6, r4 		; r6 = x; temp = x;
	movr 	r0, r7 		; r0 = n;

PowNIsPosLoop:

	jzero 	PowNIsPosLoopDone
	movr 	r7, r0 			; preserve r0.

	movr 	r0, r6 			; r0 = temp.
	store 	m16sA 			; m16sA = temp.
	movr 	r0, r4 			
	store 	m16sB 			; m16sB = r4.
	call 	Mult16s 		; Call the multiplication routine.
	load 	mres16sL 		; Load the lower 16 bits of the result.

	; !! Note: !!
	; We are ignoring the upper 16 bit value!!
	; We really should check that value to determine if we have some value in the upper 16 bits.
	; 	- Maybe we want to use that value.
	; 	- Perhaps thats just carry out that needs to be dealt with!!
	;
	movr 	r6, r0 			; move the result back to temp.
	
	; Prepare for the next iteration.

	movr 	r0, r7 			; restore the counter.
	addi 	-1 				; decrement n.
	jump 	PowNIsPosLoop 	; jump to next iteration.

PowNIsPosLoopDone:
	
	movr 	r2, r7
	jump 	PowEnd

PowNIsNeg:
	
	; Handle the case where the power is negative.
	loadi 	0
	movr 	r2, r0 		; Dont do anything with negative exponents YET...
	jump 	PowEnd

PowNIsZero:
	
	loadi 	1
	movr 	r2, r0
	jump 	PowEnd

PowZero:
	loadi 	0
	movr 	r2, r0

PowEnd:

	return 		; Return to caller.


;*******************************************************************************
; Mult16s:  16x16 -> 32-bit signed multiplication
; Based on Booth's algorithm.
; Written by Kevin Johnson.  No licence or copyright applied.
; Warning: does not work with factor B = -32768 (most-negative number).
; To use:
; - Store factors in m16sA and m16sB.
; - Call Mult16s
; - Result is stored in mres16sH and mres16sL (high and low words).
;*******************************************************************************
Mult16s:
	LOADI  0
	STORE  m16sc        ; clear carry
	STORE  mres16sH     ; clear result
	LOADI  16           ; load 16 to counter
Mult16s_loop:
	STORE  mcnt16s      
	LOAD   m16sc        ; check the carry (from previous iteration)
	JZERO  Mult16s_noc  ; if no carry, move on
	LOAD   mres16sH     ; if a carry, 
	ADD    m16sA        ;  add multiplicand to result H
	STORE  mres16sH
Mult16s_noc: ; no carry
	LOAD   m16sB
	AND    One          ; check bit 0 of multiplier
	STORE  m16sc        ; save as next carry
	JZERO  Mult16s_sh   ; if no carry, move on to shift
	LOAD   mres16sH     ; if bit 0 set,
	SUB    m16sA        ;  subtract multiplicand from result H
	STORE  mres16sH
Mult16s_sh:
	LOAD   m16sB
	SHIFT  -1           ; shift result L >>1
	AND    c7FFF        ; clear msb
	STORE  m16sB
	LOAD   mres16sH     ; load result H
	SHIFT  15           ; move lsb to msb
	OR     m16sB
	STORE  m16sB        ; result L now includes carry out from H
	LOAD   mres16sH
	SHIFT  -1
	STORE  mres16sH     ; shift result H >>1
	LOAD   mcnt16s
	ADDI   -1           ; check counter
	JPOS   Mult16s_loop ; need to iterate 16 times
	LOAD   m16sB
	STORE  mres16sL     ; multiplier and result L shared a word
	RETURN              ; Done
c7FFF: DW &H7FFF
m16sA: DW 0 ; multiplicand
m16sB: DW 0 ; multipler
m16sc: DW 0 ; carry
mcnt16s: DW 0 ; counter
mres16sL: DW 0 ; result low
mres16sH: DW 0 ; result high

;*******************************************************************************
; Div16s:  16/16 -> 16 R16 signed division
; Written by Kevin Johnson.  No licence or copyright applied.
; Warning: results undefined if denominator = 0.
; To use:
; - Store numerator in d16sN and denominator in d16sD.
; - Call Div16s
; - Result is stored in dres16sQ and dres16sR (quotient and remainder).
; Requires Abs subroutine
;*******************************************************************************
Div16s:
	LOADI  0
	STORE  dres16sR     ; clear remainder result
	STORE  d16sC1       ; clear carry
	LOAD   d16sN
	XOR    d16sD
	STORE  d16sS        ; sign determination = N XOR D
	LOADI  17
	STORE  d16sT        ; preload counter with 17 (16+1)
	LOAD   d16sD
	CALL   Abs          ; take absolute value of denominator
	STORE  d16sD
	LOAD   d16sN
	CALL   Abs          ; take absolute value of numerator
	STORE  d16sN
Div16s_loop:
	LOAD   d16sN
	SHIFT  -15          ; get msb
	AND    One          ; only msb (because shift is arithmetic)
	STORE  d16sC2       ; store as carry
	LOAD   d16sN
	SHIFT  1            ; shift <<1
	OR     d16sC1       ; with carry
	STORE  d16sN
	LOAD   d16sT
	ADDI   -1           ; decrement counter
	JZERO  Div16s_sign  ; if finished looping, finalize result
	STORE  d16sT
	LOAD   dres16sR
	SHIFT  1            ; shift remainder
	OR     d16sC2       ; with carry from other shift
	SUB    d16sD        ; subtract denominator from remainder
	JNEG   Div16s_add   ; if negative, need to add it back
	STORE  dres16sR
	LOADI  1
	STORE  d16sC1       ; set carry
	JUMP   Div16s_loop
Div16s_add:
	ADD    d16sD        ; add denominator back in
	STORE  dres16sR
	LOADI  0
	STORE  d16sC1       ; clear carry
	JUMP   Div16s_loop
Div16s_sign:
	LOAD   d16sN
	STORE  dres16sQ     ; numerator was used to hold quotient result
	LOAD   d16sS        ; check the sign indicator
	JNEG   Div16s_neg
	RETURN
Div16s_neg:
	LOAD   dres16sQ     ; need to negate the result
	CALL   Neg
	STORE  dres16sQ
	RETURN	
d16sN: DW 0 ; numerator
d16sD: DW 0 ; denominator
d16sS: DW 0 ; sign value
d16sT: DW 0 ; temp counter
d16sC1: DW 0 ; carry value
d16sC2: DW 0 ; carry value
dres16sQ: DW 0 ; quotient result
dres16sR: DW 0 ; remainder result


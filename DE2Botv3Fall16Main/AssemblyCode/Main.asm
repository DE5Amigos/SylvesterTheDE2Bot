; ==================================================================
; Main
;
; @brief 		Main entry point for the DE2 Bot code.
; 
; @author 		Daley Stepanek
; @author 		George Tang
; @author 		Harrison Statham
; @author 		Mark Woodson 	
; 
; @date 		Fall 2016
;	
; ==================================================================


Main:
	OUT    RESETPOS    ; reset odometer in case wheels moved after programming
	
	; configure timer interrupts
	LOADI  10          ; 10ms * 10 = 0.1s rate, or 10Hz.
	OUT    CTIMER      ; turn on timer peripheral
	SEI    &B0010      ; enable interrupts from source 2 (timer)
	; at this point, timer interrupts will be firing at 10Hz, and
	; code in that ISR will attempt to control the robot.
	; If you want to take manual control of the robot,
	; execute a CLI &B0010 to disable the interrupt.


	FindMin:
	;put sensor data into registers 4,5,6,7
		IN 		Dist1
		MOVR 	r4, r0
		IN 		Dist2
		MOVR 	r5, r0
		IN 		Dist3
		MOVR 	r6, r0
		IN 		Dist4
		MOVR 	r7, r0
		
		
		
		; decide which way to turn. this'll all go into a subroutine later.
	Turn:
		MOVR 	r0, r1		; puts r1 in acc
		ADDI 	-1			; is the min sensor #1?
		JZERO 	TurnL		; we need to turn left to face it
		MOVR 	r0, r1		; puts r1 in acc
		ADDI 	-4			; is the min sensor #4?
		JZERO 	TurnR		; we need to turn right to face it
		
		;turn leftwards (increasing theta) until sensor 3 sees the min
	TurnL:
		LOADI 	0
		STORE 	DVel		; desired forward velocity
		IN 		Theta		; current angle
		ADDI 	3			; move 3 at a time
		OUT 	DTheta		; turn left
		MOVR 	r0, r2		; bring r2 (min distance) into acc 
		ADDI 	50			; add some constant for error
		MOVR 	r3, r0 	; put r2 + some constant into r3
		IN 		Dist3		; check sensor 3
		MOVR 	r4, r0		; put it into r4
		CMP 	r4, r3		; compare reading from sensor 3 with min distance (+ error tolerance)
		JNEG 	Move		; reading is closer than min distance, we can move forward now
		JUMP 	TurnL		; reading is further than min distance, keep turning

		
		;turn rightwards (decreasing theta) until sensor 2 sees the min
	TurnR:
		LOADI 	0
		STORE 	DVel      ; desired forward velocity
		IN 		Theta		; current angle
		ADDI 	-3			; move 3 at a time
		OUT 	DTheta		; turn right
		MOVR 	r0, r2		; bring r2 (min distance) into acc 
		ADDI 	50			; add some constant for error
		MOVR 	r3, r0 	; put r2 + some constant into r3
		IN 		Dist2		; check sensor 2
		MOVR 	r4, r0		; put it into r4
		CMP 	r4, r3		; compare reading from sensor 2 with min distance (+ error tolerance)
		JNEG 	Move		; reading is closer than min distance, we can move forward now
		JUMP 	TurnR		; reading is further than min distance, keep turning

	Move: 
		LOADI 	500
		STORE 	DVel		; move forward fast.
		LOADI 	200		;put some minimum allowed distance (touching object) into r6
		MOVR 	r6, r0
		IN 		Dist2
		MOVR 	r4, r0		; put in r4
		IN 		Dist3
		MOVR 	r5, r0		; put in r5
		CMP 	r4, r6		; Check to see if sensor 2 sees that the object as been reached
		JNEG 	Found
		CMP 	r5, r6		; Check to see if sensor 3 sees that the object has been reached
		JNEG 	Found
		CMP 	r4, r5		; r4 still contains the error adjusted min value
		JNEG 	VeerL		; sensor 2 sees object
		JPOS 	VeerR		; sensor 3 sees object
		IN 		Dist2		; sensors 2 and 3 had the object in sight
		ADDI 	5			; adjust for error
		MOVR 	r3, r0		; update distance to target
		JUMP 	Move		; both see object, just go forward
		
	VeerL:
		IN 		Dist2		; sensor 2 had the object in sight
		ADDI 	50			; adjust for error
		MOVR 	r3, r0		; update distance to target
		IN 		Theta		; current angle
		ADDI 	1			; move 1 at a time
		OUT 	DTheta		; update angle
		JUMP 	Move		; continue moving
		
	VeerR:
		IN 		Dist3		; sensor 3 had the object in sight
		ADDI 	50			; adjust for error
		MOVR 	r3, r0		; update distance to target
		IN 		Theta		; current angle
		ADDI 	-1			; move 1 at a time
		OUT 	DTheta		; update angle
		JUMP 	Move		; continue moving
		
	Found:
		LOADI 	0
		STORE 	DVel		; stop moving
		CALL 	ReturnHome
		JUMP 	WaitForUser






; End Main.asm
; ==================================================================


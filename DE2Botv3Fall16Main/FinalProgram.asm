; Fall2016StartingPoint.asm
; This program includes a basic movement API that allows the
; user to specify a desired heading and speed, and the API will
; attempt to control the robot in an appropriate way.

; This code uses the timer interrupt for the control code.
ORG 0                  ; Jump table is located in mem 0-4
	JUMP   Init        ; Reset vector
	RETI               ; Sonar interrupt (unused)
	JUMP   CTimer_ISR  ; Timer interrupt
	RETI               ; UART interrupt (unused)
	RETI               ; Motor stall interrupt (unused)

;***************************************************************
;* Initialization
;***************************************************************
Init:
	; Always a good idea to make sure the robot
	; stops in the event of a reset.
	LOAD   Zero
	OUT    LVELCMD     ; Stop motors
	OUT    RVELCMD
	OUT    SONAREN     ; Disable sonar (optional)
	OUT    BEEP        ; Stop any beeping (optional)
	
	CALL   SetupI2C    ; Configure the I2C to read the battery voltage
	CALL   BattCheck   ; Get battery voltage (and end if too low).
	OUT    LCD         ; Display battery voltage (hex, tenths of volts)

WaitForSafety:
	; This loop will wait for the user to toggle SW17.  Note that
	; SCOMP does not have direct access to SW17; it only has access
	; to the SAFETY signal contained in XIO.
	IN     XIO         ; XIO contains SAFETY signal
	AND    Mask4       ; SAFETY signal is bit 4
	JPOS   WaitForUser ; If ready, jump to wait for PB3
	IN     TIMER       ; We'll use the timer value to
	AND    Mask1       ;  blink LED17 as a reminder to toggle SW17
	SHIFT  8           ; Shift over to LED17
	OUT    XLEDS       ; LED17 blinks at 2.5Hz (10Hz/4)
	JUMP   WaitForSafety
	
WaitForUser:
	; This loop will wait for the user to press PB3, to ensure that
	; they have a chance to prepare for any movement in the main code.
	IN     TIMER       ; We'll blink the LEDs above PB3
	AND    Mask1
	SHIFT  5           ; Both LEDG6 and LEDG7
	STORE  Temp        ; (overkill, but looks nice)
	SHIFT  1
	OR     Temp
	OUT    XLEDS
	IN     XIO         ; XIO contains KEYs
	AND    Mask2       ; KEY3 mask (KEY0 is reset and can't be read)
	JPOS   WaitForUser ; not ready (KEYs are active-low, hence JPOS)
	LOAD   Zero
	OUT    XLEDS       ; clear LEDs once ready to continue

;***************************************************************
;* Main code
;***************************************************************
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
	


;Turn45:
;	LOADI  0
;	STORE  DVel       ; desired forward velocity
;	LOADI  45
;	STORE DTheta
;	IN Theta
;	OUT SSEG1
;	ADDI -40
;	JNEG Turn45
	LOADI 45
	OUT THETA
	
EnableSensors:
	LOAD Mask1
	OR Mask2
	OR Mask3
	OR Mask4
	OUT SonarEn
	
FindMin:
;put sensor data into registers 4,5,6,7
	IN Dist1
	OUT SSEG1
	CALL Wait1
	MOVR r4, r0
	IN Dist2
	OUT SSEG1
	CALL Wait1
	MOVR r5, r0
	IN Dist3
	OUT SSEG1
	CALL Wait1
	MOVR r6, r0
	IN Dist4
	OUT SSEG1
	CALL Wait1
	MOVR r7, r0
	
	CALL MinimumOfFourWithIndex
	;r2 contains minimum value (need to modify subroutine to give index too.) we'll say r1 contains index.
	MOVR r0, r1
	OUT SSEG1
	
	; decide which way to turn. this'll all go into a subroutine later.
Turn:
	MOVR r0, r1		; puts r1 in acc
	ADDI -1			; is the min sensor #1?
	JZERO TurnL		; we need to turn left to face it
	MOVR r0, r1		; puts r1 in acc
	ADDI -4			; is the min sensor #4?
	JZERO TurnR		; we need to turn right to face it
	JUMP Move
	;turn leftwards (increasing theta) until sensor 3 sees the min
TurnL:
	LOADI 0
	STORE DVel		; desired forward velocity
	IN Theta		; current angle
	ADDI 3			; move 3 at a time
	OUT DTheta		; turn left
	MOVR r0, r2		; bring r2 (min distance) into acc 
	ADDI 50			; add some constant for error
	MOVR r3, r0 	; put r2 + some constant into r3
	IN Dist3		; check sensor 3
	MOVR r4, r0		; put it into r4
	CMP r4, r3		; compare reading from sensor 3 with min distance (+ error tolerance)
	JNEG Move		; reading is closer than min distance, we can move forward now
	JUMP TurnL		; reading is further than min distance, keep turning

	
	;turn rightwards (decreasing theta) until sensor 2 sees the min
TurnR:
	LOADI 0
	STORE DVel      ; desired forward velocity
	IN Theta		; current angle
	ADDI -3			; move 3 at a time
	OUT DTheta		; turn right
	MOVR r0, r2		; bring r2 (min distance) into acc 
	ADDI 50			; add some constant for error
	MOVR r3, r0 	; put r2 + some constant into r3
	IN Dist2		; check sensor 2
	MOVR r4, r0		; put it into r4
	CMP r4, r3		; compare reading from sensor 2 with min distance (+ error tolerance)
	JNEG Move		; reading is closer than min distance, we can move forward now
	JUMP TurnR		; reading is further than min distance, keep turning

Move: 
	LOADI 500
	STORE DVel		; move forward fast.
	LOADI 200		;put some minimum allowed distance (touching object) into r6
	MOVR r6, r0
	IN Dist2
	MOVR r4, r0		; put in r4
	IN Dist3
	MOVR r5, r0		; put in r5
	CMP r4, r6		; Check to see if sensor 2 sees that the object as been reached
	JNEG Found
	CMP r5, r6		; Check to see if sensor 3 sees that the object has been reached
	JNEG Found
	CMP r4, r5		; r4 still contains the error adjusted min value
	JNEG VeerL		; sensor 2 sees object
	JPOS VeerR		; sensor 3 sees object
	IN Dist2		; sensors 2 and 3 had the object in sight
	ADDI 5			; adjust for error
	MOVR r3, r0		; update distance to target
	JUMP Move		; both see object, just go forward
	
VeerL:
	IN Dist2		; sensor 2 had the object in sight
	ADDI 50			; adjust for error
	MOVR r3, r0		; update distance to target
	IN Theta		; current angle
	ADDI 1			; move 1 at a time
	OUT DTheta		; update angle
	JUMP Move		; continue moving
	
VeerR:
	IN Dist3		; sensor 3 had the object in sight
	ADDI 50			; adjust for error
	MOVR r3, r0		; update distance to target
	IN Theta		; current angle
	ADDI -1			; move 1 at a time
	OUT DTheta		; update angle
	JUMP Move		; continue moving
	
Found:
	LOADI 0
	STORE DVel		; stop moving
	CALL ReturnHome
	JUMP WaitForUser
	
Die:
; Sometimes it's useful to permanently stop execution.
; This will also catch the execution if it accidentally
; falls through from above.
	CLI    &B1111       ; disable all interrupts
	LOAD   Zero         ; Stop everything.
	OUT    LVELCMD
	OUT    RVELCMD
	OUT    SONAREN
	LOAD   DEAD         ; An indication that we are dead
	OUT    SSEG2        ; "dEAd" on the LEDs
Forever:
	JUMP   Forever      ; Do this forever.
	DEAD:  DW &HDEAD    ; Example of a "local" variable


; Timer ISR.  Currently just calls the control code
CTimer_ISR:
	CALL   ControlMovement
	RETI   ; return from ISR
	
	
; Control code.  If called repeatedly, this code will attempt
; to control the robot to face the angle specified in DTheta
; and match the speed specified in DVel
DTheta:    DW 0
DVel:      DW 0
ControlMovement:
	; convenient way to get +/-180 angle error is
	; ((error + 180) % 360 ) - 180
	IN     THETA
	SUB    DTheta      ; actual - desired angle
	CALL   Neg         ; desired - actual angle
	ADDI   180
	CALL   Mod360
	ADDI   -180
	; A quick-and-dirty way to get a decent velocity value
	; for turning is to multiply the angular error by 4.
	SHIFT  2
	STORE  CMAErr      ; hold temporarily

	
	; For this basic control method, simply take the
	; desired forward velocity and add a differential
	; velocity for each wheel when turning is needed.
	LOAD   DVel
	ADD    CMAErr
	CALL   CapVel      ; ensure velocity is valid
	OUT    RVELCMD
	LOAD   CMAErr
	CALL   Neg         ; left wheel gets negative differential
	ADD    DVel
	CALL   CapVel
	OUT    LVELCMD
	
	RETURN
	CMAErr: DW 0       ; holds angle error velocity

CapVel:
	; cap velocity values for the motors
	ADDI    -500
	JPOS    CapVelHigh
	ADDI    500
	ADDI    500
	JNEG    CapVelLow
	ADDI    -500
	RETURN
CapVelHigh:
	LOADI   500
	RETURN
CapVelLow:
	LOADI   -500
	RETURN

;***************************************************************
;* Subroutines
;***************************************************************
;Return Home. Does not use sensors to check for wall, so we need to add that function in.

ReturnHome:
	IN XPOS		
	STORE AtanX
	IN YPOS
	STORE AtanY
	CALL Atan2		; get the angle we need to turn to
	STORE DTheta
	
TurnH:
	IN Theta
	MOVR r9, r0		; load r9 with theta
	ADDI -1
	MOVR r10, r0	; load r10 with desired angle -1 deg
	ADDI 2
	MOVR r11, r0	; load r11 with angle +1 deg
	CMP r9, r10
	JPOS CheckH		; theta is larger than low range of desired angle
	JUMP TurnH	
CheckH:
	CMP r9, r11		
	JNEG DriveH		; theta is smaller than high range of desired angle
	JUMP TurnH
	
DriveH:
	LOADI -500		; reverse at fast speed
	STORE DVel
	IN XPOS			; check x pos
	ADDI -500		; home base
	JPOS DriveH		; keep driving if not home
	IN YPOS			; check y pos
	ADDI -500		; home base
	JPOS DriveH		; keep driving if not home
	
	LOADI 0
	STORE DVel		; stop
	return
	




;
; Minimum of 4 Values with Index
;
; Return the Minimum of 4 values along with the corresponding index
; that the minimum came from.
;
; Harrison Statham
;


;
; r4 = input 1
; r5 = input 2
; r6 = input 3
; r7 = input 4
;
; r2 = output 1
; r3 = output 2
;

MinimumOfFourWithIndex:
	
	; r4 and r5 are prepped for call to MinimumOfTwo.
	call 	MinimumOfTwo

	; Result is in r2.
	; Compare r4 to r2. If they are equal then r4 was the minimum, else r5 was.
	cmp 	r4, r2
	jzero 	MinimumOfFourWithIndexR4
	jump 	MinimumOfFourWithIndexR5

MinimumOfFourWithIndexR4:
	
	loadi 	1
	store 	MinimumOfFourWithIndexIndex
	jump 	MinimumOfFourWithIndexR5End

MinimumOfFourWithIndexR5:
	
	loadi 	2
	store 	MinimumOfFourWithIndexIndex

MinimumOfFourWithIndexR5End:
	

	; Now we have determined min{r4, r5} and we have the appropriate index.
	; Prepare for the next call.
	movr 	r4, r2
	movr 	r5, r6
	call 	MinimumOfTwo

	; Result is in r2.
	; Compare r4 to r2. If they are equal then r4 was the minimum, else r5 was.
	cmp 	r4, r2
	jzero 	MinimumOfFourWithIndexR6End

MinimumOfFourWithIndexR6:
	
	loadi 	3
	store 	MinimumOfFourWithIndexIndex

MinimumOfFourWithIndexR6End:


	; Now we have determined min{r4, r5, r6} and we have the appropriate index.
	; Prepare for the next call.
	movr 	r4, r2
	movr 	r5, r7
	call 	MinimumOfTwo

	; Result is in r2.
	; Compare r4 to r2. If they are equal then r4 was the minimum, else r5 was.
	cmp 	r4, r2
	jzero 	MinimumOfFourWithIndexEnd
	
MinimumOfFourWithIndexR7:
	
	loadi 	4
	store 	MinimumOfFourWithIndexIndex

MinimumOfFourWithIndexEnd:
	
	load	MinimumOfFourWithIndexIndex
	movr 	r1, r0

	return

MinimumOfFourWithIndexIndex: 	DW 	&H00








MinimumOfTwo:
	
	movr 	r2, r4 				; Assume r4 is min to start with.

	cmp 	r4, r5				; Is r4 < r5
	jneg 	MinimumOfTwoEnd 	; Jump to end if r4 is the min.
	movr 	r2, r5 				; Set r2 to r5 since that is min (or equal).

MinimumOfTwoEnd:
	return



;*******************************************************************************
; Mod360: modulo 360
; Returns AC%360 in AC
; Written by Kevin Johnson.  No licence or copyright applied.
;*******************************************************************************
Mod360:
	; easy modulo: subtract 360 until negative then add 360 until not negative
	JNEG   M360N
	ADDI   -360
	JUMP   Mod360
M360N:
	ADDI   360
	JNEG   M360N
	RETURN

;*******************************************************************************
; Abs: 2's complement absolute value
; Returns abs(AC) in AC
; Neg: 2's complement negation
; Returns -AC in AC
; Written by Kevin Johnson.  No licence or copyright applied.
;*******************************************************************************
Abs:
	JPOS   Abs_r
Neg:
	XOR    NegOne       ; Flip all bits
	ADDI   1            ; Add one (i.e. negate number)
Abs_r:
	RETURN

;******************************************************************************;
; Atan2: 4-quadrant arctangent calculation                                     ;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;
; Original code by Team AKKA, Spring 2015.                                     ;
; Based on methods by Richard Lyons                                            ;
; Code updated by Kevin Johnson to use software mult and div                   ;
; No license or copyright applied.                                             ;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;
; To use: store dX and dY in global variables AtanX and AtanY.                 ;
; Call Atan2                                                                   ;
; Result (angle [0,359]) is returned in AC                                     ;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;
; Requires additional subroutines:                                             ;
; - Mult16s: 16x16->32bit signed multiplication                                ;
; - Div16s: 16/16->16R16 signed division                                       ;
; - Abs: Absolute value                                                        ;
; Requires additional constants:                                               ;
; - One:     DW 1                                                              ;
; - NegOne:  DW 0                                                              ;
; - LowByte: DW &HFF                                                           ;
;******************************************************************************;
Atan2:
	LOAD   AtanY
	CALL   Abs          ; abs(y)
	STORE  AtanT
	LOAD   AtanX        ; abs(x)
	CALL   Abs
	SUB    AtanT        ; abs(x) - abs(y)
	JNEG   A2_sw        ; if abs(y) > abs(x), switch arguments.
	LOAD   AtanX        ; Octants 1, 4, 5, 8
	JNEG   A2_R3
	CALL   A2_calc      ; Octants 1, 8
	JNEG   A2_R1n
	RETURN              ; Return raw value if in octant 1
A2_R1n: ; region 1 negative
	ADDI   360          ; Add 360 if we are in octant 8
	RETURN
A2_R3: ; region 3
	CALL   A2_calc      ; Octants 4, 5            
	ADDI   180          ; theta' = theta + 180
	RETURN
A2_sw: ; switch arguments; octants 2, 3, 6, 7 
	LOAD   AtanY        ; Swap input arguments
	STORE  AtanT
	LOAD   AtanX
	STORE  AtanY
	LOAD   AtanT
	STORE  AtanX
	JPOS   A2_R2        ; If Y positive, octants 2,3
	CALL   A2_calc      ; else octants 6, 7
	CALL   Neg          ; Negatge the number
	ADDI   270          ; theta' = 270 - theta
	RETURN
A2_R2: ; region 2
	CALL   A2_calc      ; Octants 2, 3
	CALL   Neg          ; negate the angle
	ADDI   90           ; theta' = 90 - theta
	RETURN
A2_calc:
	; calculates R/(1 + 0.28125*R^2)
	LOAD   AtanY
	STORE  d16sN        ; Y in numerator
	LOAD   AtanX
	STORE  d16sD        ; X in denominator
	CALL   A2_div       ; divide
	LOAD   dres16sQ     ; get the quotient (remainder ignored)
	STORE  AtanRatio
	STORE  m16sA
	STORE  m16sB
	CALL   A2_mult      ; X^2
	STORE  m16sA
	LOAD   A2c
	STORE  m16sB
	CALL   A2_mult
	ADDI   256          ; 256/256+0.28125X^2
	STORE  d16sD
	LOAD   AtanRatio
	STORE  d16sN        ; Ratio in numerator
	CALL   A2_div       ; divide
	LOAD   dres16sQ     ; get the quotient (remainder ignored)
	STORE  m16sA        ; <= result in radians
	LOAD   A2cd         ; degree conversion factor
	STORE  m16sB
	CALL   A2_mult      ; convert to degrees
	STORE  AtanT
	SHIFT  -7           ; check 7th bit
	AND    One
	JZERO  A2_rdwn      ; round down
	LOAD   AtanT
	SHIFT  -8
	ADDI   1            ; round up
	RETURN
A2_rdwn:
	LOAD   AtanT
	SHIFT  -8           ; round down
	RETURN
A2_mult: ; multiply, and return bits 23..8 of result
	CALL   Mult16s
	LOAD   mres16sH
	SHIFT  8            ; move high word of result up 8 bits
	STORE  mres16sH
	LOAD   mres16sL
	SHIFT  -8           ; move low word of result down 8 bits
	AND    LowByte
	OR     mres16sH     ; combine high and low words of result
	RETURN
A2_div: ; 16-bit division scaled by 256, minimizing error
	LOADI  9            ; loop 8 times (256 = 2^8)
	STORE  AtanT
A2_DL:
	LOAD   AtanT
	ADDI   -1
	JPOS   A2_DN        ; not done; continue shifting
	CALL   Div16s       ; do the standard division
	RETURN
A2_DN:
	STORE  AtanT
	LOAD   d16sN        ; start by trying to scale the numerator
	SHIFT  1
	XOR    d16sN        ; if the sign changed,
	JNEG   A2_DD        ; switch to scaling the denominator
	XOR    d16sN        ; get back shifted version
	STORE  d16sN
	JUMP   A2_DL
A2_DD:
	LOAD   d16sD
	SHIFT  -1           ; have to scale denominator
	STORE  d16sD
	JUMP   A2_DL
AtanX:      DW 0
AtanY:      DW 0
AtanRatio:  DW 0        ; =y/x
AtanT:      DW 0        ; temporary value
A2c:        DW 72       ; 72/256=0.28125, with 8 fractional bits
A2cd:       DW 14668    ; = 180/pi with 8 fractional bits

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

;*******************************************************************************
; L2Estimate:  Pythagorean distance estimation
; Written by Kevin Johnson.  No licence or copyright applied.
; Warning: this is *not* an exact function.  I think it's most wrong
; on the axes, and maybe at 45 degrees.
; To use:
; - Store X and Y offset in L2X and L2Y.
; - Call L2Estimate
; - Result is returned in AC.
; Result will be in same units as inputs.
; Requires Abs and Mult16s subroutines.
;*******************************************************************************
L2Estimate:
	; take abs() of each value, and find the largest one
	LOAD   L2X
	CALL   Abs
	STORE  L2T1
	LOAD   L2Y
	CALL   Abs
	SUB    L2T1
	JNEG   GDSwap    ; swap if needed to get largest value in X
	ADD    L2T1
CalcDist:
	; Calculation is max(X,Y)*0.961+min(X,Y)*0.406
	STORE  m16sa
	LOADI  246       ; max * 246
	STORE  m16sB
	CALL   Mult16s
	LOAD   mres16sH
	SHIFT  8
	STORE  L2T2
	LOAD   mres16sL
	SHIFT  -8        ; / 256
	AND    LowByte
	OR     L2T2
	STORE  L2T3
	LOAD   L2T1
	STORE  m16sa
	LOADI  104       ; min * 104
	STORE  m16sB
	CALL   Mult16s
	LOAD   mres16sH
	SHIFT  8
	STORE  L2T2
	LOAD   mres16sL
	SHIFT  -8        ; / 256
	AND    LowByte
	OR     L2T2
	ADD    L2T3     ; sum
	RETURN
GDSwap: ; swaps the incoming X and Y
	ADD    L2T1
	STORE  L2T2
	LOAD   L2T1
	STORE  L2T3
	LOAD   L2T2
	STORE  L2T1
	LOAD   L2T3
	JUMP   CalcDist
L2X:  DW 0
L2Y:  DW 0
L2T1: DW 0
L2T2: DW 0
L2T3: DW 0


; Subroutine to wait (block) for 1 second
Wait1:
	OUT    TIMER
Wloop:
	IN     TIMER
	OUT    XLEDS       ; User-feedback that a pause is occurring.
	ADDI   -10         ; 1 second at 10Hz.
	JNEG   Wloop
	RETURN

; This subroutine will get the battery voltage,
; and stop program execution if it is too low.
; SetupI2C must be executed prior to this.
BattCheck:
	CALL   GetBattLvl
	JZERO  BattCheck   ; A/D hasn't had time to initialize
	SUB    MinBatt
	JNEG   DeadBatt
	ADD    MinBatt     ; get original value back
	RETURN
; If the battery is too low, we want to make
; sure that the user realizes it...
DeadBatt:
	LOADI  &H20
	OUT    BEEP        ; start beep sound
	CALL   GetBattLvl  ; get the battery level
	OUT    SSEG1       ; display it everywhere
	OUT    SSEG2
	OUT    LCD
	LOAD   Zero
	ADDI   -1          ; 0xFFFF
	OUT    LEDS        ; all LEDs on
	OUT    XLEDS
	CALL   Wait1       ; 1 second
	Load   Zero
	OUT    BEEP        ; stop beeping
	LOAD   Zero
	OUT    LEDS        ; LEDs off
	OUT    XLEDS
	CALL   Wait1       ; 1 second
	JUMP   DeadBatt    ; repeat forever
	
; Subroutine to read the A/D (battery voltage)
; Assumes that SetupI2C has been run
GetBattLvl:
	LOAD   I2CRCmd     ; 0x0190 (write 0B, read 1B, addr 0x90)
	OUT    I2C_CMD     ; to I2C_CMD
	OUT    I2C_RDY     ; start the communication
	CALL   BlockI2C    ; wait for it to finish
	IN     I2C_DATA    ; get the returned data
	RETURN

; Subroutine to configure the I2C for reading batt voltage
; Only needs to be done once after each reset.
SetupI2C:
	CALL   BlockI2C    ; wait for idle
	LOAD   I2CWCmd     ; 0x1190 (write 1B, read 1B, addr 0x90)
	OUT    I2C_CMD     ; to I2C_CMD register
	LOAD   Zero        ; 0x0000 (A/D port 0, no increment)
	OUT    I2C_DATA    ; to I2C_DATA register
	OUT    I2C_RDY     ; start the communication
	CALL   BlockI2C    ; wait for it to finish
	RETURN
	
; Subroutine to block until I2C device is idle
BlockI2C:
	LOAD   Zero
	STORE  Temp        ; Used to check for timeout
BI2CL:
	LOAD   Temp
	ADDI   1           ; this will result in ~0.1s timeout
	STORE  Temp
	JZERO  I2CError    ; Timeout occurred; error
	IN     I2C_RDY     ; Read busy signal
	JPOS   BI2CL       ; If not 0, try again
	RETURN             ; Else return
I2CError:
	LOAD   Zero
	ADDI   &H12C       ; "I2C"
	OUT    SSEG1
	OUT    SSEG2       ; display error message
	JUMP   I2CError

;***************************************************************
;* Variables
;***************************************************************
Temp:     DW 0 ; "Temp" is not a great name, but can be useful

;***************************************************************
;* Constants
;* (though there is nothing stopping you from writing to these)
;***************************************************************
NegOne:   DW -1
Zero:     DW 0
One:      DW 1
Two:      DW 2
Three:    DW 3
Four:     DW 4
Five:     DW 5
Six:      DW 6
Seven:    DW 7
Eight:    DW 8
Nine:     DW 9
Ten:      DW 10

; Some bit masks.
; Masks of multiple bits can be constructed by ORing these
; 1-bit masks together.
Mask0:    DW &B00000001
Mask1:    DW &B00000010
Mask2:    DW &B00000100
Mask3:    DW &B00001000
Mask4:    DW &B00010000
Mask5:    DW &B00100000
Mask6:    DW &B01000000
Mask7:    DW &B10000000
LowByte:  DW &HFF      ; binary 00000000 1111111
LowNibl:  DW &HF       ; 0000 0000 0000 1111

; some useful movement values
OneMeter: DW 961       ; ~1m in 1.04mm units
HalfMeter: DW 481      ; ~0.5m in 1.04mm units
TwoFeet:  DW 586       ; ~2ft in 1.04mm units
Deg90:    DW 90        ; 90 degrees in odometer units
Deg180:   DW 180       ; 180
Deg270:   DW 270       ; 270
Deg360:   DW 360       ; can never actually happen; for math only
FSlow:    DW 100       ; 100 is about the lowest velocity value that will move
RSlow:    DW -100
FMid:     DW 350       ; 350 is a medium speed
RMid:     DW -350
FFast:    DW 500       ; 500 is almost max speed (511 is max)
RFast:    DW -500

MinBatt:  DW 140       ; 14.0V - minimum safe battery voltage
I2CWCmd:  DW &H1190    ; write one i2c byte, read one byte, addr 0x90
I2CRCmd:  DW &H0190    ; write nothing, read one byte, addr 0x90

;***************************************************************
;* IO address space map
;***************************************************************
SWITCHES: EQU &H00  ; slide switches
LEDS:     EQU &H01  ; red LEDs
TIMER:    EQU &H02  ; timer, usually running at 10 Hz
XIO:      EQU &H03  ; pushbuttons and some misc. inputs
SSEG1:    EQU &H04  ; seven-segment display (4-digits only)
SSEG2:    EQU &H05  ; seven-segment display (4-digits only)
LCD:      EQU &H06  ; primitive 4-digit LCD display
XLEDS:    EQU &H07  ; Green LEDs (and Red LED16+17)
BEEP:     EQU &H0A  ; Control the beep
CTIMER:   EQU &H0C  ; Configurable timer for interrupts
LPOS:     EQU &H80  ; left wheel encoder position (read only)
LVEL:     EQU &H82  ; current left wheel velocity (read only)
LVELCMD:  EQU &H83  ; left wheel velocity command (write only)
RPOS:     EQU &H88  ; same values for right wheel...
RVEL:     EQU &H8A  ; ...
RVELCMD:  EQU &H8B  ; ...
I2C_CMD:  EQU &H90  ; I2C module's CMD register,
I2C_DATA: EQU &H91  ; ... DATA register,
I2C_RDY:  EQU &H92  ; ... and BUSY register
UART_DAT: EQU &H98  ; UART data
UART_RDY: EQU &H98  ; UART status
SONAR:    EQU &HA0  ; base address for more than 16 registers....
DIST0:    EQU &HA8  ; the eight sonar distance readings
DIST1:    EQU &HA9  ; ...
DIST2:    EQU &HAA  ; ...
DIST3:    EQU &HAB  ; ...
DIST4:    EQU &HAC  ; ...
DIST5:    EQU &HAD  ; ...
DIST6:    EQU &HAE  ; ...
DIST7:    EQU &HAF  ; ...
SONALARM: EQU &HB0  ; Write alarm distance; read alarm register
SONARINT: EQU &HB1  ; Write mask for sonar interrupts
SONAREN:  EQU &HB2  ; register to control which sonars are enabled
XPOS:     EQU &HC0  ; Current X-position (read only)
YPOS:     EQU &HC1  ; Y-position
THETA:    EQU &HC2  ; Current rotational position of robot (0-359)
RESETPOS: EQU &HC3  ; write anything here to reset odometry to 0
RIN:      EQU &HC8
LIN:      EQU &HC9

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

; ==================================================================
; ReturnHome
;
; @brief 	Return the robot to its initial starting posistion.
; @author 	George Tang
;
; ==================================================================

ReturnHome:

	IN 		XPOS		
	STORE 	AtanX
	IN 		YPOS
	STORE 	AtanY
	CALL 	Atan2		; get the angle we need to turn to
	STORE 	DTheta
	
TurnH:
	IN 		Theta
	MOVR 	r9, r0		; load r9 with theta
	ADDI 	-1
	MOVR 	r10, r0		; load r10 with desired angle -1 deg
	ADDI 	2
	MOVR 	r11, r0		; load r11 with angle +1 deg
	CMP 	r9, r10
	JPOS 	CheckH		; theta is larger than low range of desired angle
	JUMP 	TurnH	
CheckH:
	CMP 	r9, r11		
	JNEG 	DriveH		; theta is smaller than high range of desired angle
	JUMP 	TurnH
	
DriveH:
	LOADI 	-500		; reverse at fast speed
	STORE 	DVel
	IN 		XPOS		; check x pos
	ADDI 	-500		; home base
	JPOS 	DriveH		; keep driving if not home
	IN 		YPOS		; check y pos
	ADDI 	-500		; home base
	JPOS 	DriveH		; keep driving if not home
	
	LOADI 	0	
	STORE 	DVel		; stop

	return


; End ReturnHome.asm
; ==================================================================


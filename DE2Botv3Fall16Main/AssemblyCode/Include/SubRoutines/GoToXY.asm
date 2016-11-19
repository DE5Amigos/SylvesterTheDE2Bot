;******************************************************************************;
; GoToXY: general movement subroutine to be run from timer ISR                 ;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;
; To use: store desired XPOS and YPOS in DesX and DesY and set DesMove to 1.   ;
; When robot has reached destination, DesMove will be reset to 0.              ;
; This routine must be run at 10Hz.                                            ;
; Subroutine simulates completion immediately, so you should push the robot to ;
; the destination within that time.  (You might want to fix that).             ;
;******************************************************************************;

GoToXY:
	; this example displays a value and pretends to reach the destination
	; immediately to prove that the ISR is being run.  When the movement
	; is activated, this code will beep for one period of the timer.
	LOAD   Temp
	OUT    LEDs
	ADDI   1
	STORE  Temp
	LOAD   DesMove
	JZERO  GoToDoNothing
	; movement is active
	LOADI  0
	STORE  DesMove  ; indicate that destination is reached
	LOADI  3
	OUT    BEEP     ; start a beep
	RETURN
	
GoToDoNothing:
	LOADI  0
	OUT    BEEP   ; stop any beeping that was happening
	RETURN
	
; variables to store desired position
DesMove: DW 0
DesX: DW 0
DesY: DW 0



; End GoToXY.asm	
; ==================================================================
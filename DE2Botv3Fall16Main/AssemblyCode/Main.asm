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


; End Main.asm
; ==================================================================


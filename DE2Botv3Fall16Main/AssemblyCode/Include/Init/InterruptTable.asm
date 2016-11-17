; This code uses the timer interrupt for the control code.
	ORG 0                  ; Jump table is located in mem 0-4
	JUMP   Init        ; Reset vector
	RETI               ; Sonar interrupt (unused)
	JUMP   CTimer_ISR  ; Timer interrupt
	RETI               ; UART interrupt (unused)
	RETI               ; Motor stall interrupt (unused)

	
; End InterruptTable.asm
; ==================================================================


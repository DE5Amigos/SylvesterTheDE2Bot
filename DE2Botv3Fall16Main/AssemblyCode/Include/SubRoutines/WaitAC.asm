; ==================================================================
; WaitAC
;
; @brief 	Wait the number of counts in AC.
; @author 	Kevin Johnson
;
; ==================================================================

WaitAC:
	STORE  WaitTime
	OUT    Timer
WACLoop:
	IN     Timer
	OUT    XLEDS       ; User-feedback that a pause is occurring.
	SUB    WaitTime
	JNEG   WACLoop
	RETURN
	WaitTime: DW 0     ; "local" variable.


; End WaitAC.asm
; ==================================================================


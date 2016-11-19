; ==================================================================
; Wait1
;
; @brief 		Subroutine to wait (block) for 1 second
;
; @author 		Kevin Johnson (?)
; ==================================================================

Wait1:
	OUT    TIMER
Wloop:
	IN     TIMER
	OUT    XLEDS       ; User-feedback that a pause is occurring.
	ADDI   -10         ; 1 second at 10Hz.
	JNEG   Wloop
	RETURN


; End Wait1.asm
; ==================================================================


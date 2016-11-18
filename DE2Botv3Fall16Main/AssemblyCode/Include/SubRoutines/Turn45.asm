; ==================================================================
; Turn45
;
; @brief 	Turn the DE2 Bot 45 degrees.
; @author 	George Tang
;
; ==================================================================

Turn45:
	LOADI  	0
	STORE  	DVel       ; desired forward velocity
	LOADI  	45
	STORE 	DTheta
	IN 		Theta
	OUT 	SSEG1
	ADDI 	-40
	JNEG 	Turn45
	
	return


; End Turn45.asm
; ==================================================================


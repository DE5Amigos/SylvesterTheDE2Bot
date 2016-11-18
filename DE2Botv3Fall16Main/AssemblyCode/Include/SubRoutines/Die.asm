; ==================================================================
; Die
;
; @description 		Sometimes it's useful to permanently stop execution.
; 					This will also catch the execution if it accidentally
; 					falls through from above.
; @author 			Kevin Johnson (?)
;
; ==================================================================

Die:
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


; End Die.asm
; ==================================================================


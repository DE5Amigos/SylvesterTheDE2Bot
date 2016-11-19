; ==================================================================
; SendPosn
;
; @brief 	Send the position of the robot over the serial port.
; @author 	Kevin Johnson
;
; ==================================================================


SendPosn:
	CALL   UARTNL      ; send a newline
	LOAD   AsciiX      ; send ascii 'X'
	CALL   UARTRAW
	IN     XPOS        ; send X coordinate
	CALL   UARTSEND2
	CALL   UARTNBSP    ; send a space
	LOAD   AsciiY      ; send ascii 'Y'
	CALL   UARTRAW
	IN     YPOS        ; send Y coordinate
	CALL   UARTSEND2
	RETURN
	AsciiX: DW &H581B  ; escaped 'X'
	AsciiY: DW &H591B  ; escaped 'Y'


; End SendPosn.asm
; ==================================================================


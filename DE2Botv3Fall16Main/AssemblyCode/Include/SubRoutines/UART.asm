; ==================================================================
; UART
;
; @brief 	Routines for talking to the UART.
; @author 	Kevin Johnson
;
; ==================================================================



; Subroutines to send AC value through the UART,
; Calling UARTSend2 will send both bytes of AC
; formatted for default base station code:
; [ AC(15..8) | AC(7..0)]
; Calling UARTSend1 will only send the low byte.
; Note that special characters such as \lf are
; escaped with the value 0x1B, thus the literal
; value 0x1B must be sent as 0x1B1B, should it occur.

UARTSend2:
	STORE  UARTTemp
	SHIFT  -8
	ADDI   -27   ; escape character
	JZERO  UEsc1
	ADDI   27
	OUT    UART_DAT
	JUMP   USend2
UEsc1:
	ADDI   27
	OUT    UART_DAT
	OUT    UART_DAT
USend2:
	LOAD   UARTTemp
UARTSend1:
	AND    LowByte
	ADDI   -27   ; escape character
	JZERO  UEsc2
	ADDI   27
	OUT    UART_DAT
	RETURN
UEsc2:
	ADDI   27
	OUT    UART_DAT
	OUT    UART_DAT
	RETURN
	UARTTemp: DW 0

; Subroutine to send a newline to the computer log
UARTNL:
	LOAD   NL
	OUT    UART_DAT
	SHIFT  -8
	OUT    UART_DAT
	RETURN
	NL: DW &H0A1B

; Subroutine to send a space to the computer log
UARTNBSP:
	LOAD   NBSP
	OUT    UART_DAT
	SHIFT  -8
	OUT    UART_DAT
	RETURN
	NBSP: DW &H201B

; Subroutine to clear the internal UART receive FIFO.
UARTClear:
	IN     UART_DAT
	JNEG   UARTClear
	RETURN

; Helper subroutine for sending raw values
UARTRAW:
	OUT    UART_DAT
	SHIFT  -8
	OUT    UART_DAT
	RETURN


; End UART.asm
; ==================================================================


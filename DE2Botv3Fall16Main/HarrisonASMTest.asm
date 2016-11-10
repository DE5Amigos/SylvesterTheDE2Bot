;
; ASM Test
; An assembly file to test the new instructions.
;
; Harrison Statham
;

org 0

Main:
	
	load 	ONE
	movr 	r1, r0
	
	
	

	
zero: DW &H00



;***************************************************************
; Register Specific Constants
;***************************************************************

r0: 	EQU 	&H00
r1: 	EQU 	&H01
r2: 	EQU 	&H02
r3: 	EQU 	&H03
r4: 	EQU 	&H04
r5: 	EQU 	&H05
r6: 	EQU 	&H06
r7: 	EQU 	&H07
r8: 	EQU 	&H08
r9: 	EQU 	&H09
r10: 	EQU 	&H0A
r11: 	EQU 	&H0B
r12: 	EQU 	&H0C
r13: 	EQU 	&H0D
r14: 	EQU 	&H0E
r15: 	EQU 	&H0F
r16: 	EQU 	&H10
r17: 	EQU 	&H11
r18: 	EQU 	&H12
r19: 	EQU 	&H13
r20: 	EQU 	&H14
r21: 	EQU 	&H15
r22: 	EQU 	&H16
r23: 	EQU 	&H17
r24: 	EQU 	&H18
r25: 	EQU 	&H19
r26: 	EQU 	&H1A
r27: 	EQU 	&H1B
r28: 	EQU 	&H1C
r29: 	EQU 	&H1D
r30: 	EQU 	&H1E
r31: 	EQU 	&H1F


;***************************************************************
;* IO address space map
;***************************************************************
SWITCHES: EQU &H00  ; slide switches
LEDS:     EQU &H01  ; red LEDs
TIMER:    EQU &H02  ; timer, usually running at 10 Hz
XIO:      EQU &H03  ; pushbuttons and some misc. inputs
SSEG1:    EQU &H04  ; seven-segment display (4-digits only)
SSEG2:    EQU &H05  ; seven-segment display (4-digits only)
LCD:      EQU &H06  ; primitive 4-digit LCD display
XLEDS:    EQU &H07  ; Green LEDs (and Red LED16+17)
BEEP:     EQU &H0A  ; Control the beep
CTIMER:   EQU &H0C  ; Configurable timer for interrupts
LPOS:     EQU &H80  ; left wheel encoder position (read only)
LVEL:     EQU &H82  ; current left wheel velocity (read only)
LVELCMD:  EQU &H83  ; left wheel velocity command (write only)
RPOS:     EQU &H88  ; same values for right wheel...
RVEL:     EQU &H8A  ; ...
RVELCMD:  EQU &H8B  ; ...
I2C_CMD:  EQU &H90  ; I2C module's CMD register,
I2C_DATA: EQU &H91  ; ... DATA register,
I2C_RDY:  EQU &H92  ; ... and BUSY register
UART_DAT: EQU &H98  ; UART data
UART_RDY: EQU &H98  ; UART status
SONAR:    EQU &HA0  ; base address for more than 16 registers....
DIST0:    EQU &HA8  ; the eight sonar distance readings
DIST1:    EQU &HA9  ; ...
DIST2:    EQU &HAA  ; ...
DIST3:    EQU &HAB  ; ...
DIST4:    EQU &HAC  ; ...
DIST5:    EQU &HAD  ; ...
DIST6:    EQU &HAE  ; ...
DIST7:    EQU &HAF  ; ...
SONALARM: EQU &HB0  ; Write alarm distance; read alarm register
SONARINT: EQU &HB1  ; Write mask for sonar interrupts
SONAREN:  EQU &HB2  ; register to control which sonars are enabled
XPOS:     EQU &HC0  ; Current X-position (read only)
YPOS:     EQU &HC1  ; Y-position
THETA:    EQU &HC2  ; Current rotational position of robot (0-359)
RESETPOS: EQU &HC3  ; write anything here to reset odometry to 0
RIN:      EQU &HC8
LIN:      EQU &HC9

;
; Binary Occupancy Grid Map
;
; The goal of this file is to implement a "rough" binary occupancy grid
; map in assembly language.
;
; Harrison Statham
;

Main:
	
	; This routine would be for testing purposes ONLY.
	; The routines would be called from the main routine.
	;
	

	
	
	
;***********************************************************
; Binary Occupancy Grid Map Routines
;
; We dont assume that these routines "know" where the BOGM
; is in memory, so the programmer will have to "pass" the
; base address to any routine that wants to work with the
; BOGM.
; 
;***********************************************************

;
; InitBOGM
;
; Initialize the BOGM. Thankfully, it will be initialized to 
; zero upon first startup. 
;
; We can do any setup stuff here.
;
InitBOGM:
	
	

	return	

	
;
; ClearBOGM
;
; Clear the values of the BOGM to zero.
; 
; Unfortunately, we will be looping through all the values
; and writing them to zero - not much else we can do...
; 
; Inputs:
;
; 	r4 	= 	Base address of the BOGM.
;

ClearBOGM:
	
	; If only, if only...
	; for(int i = 0; i < 96; i++) {
	; 	BOGM[i] = 0;
	; }
	
	subr 	r0, r0 		; Set the AC = 0.
	movr 	r8, r0 		; r8 = r0 (or zero). Use for zero.
	movr 	r9, r0 		; r9 = r0 (or zero). Use for counter variable.
	
	addi 	96 			; AC = 96. 
	movr 	r10, r0 	; r10 = 96. Use for comparison.
	
ClearBOGMLoop:
	cmp 	r8, r9 				; Is r8 < r9 ??. AC = -1 if r8 < r9.
	jzero 	ClearBOGMLoopDone 	; Jump to the end if we are done.
	jpos 	ClearBOGMLoopDone 
	
	; { // <loop body>
	
	; NOTE: r4 holds the base address of BOGM.
	addr 	r4, r9 		; Add the base address to the counter.
	movr 	r12, r0 	; Move the new address to r12.
	
	storer 	r12 		; This doesnt exist yet... Can we get around it??
	
	
	
	; }
	
ClearBOGMLoopDone:
	
	return	

;***********************************************************
; Binary Occupancy Grid Map
;
; Define the BOGM in memory. It is a matrix on paper, but
; just a chunk of memory on the computer.
;
; Define that memory here.
;
;***********************************************************

; Yeah, this sucks! We dont have a convienient way of defining a
; large chunk of memory using this assembler...
;
; Or at least not one that I know of.
;
; BOGM = 12*8 matrix. (12*8 = 96 total elements)
;
; In our program we can use BOGM0 as the base address of the array
; and calculate all of the addresses relative to that.
;
;

BOGM0: 		DW 	&H00
BOGM1: 		DW 	&H00
BOGM2: 		DW 	&H00
BOGM3: 		DW 	&H00
BOGM4: 		DW 	&H00
BOGM5: 		DW 	&H00
BOGM6: 		DW 	&H00
BOGM7: 		DW 	&H00
BOGM8: 		DW 	&H00
BOGM9: 		DW 	&H00
BOGM10: 	DW 	&H00
BOGM11: 	DW 	&H00
BOGM12: 	DW 	&H00
BOGM13: 	DW 	&H00
BOGM14: 	DW 	&H00
BOGM15: 	DW 	&H00
BOGM16: 	DW 	&H00
BOGM17: 	DW 	&H00
BOGM18: 	DW 	&H00
BOGM19: 	DW 	&H00
BOGM20: 	DW 	&H00
BOGM21: 	DW 	&H00
BOGM22: 	DW 	&H00
BOGM23: 	DW 	&H00
BOGM24: 	DW 	&H00
BOGM25: 	DW 	&H00
BOGM26: 	DW 	&H00
BOGM27: 	DW 	&H00
BOGM28: 	DW 	&H00
BOGM29: 	DW 	&H00
BOGM30: 	DW 	&H00
BOGM31: 	DW 	&H00
BOGM32: 	DW 	&H00
BOGM33: 	DW 	&H00
BOGM34: 	DW 	&H00
BOGM35: 	DW 	&H00
BOGM36: 	DW 	&H00
BOGM37: 	DW 	&H00
BOGM38: 	DW 	&H00
BOGM39: 	DW 	&H00
BOGM40: 	DW 	&H00
BOGM41: 	DW 	&H00
BOGM42: 	DW 	&H00
BOGM43: 	DW 	&H00
BOGM44: 	DW 	&H00
BOGM45: 	DW 	&H00
BOGM46: 	DW 	&H00
BOGM47: 	DW 	&H00
BOGM48: 	DW 	&H00
BOGM49: 	DW 	&H00
BOGM50: 	DW 	&H00
BOGM51: 	DW 	&H00
BOGM52: 	DW 	&H00
BOGM53: 	DW 	&H00
BOGM54: 	DW 	&H00
BOGM55: 	DW 	&H00
BOGM56: 	DW 	&H00
BOGM57: 	DW 	&H00
BOGM58: 	DW 	&H00
BOGM59: 	DW 	&H00
BOGM60: 	DW 	&H00
BOGM61: 	DW 	&H00
BOGM62: 	DW 	&H00
BOGM63: 	DW 	&H00
BOGM64: 	DW 	&H00
BOGM65: 	DW 	&H00
BOGM66: 	DW 	&H00
BOGM67: 	DW 	&H00
BOGM68: 	DW 	&H00
BOGM69: 	DW 	&H00
BOGM70: 	DW 	&H00
BOGM71: 	DW	&H00
BOGM72: 	DW 	&H00
BOGM73: 	DW 	&H00
BOGM74: 	DW 	&H00
BOGM75: 	DW 	&H00
BOGM76: 	DW 	&H00
BOGM77: 	DW 	&H00
BOGM78: 	DW 	&H00
BOGM79: 	DW 	&H00
BOGM80: 	DW 	&H00
BOGM81: 	DW 	&H00
BOGM82: 	DW 	&H00
BOGM83: 	DW 	&H00
BOGM84: 	DW 	&H00
BOGM85: 	DW 	&H00
BOGM86: 	DW 	&H00
BOGM87: 	DW 	&H00
BOGM88: 	DW 	&H00
BOGM89: 	DW 	&H00
BOGM90: 	DW 	&H00
BOGM91: 	DW 	&H00
BOGM92: 	DW 	&H00
BOGM93: 	DW 	&H00
BOGM94: 	DW 	&H00
BOGM95: 	DW 	&H00



;***************************************************************
; Register Specific Constants
;
; NOTE: Copy all of these to the bottom of your assembly code.
;		Using these makes your code more descriptive. 
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
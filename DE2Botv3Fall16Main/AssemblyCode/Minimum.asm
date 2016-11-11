;
; Minimum.asm
;
; Find the minimum of a set of values.
;



;
; MinimumOfTwo
;
; Find the minimum of two values.
;
; Inputs:
; 	
; r4 = Test value 1
; r5 = Test value 2
;
; Outputs:
;
; r2 = Min{r4, r5}

MinimumOfTwo:
	
	movr 	r2, r4 				; Assume r4 is min to start with.

	cmp 	r4, r5				; Is r4 < r5
	jneg 	MinimumOfTwoEnd 	; Jump to end if r4 is the min.
	movr 	r2, r5 				; Set r2 to r5 since that is min (or equal).

MinimumOfTwoEnd:
	return


;
; MinimumOfFour
;
; Find the minimum of four values.
;
; Inputs:
; 	
; r4 = Test value 1
; r5 = Test value 2
; r6 = Test value 3
; r7 = Test value 4
;
; Outputs:
;
; r2 = Min{r4, r5, r6, r7}

MinimumOfFour:
	
	; r2 = the minimum register.

	call 	MinimumOfTwo 	; Will place the min{r4, r5} in r2.

	movr 	r4, r2 			; Move the new min to the input r4.
	movr 	r5, r6 			; Move the next test value to input r5.

	call 	MinimumOfTwo 	; Will place min{r4, r5, r6} into r2.

	movr 	r4, r2
	movr 	r5, r7 

	call 	MinimumOfTwo 	; r2 will contain proper return value.
	
	return				; Finished



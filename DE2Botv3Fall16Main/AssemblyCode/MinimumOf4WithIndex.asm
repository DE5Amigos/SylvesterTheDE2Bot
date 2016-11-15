;
; Minimum of 4 Values with Index
;
; Return the Minimum of 4 values along with the corresponding index
; that the minimum came from.
;
; Harrison Statham
;


;
; r4 = input 1
; r5 = input 2
; r6 = input 3
; r7 = input 4
;
; r2 = output 1
; r3 = output 2
;

MinimumOfFourWithIndex:
	
	; r4 and r5 are prepped for call to MinimumOfTwo.
	call 	MinimumOfTwo

	; Result is in r2.
	; Compare r4 to r2. If they are equal then r4 was the minimum, else r5 was.
	cmp 	r4, r2
	jzero 	MinimumOfFourWithIndexR4
	jump 	MinimumOfFourWithIndexR5

MinimumOfFourWithIndexR4:
	
	loadi 	1
	store 	MinimumOfFourWithIndexIndex
	jump 	MinimumOfFourWithIndexR5End

MinimumOfFourWithIndexR5:
	
	loadi 	2
	store 	MinimumOfFourWithIndexIndex

MinimumOfFourWithIndexR5End:
	

	; Now we have determined min{r4, r5} and we have the appropriate index.
	; Prepare for the next call.
	movr 	r4, r2
	movr 	r5, r6
	call 	MinimumOfTwo

	; Result is in r2.
	; Compare r4 to r2. If they are equal then r4 was the minimum, else r5 was.
	cmp 	r4, r2
	jzero 	MinimumOfFourWithIndexR4R5
	jump 	MinimumOfFourWithIndexR6


MinimumOfFourWithIndexR4R5:
	
	jump 	MinimumOfFourWithIndexR6End

MinimumOfFourWithIndexR6:
	
	loadi 	3
	store 	MinimumOfFourWithIndexIndex

MinimumOfFourWithIndexR6End:


	; Now we have determined min{r4, r5, r6} and we have the appropriate index.
	; Prepare for the next call.
	movr 	r4, r2
	movr 	r5, r7
	call 	MinimumOfTwo

	; Result is in r2.
	; Compare r4 to r2. If they are equal then r4 was the minimum, else r5 was.
	cmp 	r4, r2
	jzero 	MinimumOfFourWithIndexR4R5R6
	jump 	MinimumOfFourWithIndexR7


MinimumOfFourWithIndexR4R5R6:
	; Do nothing since the index of the min hasnt changed.
	jump 	MinimumOfFourWithIndexEnd

MinimumOfFourWithIndexR7:
	
	loadi 	4
	store 	MinimumOfFourWithIndexIndex

MinimumOfFourWithIndexEnd:

	return

MinimumOfFourWithIndexIndex: 	DW 	&H00








MinimumOfTwo:
	
	movr 	r2, r4 				; Assume r4 is min to start with.

	cmp 	r4, r5				; Is r4 < r5
	jneg 	MinimumOfTwoEnd 	; Jump to end if r4 is the min.
	movr 	r2, r5 				; Set r2 to r5 since that is min (or equal).

MinimumOfTwoEnd:
	return
;
; DoWhile Example Code
; 
; 
; Harrison Statham
;
;

Main:
	
	; do {
	;
	; 	<loop body> 
	;
	;} while(i < sentinel); 

	addi 	0
	movr 	r1, r0

	addi 	sentinel
	movr 	r2, r0

	DoWhile:

		; <loop body>

		; Check condition
		cmp 	r1, r2 		; Is r1 < r2
		jzero 	DoWhileEnd
		jpos 	DoWhileEnd

		; Prepare for next iteration of loop.
		movr 	r0, r1
		addi 	1
		movr 	r1, r0
		jump 	DoWhile

	DoWhileEnd:

	; Do something else....
	movr 	r0, r0
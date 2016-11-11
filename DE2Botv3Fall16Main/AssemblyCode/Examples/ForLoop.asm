;
; For Loop Example
;
; Harrison Statham


Main:
	
	; for(int i = 0; i < sentinel; i++) {
	; 	<loop body>	
	; }

	loadi 	0
	movr 	r1, r0 		; Move zero into r1. r1 = iteration variable.

	loadi 	sentinel 	; Load the sentinel value into the AC.
	movr 	r2, r0 		; Move the sentinel into r2

	ForLoop:

		cmp 	r1, r2 	; Is r1 < r2
		jzero 	ForLoopEnd
		jpos 	ForLoopEnd

		;{ <loop body>



		;}

		; Prepare for next iteration
		movr 	r0, r1
		addi 	1
		movr 	r1, r0 	; Not the prettiest way to increment.


	ForLoopEnd:

	; Do something else....
	movr r0, r0
	

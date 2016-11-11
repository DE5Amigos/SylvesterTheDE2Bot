;
; Array Example in ASM
;
; Harrison Statham
;

Main:
	
	; Writing to an array.

	loadi 	MyArray 	; Load the base address into r0.
	addi 	4 			; The fifth element.

	store 	MyArrayPtr 	; Store the address to the pointer.

	loadi 	100 		; The value we want to write to MyArray[4]
	istore 	MyArrayPtr 	; Write the value to the memory location pointed to by
						; the pointer.


	; Reading from an array.
	loadi 	MyArray 	; Load the base address into r0.
	addi 	4 			; The fifth element.

	store 	MyArrayPtr 	; Store the address to the pointer.

	iload 	MyArrayPtr 	; Get the value at that pointer and store in r0.

	; Do something with the value.

	jump 	Main


; You need one pointer per array you create.
MyArrayPtr: 		DW 	&H00
MyOtherArrayPtr: 	DW 	&H00

; An array of 5 elements.
; Nothing really special here.
MyArray: 	
	DW 	&H00
	DW 	&H00
	DW 	&H00
	Dw 	&H00
	DW 	&H00


; Another array of 5 elements.
; There is no difference between the two options
; However the above example is a little cleaner.
MyOtherArray0: 	DW 	&H00
MyOtherArray1: 	DW 	&H00
MyOtherArray2: 	DW 	&H00
MyOtherArray3: 	DW 	&H00
MyOtherArray4: 	DW 	&H00

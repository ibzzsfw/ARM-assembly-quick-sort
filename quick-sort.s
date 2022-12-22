; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; +								+
; +		Register usage					+
; +								+
; +		R0 : Array A[left...right]			+
; +		R1 : left index					+
; +		R2 : right index				+
; +		R3 : pivot value				+
; +		R4 : A[i]					+
; +		R5 : A[j]					+
; +		R6 : A[right]					+
; +		R7 : - 						+
; +		R8 : -						+
; +		R9 : Bottom stack R10				+
; +		R10: Parameter stack				+
; +		R11: i						+
; +		R12: j						+
; +		R13: -						+
; +		LR : -						+
; +		PC : -						+
; +								+
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

				
ARRAY		DCD		85, 22, 79, 20, 1, 28, 45, 20, 6, 19, 94, 62, 38, 8, 50, 5, 13, 49, 57, 93
		ADR		R0, ARRAY
		;		use in-place swap (inside the register. so, we do not want top index pointer in this case).
		;		parameter of stack filled with initial end point, default LEFT and default RIGHT.


STACK		DCD		19, 0					; <--- CHANGE <LENGHT - 1>
		ADR		R10, STACK		
		MOV		R9, R10					; store initial address
		ADD		R10, R10, #4				; point at latest element


QUICKSORT       ; (ARR, LEFT, RIGHT) => none return

		LDR		R1, [R10]				; LOAD LEFT
		SUB		R10, R10, #4
		LDR		R2, [R10]				; LOAD RIGHT
		SUB		R10, R10, #4
		CMP		R1, R2					; LEFT < RIGHT ?
		BGE		END_QUICKSORT				; if NOT EXPECTED case
					
		B		PARTITION				; Partition

				
AFTER_PARTITION
		;		set up to operate quick sort RHS of PIVOT
		;		Note that we push RIGHT end point before LEFT end point
		;		because of STACK structure; LIFO.
		LDR		R11, [R10]				; POP PIVOT index
		SUB		R10, R10, #4
		;		RHS: QSORT(ARR, PIVOT + 1, RIGHT)
		ADD		R10, R10, #4
		STR		R2, [R10]				; PUSH RIGHT
		ADD		R11, R11, #1				; PIVOT++
		ADD		R10, R10, #4
		STR		R11, [R10]				; PUSH PIVOT + 1
		;		LHS: QSORT(ARR, LEFT, PIVOT - 1)
		SUB		R11, R11, #2 				; +1 -> -1 ==> -2
		ADD		R10, R10, #4
		STR		R11, [R10] 				; PUSH PIVOT - 1
		ADD		R10, R10, #4
		STR		R1, [R10] 				; PUSH LEFT

		B		QUICKSORT				; perform Quick Sort


END_QUICKSORT

		CMP		R10, R9 				; is parameter stack empty ?
		;		Note that empty means stack address turn into initial.
		;		jump to sort if STACK is not empty
		BGE		QUICKSORT

		END							; stop emulator
				

PARTITION			;   = (ARR, LEFT, RIGHT) => j
				
		LDR		R3, [R0, R2, LSL #2] 			; PIVOT = ARR[RIGHT]
		MOV		R11, R1					; i = LEFT
		SUB		R11, R11, #1 				; i = LEFT - 1
		MOV		R12, R1					; j = LEFT

				
ITERATE
				
		CMP		R12, R2					; j < RIGHT ?
		BGE		RETURN					; if FALSE
		;		if current element is smaller than the pivot,
		;		swap the element with pivot
		LDR		R5, [R0, R12, LSL #2] 			; R5 = ARR[j]
		CMP		R5, R3					; ARR[j] < pivot ?
		BGE		INCREMENT					; if FALSE
		ADD		R11, R11, #1				; i++
		;		SWAP(ARR[i], ARR[j])
		LDR		R4, [R0, R11, LSL #2]
		STR		R4, [R0, R12, LSL #2]
		STR		R5, [R0, R11, LSL #2]
				

INCREMENT
					
		ADD		R12, R12, #1				; j++
		B		ITERATE					; back to top of FOR
				

RETURN
		
		ADD		R11, R11, #1				; i++ (prepare)
		;		SWAP(ARR[i+1], ARR[RIGHT])
		LDR		R4, [R0, R11, LSL #2]
		LDR		R6, [R0, R2 , LSL #2]
		STR		R6, [R0, R11, LSL #2]
		STR		R4, [R0, R2 , LSL #2]
		;		now we have the return value, PUSH in the STACK
		ADD		R10, R10, #4
		STR		R11, [R10]
		B		AFTER_PARTITION 			; back to QUICKSORT

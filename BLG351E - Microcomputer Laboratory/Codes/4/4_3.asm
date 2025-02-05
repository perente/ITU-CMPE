;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
			mov.b	#0d, P2SEL


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

				mov.w	#array_A, r4	; A
				mov.w	#array_B, r5	; B
				mov.w	#0, r6			; i
				mov.w	#4, r7			; N
				push	r4
				push 	r5
				push 	r6
				push 	r7
				call 	#dotProduct
				pop		r10
				jmp 	end

dotProduct		pop r15
				pop r7
				pop	r6
				pop r5
				pop	r4
recursive	    cmp r6, r7			; r6 -> i , r7 -> N , if r6 = r7
			    jeq base
			    mov @r4+, r8		; A[i]
			    mov @r5+, r9		; B[i]

				push r8

			    push r8
			    push r9
			    call #Multiply

			    pop r9

			    pop r8


			    push r9
			    inc r6


				push 	r15

			    push	r4
				push 	r5
				push 	r6
				push 	r7

			    call #dotProduct
			    pop	r10

			    pop r15

			    pop	r9
			    add r9, r10
			    push r10
			    push r15
			    ret

base			mov.w #0, r10
				push r10
				push r15
				ret

end				jmp end



Add 		pop r8
			pop r6
		    pop r5
		    add r6, r5
		    push r5
		    push r8
		    ret

Multiply    pop r9
			pop r6						; multiplier
		    pop r5	   					; multiplicand
			mov #0, r4                 	; result
loop1	    cmp #0, r6
		    jeq end1
		    push r6
		    push r5
		    push r4                    	; previous result
		    push r5                    	; multiplicand
		    call #Add
		    pop r4
		    pop r5
		    pop r6                   	; result from addition
		    dec r6
		    jmp loop1
end1	    push r4                    	; final result
			push r9
		    ret



			.data
array_A			.word 15, 3, 7, 5
array_B			.word 2, 1, 7, 3
                                            

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            

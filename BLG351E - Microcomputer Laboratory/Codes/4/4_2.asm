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


			mov.w #9, r5
			mov.w #4, r6

			push r5
			push r6

			;call #Add
			;call #Subtract
			;call #Multiply
			call #Divide
			pop r7
			jmp end


Add 		pop r8
			pop r6
		    pop r5
		    add r6, r5
		    push r5
		    push r8
		    ret

Subtract	pop r8
			pop r6
		    pop r5
		    sub r6, r5
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


Divide		pop r9
			pop r6						; divisor
		    pop r5						; dividend
			mov #0, r4                 	; result
loop2		cmp r6, r5                 	; if r5 < r6
		    jl end2
		    push r6
		    push r5
		    push r6
		    call #Subtract
		    pop	r5
		    pop r6
			inc r4
		    jmp loop2
end2	    push r4      				; final result
		    push r9
		    ret

end			jmp end

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
            

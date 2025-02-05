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

			mov.b #11111111b, &P1DIR
			mov.b #11111111b, &P1OUT

			mov.b #11111111b, &P2DIR
			mov.b #00000100b, &P2OUT
			mov #lastElement,r7


start		mov #array,r6

count_loop  mov.b @r6,&P1OUT
			call #delay
			inc r6

			cmp r6,r7
			jeq start


			jmp count_loop


delay 		mov.w #0Ah , R14
L2			mov.w #07A00h , R15
L1			dec.w R15 ; Decrement R15
			jnz L1
			dec.w R14
			jnz L2
			ret


	.data


;array .byte 00000001b
array .byte 00111111b,00000110b,01011011b,01001111b,01100110b,01101101b,01111101b,00000111b,01111111b,01101111b
lastElement

;array .byte 00000110b,01001111b,01101101b,00000111b,01101111b

;array .byte 00111111b,01011011b,01100110b,01111101b,01111111b



end


                                            

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
            

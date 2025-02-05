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
initINT bis.b #040h , &P2IE
        and.b #0BFh , &P2SEL
        and.b #0BFh , &P2SEL2
        bis.b #040h , &P2IES
        clr &P2IFG
        eint
        mov.b #11111111b, &P1DIR
        mov.b #00001111b, &P2DIR
        mov.b #11110010b, &P2OUT







start   mov.b #00000001b,r6
        mov #array_even, R4
        mov #array_odd, R5
        mov #lastElement_even , r8
        mov #lastElement_odd , r9




loop    and.b #00000001b, r6
        cmp #00000001b,r6
        jeq odd
        jmp even

even    mov.b @r4 , &P1OUT
        call #delay
        inc r4
        cmp r4,r8
        jne loop
        mov #array_even, R4
        jmp loop


odd     mov.b @r5 , &P1OUT
        call #delay
        inc r5
        cmp r5,r9
        jne loop
        mov #array_odd, R5
        jmp loop






delay 	mov.w #0Ah , R14
L2 		mov.w #07A00h , R15
L1 		dec.w R15 ; Decrement R15
		jnz L1
		dec.w R14
		jnz L2
		ret



ISR 	dint
		clr &P2IFG
	    inc R6
	    eint
	    reti

	.data

array_even .byte 00111111b,01011011b,01100110b,01111101b,01111111b
lastElement_even

array_odd .byte 00000110b,01001111b,01101101b,00000111b,01101111b
lastElement_odd



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
            .sect ".int03"
       		.short ISR



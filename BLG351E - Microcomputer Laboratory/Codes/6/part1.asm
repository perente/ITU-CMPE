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

	
;Mainloop
            mov.b #00001010b,r10
            mov.b #00000001b, r11       ;counter for digits
            mov.w #seconds,r5
            mov.w #centiseconds,r4
            mov.w #array,r12
            mov.b #11111111b, &P1DIR
            mov.b #00001111b, &P2DIR

            





loop

			cmp #00000001b,r11
            jeq first_digit

            cmp #00000010b,r11
            jeq second_digit

            cmp #00000100b,r11
            jeq third_digit

            cmp #00001000b,r11
            jeq forth_digit


first_digit     mov.b @r5,r6
                push r6
                push r10
                call #divide
                pop r6
                pop r7
				mov.b #00000000b,&P1OUT

                mov.b #11110001b, &P2OUT
                add.w r12,r6
                mov.b @r6,&P1OUT

                mov.b #00000010b, r11       ;counter for digits
                jmp loop

second_digit    mov.b @r5,r6
                push r6
                push r10
                call #divide
                pop r6
                pop r7
				mov.b #00000000b,&P1OUT

                mov.b #11110010b, &P2OUT
                add.w r12,r7
                mov.b @r7,&P1OUT

                ;bis.b #10000000b, &P1OUT    ;nokta icin


                mov.b #00000100b, r11       ;counter for digits
                jmp loop

third_digit     mov.b @r4,r6
                push r6
                push r10
                call #divide
                pop r6
                pop r7
				mov.b #00000000b,&P1OUT
                mov.b #11110100b, &P2OUT
                add.w r12,r6
                mov.b @r6,&P1OUT

                mov.b #00001000b, r11       ;counter for digits
                jmp loop

forth_digit     mov.b @r4,r6
                push r6
                push r10
                call #divide
                pop r6
                pop r7
				mov.b #00000000b,&P1OUT
                mov.b #11111000b, &P2OUT
                add.w r12,r7
                mov.b @r7,&P1OUT

                mov.b #00000001b, r11       ;counter for digits
                jmp loop




divide		pop r9
		    pop r15						; dividend
			pop r6						; divisor
			mov #0, r14                 	; result
loop2		cmp r15, r6                 	; if r5 < r6
		    jl end2
		    sub r15,r6
			inc r14
		    jmp loop2
end2	    push r6      				; reminder
            push r14                     ; final result
		    push r9                     ; address for ret
		    ret
end






        .data
seconds         .byte 0Ch
centiseconds    .byte 22h

array .byte 00111111b,00000110b,01011011b,01001111b,01100110b,01101101b,01111101b,00000111b,01111111b,01101111b
lastElement
E

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

            
            

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

			bis.b #0E0h , &P2IE
            and.b #01Fh , &P2SEL
            and.b #01Fh , &P2SEL2
            bis.b #0E0h , &P2IES
            clr &P2IFG
            eint
;Mainloop
            mov.b #00001010b,r10
            mov.b #00000001b, r11       ;counter for digits
            mov.w #seconds,r5
            mov.w #centiseconds,r4
            mov.w #array,r12
            mov.b #11111111b, &P1DIR
            mov.b #00001111b, &P2DIR

            mov.w #0292h,&TA0CTL

            mov.w #0A3D7h, &TA0CCR0
            mov.w #04010h,&TA0CCTL0





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

TISR
		dint
		clr &TAIFG
		mov.w #0292h,&TA0CTL

		mov.b @r4, r13
		add #10d, r13
		cmp.w #100d,r13
		jeq sifirla


		mov.b r13, 0(r4)
		jmp enddd

sifirla
		mov.b #0d, 0(r4)
		mov.b @r5, r13
		inc.b r13
		mov.b r13, 0(r5)


enddd	mov.w #04010h,&TA0CCTL0
	    eint
	    reti


ISR_start 	dint

			;jmp stop
			and.b #01110000b,&P2IFG
			cmp #01000000b,&P2IFG
			jeq start

			cmp #00100000b,&P2IFG
			jeq stop

			cmp #00010000b,&P2IFG
			jeq res

			jmp end10

start		mov.w #0292h,&TA0CTL
			jmp end10

stop		mov.w #0282h,&TA0CTL
			jmp end10


res 		mov.w #0286h,&TA0CTL
			jmp end10



end10
			clr &P2IFG

			eint
	    	reti


        .data
seconds         .byte 00h
centiseconds    .byte 00h

array .byte 00111111b,00000110b,01011011b,01001111b,01100110b,01101101b,01111101b,00000111b,01111111b,01101111b
lastElement


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

            .sect   ".int09"                ; MSP430 RESET Vector
            .short  TISR
            

			.sect   ".int03"
        	.short ISR_start


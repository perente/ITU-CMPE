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
                bis.b #020h , &P2IE
                and.b #0DFh , &P2SEL
                and.b #0DFh , &P2SEL2
                bis.b #020h , &P2IES
                clr &P2IFG
                eint

                mov.w #array,r12
                mov.b #11111111b, &P1DIR
                mov.b #00001111b, &P2DIR
                mov.b #00000001b, r13       ;counter for digits


                mov.w #0d,r11 	;display
                mov.w #5d, r8	;x
                mov.w #1d, r7	;w
                mov.w #10d,r10



mainloop        push.w r11
                push.w r10
                call #divide
                pop.w r4              ;result
                pop.w r5              ;reminder

                cmp #00000001b,r13
                jeq first_digit

                cmp #00000010b,r13
                jeq second_digit

                cmp #00000100b,r13
                jeq third_digit

                cmp #00001000b,r13
                jeq forth_digit

first_digit     mov.b #00000000b,&P1OUT

                mov.b #11110001b, &P2OUT

                mov.b #00000010b, r13       ;counter for digits
                jmp mainloop

second_digit    push.w r4
                push.w r10
                call #divide
                pop.w r4
                pop.w r5
				mov.b #00000000b,&P1OUT

                mov.b #11110010b, &P2OUT
                add.w r12,r4
                mov.b @r4,&P1OUT

                mov.b #00000100b, r13       ;counter for digits
                jmp mainloop

third_digit     push.w r4
                push.w r10
                call #divide
                pop.w r4
                pop.w r5
				mov.b #00000000b,&P1OUT
                mov.b #11110100b, &P2OUT
                add.w r12,r5
                mov.b @r5,&P1OUT

                mov.b #00001000b, r13       ;counter for digits
                jmp mainloop

forth_digit
				mov.b #00000000b,&P1OUT
                mov.b #11111000b, &P2OUT
                add.w r12,r5
                mov.b @r5,&P1OUT

                mov.b #00000001b, r13       ;counter for digits
                jmp mainloop








divide		    pop.w r9
                pop.w r15						; dividend
                pop.w r6						; divisor
                mov.w #0, r14                 	; result
loop2		    cmp.w r15, r6                 	; if r5 < r6
                jl end2
                sub.w r15,r6
                inc.w r14
                jmp loop2
end2	        push.w r6      				; reminder
                push.w r14                    ; final result
                push.w r9                     ; address for ret
                ret





multiply        pop.w r9
                pop.w r6
                pop.w r5
                mov.w #0d, r14
loop1           cmp.w #0,r6
                jeq end1
                mov.w #1d,r15
                and.w r6,r15
                cmp.w #0d,r15
                jeq after_add
                add.w r5,r14

after_add       rla.w r5
                rra.w r6
                jmp loop1
end1            push.w r14
                push.w r9
                ret





ISR_start   dint
            clr &P2IFG

            push.w r4         ;save r4
            push.w r5         ;save r5
            push.w r6         ;save r6

            ;push.w r7         ;save r7
            ;push.w r8         ;save r8
            push.w r9         ;save r9
            push.w r14        ;save r14
            push.w r15        ;save r15

            push.w r8
            push.w r8
            call #multiply
            pop.w r8          ;r6 = pow(r6,2)

            add.w #2d,r7 		; w+s
            add.w r7,r8 		; w+x
            mov.w r8,r9
            mov.w r8,r6

            rla.w r6
            rla.w r6
            rla.w r6
            rla.w r6

            rra.w r9
            rra.w r9
            rra.w r9
            rra.w r9



            bis.w r6,r9
            mov.w r9,r11
			push.w r9
			push.w r6


            push.w r11
            mov.w #128d,r4
            push.w r4
            call #divide
            pop.w r11
            pop.w r11

            pop.w r6
            pop.w r9








            pop.w r15        ;save r15
            pop.w r14        ;save r14
            pop.w r9         ;save r9
            ;pop.w r8         ;save r8
            ;pop.w r7         ;save r7
            pop.w r6         ;save r6
            pop.w r5         ;save r5
            pop.w r4         ;save r4
            eint
            reti


end 		jmp end



        .data
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
            
			.sect   ".int03"
        	.short ISR_start
            ;.sect   ".int09"                ; MSP430 RESET Vector
            ;.short  TISR


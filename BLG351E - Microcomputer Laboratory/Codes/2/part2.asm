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

       	mov.b		#00000000b,&P1DIR
		mov.b		#11111111b,&P2DIR

		mov.b		#00000000b,&P1IN
		mov.b		#00000100b,&P2OUT


loop1	mov.b		#00010000b,r4
		and.b		&P1IN,r4
		cmp.b		#0, R4
		jne			sw
		jeq			loop1


sw 		mov.b		#0000100b,r4
		and.b		&P2OUT,r4
		cmp.b		#0, R4
		jne			turnon1
		jmp 		turnon2

turnon1 mov.b 		#0001000b,&P2OUT
		mov.b		#1000,r15
sleep1	dec.w		r15
		jnz 		sleep1
		jmp loop2

turnon2 mov.b 		#0000100b,&P2OUT
		mov.b		#1000,r15
sleep2	dec.w		r15
		jnz 		sleep2
		jmp loop2

loop2 	mov.b		#00010000b,r4
		and.b		&P1IN,r4
		cmp.b		#0, R4
		jeq			loop1
		jmp			loop2


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
            

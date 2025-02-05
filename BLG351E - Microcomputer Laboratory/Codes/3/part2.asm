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


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

				mov.w   #hash, R10
				mov.w   #i1, R4
				mov.w   @R4, R5
				CALL    remainder
				CALL    insert

				mov.w   #i2, R4
				mov.w   @R4, R5
				CALL    remainder
				CALL    insert

				mov.w   #i3, R4
				mov.w   @R4, R5		; R5 stores ID value
				CALL    remainder
				CALL    insert
				JMP		end



insert			mov.w	R14, R8
				add.w	R10, R8			; location of ID
check			mov.w	@R8, R9
				cmp.w	#0, R9
				jeq		store
				add.w   #1, R8
				MOV.W	#58, R15
				ADD.W	#hash, R15
				CMP.w 	R15, R8
				jl	 	check

store			mov.w	@R8, R9
				mov.w	R5, R9
				ret


; FUNCTION IN THE PREVIOUS PART IS USED TO CALCULATE THE REMAINDER

remainder		mov.w   R5, R14      ; R14 stores D
		        mov.w   #29, R11     ; R11 stores C
		        mov.w   R5, R12     ; LOAD VALUE OF A INTO R12
		        mov.w   #29, R13     ; LOAD VALUE OF B INTO R13


        		RRA.w   R12          ; A/2
loop1   		CMP.w   R12, R11      ; if c<a/2
		        JGE     loop2
		        RLA.w   R11          ; C*2
		        JMP     loop1

loop2   		CMP.w   R14, R13      ; if B > D
		        JGE     returnRemainder
		        CMP.w   R14, R11     ; if C>D
		        JGE     divC
		        SUB.w   R11,R14       ; d-c
divC    		RRA.w   R11          ; C/2
        		JMP     loop2

returnRemainder	RET


end	        	JMP     end






           	.data
hash:	    	.space 58
i1:			.word 150
i2:			.word 210
i3:			.word 053



                                            

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
            

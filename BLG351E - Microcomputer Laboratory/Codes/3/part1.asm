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


        mov.w   #A , R4
        mov.w   #B , R5
        mov.w   @R4, R6     ; R6 stores D
        mov.w   @R5, R7     ; R7 stores C
        mov.w   @R4, R8     ; LOAD VALUE OF A INTO r8
        mov.w   @R5, R9     ; LOAD VALUE OF B INTO r9

        RRA.w   R8          ; A/2
loop1   CMP.w   R8, R7      ; if c<a/2
        JGE     loop2
        RLA.w   R7          ; C*2
        JMP     loop1

loop2   CMP.w   R6, R9      ; if B > D
        JGE     end
        CMP.w   R6, R7     ; if C>D
        JGE     divC
        SUB.w   r7,r6       ; d-c
divC    RRA.w   R7          ; C/2
        JMP     loop2

end     JMP     end

        .data
A:       .word 120
B:       .word 7

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
            

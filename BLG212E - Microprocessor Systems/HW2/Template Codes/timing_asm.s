        AREA    Timing_Code, CODE, READONLY
        ALIGN
        THUMB
        EXPORT  Systick_Start_asm
        EXPORT  Systick_Stop_asm
		EXPORT	SysTick_Handler 
		EXTERN	ticks

SysTick_Handler FUNCTION
		PUSH	{LR}
		
		LDR 	R0, =ticks	; load address of ticks
		LDR 	R1, [R0]	; load the value stored at the address of ticks
		ADDS 	R1, #1	; increment it by one, ticks++
		STR 	R1, [R0] ; store value in R0 after increment
		
		POP		{PC}
		ENDFUNC

Systick_Start_asm FUNCTION
		PUSH	{LR}
		
		LDR		R0, =ticks	; load address of ticks
		MOVS 	R1, #0	; holds zero
		STR 	R1, [R0]	; store 0 in R0, ticks = 0
		LDR 	R0, =0xE000E014	; load address of SysTick LOAD
		MOVS		R1, #249	; holds reload value as 249
								; LOAD =  (25 MHz / 100000) - 1 = 250 - 1 = 249
		STR 	R1, [R0]	; store reload value in R0
		LDR 	R0, =0xE000E018	; load address of SysTick VAL
		MOVS 	R1, #0		; holds zero
		STR 	R1, [R0]	; store zero in R0, SysTick->VAL = 0U		
		LDR 	R0, =0xE000E010	; load address of SysTick CTRL
		MOVS 	R1, #7	; holds seven
		STR 	R1, [R0]	; store seven in R0, CTRL_CLKSOURCE_Msk | CTRL_TICKINT_Msk | CTRL_ENABLE_Msk
							; 1 | 1 | 1 = 4 + 2 + 1 = 7 = 0x7

		POP		{PC}
		ENDFUNC

Systick_Stop_asm FUNCTION
		PUSH	{LR}
		
		LDR		R1, =0xE000E010	; load address of SysTick CTRL
		LDR		R0, [R1]	; load value of SysTick CTRL	
		MOVS	R2, #1	; holds 1
		LSLS	R2, R2, #31	; shift left 31 times to reach 0x80000000
		LSRS	R2, R2, #31	; shift right 31 times to reach 0xFFFFFFFE
		ANDS	R0, R0, R2	; perform anding to clear Enable bit, same as BIC operation,
							; since compiler says BIC is not supported by current instruction set
		STR 	R0, [R1]	; store cleared Enable bit in SysTick CTRL	
		LDR 	R2, =ticks	; load address of ticks
		LDR 	R0, [R2]	; load the value stored at the address of ticks
		LDR		R1, =ticks	; load address of ticks
		MOVS    R3, #0	; holds zero
		STR		R3, [R1]	; store zero into ticks to reset the timer
		
		POP		{PC}
		ENDFUNC

		END

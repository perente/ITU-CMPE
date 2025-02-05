; Function: ft_lstsort_asm
; Parameters:
;   R0 - Pointer to the list (address of t_list *)
;   R1 - Pointer to comparison function (address of int (*f_comp)(int, int))
        AREA    Sorting_Code, CODE, READONLY
        ALIGN
        THUMB
        EXPORT  ft_lstsort_asm
			
ft_lstsort_asm FUNCTION
		PUSH    {R0-R1,LR}
		
		LDR     R4, [SP]	; load address of head pointer from R1 which is on stack
		LDR     R5, [R4]	; load actual head, *lst
		LDR     R6, [SP, #4]	; load comparison function, f_comp which is on stack
		B		is_empty	; branch to function is_empty

first_loop
		MOVS    R3, #0	; initialize swap flag to zero
		MOV     R2, R4	; holds address of head pointer which is prev
		MOV     R7, R5	; holds head which is current node

second_loop
		LDR     R1, [R7, #4]	; load current's next
		CMP     R1, #0	; check if current's next is null
		BEQ     is_swapped	; if there is not next node, finish inner loop
		PUSH    {R1,R2,R3}	; pushes current's next, prev, and swap flag onto stack
		LDR     R0, [R7, #0] ; load value of current node
		LDR     R1, [SP, #0] ; load current's next which is on top of stack
		LDR     R1, [R1, #0] ; load value of next node
		BLX     R6	; call comparison function f_comp for current->num and next->num, result returns in R0
		POP     {R1,R2,R3}	; restore current's next, prev, and swap flag from stack
		CMP     R0, #0	; check result of comparison function
		BEQ     swap	; if result is zero, branch to swap function, 
		ADDS    R2, R7, #4	; update prev to point current->next, doing current + 4
		MOV     R7, R1	; set current to current's next
		B       second_loop	; branch to inner loop

swap
		LDR     R0, [R1, #4]	; load next's next
		STR     R0, [R7, #4]    ; set current->next to next's next
		STR     R7, [R1, #4]	; set next's next to current
		STR     R1, [R2]	; set prev to point next
		CMP     R2, R4	; check if prev points to head pointer
		BEQ     update_head	; branch to function update_head if equal
		
change_flag_and_node
		MOVS    R3, #1	; set swap flag to one
		ADDS    R2, R1, #4	; set prev to point next's next
		B       second_loop	; branch to function second_loop to repeat the inner loop, current does not change

update_head
		MOV     R5, R1	; set head pointer to next 
		B		change_flag_and_node	; branch to function change_flag_and_node

is_swapped
		CMP     R3, #0	; check swap flag to determine if swap occured
		BNE     first_loop	; branch to outer loop, if swap occured
		B		end	; if there is no swap function finishes

is_empty
		CMP     R5, #0	; check if head is null
		BEQ     end	; list is empty, so, function finishes
		LDR     R0, [R5, #4]	; load head's next
		CMP     R0, #0	; check if head's next is only node in list
		BNE		first_loop ; if not branch to outer loop, if it is it continues to end of function
		
end
		STR     R5, [R4]	; store updated head to its initial position 
		
		POP     {R0-R1,PC}
		ENDFUNC
		END
;***************************************************************************
;  PROGRAM:			MONCommands        
;  PURPOSE:			Subroutines for all monitor commands
;  ASSEMBLER:		TASM 3.2        
;  LICENCE:			The MIT Licence
;  AUTHOR :			MCook
;  CREATE DATE :	06 May 15
;***************************************************************************

;***************************************************************************
;HELP_COMMAND
;Function: Print help dialogue box
;***************************************************************************
HELP_MSG_1: .BYTE "ZMC80 Monitor Command List\r\n",EOS
HELP_MSG_2: .BYTE "? - view command list\r\n",EOS
HELP_MSG_3: .BYTE "R - monitor reset\r\n",EOS
HELP_MSG_4: .BYTE "C - clear screen\r\n",EOS
HELP_MSG_5: .BYTE "D - print $80 bytes from specified location\r\n",EOS

HELP_COMMAND:
			LD 		HL,HELP_MSG_1		;Print some messages
			CALL    PRINT_STRING		
			LD 		HL,HELP_MSG_2		
			CALL    PRINT_STRING			
			LD 		HL,HELP_MSG_3		
			CALL    PRINT_STRING
			LD 		HL,HELP_MSG_4		
			CALL    PRINT_STRING
			LD 		HL,HELP_MSG_5		
			CALL    PRINT_STRING
			LD		A,$FF				;Load $FF into Acc so MON_COMMAND finishes
			RET

;***************************************************************************
;MEMORY_DUMP_COMMAND
;Function: Print $80 databytes from specified location
;***************************************************************************
MDC_1: .BYTE "Memory Dump Command\r\n",EOS
MDC_2: .BYTE "Location to start in 4 digit HEX:",EOS
MDC_3: .BYTE "     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F\r\n",EOS

MEMORY_DUMP_COMMAND:
			LD 		HL,MDC_1			;Print some messages 
			CALL    PRINT_STRING
			LD 		HL,MDC_2	
			CALL    PRINT_STRING
			CALL    GET_HEX_WORD		;HL now points to databyte location	
			PUSH	HL					;Save HL that holds databyte location on stack
			CALL    PRINT_NEW_LINE		;Print some messages
			CALL    PRINT_NEW_LINE
			LD 		HL,MDC_3	
			CALL    PRINT_STRING
			CALL    PRINT_NEW_LINE
			POP		HL					;Restore HL that holds databyte location on stack
			LD		C,10				;Register C holds counter of dump lines to print
MEMORY_DUMP_LINE:	
			LD		B,16				;Register B holds counter of dump bytes to print
			CALL	PRINT_HEX_WORD		;Print dump line address in hex form
			LD		A,' '				;Print spacer
			CALL	PRINT_CHAR
			DEC		C					;Decrement C to keep track of number of lines printed
MEMORY_DUMP_BYTES:
			LD		A,(HL)				;Load Acc with databyte HL points to
			CALL	PRINT_HEX_BYTE		;Print databyte in HEX form 
			LD		A,' '				;Print spacer
			CALL	PRINT_CHAR	
			INC 	HL					;Increase HL to next address pointer
			DJNZ	MEMORY_DUMP_BYTES	;Print 16 bytes out since B holds 16
			LD		B,C					;Load B with C to keep track of number of lines printed
			CALL    PRINT_NEW_LINE		;Get ready for next dump line
			DJNZ	MEMORY_DUMP_LINE	;Print 10 line out since C holds 10 and we load B with C
			LD		A,$FF				;Load $FF into Acc so MON_COMMAND finishes
			RET
			
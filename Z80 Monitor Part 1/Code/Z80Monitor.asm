;***************************************************************************
;  PROGRAM:			Z80 Monitor        
;  PURPOSE:			ROM Monitor Program
;  ASSEMBLER:		TASM 3.2        
;  LICENCE:			The MIT Licence
;  AUTHOR :			MCook
;  CREATE DATE :	05 May 15
;***************************************************************************

ROM_BOTTOM:  .EQU    $0000				;Bottom address of ROM
ROM_TOP:     .EQU    $07FF				;Top address of ROM
RAM_BOTTOM:  .EQU    $8000   			;Bottom address of RAM
RAM_TOP:     .EQU    $87FF				;Top address of RAM	

EOS:         .EQU    $FF            	;End of string

.ORG $0000

START:
			DI							;Disable interrupts
			JP 		MAIN  				;Jump to the MAIN routine
			
.ORG $0038

INT_CATCH:
			JP 		INT_CATCH			;INF loop to catch interrupts (not enabled)
			
.ORG $0066

NMI_CATCH:
			JP		NMI_CATCH			;INF loop to catch interrupts (not enabled)
			
.ORG $0100
;***************************************************************************
;MAIN
;Function: Entrance to user program
;***************************************************************************
MAIN:
			LD		SP,RAM_TOP			;Load the stack pointer for stack operations.
			CALL	UART_INIT			;Initialize UART
			CALL	PRINT_MON_HDR		;Print the monitor header info
			CALL    MON_PROMPT_LOOP		;Monitor user prompt loop
			HALT

;***************************************************************************
;CLEAR_SCREEN
;Function: Clears terminal screen
;***************************************************************************
MON_CLS: .BYTE "\f",EOS  				;Escape sequence for CLS. (aka form feed) 
		
CLEAR_SCREEN:		
			LD 		HL,MON_CLS			
			CALL    PRINT_STRING
			RET			
			
;***************************************************************************
;RESET_COMMAND
;Function: Software Reset to $0000
;***************************************************************************
RESET_COMMAND:
			JP		START				;Jumps to $0000 (reset)	
			
;***************************************************************************
;PRINT_MON_HDR
;Function: Print out program header info
;***************************************************************************
MON_MSG: .BYTE "\r\nZMC80 Computer\t\t2015 MCook\r\n\r\n",EOS
MON_VER: .BYTE "ROM Monitor v0.1\r\n\r\n",EOS
MON_HLP: .BYTE "\t Input ? for command list\r\n",EOS

PRINT_MON_HDR:
			CALL	CLEAR_SCREEN		;Clear the terminal screen
			LD 		HL,MON_MSG			;Print some messages
			CALL    PRINT_STRING	
			LD 		HL,MON_VER
			CALL    PRINT_STRING
			LD 		HL,MON_HLP
			CALL    PRINT_STRING
			RET
			
;***************************************************************************
;MON_PROMPT
;Function: Prompt user for input
;***************************************************************************			
MON_PROMPT: .BYTE ">",EOS

MON_PROMPT_LOOP:
			LD 		HL,MON_PROMPT		;Print monitor prompt
			CALL    PRINT_STRING		
			CALL	GET_CHAR			;Get a character from user into Acc
			CALL 	PRINT_CHAR
			CALL    PRINT_NEW_LINE		;Print a new line
			CALL	MON_COMMAND			;Respond to user input
			CALL 	PRINT_NEW_LINE		;Print a new line	
			JP		MON_PROMPT_LOOP

;***************************************************************************
;MON_COMMAND
;Function: User input in accumulator to respond to 
;***************************************************************************
MON_COMMAND:
			CP		'?'					
			CALL  	Z,HELP_COMMAND
			CP		'D'
			CALL  	Z,MEMORY_DUMP_COMMAND
			CP		'C'
			CALL  	Z,CLEAR_SCREEN
			CP		'R'
			CALL	Z,RESET_COMMAND
			RET
			
#INCLUDE	"UARTDriver.asm"
#INCLUDE	"MONCommands.asm"
#INCLUDE	"CONIO.asm"

.END
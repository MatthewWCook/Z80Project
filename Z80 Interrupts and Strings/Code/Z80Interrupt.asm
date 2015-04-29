;***************************************************************************
;  PROGRAM:			Z80 Mode 1 Interrupts        
;  PURPOSE:			Tests that mode 1 interrupts function properly
;  ASSEMBLER:		TASM 3.2        
;  LICENCE:			The MIT Licence
;  AUTHOR :			MCook
;  CREATE DATE :	27 Apr 15
;***************************************************************************

;ROM : 0000H - > 07FFH
;RAM : 8000H - > 87FFH 

UART0:       .EQU    $00            ; DATA IN/OUT
UART1:       .EQU    $01            ; CHECK RX
UART2:       .EQU    $02            ; INTERRUPTS
UART3:       .EQU    $03            ; LINE CONTROL
UART4:       .EQU    $04            ; MODEM CONTROL
UART5:       .EQU    $05            ; LINE STATUS
UART6:       .EQU    $06            ; MODEM STATUS
UART7:       .EQU    $07            ; SCRATCH REG.

RAMTOP:      .EQU    $87FF			; Top address of RAM
STR_TER:     .EQU	 $FF            ; Mark END OF TEXT
CHR_HLD:     .EQU    $8000			; GET_CHAR_UART holding location			


.ORG $0000

START:
			DI
			JP 		MAIN  			;Jump to the MAIN routine
			
.ORG $0038

MODE1_INTERRUPT:
			DI						;Disable interrupts
			EX		AF,AF'			;Save register states
			EXX        
			;Start interrupt routine
			CALL	UART_RX	
			CALL	UART_TX
			;End interrupt routine
			EXX						;Restore register states
			EX		AF,AF'			
			EI   					;Enable interrupts	 
			RET
			
.ORG $0066

NMI_CATCH:
			JP		NMI_CATCH
			
.ORG $0100

;***************************************************************************
;MAIN
;Function: Entrance to user program
;***************************************************************************

MAIN:
			LD		SP,RAMTOP
			CALL	INIT_UART
			CALL	PRINT_MON_HDR
			IM 		1				;Use interrupt mode 1
			EI 						;Enable interrupts
END_PROGRAM:
			HALT
			JP		END_PROGRAM
			
;***************************************************************************
;INIT_UART
;Function: Initialize the UART to BAUD Rate 9600 (1.8432 MHz clock input)
;***************************************************************************

INIT_UART:
            LD     A,$80			; Mask to Set DLAB Flag
			OUT    (UART3),A
			LD     A,12				; Divisor = 12 @ 9600bps w/ 1.8432 Mhz
			OUT    (UART0),A		; Set BAUD rate to 9600
			LD     A,00
			OUT    (UART1),A		; Set BAUD rate to 9600
			LD     A,$03
			OUT    (UART3),A		; Set 8-bit data, 1 stop bit, reset DLAB Flag
			LD	   A,$01
			OUT    (UART1),A		; Enable receive data available interrupt only
			RET
			
;***************************************************************************
;UART_TX_READY
;Function: Check if UART is ready to transmit
;***************************************************************************

UART_TX_RDY:
			PUSH 	AF
UART_TX_RDY_LP:			
			IN		A,(UART5)    	;Fetch the control register
			BIT 	5,A            	;Bit will be set if UART is ready to send
			JP		Z,UART_TX_RDY_LP		
			POP     AF
			RET
	
;***************************************************************************
;UART_TX
;Function: Transmit character in A to UART
;***************************************************************************

UART_TX:
			CALL  UART_TX_RDY
			OUT   (UART0),A
			RET
				
;***************************************************************************
;UART_RX_READY
;Function: Check if UART is ready to receive
;***************************************************************************

UART_RX_RDY:
			PUSH 	AF
UART_RX_RDY_LP:			
			IN		A,(UART5)    	;Fetch the control register
			BIT 	0,A             ;Bit will be set if UART is ready to receive
			JP		Z,UART_RX_RDY_LP		
			POP     AF
			RET
	
;***************************************************************************
;UART_RX
;Function: Receive character in UART to A
;***************************************************************************

UART_RX:
			CALL  UART_RX_RDY
			IN    A,(UART0)
			RET			
			
;***************************************************************************
;PRINT_MON_HDR
;Function: Print out program header info
;***************************************************************************

PRINT_LINE_1: .BYTE "ZMAC80 Computer\t\t2015 MCook\n\r",STR_TER
PRINT_LINE_2: .BYTE "ROM Monitor v0.1\n\r",STR_TER
PRINT_LINE_3: .BYTE "Function: Interrupt Test\n\r\n\r",STR_TER
PRINT_LINE_4: .BYTE ">",STR_TER

PRINT_MON_HDR:
			LD 		HL,PRINT_LINE_1		;Point HL to beginning of string
			CALL    PRINT_STRING		;Print the string
			LD 		HL,PRINT_LINE_2
			CALL    PRINT_STRING
			LD 		HL,PRINT_LINE_3
			CALL    PRINT_STRING
			LD 		HL,PRINT_LINE_4
			CALL    PRINT_STRING
			RET
			
;***************************************************************************
;PRINT_STRING
;Function: Print out string starting at MEM location (HL) to UART
;***************************************************************************

PRINT_STRING:
			 LD		A,(HL)
             CP     STR_TER             ; Test for end byte
             JP     Z,END_PRINT_STRING  ; Jump if end byte is found
			 CALL   UART_TX
             INC    HL                  ; Increment pointer to next char
             JP     PRINT_STRING    	; Transmit loop
END_PRINT_STRING:
			 RET


.END
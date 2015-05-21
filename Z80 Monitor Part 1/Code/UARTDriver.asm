;***************************************************************************
;  PROGRAM:			UARTDriver        
;  PURPOSE:			Subroutines for a 16550 UART
;  ASSEMBLER:		TASM 3.2        
;  LICENCE:			The MIT Licence
;  AUTHOR :			MCook
;  CREATE DATE :	06 May 15
;***************************************************************************

;The eight addresses that the 16550 resides in I/O space.
;Change to suit hardware.
UART0:       .EQU    $00				;Data in/out
UART1:       .EQU    $01            	;Check RX
UART2:       .EQU    $02            	;Interrupts
UART3:       .EQU    $03            	;Line control
UART4:       .EQU    $04            	;Modem control
UART5:       .EQU    $05            	;Line status
UART6:       .EQU    $06            	;Modem status
UART7:       .EQU    $07            	;Scratch register		
		
;***************************************************************************
;UART_INIT
;Function: Initialize the UART to BAUD Rate 9600 (1.8432 MHz clock input)
;***************************************************************************
UART_INIT:
            LD     A,$80				;Mask to Set DLAB Flag
			OUT    (UART3),A
			LD     A,12					;Divisor = 12 @ 9600bps w/ 1.8432 Mhz
			OUT    (UART0),A			;Set BAUD rate to 9600
			LD     A,00
			OUT    (UART1),A			;Set BAUD rate to 9600
			LD     A,$03
			OUT    (UART3),A			;Set 8-bit data, 1 stop bit, reset DLAB Flag
			LD	   A,$01
			OUT    (UART1),A			;Enable receive data available interrupt only
			RET		
		
;***************************************************************************
;UART_PRNT_STR:
;Function: Print out string starting at MEM location (HL) to 16550 UART
;***************************************************************************
UART_PRNT_STR:
			PUSH	AF
UART_PRNT_STR_LP:
			LD		A,(HL)
            CP		EOS					;Test for end byte
            JP		Z,UART_END_PRNT_STR	;Jump if end byte is found
			CALL	UART_TX
            INC		HL					;Increment pointer to next char
            JP		UART_PRNT_STR_LP	;Transmit loop
UART_END_PRNT_STR:
			POP		AF
			RET	 
			 	
;***************************************************************************
;UART_TX_READY
;Function: Check if UART is ready to transmit
;***************************************************************************
UART_TX_RDY:
			PUSH 	AF
UART_TX_RDY_LP:			
			IN		A,(UART5)			;Fetch the control register
			BIT 	5,A					;Bit will be set if UART is ready to send
			JP		Z,UART_TX_RDY_LP		
			POP     AF
			RET
	
;***************************************************************************
;UART_TX
;Function: Transmit character in A to UART
;***************************************************************************
UART_TX:
			CALL  UART_TX_RDY			;Make sure UART is ready to receive
			OUT   (UART0),A				;Transmit character in A to UART
			RET
				
;***************************************************************************
;UART_RX_READY
;Function: Check if UART is ready to receive
;***************************************************************************
UART_RX_RDY:
			PUSH 	AF					
UART_RX_RDY_LP:			
			IN		A,(UART5)			;Fetch the control register
			BIT 	0,A					;Bit will be set if UART is ready to receive
			JP		Z,UART_RX_RDY_LP		
			POP     AF
			RET
	
;***************************************************************************
;UART_RX
;Function: Receive character in UART to A
;***************************************************************************
UART_RX:
			CALL  UART_RX_RDY			;Make sure UART is ready to receive
			IN    A,(UART0)				;Receive character in UART to A
			RET			

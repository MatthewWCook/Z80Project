;***************************************************************************
;  PROGRAM:			UART  Echo Test Program        
;  PURPOSE:			Key typed on PC will display   
;  ASSEMBLER:		TASM 3.2        
;  LICENCE:			The MIT Licence
;  AUTHOR :			MCook
;  CREATE DATE :	15 Mar 15
;***************************************************************************

UART0:       .EQU    00H            ; DATA IN/OUT
UART1:       .EQU    01H            ; CHECK RX
UART2:       .EQU    02H            ; INTERRUPTS
UART3:       .EQU    03H            ; LINE CONTROL
UART4:       .EQU    04H            ; MODEM CONTROL
UART5:       .EQU    05H            ; LINE STATUS
UART6:       .EQU    06H            ; MODEM STATUS
UART7:       .EQU    07H            ; SCRATCH REG.

.ORG 00H

;***************************************************************************
;INIT_UART
;Function: Initialize the UART to BAUD Rate 9600 (1.8432 MHz clock input)
;DLAB A2 A1 A0 Register
;0    0  0  0  Receiver Buffer (read),
;              Transmitter Holding
;              Register (write)
;0    0  0  1  Interrupt Enable
;X    0  1  0  Interrupt Identification (read)
;X    0  1  0  FIFO Control (write)
;X    0  1  1  Line Control
;X    1  0  0  MODEM Control
;X    1  0  1  Line Status
;X    1  1  0  MODEM Status
;X    1  1  1  Scratch
;1    0  0  0  Divisor Latch
;              (least significant byte)
;1    0  0  1  Divisor Latch
;              (most significant byte)
;***************************************************************************

INIT_UART:
            LD     A,80H			; Mask to Set DLAB Flag
			OUT    (UART3),A
			LD     A,12				; Divisor = 12 @ 9600bps w/ 1.8432 Mhz
			OUT    (UART0),A		; Set BAUD rate to 9600
			LD     A,00
			OUT    (UART1),A		; Set BAUD rate to 9600
			LD     A,03H
			OUT    (UART3),A		; Set 8-bit data, 1 stop bit, reset DLAB Flag
			
			
MAIN:
			LD 		A,00H		
			
;***************************************************************************
;GET_CHAR_UART
;Function: Get current character from UART place in Accumulator
;***************************************************************************

GET_CHAR_UART:   
			IN      A,(UART5)		; Get the line status register's contents
			BIT     0,A				; Test BIT 0, it will be set if the UART is ready to receive
			JP      Z,GET_CHAR_UART
			
			IN      A,(UART0)		; Get character from the UART 
			LD      B,A				; Store character into B Register
			
;***************************************************************************
;SEND_CHAR_UART
;Function: Send current character in Accumulator to UART
;***************************************************************************

SEND_CHAR_UART:   
			IN      A,(UART5)		; Get the line status register's contents
			BIT     5,A				; Test BIT 5, it will be set if the UART is ready to send
			JP      Z,SEND_CHAR_UART
			
			LD		A,B				; Get character from B Register obtained earlier
			OUT     (UART0),A		; Send character through the UART 
			
	JP      MAIN
			
.END			


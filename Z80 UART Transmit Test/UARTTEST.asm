;***********************************
;*  UART Test Program              *
;*                                 *
;***********************************

.ORG 0000H

;******************************************************************
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
;******************************************************************

INIT_UART:
            LD     A,80H       ; Mask to Set DLAB Flag
			OUT    (03H),A
			LD     A,12        ; Divisor = 12 @ 9600bps w/ 1.8432 Mhz
			OUT    (00H),A     ; Set BAUD rate to 9600
			LD     A,00
			OUT    (01H),A     ; Set BAUD rate to 9600
			LD     A,03H
			OUT    (03H),A     ; Set 8-bit data, 1 stop bit, reset DLAB Flag
			
;******************************************************************
;Main Program
;Function: Display A->Z then a new line and loop
;******************************************************************


MAIN_LOOP:   
			IN      A,(05H)        ; Get the line status register's contents
			BIT     5,A            ; Test BIT, it will be set if the UART is ready
			JP      Z,MAIN_LOOP    
			LD      A,41H          ; Load acumulator with "A" Character
			OUT     (00H),A        ; Send "A" Character through the UART
			JP      MAIN_LOOP

.END
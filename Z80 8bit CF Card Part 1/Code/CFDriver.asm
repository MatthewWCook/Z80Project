;***************************************************************************
;  PROGRAM:			CFDriver        
;  PURPOSE:			Subroutines for a CF Card
;  ASSEMBLER:		TASM 3.2        
;  LICENCE:			The MIT Licence
;  AUTHOR :			MCook
;  CREATE DATE :	19 June 15
;***************************************************************************

;The addresses that the CF Card resides in I/O space.
;Change to suit hardware.
CFDATA:		.EQU	CFBASE + $00		; Data (R/W)
CFERR:		.EQU	CFBASE + $01		; Error register (R)
CFFEAT:		.EQU	CFBASE + $01		; Features (W)
CFSECCO:	.EQU	CFBASE + $02		; Sector count (R/W)
CFLBA0:		.EQU	CFBASE + $03		; LBA bits 0-7 (R/W, LBA mode)
CFLBA1:		.EQU	CFBASE + $04		; LBA bits 8-15 (R/W, LBA mode)
CFLBA2:		.EQU	CFBASE + $05		; LBA bits 16-23 (R/W, LBA mode)
CFLBA3:		.EQU	CFBASE + $06		; LBA bits 24-27 (R/W, LBA mode)
CFSTAT:		.EQU	CFBASE + $07		; Status (R)
CFCMD:		.EQU	CFBASE + $07		; Command (W)	

;***************************************************************************
;CF_INIT
;Function: Initialize CF to 8 bit data transfer mode
;***************************************************************************	
CF_INIT:
	CALL	LOOP_BUSY
	LD		A,$01						;LD features register to enable 8 bit
	OUT		(CFFEAT),A
	CALL	LOOP_BUSY
	LD		A,$EF						;Send set features command
	OUT		(CFCMD),A
	CALL	LOOP_BUSY
	RET

;***************************************************************************
;LOOP_BUSY
;Function: Loops until status register bit 7 (busy) is 0
;***************************************************************************	
LOOP_BUSY:
	IN		A, (CFSTAT)					;Read status
	AND		%10000000					;Mask busy bit
	JP		NZ,LOOP_BUSY				;Loop until busy(7) is 0
	RET

;***************************************************************************
;LOOP_CMD_RDY
;Function: Loops until status register bit 7 (busy) is 0 and drvrdy(6) is 1
;***************************************************************************	
LOOP_CMD_RDY:
	IN		A,(CFSTAT)					;Read status
	AND		%11000000					;mask off busy and rdy bits
	XOR		%01000000					;we want busy(7) to be 0 and drvrdy(6) to be 1
	JP		NZ,LOOP_CMD_RDY
	RET

;***************************************************************************
;LOOP_DAT_RDY
;Function: Loops until status register bit 7 (busy) is 0 and drq(3) is 1
;***************************************************************************		
LOOP_DAT_RDY:
	IN		A,(CFSTAT)					;Read status
	AND		%10001000					;mask off busy and drq bits
	XOR		%00001000					;we want busy(7) to be 0 and drq(3) to be 1
	JP		NZ,LOOP_DAT_RDY
	RET
	
;***************************************************************************
;CF_RD_CMD
;Function: Gets a sector (512 bytes) into RAM buffer.
;***************************************************************************			
CF_RD_CMD:
	CALL	LOOP_CMD_RDY				;Make sure drive is ready for command
	LD		A,$20						;Prepare read command
	OUT		(CFCMD),A					;Send read command
	CALL	LOOP_DAT_RDY				;Wait until data is ready to be read
	IN		A,(CFSTAT)					;Read status
	AND		%00000001					;mask off error bit
	JP		NZ,CF_RD_CMD				;Try again if error
	LD 		HL,CFSECT_BUFF
	LD 		B,0							;read 256 words (512 bytes per sector)
CF_RD_SECT:
	CALL	LOOP_DAT_RDY	
	IN 		A,(CFDATA)					;get byte of ide data	
	LD 		(HL),A
	INC 	HL
	CALL	LOOP_DAT_RDY
	IN 		A,(CFDATA)					;get byte of ide data	
	LD 		(HL),A
	INC 	HL
	DJNZ 	CF_RD_SECT
	RET
	
;***************************************************************************
;CF_TEST
;Function: Read sector 0 into RAM buffer.
;***************************************************************************	
CF_MSG_1: .BYTE "CF Card Test\r\n",EOS
CF_MSG_2: .BYTE "Reading sector 0 into RAM buffer...\r\n",EOS
CF_MSG_3: .BYTE "Sector 0 read ...\r\n",EOS

CF_TEST:
	LD 		HL,CF_MSG_1					;Print some messages 
	CALL    PRINT_STRING
	LD 		HL,CF_MSG_2	
	CALL    PRINT_STRING
	CALL 	LOOP_BUSY
	LD 		A,1
	OUT 	(CFSECCO),A					;Deal with only one sector at a time (512 bytes)
	CALL 	LOOP_BUSY
	LD      A,$00
	OUT		(CFLBA0),A					;LBA 0:7
	CALL 	LOOP_BUSY
	LD      A,$00
	OUT		(CFLBA1),A					;LBA 8:15
	CALL 	LOOP_BUSY
	LD      A,$00
	OUT 	(CFLBA2),A					;LBA 16:23
	CALL 	LOOP_BUSY
	LD 		A,$E0						;Selects CF as master
	OUT 	(CFLBA3),A					;LBA 24:27 + DRV 0 selected + bits 5:7=111
	CALL	CF_RD_CMD
	LD 		HL,CF_MSG_3			
	CALL    PRINT_STRING
	RET
	
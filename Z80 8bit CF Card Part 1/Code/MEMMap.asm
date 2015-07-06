;***************************************************************************
;  PROGRAM:			MEMMap       
;  PURPOSE:			Memory Map
;  ASSEMBLER:		TASM 3.2        
;  LICENCE:			The MIT Licence
;  AUTHOR :			MCook
;  CREATE DATE :	26 June 15
;***************************************************************************

ROM_BOTTOM:  .EQU    $0000				;Bottom address of ROM
ROM_TOP:     .EQU    $07FF				;Top address of ROM
RAM_BOTTOM:  .EQU    $8000   			;Bottom address of RAM
RAM_TOP:     .EQU    $87FF				;Top address of RAM	

CFSECT_BUFF	.EQU     $8000     	        ;CF Sector Buffer
		

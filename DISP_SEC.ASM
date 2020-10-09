CGROUP	GROUP	CODE_SEG, DATA_SEG	;Group two segments together
	ASSUME	CS:CGROUP, DS:CGROUP

CODE_SEG	SEGMENT	PUBLIC
	ORG	100h
	
	EXTRN	WRITE_HEX:NEAR
	EXTRN	WRITE_CHAR:NEAR
;-----------------------------------------------------------------------;
; This is a simple test program to dump 16 bytes of memory as hex       ;
; numbers, all on one line.                                             ;
;-----------------------------------------------------------------------;
DISP_LINE	PROC	NEAR
	XOR	BX,BX			;Set BX to 0
	MOV	CX,16			;Dump 16 bytes
HEX_LOOP:
	MOV	DL,SECTOR[BX]		;Get 1 byte
	CALL	WRITE_HEX		;Dump this byte in hex
	MOV	DL,' '			;Write a space between numbers
	CALL	WRITE_CHAR
	INC	BX
	LOOP	HEX_LOOP
	
	MOV	DL,' '			;Add another space before characters
	CALL	WRITE_CHAR
	MOV	CX,16
	XOR	BX,BX			;Set BX back to 0
ASCII_LOOP:
	MOV	DL,SECTOR[BX]
	CALL	WRITE_CHAR
	INC	BX
	LOOP	ASCII_LOOP
	
	INT	20h			;Return to DOS
DISP_LINE	ENDP

CODE_SEG	ENDS


DATA_SEG	SEGMENT	PUBLIC
	PUBLIC	SECTOR
SECTOR	DB	10h, 11h, 12h, 13h, 14h, 15h, 16h, 17h  ;Test pattern
	DB	18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh
DATA_SEG	ENDS


	END	DISP_LINE

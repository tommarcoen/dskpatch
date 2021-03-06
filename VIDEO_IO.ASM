CGROUP	GROUP	CODE_SEG
	ASSUME	CS:CGROUP

CODE_SEG	SEGMENT
	ORG	100h

TEST_WRITE_DECIMAL	PROC	NEAR
	MOV	DX,12345
	CALL	WRITE_DECIMAL
	INT	20h			;Return to DOS
TEST_WRITE_DECIMAL	ENDP

TEST_WRITE_HEX	PROC	NEAR
	MOV	DL,3Fh			;Test with 3Fh
	CALL	WRITE_HEX
	INT	20h			;Return to DOS
TEST_WRITE_HEX	ENDP


	PUBLIC	WRITE_CHAR_N_TIMES
;-----------------------------------------------------------------------;
; This procedure writes more than one copy of a character               ;
;                                                                       ;
;       DL      Character code                                          ;
;       CX      Number of times to write the character                  ;
;                                                                       ;
; Uses:         WRITE_CHAR
;-----------------------------------------------------------------------;
WRITE_CHAR_N_TIMES	PROC	NEAR
	PUSH	CX
N_TIMES:
	CALL	WRITE_CHAR
	LOOP	N_TIMES
	POP	CX
	RET
WRITE_CHAR_N_TIMES	ENDP

	PUBLIC	WRITE_DECIMAL
;-----------------------------------------------------------------------;
; This procedure writes a 16-bit, unsigned number in decimal notation.  ;
;                                                                       ;
;       DX      N : 16-bit, unsigned number.                            ;
;                                                                       ;
; Uses:         WRITE_HEX_DIGIT                                         ;
;-----------------------------------------------------------------------;
WRITE_DECIMAL	PROC	NEAR
	PUSH	AX			;Save registers used here
	PUSH	CX
	PUSH	DX
	PUSH	SI
	MOV	AX,DX
	MOV	SI,10			;Will divide by 10 using SI
	XOR	CX,CX			;Count of digits placed on stack
NON_ZERO:
	XOR	DX,DX			;Set upper word of N to 0
	DIV	SI			;Calculate N/10 and (N mod 10)
	PUSH	DX			;Push one digit onto the stack
	INC	CX			;One more digit added
	OR	AX,AX			;N = 0 yet?
	JNE	NON_ZERO		;Nope, continue
WRITE_DIGIT_LOOP:
	POP	DX			;Get the digits in reverse order
	CALL	WRITE_HEX_DIGIT
	LOOP	WRITE_DIGIT_LOOP
END_DECIMAL:
	POP	SI
	POP	DX
	POP	CX
	POP	AX
	RET
WRITE_DECIMAL	ENDP

	PUBLIC	WRITE_HEX
;-----------------------------------------------------------------------;
; This procedure converts the byte in the DL register to hex and writes ;
; the two hex digits at the current cursor position.                    ;
;                                                                       ;
;       DL      Byte to be converted to hex.                            ;
;                                                                       ;
; Uses:         WRITE_HEX_DIGIT                                         ;
;-----------------------------------------------------------------------;
WRITE_HEX	PROC	NEAR		;Entry point
	PUSH	CX			;Save registers used in this procedure
	PUSH	DX
	MOV	DH,DL			;Make a copy of byte
	MOV	CX,4			;Get the upper nibble in DL
	SHR	DL,CL
	CALL	WRITE_HEX_DIGIT		;Display first hex digit
	MOV	DL,DH			;Get lower nibble in DL
	AND	DL,0Fh			;Remove the upper nibble
	CALL	WRITE_HEX_DIGIT		;Display second hex digit
	POP	DX
	POP	CX
	RET
WRITE_HEX	ENDP

	PUBLIC	WRITE_HEX_DIGIT
;-----------------------------------------------------------------------;
; This procedure converts the lower 4 bits of DL to a hex digit and     ;
; writes it to the screen.                                              ;
;                                                                       ;
;       DL      Lower 4 bits contain number to be printed in hex.       ;
;                                                                       ;
; Uses:         WRITE_CHAR                                              ;
;-----------------------------------------------------------------------;
WRITE_HEX_DIGIT	PROC	NEAR
	PUSH	DX			;Save registers used
	CMP	DL,10			;Is this nibble <10?
	JAE	HEX_LETTER		;No, convert to a letter
	ADD	DL,"0"			;Yes, convert to a digit
	JMP	Short WRITE_DIGIT	;Now write this character
HEX_LETTER:
	ADD	DL,"A"-10		;Convert to hex letter
WRITE_DIGIT:
	CALL	WRITE_CHAR		;Display the letter on the screen
	POP	DX
	RET
WRITE_HEX_DIGIT	ENDP

	PUBLIC	WRITE_CHAR
;-----------------------------------------------------------------------;
; This procedure prints a character on the screen using the DOS         ;
; function call.  WRITE_CHAR replaces the characters 0 through 1Fh with ;
; a period.                                                             ;
;                                                                       ;
;       DL      Byte to print on screen.                                ;
;-----------------------------------------------------------------------;
WRITE_CHAR	PROC	NEAR
	PUSH	AX
	PUSH	DX
	CMP	DL,32			;Is character before a space?
	JAE	IS_PRINTABLE		;No, then print as is
	MOV	DL,'.'			;Yes, replace with a period
IS_PRINTABLE:
	MOV	AH,2			;Call for character output
	INT	21h			;Output character in DL register
	POP	DX			;Restore old value in AX and DX
	POP	AX
	RET				;And return
WRITE_CHAR	ENDP

	PUBLIC	WRITE_PATTERN
;-----------------------------------------------------------------------;
; This procedure writes a line to the screen, based on data in the form ;
;                                                                       ;
;      DB       (character, number of times to write character), 0      ;
; Where (x) means that x can be repeated any number of times            ;
;      DS:DX    Address of above data statement                         ;
;                                                                       ;
; Uses:         WRITE_CHAR_N_TIMES                                      ;
;-----------------------------------------------------------------------;
WRITE_PATTERN	PROC	NEAR
	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSHF				;Save the direction flag
	CLD				;Set direction flag for increment
	MOV	SI,DX			;Move offset into SI register for LODSB
PATTERN_LOOP:
	LODSB				;Get character data into AL
	OR	AL,AL			;Is it the end of data (0h)?
	JZ	END_PATTERN		;Yes, return
	MOV	DL,AL			;No, set up to write character N times
	LODSB				;Get the repeat count into AL
	MOV	CL,AL			;And put in CX for WRITE_CHAR_N_TIMES
	XOR	CH,CH			;Zero upper byte of CX
	CALL	WRITE_CHAR_N_TIMES
	JMP	PATTERN_LOOP
END_PATTERN:
	POPF				;Restore direction flag
	POP	SI
	POP	DX
	POP	CX
	POP	AX
	RET
WRITE_PATTERN	ENDP

CODE_SEG	ENDS

	END	TEST_WRITE_DECIMAL

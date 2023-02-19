ORG 0x0

START:
	DI
	IM	2
	LD	A,INTERRUPT_VECTORS / 0x0100
	LD	I,A
	LD	SP,0E7FFh	; Stack pointer
	CALL	INIT1		; Sets up IO F4, F0 and F1, has a big delay in the end
	JR	INIT2

	; This region had what looks like a second start for the CPU?
	SEEK	0x000F
	ORG	0x000F
START2:
	DI
	IM	2
	LD	A,INTERRUPT_VECTORS / 0x0100
	LD	I,A
	LD	SP,0E7FFh	; Stack pointer
	CALL	INIT1		; Sets up IO F4, F0 and F1, has a big delay in the end
	JR	INIT2

	; -- L0019 --
INIT2:
	CALL	INIT_EI_RETI
	CALL	INIT_CTC
	CALL	INIT_SIO
	CALL	INIT_PIO
	CALL	INIT_4B 		; Unknown, possibly unpopulated IO?
	CALL	SHARED_MEM_INIT		; Possibly not needed, just reads and then discards stuff from memory
	CALL	INIT_44_45
	CALL	INIT_48_49
	CALL	LCD_INIT

	LD	A, "X"
	OUT	(SIO_A_DATA), A
	JP	MAIN_LOOP

	SEEK 0x70
	ORG 0x70
	; Interrupts
INTERRUPT_VECTORS:
	DW	INT_SIO_B_TX_EMPTY
	DW	INT_SIO_B_STATUS_CHANGE
	DW	INT_SIO_B_RX_AVAILABLE
	DW	INT_SIO_B_ERROR
	DW	INT_SIO_A_TX_EMPTY
	DW	INT_SIO_A_STATUS_CHANGE
	DW	INT_SIO_A_RX_AVAILABLE
	DW	INT_SIO_A_ERROR
CTC_VECTORS:
	DW	INT_CTC_CH1
	DW	INT_CTC_CH2
	DW	INT_CTC_CH3
	DW	INT_CTC_CH4
PIO_VECTORS:
	DW	INT_PIO_A
	DW	INT_PIO_B

	SEEK 0x90
	ORG 0x90
	; -- L00C8 --
INIT1: PROC
	LD	A,00h
	OUT	(0F4h),A
	CALL	INIT_F0_F1
	LD	HL,012Ch
loop1:	LD	B,00h
loop2:	DJNZ	loop2
	DEC	HL
	LD	A,H
	OR	L
	JR	NZ,loop1
	RET
ENDP

MAIN_LOOP: PROC
	ZFILL	LAMP_DEST, LAMP_BYTES
	ZFILL	LAMP_SRC, LAMP_BYTES
	CALL	LAMP_UPDATE		; Turn all lamps off

	LD	HL,LCD_SPLASH		; Load the splash screen to the LCD
	CALL	LCD_UPDATE
	EI
	TX_A	"L"

	LD	A, 0x01			; Initialize the LCD work ram
	LD	(LCD_FLAG), A
	MCOPY	LCD_SPLASH,LCD_SRC,LCD_BYTES
	LD	HL, LCD_WRITE_DEST
	LD	(LCD_POINTER), HL	; Set up a write pointer for the LCD
	CALL	LCD_COPY
	; CALL	LAMP_COPY		; Copy 1Ah bytes from LAMP_SRC to LAMP_DEST
	CALL	RX_INIT			; Initialise receive counter, type, pointer
	TX_A	"M"

	LD	A, "D"
	CALL	LCD_WRITE
	LD	A, "I"
	CALL	LCD_WRITE
	LD	A, "S"
	CALL	LCD_WRITE
	LD	A, "O"
	CALL	LCD_WRITE
	LD	A, "B"
	CALL	LCD_WRITE
	LD	A, "E"
	CALL	LCD_WRITE
	LD	A, "Y"
	CALL	LCD_WRITE
	LD	A, "["
	CALL	LCD_WRITE
	LD	A, "l"
	CALL	LCD_WRITE
	LD	A, "c"
	CALL	LCD_WRITE
	LD	A, "d"
	CALL	LCD_WRITE
	LD	A, 0x00
	LD	(MAIN_COUNTER), A

loop:	; CALL	  LAMP_COPY	  	; Copy 1Ah bytes from LAMP_SRC to LAMP_DEST
	CALL	LAMP_UPDATE
	; CALL	  LCD_COPY		; Update LCD from shared memory
	LD	HL, LCD_DEST
	CALL	LCD_UPDATE
	; IN A, (00h)			; Wiggle some CS lines
	; IN A, (02h)
	DI
	CALL	CHECK_RX
	EI
	LD	A, (MAIN_COUNTER)
	INC	A
	LD	(MAIN_COUNTER), A
	AND	A
	JR	NZ, loop
	TX_A	"-"
	JR	loop
ENDP

	; --- L0304 ---
	; Unknown, possibly unpopulated devices
INIT_48_49: PROC
	LD	A,0FFh
	OUT	(49h),A ; 0xFF
	LD	D,00h
	LD	B,08h
	LD	A,D
	OUT	(48h),A 	; 0x00
	LD	A,0FCh
	OUT	(49h),A 	; 0xFC
	AND	0FBh
	OUT	(49h),A 	; 0xF8
	LD	A,0FFh
	OUT	(49h),A 	; 0xFF
loop1:	LD	A,0FFh
	OUT	(48h),A 	; 0xFF
	LD	A,0FEh
	OUT	(49h),A 	; 0xFE
	AND	0FBh
	OUT	(49h),A 	; 0xFB
	LD	A,0FFh
	OUT	(49h),A 	; 0xFF
	INC	D
	DJNZ	loop1		; 8 times
	LD	D,00h
	LD	HL,INIT_48_DATA
	LD	B,08h
loop2:	LD	C,03h
	LD	A,D
	OUT	(48h),A		; 0x00 - 0x08
	LD	A,0FCh
	OUT	(49h),A		; 0xFC
	AND	0FBh
	OUT	(49h),A		; 0xFB
	LD	A,0FFh
	OUT	(49h),A		; 0xFF
loop3:	LD	A,(HL)
	OUT	(48h),A		; Data from table
	LD	A,0FDh
	OUT	(49h),A		; 0xFD
	AND	0FBh
	OUT	(49h),A		; 0xFB
	LD	A,0FFh
	OUT	(49h),A		; 0xFF
	INC	HL
	DEC	C
	JP	NZ,loop3	; 3 times
	INC	D
	DJNZ	loop2		; 8 times
	RET
ENDP

INIT_48_DATA:
	DB	03h
	DB	05h
	DB	14h
	DB	3Fh
	DB	00h
	DB	00h
	DB	00h
	DB	3Fh
	DB	00h
	DB	3Fh
	DB	3Fh
	DB	00h
	DB	00h
	DB	00h
	DB	3Fh
	DB	3Fh
	DB	00h
	DB	3Fh
	DB	00h
	DB	3Fh
	DB	3Fh
	DB	3Fh
	DB	3Fh
	DB	3Fh

	; --- L02E2 ---
	; Unknown device init? writes incrementing bytes to 44 and data to 45
INIT_44_45: PROC
	LD	D,00h
	LD	HL,INIT_45_DATA
	LD	B,10h
loop:	LD	A,D
	OUT	(44h),A
	LD	A,(HL)
	OUT	(45h),A
	INC	D
	INC	HL
	DJNZ	loop
	RET
ENDP

INIT_45_DATA:
	DB	64h
	DB	50h
	DB	52h
	DB	2Ch
	DB	1Ch
	DB	01h
	DB	19h
	DB	1Ah
	DB	50h
	DB	0Fh
	DB	20h
	DB	0Fh
	DB	0F8h
	DB	00h
	DB	0F8h
	DB	00h

FLAG_END: ; xor 42h of KouvostoTelecomSecureSystem]
	DB 09h
	DB 2dh
	DB 37h
	DB 34h
	DB 2dh
	DB 31h
	DB 36h
	DB 2dh
	DB 16h
	DB 27h
	DB 2eh
	DB 27h
	DB 21h
	DB 2dh
	DB 2fh
	DB 11h
	DB 27h
	DB 21h
	DB 37h
	DB 30h
	DB 27h
	DB 11h
	DB 3bh
	DB 31h
	DB 36h
	DB 27h
	DB 2fh
	DB 1fh

	; --- L03E2 ---
	; Not entirely sure about this, seems strange...
SHARED_MEM_INIT: PROC
	LD	HL,7D33h
loop:	DEC	HL
	LD	A,H
	OR	L
	JR	NZ,loop
	LD	HL,0F000h
	LD	A,(HL)
	LD	HL,0F800h
	LD	A,(HL)
	LD	HL,0E800h
	LD	A,(HL)
	RET
ENDP

	; --- L02D7 ---
INIT_4B:
	LD	HL,INIT_4B_DATA
	LD	C,4Bh
	LD	B,01h
	OTIR
	RET

INIT_4B_DATA:
	DB	80h

	; --- L00DC ---
INIT_F0_F1:
	LD	A,5Bh
	OUT	(0F0h),A
	LD	A,0B1h
	OUT	(0F1h),A
	RET

	; --- L00B8 ---
INIT_EI_RETI:
	LD	A,0FBh
	LD	(8000h),A
	LD	A,0EDh
	LD	(8001h),A
	LD	A,4Dh
	LD	(8002h),A
	RET

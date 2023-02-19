	; Write A to LCD_POINTER, increment it, resetting if needed
LCD_WRITE: PROC
	LD	HL, (LCD_POINTER)
	LD	(HL), A
	INC	HL
	LD	A, 0x01
	LD	(LCD_FLAG), A
	LD	A, H
	CP	0 + (LCD_DEST + LCD_BYTES) / 0x0100
	JP	NZ, no_reset
	LD	A, L
	CP	0 + (LCD_DEST + LCD_BYTES) % 0x0100
	JR	NZ, no_reset
	LD	HL, LCD_DEST
	LD	(LCD_POINTER), HL
	RET
no_reset:
	LD	(LCD_POINTER), HL
	RET
ENDP

	; --- L0376 ---
	; Init both LCD controllers
	; Set data length 8, lines 2, display on, cursor off, blink off,
	; auto-increment writes, no display shift
LCD_INIT:
	LD	A,30h
	CALL	LCD1_REGISTER
	CALL	LCD_DELAY3
	LD	A,30h
	CALL	LCD1_REGISTER
	CALL	LCD_DELAY3
	LD	A,30h
	CALL	LCD2_REGISTER
	CALL	LCD_DELAY3
	LD	A,30h
	CALL	LCD2_REGISTER
	CALL	LCD_DELAY3
	LD	A,30h
	CALL	LCD2_REGISTER
	CALL	LCD_DELAY3
	LD	A,30h
	CALL	LCD2_REGISTER
	CALL	LCD_DELAY3
	LD	A,38h
	CALL	LCD1_REGISTER
	CALL	LCD_DELAY2
	LD	A,38h
	CALL	LCD2_REGISTER
	CALL	LCD_DELAY2
	LD	A,0Ch
	CALL	LCD1_REGISTER
	CALL	LCD_DELAY2
	LD	A,0Ch
	CALL	LCD2_REGISTER
	CALL	LCD_DELAY2
	LD	A,06h
	CALL	LCD1_REGISTER
	CALL	LCD_DELAY2
	LD	A,06h
	CALL	LCD2_REGISTER
	CALL	LCD_DELAY2
	; LD	HL,9450h
	; LD	(94F0h),HL
	; LD	A,00h
	; LD	(94F2h),A
	RET

	; --- L0DE0 ---
	; Writes A to LCD controller 1 registers
LCD1_REGISTER:
	PUSH	DE
	LD	D,A
	IN	A,(1Eh)
	AND	0F0h
	OR	00h
	OUT	(1Eh),A
	OR	01h
	OUT	(1Eh),A
	LD	A,D
	OUT	(1Ch),A
	IN	A,(1Eh)
	AND	0F0h
	OR	00h
	OUT	(1Eh),A
	CALL	LCD_DELAY2
	POP	DE
	RET

	; --- L0DFE ---
	; Writes A to LCD controller 2 registers
LCD2_REGISTER:
	PUSH	DE
	LD	D,A
	IN	A,(1Eh)
	AND	0F0h
	OR	00h
	OUT	(1Eh),A
	OR	02h
	OUT	(1Eh),A
	LD	A,D
	OUT	(1Ch),A
	IN	A,(1Eh)
	AND	0F0h
	OR	00h
	OUT	(1Eh),A
	CALL	LCD_DELAY2
	POP	DE
	RET

	; Reads 160 bytes starting from HL and writes to the LCD
	; Verified as working
LCD_UPDATE: PROC
	LD	A,00h
	CALL	SET_LCD1_ADDR
	LD	B,28h
loop1:	LD	A,(HL)
	CALL	WRITE_LCD1
	INC	HL
	DJNZ	loop1
	LD	A,40h		; 0x40=64, address for the second row
	CALL	SET_LCD1_ADDR
	LD	B,28h
loop2:	LD	A,(HL)
	CALL	WRITE_LCD1
	INC	HL
	DJNZ	loop2
	LD	A,00h
	CALL	SET_LCD2_ADDR
	LD	B,28h
loop3:	LD	A,(HL)
	CALL	WRITE_LCD2
	INC	HL
	DJNZ	loop3
	LD	A,40h		; 0x40=64, address for the second row
	CALL	SET_LCD2_ADDR
	LD	B,28h
loop4:	LD	A,(HL)
	CALL	WRITE_LCD2
	INC	HL
	DJNZ	loop4
	LD	A,0Bh		; CTF flag mangling, replace "SystemTry" part of the flag with Kouvosto
	LD  HL, FLAG_END
	LD  DE, INIT_45_DATA
	CALL	SET_LCD1_ADDR
	LD	B,1ch 		; Flag end length
loopCTF:	LD	A,(HL)
    XOR 42h
    CALL	WRITE_LCD1
	INC	HL
	DJNZ	loopCTF
	RET
ENDP

; Set LCD1 DDRAM address to A
SET_LCD1_ADDR:
	PUSH	DE
	LD	D,A
	IN	A,(1Eh)
	AND	0F0h
	OR	00h
	OUT	(1Eh),A
	OR	01h
	OUT	(1Eh),A
	LD	A,D
	AND	7Fh
	OR	80h
	OUT	(1Ch),A
	IN	A,(1Eh)
	AND	0F0h
	OR	00h
	OUT	(1Eh),A
	CALL	LCD_DELAY1
	POP	DE
	RET

; SET LCD2 DDRAM address to A
SET_LCD2_ADDR:
	PUSH	DE
	LD	D,A
	IN	A,(1Eh)
	AND	0F0h
	OR	00h
	OUT	(1Eh),A
	OR	02h
	OUT	(1Eh),A
	LD	A,D
	AND	7Fh
	OR	80h
	OUT	(1Ch),A
	IN	A,(1Eh)
	AND	0F0h
	OR	00h
	OUT	(1Eh),A
	CALL	LCD_DELAY1
	POP	DE
	RET

; Write A to LCD1 DDRAM
WRITE_LCD1:
	PUSH	DE
	LD	D,A
	IN	A,(1Eh)
	AND	0F0h
	OR	04h
	OUT	(1Eh),A
	OR	01h
	OUT	(1Eh),A
	LD	A,D
	OUT	(1Ch),A
	IN	A,(1Eh)
	AND	0F0h
	OR	04h
	OUT	(1Eh),A
	CALL	LCD_DELAY1
	POP	DE
	RET

; Write A to LCD2 DDRAM
WRITE_LCD2:
	PUSH	DE
	LD	D,A
	IN	A,(1Eh)
	AND	0F0h
	OR	04h
	OUT	(1Eh),A
	OR	02h
	OUT	(1Eh),A
	LD	A,D
	OUT	(1Ch),A
	IN	A,(1Eh)
	AND	0F0h
	OR	04h
	OUT	(1Eh),A
	CALL	LCD_DELAY1
	POP	DE
	RET

; Delay loop for the LCD control
LCD_DELAY1: PROC
	PUSH	BC
	LD	B,19h
loop:	DJNZ	loop
	POP	BC
	RET
ENDP

	; --- L0F23 ---
LCD_DELAY2: PROC
	PUSH	BC
	LD	B,00h
loop:	DJNZ	loop
	POP	BC
	RET
ENDP

	; --- L0F0B ---
LCD_DELAY3: PROC
	PUSH	BC
	LD	B,00h
loop1:	DJNZ	loop1
loop2:	DJNZ	loop2
loop3:	DJNZ	loop3
loop4:	DJNZ	loop4
loop5:	DJNZ	loop5
	POP	BC
	RET
ENDP

	; Check LCD_FLAG location for non-zero value
	; If so zero it and copy the new LCD data down
	; to LCD_DEST and update the LCD
LCD_COPY: PROC
	LD	HL, LCD_FLAG
	LD	A,(HL)
	AND	A
	JR	Z, return
	LD	A, 0x00
	LD	(HL), A
	MCOPY	LCD_SRC, LCD_DEST, LCD_BYTES
	LD	HL,LCD_DEST
	CALL	LCD_UPDATE
return: RET
ENDP

LCD_SPLASH: ;
    ;   DISOBEY[lcd
    ;              KouvostoTelecomSecureSystem]
	DB "***********SytemTryHarder]**************"
	DB "*   VIDEO PRODUCTION SYSTEM Z80 ultra  *"
	DB "* Kouvosto Telecom Edition (Mil grade) *"
	DB "****************************************"
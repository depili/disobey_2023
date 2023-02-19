	; Waits for TX buffer to be empty, then sends A
	; Verfied working
SIO_A_TX_BLOCKING: PROC
	LD	D, A
	CALL	SIO_A_TX_CHECK
	LD	A, D
	OUT	(SIO_A_DATA), A 	; Send the character
	RET
ENDP

	; Wait until SIO A TX buffer is empty
	; Verified working
SIO_A_TX_CHECK: PROC
	LD	A, 0x01			; Select register 1
	OUT	(SIO_A_CMD), A
	IN	A, (SIO_A_CMD)		; Read register 1
	BIT	0, A			; Bit 0 is "All sent"
	JP	Z, SIO_A_TX_CHECK
	RET
ENDP

RX_INIT:
	LD	A, 0x00			; Error in message, zero the counter and type
	LD	(RX_COUNTER), A
	LD	(RX_TYPE), A
	LD	HL, RX_POINTER+2
	LD	(RX_POINTER), HL
	RET

; Check the RX buffer
CHECK_RX: PROC
	LD	IX, RX_TYPE		; Start of the buffer
	LD	IY, 0x0000		; Total bytes consumed
process:
	LD	A, (RX_COUNTER)
	LD	C, 0x01			; Default consume 1 byte
	AND	A
	JR	NZ, check_msg
	RET				; No bytes in buffer
check_msg:
	LD	A, (IX)
	CP	0x80			; Lamp message
	JR	Z, lamp
	CP	0x81			; LCD message
	JP	Z, lcd
	JR	inc_bytes	    	; Invalid message
lamp:
	LD	A, "L"
	CALL	SIO_A_TX_BLOCKING
	LD	A, (RX_COUNTER)
	CP	0x03
	JP	C, shift		; not enough bytes for full message

	LD	A, (IX+0x01)		; Byte offset of the lamp data
	CP	LAMP_BYTES
	JP	NC, inc_bytes		; Too big offset

	LD	BC, 0x0000
	LD	C, A
	LD	HL, LAMP_DEST
	ADD	HL, BC

	LD	A, (IX+0x02)
	LD	(HL), A
	LD	C, 0x03			; Consume full message
	JP	inc_bytes
lcd:
	LD	A, "D"
	CALL	SIO_A_TX_BLOCKING
	LD	A, (RX_COUNTER)
	CP	0x02
	JP	C, shift		; Not enough for full message
	LD	A, (IX+0x01)
	CALL	SIO_A_TX_BLOCKING
	CALL	LCD_WRITE
	LD	C, 0x02
	JP	inc_bytes
inc_bytes:
	LD	A, "i"
	CALL	SIO_A_TX_BLOCKING
	LD	B, 0x00
	ADD	IX, BC
	ADD	IY, BC

	LD	A, (RX_COUNTER)		; Shift out C bytes from the buffer
	SUB	C
	LD	(RX_COUNTER), A

	LD	A, (RX_COUNTER)
	AND	A
	JP	NZ, process		; Still bytes to check
shift:
	LD	A, "s"
	CALL	SIO_A_TX_BLOCKING
	LD	HL, RX_TYPE
	PUSH	IY
	POP	BC
	ADD	HL, BC
	LD	DE, RX_TYPE
	LD	A, (RX_COUNTER)
	AND	A
	JR	Z, set_pointer		; Zero bytes to copy
	LD	C, A
	LD	B, 0x00
	LDIR
set_pointer:
	LD	HL, RX_TYPE		; Set the write pointer
	LD	B, 0x00
	LD	C, A
	ADD	HL, BC
	LD	(RX_POINTER), HL
	RET
ENDP

	; --- L015A ---
INIT_SIO:
	LD	HL,SIO_A_INIT_DATA
	LD	C,19h
	LD	B,0Dh
	OTIR
	LD	HL,SIO_B_INIT_DATA
	LD	C,1Bh
	LD	B,0Fh
	OTIR
	RET

SIO_A_INIT_DATA:
	DB	00h	; Write register 0
	DB	00h
	DB	18h	; CMD error reset
	DB	10h	; CMD reset status interrupts
	DB	04h	; Write register 4
	DB	45h	; 1,5 stop bits, even parity, 8bit programmed sync, data rate=16x clock rate
	DB	03h	; Write register 3
	DB	0C1h	; RX enable, 8 bits per character
	DB	05h	; Write register 5
	DB	0EAh	; TX crc disable, RTS low, TX enable, DTR low, external sync
	DB	10h	; CMD reset status interrupts
	DB	01h	; Write register 1
	DB	10h	; Transmit interrupt enable, receive interrupt on all characters
SIO_B_INIT_DATA:
	DB	00h	; Write register 0
	DB	00h
	DB	18h	; CMD error reset
	DB	10h	; CMD reset status interrupts
	DB	04h	; Write register 4
	DB	45h	; 1,5 stop bits, even parity, 8bit programmed sync, data rate=16x clock rate
	DB	03h	; Write register 3
	DB	0C1h	; RX enable, 8 bits per character
	DB	05h	; Write register 5
	DB	0EAh	; TX crc disable, RTS low, TX enable, DTR low, external sync
	DB	02h	; Write register 2
	DB	INTERRUPT_VECTORS % 0x0100
	DB	10h	; CMD reset status interrupts
	DB	01h	; Write register 1
	DB	14h	; Transmit interrupt enable, receive interrupt on all characters, status affects vector

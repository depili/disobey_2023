SIO_CMD_NULL		EQU	0x00
SIO_CMD_TX_ABORT	EQU	0x08
SIO_CMD_RST_STATUS	EQU	0x10
SIO_CMD_CH_RESET	EQU	0x18
SIO_CMD_EI_RX		EQU	0x20
SIO_CMD_TX_IR_RST	EQU	0x28
SIO_CMD_ERROR_RST	EQU	0x30
SIO_CMD_RETI		EQU	0x38
; IO PORTS
CTC_CH1			EQU	0x10
CTC_CH2			EQU	0x11
CTC_CH3			EQU	0x12
CTC_CH4			EQU	0x13
SIO_A_DATA		EQU	0x18
SIO_A_CMD		EQU	0x19
SIO_B_DATA		EQU	0x1A
SIO_B_CMD		EQU	0x1B
PIO_A_DATA		EQU	0x1C
PIO_A_CMD		EQU	0x1D
PIO_B_DATA		EQU	0x1E
PIO_B_CMD		EQU	0x1F

; Memory
MAIN_COUNTER		EQU	0x8010
; Serial receive
RX_COUNTER		EQU	0x9000
RX_POINTER		EQU	0x9002  ; Write pointer
RX_READ			EQU	0x9004  ; Read pointer
RX_TYPE			EQU	0x9006  ; first byte of the message
RX_MAX_BYTES		EQU	0xFF - 0x06
; LCD
LCD_FLAG		EQU	0xE800
LCD_SRC			EQU	0xE801  ; Source for LCD data in shared memory
LCD_DEST		EQU	0xA000  ; Local memory copy destination for lcd data
LCD_BYTES		EQU	0xA0    ; 40 bytes per line, 4 lines = 160 = 0xA0 bytes
LCD_POINTER		EQU	0x8100  ; Pointer for writing bytes to the LCD_DEST buffer
LCD_WRITE_DEST		EQU	LCD_DEST
; Lamps
LAMP_SRC		EQU	0xEA00  ; Source for lamp data in shared memory
LAMP_DEST		EQU	0x9500  ; Local memory destination for lamp data
LAMP_BYTES		EQU	0x1B    ; 27 bytes for lamp data
; Macro to zero fill memory
ZFILL(ptr,len) MACRO
	LD  HL,ptr
	LD  DE,ptr+1
	LD  BC,len-1
	LD  (HL),0
	LDIR
ENDM

; Memory copy
MCOPY(src,dest,len) MACRO
	LD HL,src
	LD DE,dest
	LD BC, len
	LDIR
ENDM

; Send (blocking) data with SIO port A
TX_A(data) MACRO
	LD	A, data
	CALL	SIO_A_TX_BLOCKING
ENDM

CP_HL_C(value, jump) MACRO
	LD	A, H
	CP	value / 0x0100
	JP	C, jump
	LD	A, L
	CP	value % 0x0100
	JP	C, jump
ENDM
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
	; --- L5783 ---
	; Shifts out LAMP_BYTES bytes to the various lamps
	; Verified working
LAMP_UPDATE: PROC
	LD	HL,LAMP_DEST + LAMP_BYTES - 1
	LD	B,1Bh
loop:	LD	A,(HL)
	OUT	(01h),A
	OUT	(00h),A
	OUT	(03h),A
	OUT	(03h),A
	OUT	(03h),A
	OUT	(03h),A
	OUT	(03h),A
	OUT	(03h),A
	OUT	(03h),A
	OUT	(03h),A
	DEC	HL
	DJNZ	loop
	OUT	(02h),A
	RET
ENDP

	; --- L57A3 ---
LAMP_COPY:
	LD	HL,LAMP_SRC
	LD	DE,LAMP_DEST
	LD	BC,LAMP_BYTES
	LDIR
	RET
	; --- L0194 ---
INIT_CTC:
	LD	HL,CTC_1_DATA
	LD	C,10h
	LD	B,03h
	OTIR
	LD	HL,CTC_2_DATA	; address or value?
	LD	C,11h
	LD	B,02h
	OTIR
	LD	HL,CTC_3_DATA	; address or value?
	LD	C,12h
	LD	B,02h
	OTIR
	LD	HL,CTC_4_DATA	; address or value?
	LD	C,13h
	LD	B,02h
	OTIR
	RET

CTC_1_DATA:
	DB	CTC_VECTORS % 0x0100	; Interrupt vector location
	DB	05Dh	; Interrupt enabled, Counter, prescaler 16, rising edge, clk starts, time constant follows, no reset
	DB	0Ch	; Time constant
CTC_2_DATA:
	DB	5Dh	; No interrupt, Counter, prescaler 16, rising edge, clk starts, time constant follows, no reset
	DB	01h	; Time constant
CTC_3_DATA:
	DB	027h	; No Interrupt, timer, prescaler 16, falling edge, time constant follow, software reset
	DB	0A3h	; Time constant
CTC_4_DATA:
	DB	5Dh	; No interrupt, Counter, prescaler 16, rising edge, clk starts, time constant follows, no reset
	DB	01h	; Time constant
	; --- L0136 ---
INIT_PIO:
	LD	HL,PIO_A_INIT_DATA
	LD	C,1Dh
	LD	B,03h
	OTIR
	LD	HL,PIO_B_INIT_DATA
	LD	C,1Fh
	LD	B,03h
	OTIR
	RET

PIO_A_INIT_DATA:
	DB	0CFh	; Mode 3
	DB	00h	; All pins outputs
	DB	07h	; No interrupts
PIO_B_INIT_DATA:
	DB	0CFh	; Mode 3
	DB	00h	; All pins outputs
	DB	07h	; No interrupts
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
	DB "****************************************"	; -- INTERRUPT HANDLERS --
INT_SIO_B_TX_EMPTY:
	DI
	PUSH	AF
	LD	A, "z"
	OUT	(SIO_A_DATA), A
	POP	AF
	JP	0x8000

INT_SIO_B_STATUS_CHANGE:
	DI
	PUSH	AF
	LD	A, "x"
	OUT	(SIO_A_DATA), A
	POP	AF
	JP	0x8000

INT_SIO_B_RX_AVAILABLE:
	DI
	PUSH	AF
	IN	A, (SIO_B_DATA)
	LD	A, "c"
	OUT	(SIO_A_DATA), A
	POP	AF
	JP 0x8000

INT_SIO_B_ERROR:
	DI
	PUSH	AF
	LD	A, SIO_CMD_ERROR_RST
	OUT	(SIO_B_CMD), A
	IN	A, (SIO_B_DATA)
	LD	A, "v"
	OUT	(SIO_A_DATA), A
	POP	AF
	JP	0x8000

INT_SIO_A_TX_EMPTY:
	DI
	PUSH	AF
	LD	A, "T"
	OUT	(SIO_A_DATA), A
	POP	AF
	JP	0x8000

INT_SIO_A_STATUS_CHANGE:
	DI
	PUSH	AF
	LD	A, "S"
	OUT	(SIO_A_DATA), A
	POP	AF
	JP	0x8000

INT_SIO_A_RX_AVAILABLE: PROC
	DI
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	IN	A, (SIO_A_DATA)		; Read the character
	OUT	(SIO_A_DATA), A
	LD	D, A			; Tuck the read character into D
	LD	A, (RX_COUNTER)
	AND	A
	JR	Z, first_byte		; Seek for the start byte
	CP	RX_MAX_BYTES
	JR	Z, return		; Buffer full
	LD	A, D			; Restore read character
store:	LD	HL, (RX_POINTER)
	LD	(HL), A
	INC	HL
	LD	(RX_POINTER), HL
	LD	HL, RX_COUNTER
	INC	(HL)
	LD	A, (HL)
	OUT	(SIO_A_DATA), A		; Send the RX count
	JR	return
first_byte:
	LD	A, D			; Restore read character
	BIT	7, A
	JR	NZ, store		; Valid first byte
return: POP	HL
	POP	DE
	POP	BC
	POP	AF
	JP	0x8000
ENDP

INT_SIO_A_ERROR:
	DI
	PUSH	AF
	LD	A, SIO_CMD_ERROR_RST
	OUT	(SIO_A_CMD), A
	IN	A, (SIO_A_DATA)
	LD	A, "!"
	OUT	(SIO_A_DATA), A

	POP	AF
	JP	0x8000

INT_CTC_CH1:
	DI
	JP	0x8000

INT_CTC_CH2:
	DI
	JP	0x8000

INT_CTC_CH3:
	DI
	JP	0x8000

INT_CTC_CH4:
	DI
	JP	0x8000

INT_PIO_A:
	DI
	JP	0x8000

INT_PIO_B:
	DI
	JP	0x8000

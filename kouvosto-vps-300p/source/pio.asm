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

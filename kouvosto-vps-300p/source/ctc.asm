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

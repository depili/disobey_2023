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

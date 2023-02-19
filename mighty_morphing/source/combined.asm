FLAG_LEN EQU 19

ORG 0x0

START:
	DI
	IM	2
	LD	SP,0E7FFh	; Stack pointer
	LD HL, XOR_MORPH
	LD (HL), 0xee ; XOR imm8
	INC HL
	INC HL
	LD (HL), 0xad ; XOR L
	INC HL
	LD (HL), 0xc9 ; RET
	LD HL, FLAG_ENCRYPT
	LD DE, FLAG_DEST
	LD B, FLAG_LEN
copy_loop:
	LD A, E 				; Setup the morphing code to do XOR E XOR L RET
	LD (XOR_MORPH+1), A     ; By replacing the imm8 value of the first XOR
	LD A, (HL) 				; with E
	CALL XOR_MORPH
	LD (DE), A
	INC HL
	INC DE
	DJNZ copy_loop
	HALT

; Do you even morph?]
; The keys will be
; D  o     y  o  u     e  v  e  n     m  o  r  p  h  ?  ]
; 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35 36 37 38 39 3a
; 4e 4f 50 51 52 53 54 55 56 57 58 59 5a 5b 5c 5d 5e 5f 60
FLAG_ENCRYPT:
	db 22h
	db 09h
	db 5ah
	db 03h
	db 11h
	db 0bh
	db 5ah
	db 1fh
	db 10h
	db 03h
	db 04h
	db 4ah
	db 03h
	db 01h
	db 18h
	db 1ah
	db 0eh
	db 59h
	db 07h

SEEK 0x4242
ORG 0x4242

XOR_MORPH:					; This will be rewritten to XOR 00h; XOR L; RET by the initialization
	DB "FLAG"

FLAG_STRING:
	DB "DISOBEY["
FLAG_DEST:
	DB 18 DUP 0

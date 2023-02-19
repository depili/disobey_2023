FLAG_LEN EQU FLAG_KEY - FLAG_ENC

ORG 0x0

START:
	DI
	IM	2
	LD	SP,0E7FFh	; Stack pointer
	LD IX, FLAG_ENC
	LD IY, FLAG_KEY
	LD DE, FLAG_DEST
	LD B, FLAG_LEN
loop:
    LD A, (IX)
    LD H, (IY)
    XOR H
    PUSH AF
    LD (DE), A
    POP HL
    INC IX
    INC DE
    DEC B
    JR Z, hlt
    LD A, (IX)
    XOR L
    LD (DE), A
    INC IX
    INC IY
    INC DE
    DJNZ loop
hlt:
    HALT

FLAG_ENC:
    DB 0A8h ; D
    DB 4dh  ; I
    DB 4Bh  ; S
    DB 4bh  ; O
    DB 6Ch  ; B
    DB 41h  ; E
    DB 96h  ; Y
    DB 57h  ; [
    DB 0dh  ; r
    DB 61h  ; E
    DB 0bh  ; g
    DB 61h  ; A
    DB 2ah  ; b
    DB 55h  ; u
    DB 0AFh  ; s
    DB 13h  ; 3
    DB 0E7h  ; l
    DB 1dh  ; 1
    DB 0E0h  ; F
    DB 33h  ; 3
    DB 30h  ; 4
    DB 57h  ; w
    DB 0A8h  ; I
    DB 66h  ; n
    DB 7Eh  ; ]

FLAG_KEY:
    DB 0ech
    DB 18h
    DB 2eh
    DB 0cfh
    DB 7fh
    DB 6ch
    DB 48h
    DB 0dch
    DB 8bh
    DB 0a6h
    DB 04h
    DB 0e1h
    DB 23h
    DB 0c9h
    DB 0c9h
    DB 1dh

ORG 2000h

FLAG_DEST:
    DB "FLAG HERE"
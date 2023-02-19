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

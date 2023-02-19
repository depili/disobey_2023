#!/bin/sh
FILES="equ.asm macros.asm main.asm lamp.asm ctc.asm pio.asm sio.asm lcd.asm interrupts.asm"
# Combine the files
cat $FILES > combined.asm
mono ../yaza.exe combined.asm && srec_cat combined.bin -binary -o combined.hex -intel

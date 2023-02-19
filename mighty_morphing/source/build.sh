#!/bin/sh
FILES="main.asm"
# Combine the files
cat $FILES > combined.asm
mono ../yaza.exe combined.asm && srec_cat combined.bin -binary -o combined.hex -intel

# Mighty Morphing

A really small binary for a Z80, that uses self modifying code to obfuscate a key.

## Description

Finster has been able to obtain this piece of highly classified power rangers hq code by dumping their Z80 workstation. We need to figure out their top secret access key ASAP.

## Difficulty

Would probably classify this as a medium challenge. The code is really short, but selft modifying for the two keys. The keys end up being just the lower 8 bits of both the source and destination addresses.

## Flags

* DISOBEY[Do you even morph?]

## Walkthrough

The assembler source is in source/ compiled using yaza assembler: https://github.com/toptensoftware/yazd

1. Load the binary into ghidra
2. Decompile from 0x0000
3. Alter the fallthrough on 0x0027 to for example address 0 to get usable decompilation
  * ghidra conveniently assumes we are waiting for a wakeup on the HALT instruction and adds bunch of garbage to the code flow
4. see the writes to addresses around 0x4242
5. use the bytes window to patch the said bytes
6. decompile FUN_ram_4242 after the patching
7. figure out the XORs by seeing the effect of writing to the given byte in the copy loop.

## Contact info

vpalmu@depili.fi
Depili @ ircnet
+358 40 5278601

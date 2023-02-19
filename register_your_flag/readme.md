# Register your flag

Yet another small Z80 binary, this time abusing the flags register as part of the the xor key

## Description

The intel reports that Kouvosto Telecom is somehow using the flag register to encrypt their credentials on their hyper modern Z80 based workstations.

## Difficulty

If doing this by hand it will be decently challenging, easy mode is to use an emulator

## Flags

* DISOBEY[rEgAbus3l1F34wIn]

## Walkthrough

Best way to see the program working would be to load the register_your_flag_source.asm to https://www.asm80.com/ (new file -> give it a name and select Z80 as CPU) and check the simulator output. The flag will be at 0x2000. Ghidras decompiler isn't really helpful in here...

## Contact info

vpalmu@depili.fi
Depili @ ircnet
+358 40 5278601

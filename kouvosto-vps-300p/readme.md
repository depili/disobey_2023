# Kouvosto VPS-300P CTF challenge

This is a challenge based on my old code for reverse engineered vps-300p video mixer console. The suggested name is also a hint, as with it one could find the asm code I used as the base and thus make the challenge much easier.

## Description

Our best agent was able to infiltrate Kouvosto Telecom and dump the firmware of their latest key distribution system. As expected from them they have used old technology from the 1980, and the terminal is apparently running on some kind of Z80 platform.

## Difficulty

I'm not so sure on it. There are two flags in there, first is made by just combining a LCD splash string clearly visible on the binary and the character-by-character writes to the lcd. Finding the second requires a better look at the LCD update routine, as it actually writes another xorred string to a offset on the display, forming a second flag.

## Flags

* DISOBEY[lcdSystemTryHarder] (the easier one)
* DISOBEY[lcdKouvostoTelecomSecureSystem] (the harder one)

## Walkthrough

Load the binary kouvosto-vps-300p into ghidra or what ever you want to use for reverse engineering, select z80 and get to it. I have included a ready made ghidra project with labels applied and the asm sources used to build the binary with yaza assembler: https://github.com/toptensoftware/yazd

If you need extra data on the walkthrough then feel free to ask

## Possible hints

Hinting about https://github.com/depili/vps-300p/tree/master/rom/rom1_custom could reveal the code used to base the challenge on and will make the reversing much easier.

## Contact info

vpalmu@depili.fi
Depili @ ircnet
+358 40 5278601

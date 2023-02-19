# Kouvosto Telecom TOTP terminal

Challenge involving electronics reverse engineering and using a logic analyser. A device constructed on a electronics breadboard under a protective see-through cover and a cheap-ass 8 channel logic analyser will be provided.

The circuit consists of a arduino nano, 74-series logic chips; two 04 hex-inverters and one 595 shift register, Hitachi HD44780 compatible LCD and some passive components that don't affect the signals. The circuit will need to be powered from a USB charger. The arduino USB connection should be treated as being out of scope.

The provided and connected logic analyzer is a cheap fx2la -based one and it is supported by the open source logic analyser software package sigrok and it's graphical UI pulseview, which is available for linux, osx and windows.

The aim is to have the victims^Wcontestants first visually figure out the circuit and then connect their laptop via usb to the logic analyser to get the signals and then figure out the flag from the signal capture. In case of magic smoke the example capture can also be provided.

As depending on lighting at the venue reading the chip markings might be hard it is suggested to provide their types in the challenge description.

Included files:
* kt_totp_arduino_code/ - The code running on the arduino, including a modified LCD library to deal with the circuit
  * 595_lcd.ino - main program
  * lcd.cpp - modified LCD library code
  * lcd.h - modified LCD library headers
* kt_totp_breadboard.png - A clean generated image of the breadboard connecitions
* kt_totp_capture.pvs & kt_totp_capture.sr - sigrok (& pulseview) files for the logic analyser capture
* kt_totp_decode.rb - example decoder for the captured SPI bytes to flag
* kt_totp_device_photo.jpeg - A photo of the hardware package
* kt_totp_pulseview.png - Screenshot of pulseview session, highlighting the few cryptic UI buttons
* kt_totp_spi_bytes.bin - Raw extracted SPI bytes from the logic capture
* readme.md - no clue what this is

## Description

We have secured a secret development prototype of a Kouvosto Telecom TOTP code generator built on a electronics breadboard. Unfortunately the display on the prototype seems to be too small and we can't get the code. The RD department has spent most of their budget on a fancy fx2la logic analyser to work with sigrok but they haven't been able to crack the military grade encryption. Can you?

The circuit seems to be using the following active components:
* Arduino nano
* Hitachi HD44780 compatible LCD
* Two 74AC04 military grade encryption chips
* One 74AHC595 advanced encryption chip

## Difficulty

For someone experienced in electronics this shouldn't be too hard, but if one doesn't have a clue about the basics of digital signals and arduino then it will need a decent amount of studying. Probably better to mark it as hard due to unfamiliar tools required?

## Possible hints

* Providing the cleaned up breadboard connection diagram in `kt_totp_breadboard.png` should help understanding the connections.
* Telling to add a SPI decoder with ch7 = CLK, ch6=CS, ch5=MOSI, CS# polarity = active-high gets one the data going to the shift register
  * the "Decoder bytes view" from the dropdown from the first icon on the pulseview window allows one to save the raw decoded bytes to a file

## Flags

* DISOBEY[W3N33DbIggeRScr3en]

## Walkthrough

1. Figure out the connections and what signals are inverted from the circuit
2. Install and open pulseview
3. Open the connect to device window (menu bar, the dropdown button with text like "Demo device" on it)
4. Select fx2lafw as the device type
5. Scan for devices with the selected driver, select the found device
6. Disable the analog channel from the button next to the select device one
7. Do a capture of the signals with pulseview, the whole sequence of transmissions repeats every 500ms
  * Using the maximum sample rate supported, 24MHz is recommended, 50M samples is enough to capture few repetitions of the signals
  * `kt_totp_capture.sr` has example capture, with the relevant signals having been renamed
8. Add a SPI decoder with D7 = CLK, D6=CS, D5=MOSI, CS# polarity = active-high gets one the data going to the shift register
  * The add decoder button is the one with the yellow-and-green graph on it on the toolbar.
  * To modify the decoder settings double click on the decoder name (SPI) on the trace view
9. Use the view dropdown to see the decoded bytes
10. Select "SPI" and "MOSI" on the bytes panel
11. Use the save icon to save the data as raw binary to a file. `kt_totp_spi_bytes.bin` has example data
12. Write a script to analyse the raw bytes, see `kt_totp_decode.rb` for one implementation
13. Get the flag


## Contact info

vpalmu@depili.fi
Depili @ ircnet
+358 40 5278601

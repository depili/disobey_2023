#!/usr/bin/env ruby

# Usage: kt_totp_decode.rb <SPI_bytes_file>

# Bit positions for the 595 shift register outputs
RS = 1
Enable = 3
D4 = 4
D5 = 7
D6 = 6
D7 = 2

char = 0
stage = 0

File.open(ARGV.last, "rb") do |f|
	f.each_byte do |b|
		# The data we got from the capture is inverted, so set lines are "0"
		if b[Enable] == 0 then
			# Enable bit is set

			if b[RS] == 0 then
				# A Write targeting the display ram
				# The display is in 4 bit bus mode, so first transaction will include the most significant 4 bytes
				# And the one after that will have the least significant bytes

				# We need to invert the middle bytes of each nibble to get the true output to the display
				if stage == 0 then
					char = 0
					char |= (b[D4]==1 ? 1 : 0) << 4
					char |= (b[D5]==1 ? 0 : 1) << 5
					char |= (b[D6]==1 ? 0 : 1) << 6
					char |= (b[D7]==1 ? 1 : 0) << 7
					stage = 1
				elsif stage == 1 then
					char |= (b[D4]==1 ? 1 : 0) << 0
					char |= (b[D5]==1 ? 0 : 1) << 1
					char |= (b[D6]==1 ? 0 : 1) << 2
					char |= (b[D7]==1 ? 1 : 0) << 3
					stage = 0
					puts "Char: #{char.to_s(2).rjust(8, "0")} #{char.chr}"
				end
			end
		end
	end
end

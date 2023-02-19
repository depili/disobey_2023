#!/usr/bin/env ruby
require 'serialport'

Baud = 38400
Delay = 0.5

module VPS300
  def send_lamps(offset, data)
    msg = [0x80, offset, data].pack("C*")
    write msg
  end
end


sp = SerialPort.new(ARGV[0], Baud, 8, 1, SerialPort::NONE)
# sp = Serial.new ARGV.last, Baud, 8, 1
sp.extend(VPS300)

# sp.send_lamps(0x00,0xff)

(0..0x1A).each do |offset|
  data = 0x01
  8.times do
    puts "Sending lamp packet: offset=#{offset}\tdata=#{data}"
    sp.send_lamps(offset, data)
    sleep(Delay)
    data = data << 1
  end
  puts "Sending lamp packet: offset=#{offset}\tdata=0"
  sp.send_lamps(offset, 0x00)
  sleep(Delay)
end
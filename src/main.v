module main

import os
import peripherals.bootrom
import gameboy

fn main() {
	bootrom_file_name := os.args[1] or { panic('please insert bootrom file name') }
	bootrom_file := os.read_bytes(bootrom_file_name)!
	bootrom_data := [0x100]u8{init: bootrom_file[index]}
	b := bootrom.BootRom.new(bootrom_data)
	mut g := gameboy.Gameboy.new(b)
	g.run()!
}

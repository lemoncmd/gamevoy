module main

import peripherals.bootrom
import gameboy

fn main() {
	b := bootrom.BootRom.new([0x100]u8{})
	mut g := gameboy.Gameboy.new(b)
	g.run()
}

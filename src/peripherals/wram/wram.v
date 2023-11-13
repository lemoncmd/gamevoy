module wram

const size = 0x2000

pub struct WRam {
mut:
	ram [size]u8
}

pub fn WRam.new() WRam {
	return WRam{}
}

pub fn (w WRam) read(addr u16) u8 {
	return w.ram[addr & (size - 1)]
}

pub fn (mut w WRam) write(addr u16, val u8) {
	w.ram[addr & (size - 1)] = val
}

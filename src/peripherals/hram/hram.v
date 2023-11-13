module hram

const size = 0x80

pub struct HRam {
mut:
	ram [size]u8
}

pub fn HRam.new() HRam {
	return HRam{}
}

pub fn (h HRam) read(addr u16) u8 {
	return h.ram[addr & (size - 1)]
}

pub fn (mut h HRam) write(addr u16, val u8) {
	h.ram[addr & (size - 1)] = val
}

module bootrom

const size = 0x100

pub struct BootRom {
	rom [size]u8
}

pub fn BootRom.new(rom [size]u8) BootRom {
	return BootRom{rom}
}

pub fn (b BootRom) read(addr u16) u8 {
	return b.rom[addr]
}

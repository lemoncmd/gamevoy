module bootrom

pub struct BootRom {
	rom []u8
mut:
	active bool
}

pub fn BootRom.new(rom []u8) BootRom {
	return BootRom{rom, true}
}

pub fn (b &BootRom) read(addr u16) u8 {
	return b.rom[addr]
}

pub fn (mut b BootRom) write(addr u16, val u8) {
	b.active = b.active && val == 0
}

pub fn (b &BootRom) is_active() bool {
	return b.active
}

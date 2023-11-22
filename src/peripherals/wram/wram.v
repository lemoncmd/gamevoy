module wram

const size = 0x8000

pub struct WRam {
mut:
	ram  [size]u8
	bank u8 = 1
}

pub fn WRam.new() WRam {
	return WRam{}
}

pub fn (w &WRam) read(addr u16) u8 {
	return match addr {
		0xC000...0xCFFF { w.ram[addr & 0xFFF] }
		0xD000...0xDFFF { w.ram[(u16(w.bank) << 12) | (addr & 0xFFF)] }
		0xE000...0xFDFF { w.ram[(u16(w.bank) << 12) | (addr & 0xFFF)] }
		0xFF70 { w.bank }
		else { panic('unexpected address for wram: 0x${addr:04X}') }
	}
}

pub fn (mut w WRam) write(addr u16, val u8) {
	match addr {
		0xC000...0xCFFF {
			w.ram[addr & 0xFFF] = val
		}
		0xD000...0xDFFF {
			w.ram[(u16(w.bank) << 12) | (addr & 0xFFF)] = val
		}
		0xE000...0xFDFF {
			w.ram[(u16(w.bank) << 12) | (addr & 0xFFF)] = val
		}
		0xFF70 {
			if 0 <= val && val <= 7 {
				w.bank = if val != 0 {
					val
				} else {
					1
				}
			}
		}
		else {}
	}
}

module peripherals

import peripherals.bootrom { BootRom }
import peripherals.wram { WRam }
import peripherals.hram { HRam }

pub struct Peripherals {
mut:
	bootrom bootrom.BootRom
	wram    wram.WRam
	hram    hram.HRam
}

pub fn Peripherals.new(br BootRom) Peripherals {
	return Peripherals{
		bootrom: br
		wram: WRam.new()
		hram: HRam.new()
	}
}

pub fn (p Peripherals) read(addr u16) u8 {
	return match addr {
		0x0000...0x00FF {
			if p.bootrom.is_active() {
				p.bootrom.read(addr)
			} else {
				0xFF
			}
		}
		0xC000...0xFDFF {
			p.wram.read(addr)
		}
		0xFF80...0xFFFE {
			p.hram.read(addr)
		}
		else {
			0xFF
		}
	}
}

pub fn (mut p Peripherals) write(addr u16, val u8) {
	match addr {
		0xC000...0xFDFF { p.wram.write(addr, val) }
		0xFF50 { p.bootrom.write(addr, val) }
		0xFF80...0xFFFE { p.hram.write(addr, val) }
		else {}
	}
}

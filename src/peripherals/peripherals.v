module peripherals

import peripherals.bootrom { BootRom }
import peripherals.cartridge { Cartridge }
import peripherals.wram { WRam }
import peripherals.hram { HRam }
import peripherals.ppu { CgbPpu, DmgPpu, Ppu }
import peripherals.apu { Apu }
import peripherals.timer { Timer }
import peripherals.joypad { Joypad }
import cpu.interrupts { Interrupts }

pub struct Peripherals {
mut:
	bootrom bootrom.BootRom
	wram    wram.WRam
	hram    hram.HRam
pub mut:
	cartridge cartridge.Cartridge
	ppu       ppu.Ppu
	apu       apu.Apu
	timer     timer.Timer
	joypad    joypad.Joypad
}

pub fn Peripherals.new(br BootRom, cg Cartridge) Peripherals {
	return Peripherals{
		bootrom: br
		cartridge: cg
		wram: WRam.new()
		hram: HRam.new()
		ppu: if cg.cgb_flag {
			ppu.Ppu(CgbPpu.new())
		} else {
			ppu.Ppu(DmgPpu.new())
		}
		apu: Apu.new()
		timer: Timer.new()
		joypad: Joypad.new()
	}
}

pub fn (p &Peripherals) read(ins &Interrupts, addr u16) u8 {
	return match addr {
		0x0000...0x00FF {
			if p.bootrom.is_active() {
				p.bootrom.read(addr)
			} else {
				p.cartridge.read(addr)
			}
		}
		0x0100...0x7FFF {
			p.cartridge.read(addr)
		}
		0x8000...0x9FFF {
			p.ppu.read(addr)
		}
		0xA000...0xBFFF {
			p.cartridge.read(addr)
		}
		0xC000...0xFDFF {
			p.wram.read(addr)
		}
		0xFE00...0xFE9F {
			p.ppu.read(addr)
		}
		0xFF00 {
			p.joypad.read()
		}
		0xFF04...0xFF07 {
			p.timer.read(addr)
		}
		0xFF0F {
			ins.read(addr)
		}
		0xFF10...0xFF26, 0xFF30...0xFF3F {
			p.apu.read(addr)
		}
		0xFF40...0xFF4B {
			p.ppu.read(addr)
		}
		0xFF80...0xFFFE {
			p.hram.read(addr)
		}
		0xFFFF {
			ins.read(addr)
		}
		else {
			0xFF
		}
	}
}

pub fn (mut p Peripherals) write(mut ins Interrupts, addr u16, val u8) {
	match addr {
		0x0000...0x00FF {
			if !p.bootrom.is_active() {
				p.cartridge.write(addr, val)
			}
		}
		0x0100...0x7FFF {
			p.cartridge.write(addr, val)
		}
		0x8000...0x9FFF {
			p.ppu.write(addr, val)
		}
		0xA000...0xBFFF {
			p.cartridge.write(addr, val)
		}
		0xC000...0xFDFF {
			p.wram.write(addr, val)
		}
		0xFE00...0xFE9F {
			p.ppu.write(addr, val)
		}
		0xFF00 {
			p.joypad.write(addr, val)
		}
		0xFF04...0xFF07 {
			p.timer.write(addr, val)
		}
		0xFF0F {
			ins.write(addr, val)
		}
		0xFF10...0xFF26, 0xFF30...0xFF3F {
			p.apu.write(addr, val)
		}
		0xFF40...0xFF4B {
			p.ppu.write(addr, val)
		}
		0xFF50 {
			p.bootrom.write(addr, val)
		}
		0xFF70 {
			if p.cartridge.cgb_flag {
				p.wram.write(addr, val)
			}
		}
		0xFF80...0xFFFE {
			p.hram.write(addr, val)
		}
		0xFFFF {
			ins.write(addr, val)
		}
		else {}
	}
}

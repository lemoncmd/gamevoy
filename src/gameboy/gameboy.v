module gameboy

import cpu { Cpu }
import peripherals { Peripherals }
import peripherals.bootrom { BootRom }

pub struct Gameboy {
	cpu         Cpu
	peripherals Peripherals
}

pub fn Gameboy.new(b BootRom) &Gameboy {
	c := Cpu.new()
	p := Peripherals.new(b)
	return &Gameboy{
		cpu: c
		peripherals: p
	}
}

pub fn (mut g Gameboy) run() {
}

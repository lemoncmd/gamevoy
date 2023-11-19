module gameboy

import gg
import cpu { Cpu }
import peripherals { Peripherals }
import peripherals.bootrom { BootRom }
import peripherals.cartridge { Cartridge }

pub struct Gameboy {
mut:
	cpu         Cpu
	peripherals Peripherals
	gg          ?&gg.Context
	image_idx   int
}

pub fn Gameboy.new(br BootRom, cg Cartridge) &Gameboy {
	c := Cpu.new()
	p := Peripherals.new(br, cg)
	mut ret := &Gameboy{
		cpu: c
		peripherals: p
	}
	ret.cpu.init(ret.peripherals)
	ret.init_gg()
	return ret
}

pub fn (mut g Gameboy) run() ! {
	mut gg_ctx := g.gg or { return error('gg is not initialized') }

	gg_ctx.run()
}

fn (mut g Gameboy) emulate_cycle() bool {
	g.cpu.emulate_cycle(mut g.peripherals)
	g.peripherals.timer.emulate_cycle(mut g.cpu.interrupts)
	if g.peripherals.ppu.emulate_cycle() {
		g.draw_lcd(g.peripherals.ppu.pixel_buffer())
		return true
	}
	return false
}

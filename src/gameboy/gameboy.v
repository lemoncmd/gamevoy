module gameboy

import os
import gg { Context }
import cpu { Cpu }
import peripherals { Peripherals }
import peripherals.bootrom { BootRom }
import peripherals.cartridge { Cartridge }
import peripherals.joypad { Button }

pub struct Gameboy {
mut:
	cpu            Cpu
	peripherals    Peripherals
	gg             ?&Context
	image_idx      int
	save_file_name string
}

pub fn Gameboy.new(br BootRom, cg Cartridge, save_file_name string) &Gameboy {
	c := Cpu.new()
	p := Peripherals.new(br, cg)
	mut ret := &Gameboy{
		cpu: c
		peripherals: p
		save_file_name: save_file_name
	}
	ret.cpu.init(ret.peripherals)
	ret.load()
	ret.init_audio()
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
	g.peripherals.apu.emulate_cycle()
	if addr := g.peripherals.ppu.oam_dma {
		g.peripherals.ppu.oam_dma_emulate_cycle(g.peripherals.read(g.cpu.interrupts, addr))
	}
	if g.peripherals.ppu.emulate_cycle(mut g.cpu.interrupts) {
		g.draw_lcd(g.peripherals.ppu.pixel_buffer())
		return true
	}
	return false
}

fn (mut g Gameboy) on_key_down(b Button) {
	g.peripherals.joypad.button_down(mut g.cpu.interrupts, b)
}

fn (mut g Gameboy) on_key_up(b Button) {
	g.peripherals.joypad.button_up(b)
}

fn (g &Gameboy) save() {
	if !g.peripherals.cartridge.is_savable() {
		return
	}
	data := g.peripherals.cartridge.save()
	mut file := os.create(g.save_file_name) or { return }
	file.write(data) or { return }
	println('saved to ${g.save_file_name}')
}

fn (mut g Gameboy) load() {
	data := os.read_bytes(g.save_file_name) or { return }
	g.peripherals.cartridge.load(data)
}

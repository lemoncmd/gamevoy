module gameboy

import os
import time
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
	timer_cycle    u8
	last_utc       i64
}

pub fn Gameboy.new(br BootRom, cg Cartridge, save_file_name string) &Gameboy {
	c := Cpu.new()
	p := Peripherals.new(br, cg)
	mut ret := &Gameboy{
		cpu:            c
		peripherals:    p
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
	clock_rate := if g.cpu.interrupts.stop_count > 0 {
		g.cpu.interrupts.stop_count--
		0
	} else if g.cpu.interrupts.read(0xFF4D) & 0x80 == 0 {
		1
	} else {
		2
	}
	if g.timer_cycle == 0 {
		g.last_utc = time.now().unix_milli()
		g.timer_cycle = 255
	} else {
		g.timer_cycle--
	}
	in_hdma_transfer := if g.peripherals.ppu.hdma.in_transfer() {
		g.peripherals.ppu.hdma_emulate_cycle(g.peripherals.read(g.cpu.interrupts, g.peripherals.ppu.dma_source))
	} else {
		false
	}
	for _ in 0 .. clock_rate {
		if !in_hdma_transfer {
			g.cpu.emulate_cycle(mut g.peripherals)
		}
		g.peripherals.timer.emulate_cycle(mut g.cpu.interrupts)
		if addr := g.peripherals.ppu.oam_dma {
			g.peripherals.ppu.oam_dma_emulate_cycle(g.peripherals.read(g.cpu.interrupts,
				addr))
		}
		g.peripherals.serial.emulate_cycle(mut g.cpu.interrupts)
	}
	g.peripherals.cartridge.rtc.emulate_cycle(g.last_utc)
	g.peripherals.apu.emulate_cycle()
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

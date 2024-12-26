module ppu

import cpu.interrupts { Interrupts }

pub const lcd_width = 160

pub const lcd_height = 144

enum Mode {
	hblank
	vblank
	oamscan
	drawing
}

@[flag]
enum Stat {
	mode_l
	mode_h
	lyc_eq_ly
	hblank_int
	vblank_int
	oam_scan_int
	lyc_eq_ly_int
	always_1
}

fn (s Stat) get_mode() Mode {
	return match u8(s) & 0x03 {
		0 { .hblank }
		1 { .vblank }
		2 { .oamscan }
		3 { .drawing }
		else { .hblank }
	}
}

fn (mut s Stat) set_mode(m Mode) {
	match m {
		.hblank {
			s.clear(.mode_l)
			s.clear(.mode_h)
		}
		.vblank {
			s.set(.mode_l)
			s.clear(.mode_h)
		}
		.oamscan {
			s.clear(.mode_l)
			s.set(.mode_h)
		}
		.drawing {
			s.set(.mode_l)
			s.set(.mode_h)
		}
	}
}

type HdmaRun = u8
type HdmaStop = u8

type Hdma = HdmaRun | HdmaStop

pub fn (h Hdma) in_transfer() bool {
	return match h {
		HdmaRun { true }
		HdmaStop { false }
	}
}

pub interface Ppu {
	dma_source u16
	read(addr u16) u8
	pixel_buffer() []u8
mut:
	oam_dma ?u16
	hdma    Hdma
	write(addr u16, val u8)
	oam_dma_emulate_cycle(val u8)
	hdma_emulate_cycle(val u8) bool
	emulate_cycle(mut ints Interrupts) bool
}

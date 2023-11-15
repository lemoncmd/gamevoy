module ppu

pub const lcd_width = 160

pub const lcd_height = 144

enum Mode {
	hblank
	vblank
	oamscan
	drawing
}

[flag]
enum Lcdc as u8 {
	bg_window_enable
	sprite_enable
	sprite_size
	bg_title_map
	tile_data_addressing_mode
	window_enable
	window_tile_map
	ppu_enable
}

[flag]
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

pub struct Ppu {
mut:
	lcdc   Lcdc
	stat   Stat = .always_1
	scy    u8
	scx    u8
	ly     u8
	lyc    u8
	bgp    u8
	obp0   u8
	obp1   u8
	wy     u8
	wx     u8
	cycles u8 = 1
	vram   [0x2000]u8
	oam    [0xA0]u8
	buffer [lcd_width * lcd_height]u8
}

pub fn Ppu.new() Ppu {
	mut p := Ppu{}
	p.stat.set_mode(.oamscan)
	return p
}

pub fn (p &Ppu) read(addr u16) u8 {
	return match addr {
		0x8000...0x9FFF {
			if p.stat.get_mode() != .drawing {
				p.vram[addr & 0x1FFF]
			} else {
				0xFF
			}
		}
		0xFE00...0xFE9F {
			if p.stat.get_mode() in [.hblank, .vblank] {
				p.oam[addr & 0xFF]
			} else {
				0xFF
			}
		}
		0xFF40 {
			u8(p.lcdc)
		}
		0xFF41 {
			u8(p.stat)
		}
		0xFF42 {
			p.scy
		}
		0xFF43 {
			p.scx
		}
		0xFF44 {
			p.ly
		}
		0xFF45 {
			p.lyc
		}
		0xFF47 {
			p.bgp
		}
		0xFF48 {
			p.obp0
		}
		0xFF49 {
			p.obp1
		}
		0xFF4A {
			p.wy
		}
		0xFF4B {
			p.wx
		}
		else {
			panic('unexpected address for ppu: ${addr:04x}')
		}
	}
}

pub fn (mut p Ppu) write(addr u16, val u8) {
	match addr {
		0x8000...0x9FFF {
			if p.stat.get_mode() != .drawing {
				p.vram[addr & 0x1FFF] = val
			}
		}
		0xFE00...0xFE9F {
			if p.stat.get_mode() in [.hblank, .vblank] {
				p.oam[addr & 0xFF] = val
			}
		}
		0xFF40 {
			p.lcdc = unsafe { Lcdc(val) }
		}
		0xFF41 {
			s := unsafe { Stat(val) }
			if s.has(.hblank_int) {
				p.stat.set(.hblank_int)
			}
			if s.has(.vblank_int) {
				p.stat.set(.vblank_int)
			}
			if s.has(.oam_scan_int) {
				p.stat.set(.oam_scan_int)
			}
			if s.has(.lyc_eq_ly_int) {
				p.stat.set(.lyc_eq_ly_int)
			}
		}
		0xFF42 {
			p.scy = val
		}
		0xFF43 {
			p.scx = val
		}
		0xFF45 {
			p.lyc = val
		}
		0xFF47 {
			p.bgp = val
		}
		0xFF48 {
			p.obp0 = val
		}
		0xFF49 {
			p.obp1 = val
		}
		0xFF4A {
			p.wy = val
		}
		0xFF4B {
			p.wx = val
		}
		else {
			panic('unexpected address for ppu: ${addr:04x}')
		}
	}
}

fn (p &Ppu) get_pixel_from_tile(tile_idx u16, row u8, col u8) u8 {
	r := u16(row * 2)
	c := u16(7 - col)
	tile_addr := tile_idx << 4
	low := p.vram[(tile_addr | r) & 0x1FFF]
	high := p.vram[(tile_addr | (r + 1)) & 0x1FFF]
	return (((high >> c) & 1) << 1) | ((low >> c) & 1)
}

fn (p &Ppu) get_tile_idx_from_tile_map(tile_map bool, row u8, col u8) u16 {
	start_addr := 0x1800 | (u16(tile_map) << 10)
	ret := p.vram[start_addr | ((u16(row) << 5) + u16(col))]
	return if p.lcdc.has(.tile_data_addressing_mode) {
		ret
	} else {
		ret + 0x100
	}
}

fn (mut p Ppu) render_bg() {
	if !p.lcdc.has(.bg_window_enable) {
		return
	}
	y := p.ly + p.scy
	for i in 0 .. ppu.lcd_width {
		x := i + p.scx

		tile_idx := p.get_tile_idx_from_tile_map(p.lcdc.has(.bg_title_map), y >> 3, x >> 3)

		pixel := p.get_pixel_from_tile(tile_idx, y & 7, x & 7)

		p.buffer[ppu.lcd_width * int(p.ly) + i] = match (p.bgp >> (pixel << 1)) & 0b11 {
			0b00 { 0xFF }
			0b01 { 0xAA }
			0b10 { 0x55 }
			else { 0x00 }
		}
	}
}

fn (mut p Ppu) check_lyc_eq_ly() {
	if p.ly == p.lyc {
		p.stat.set(.lyc_eq_ly)
	} else {
		p.stat.clear(.lyc_eq_ly)
	}
}

pub fn (mut p Ppu) emulate_cycle() bool {
	if !p.lcdc.has(.ppu_enable) {
		return false
	}

	p.cycles--
	if p.cycles > 0 {
		return false
	}

	mut ret := false
	match p.stat.get_mode() {
		.hblank {
			p.ly++
			if p.ly < 144 {
				p.stat.set_mode(.oamscan)
				p.cycles = 20
			} else {
				p.stat.set_mode(.vblank)
				p.cycles = 114
			}
			p.check_lyc_eq_ly()
		}
		.vblank {
			p.ly++
			if p.ly > 153 {
				ret = true
				p.ly = 0
				p.stat.set_mode(.oamscan)
				p.cycles = 20
			} else {
				p.cycles = 114
			}
			p.check_lyc_eq_ly()
		}
		.oamscan {
			p.stat.set_mode(.drawing)
			p.cycles = 43
		}
		.drawing {
			p.render_bg()
			p.stat.set_mode(.hblank)
			p.cycles = 51
		}
	}
	return ret
}

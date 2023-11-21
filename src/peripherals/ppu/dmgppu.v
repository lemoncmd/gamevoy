module ppu

import util
import cpu.interrupts { Interrupts }

@[flag]
enum Lcdc as u8 {
	bg_window_enable
	sprite_enable
	sprite_size
	bg_tile_map
	tile_data_addressing_mode
	window_enable
	window_tile_map
	ppu_enable
}

struct Sprite {
	y        u8
	x        u8
	tile_idx u8
	flags    SpriteFlag
}

@[flag]
enum SpriteFlag as u8 {
	unused0
	unused1
	unused2
	unused3
	palette
	x_flip
	y_flip
	obj2bg_priority
}

pub struct DmgPpu {
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
	wly    u8
	cycles u8 = 20
	vram   [0x2000]u8
	oam    [0xA0]u8
	buffer [23040]u8
pub mut:
	oam_dma ?u16
}

pub fn DmgPpu.new() DmgPpu {
	mut p := DmgPpu{}
	p.stat.set_mode(.oamscan)
	return p
}

pub fn (p &DmgPpu) read(addr u16) u8 {
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
				if p.oam_dma == none {
					p.oam[addr & 0xFF]
				} else {
					0xFF
				}
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

pub fn (mut p DmgPpu) write(addr u16, val u8) {
	match addr {
		0x8000...0x9FFF {
			if p.stat.get_mode() != .drawing {
				p.vram[addr & 0x1FFF] = val
			}
		}
		0xFE00...0xFE9F {
			if p.stat.get_mode() in [.hblank, .vblank] && p.oam_dma == none {
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
		0xFF46 {
			p.oam_dma = u16(val) << 8
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
			panic('unexpected address for ppu: 0x${addr:04x}')
		}
	}
}

fn (p &DmgPpu) get_pixel_from_tile(tile_idx u16, row u8, col u8) u8 {
	r := u16(row * 2)
	c := u16(7 - col)
	tile_addr := tile_idx << 4
	low := p.vram[(tile_addr | r) & 0x1FFF]
	high := p.vram[(tile_addr | (r + 1)) & 0x1FFF]
	return (((high >> c) & 1) << 1) | ((low >> c) & 1)
}

fn (p &DmgPpu) get_tile_idx_from_tile_map(tile_map bool, row u8, col u8) u16 {
	start_addr := 0x1800 | (u16(tile_map) << 10)
	ret := p.vram[start_addr | ((u16(row) << 5) + u16(col))]
	return if p.lcdc.has(.tile_data_addressing_mode) {
		u16(ret)
	} else {
		u16(i16(i8(ret)) + 0x100)
	}
}

fn (mut p DmgPpu) render_bg(mut bg_prio [160]bool) {
	if !p.lcdc.has(.bg_window_enable) {
		return
	}
	y := p.ly + p.scy
	for i in 0 .. lcd_width {
		x := i + p.scx

		tile_idx := p.get_tile_idx_from_tile_map(p.lcdc.has(.bg_tile_map), y >> 3, x >> 3)

		pixel := p.get_pixel_from_tile(tile_idx, y & 7, x & 7)

		p.buffer[lcd_width * int(p.ly) + i] = match (p.bgp >> (pixel << 1)) & 0b11 {
			0b00 { 0xFF }
			0b01 { 0xAA }
			0b10 { 0x55 }
			else { 0x00 }
		}
		bg_prio[i] = pixel != 0
	}
}

fn (mut p DmgPpu) render_window(mut bg_prio [160]bool) {
	if !p.lcdc.has(.bg_window_enable) || !p.lcdc.has(.window_enable) || p.wy > p.ly {
		return
	}
	mut wly_add := u8(0)
	y := p.wly
	for i in 0 .. lcd_width {
		x, overflow := util.sub_8(i, p.wx - 7, 0)
		if overflow > 0 {
			continue
		}
		wly_add = 1

		tile_idx := p.get_tile_idx_from_tile_map(p.lcdc.has(.window_tile_map), y >> 3,
			x >> 3)

		pixel := p.get_pixel_from_tile(tile_idx, y & 7, x & 7)

		p.buffer[lcd_width * int(p.ly) + i] = match (p.bgp >> (pixel << 1)) & 0b11 {
			0b00 { 0xFF }
			0b01 { 0xAA }
			0b10 { 0x55 }
			else { 0x00 }
		}
		bg_prio[i] = pixel != 0
	}
	p.wly += wly_add
}

fn (mut p DmgPpu) render_sprite(bg_prio [160]bool) {
	if !p.lcdc.has(.sprite_enable) {
		return
	}
	size := if p.lcdc.has(.sprite_size) { 16 } else { 8 }

	mut sprites := []Sprite{len: 40, init: Sprite{
		y: p.oam[index * 4]
		x: p.oam[index * 4 + 1]
		tile_idx: p.oam[index * 4 + 2]
		flags: unsafe { SpriteFlag(p.oam[index * 4 + 3]) }
	}}.map(|it| Sprite{
		...it
		y: it.y - 16
		x: it.x - 8
	}).filter(p.ly - it.y < size)
	sprites.trim(10)
	sprites.sort(b.x < a.x)

	for sprite in sprites {
		palette := if sprite.flags.has(.palette) { p.obp1 } else { p.obp0 }
		mut tile_idx := u16(sprite.tile_idx)
		mut row := u8(if sprite.flags.has(.y_flip) {
			size - 1 - (p.ly - sprite.y)
		} else {
			p.ly - sprite.y
		})
		if size == 16 {
			tile_idx &= 0xFE
		}
		tile_idx += u16(row >= 8)
		row &= 7

		for col in 0 .. 8 {
			col_flipped := u8(if sprite.flags.has(.x_flip) {
				7 - col
			} else {
				col
			})
			pixel := p.get_pixel_from_tile(tile_idx, row, col_flipped)
			i := int(sprite.x + col)
			if i < lcd_width && pixel > 0 {
				if !sprite.flags.has(.obj2bg_priority) || !bg_prio[i] {
					p.buffer[lcd_width * int(p.ly) + i] = match (palette >> (pixel << 1)) & 0b11 {
						0b00 { 0xFF }
						0b01 { 0xAA }
						0b10 { 0x55 }
						else { 0x00 }
					}
				}
			}
		}
	}
}

fn (mut p DmgPpu) check_lyc_eq_ly(mut ints Interrupts) {
	if p.ly == p.lyc {
		p.stat.set(.lyc_eq_ly)
		if p.stat.has(.lyc_eq_ly_int) {
			ints.irq(.stat)
		}
	} else {
		p.stat.clear(.lyc_eq_ly)
	}
}

pub fn (mut p DmgPpu) oam_dma_emulate_cycle(val u8) {
	if addr := p.oam_dma {
		if p.stat.get_mode() !in [.drawing, .oamscan] {
			p.oam[addr & 0xFF] = val
		}
		p.oam_dma = if u8(addr + 1) < 0xA0 {
			addr + 1
		} else {
			none
		}
	}
}

pub fn (mut p DmgPpu) emulate_cycle(mut ints Interrupts) bool {
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
				if p.stat.has(.oam_scan_int) {
					ints.irq(.stat)
				}
			} else {
				p.stat.set_mode(.vblank)
				p.cycles = 114
				ints.irq(.vblank)
				if p.stat.has(.vblank_int) {
					ints.irq(.stat)
				}
			}
			p.check_lyc_eq_ly(mut ints)
		}
		.vblank {
			p.ly++
			if p.ly > 153 {
				ret = true
				p.ly = 0
				p.wly = 0
				p.stat.set_mode(.oamscan)
				p.cycles = 20
				if p.stat.has(.oam_scan_int) {
					ints.irq(.stat)
				}
			} else {
				p.cycles = 114
			}
			p.check_lyc_eq_ly(mut ints)
		}
		.oamscan {
			p.stat.set_mode(.drawing)
			p.cycles = 43
		}
		.drawing {
			mut bg_prio := [160]bool{}
			p.render_bg(mut bg_prio)
			p.render_window(mut bg_prio)
			p.render_sprite(bg_prio)
			p.stat.set_mode(.hblank)
			p.cycles = 51
			if p.stat.has(.hblank_int) {
				ints.irq(.stat)
			}
		}
	}
	return ret
}

pub fn (p &DmgPpu) pixel_buffer() []u8 {
	return []u8{len: lcd_width * lcd_height, init: p.buffer[index]}
}

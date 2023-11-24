module timer

import cpu.interrupts { Interrupts }
import util

pub struct Timer {
mut:
	div      u16
	tima     u8
	overflow bool
	after    bool
	tima_w   bool
	tma_w    bool
	tma      u8
	tac      u8
}

pub fn Timer.new() Timer {
	return Timer{}
}

pub fn (mut t Timer) emulate_cycle(mut ints Interrupts) {
	t.div += 4
	modulo := u16(match t.tac & 0b11 {
		0b01 { 16 }
		0b10 { 64 }
		0b11 { 256 }
		else { 1024 }
	})
	if t.after && (t.tima_w || t.tma_w) {
		t.tima = t.tma
		t.overflow = false
	}
	t.after = false
	if t.overflow {
		if !t.tima_w {
			t.tima = t.tma
		}
		t.overflow = false
		ints.irq(.timer)
		t.after = true
	} else if t.tac & 0b100 > 0 && t.div & (modulo - 1) == 0 {
		tima, overflow := util.add_8(t.tima, 1, 0)
		t.tima = tima
		t.overflow = overflow > 0
	}
	t.tima_w = false
	t.tma_w = false
}

pub fn (t &Timer) read(addr u16) u8 {
	return match addr {
		0xFF04 { u8(t.div >> 8) }
		0xFF05 { t.tima }
		0xFF06 { t.tma }
		0xFF07 { 0b1111100 | t.tac }
		else { panic('unexpected address for timer: 0x${addr:04X}') }
	}
}

pub fn (mut t Timer) write(addr u16, val u8) {
	match addr {
		0xFF04 {
			modulo := u16(match t.tac & 0b11 {
				0b01 { 16 }
				0b10 { 64 }
				0b11 { 256 }
				else { 1024 }
			}) >> 1
			if t.tac & 0b100 > 0 && t.div & modulo > 0 {
				tima, overflow := util.add_8(t.tima, 1, 0)
				t.tima = tima
				t.overflow = overflow > 0
			}
			t.div = 0
		}
		0xFF05 {
			t.tima = val
			t.tima_w = true
		}
		0xFF06 {
			t.tma = val
			t.tma_w = true
		}
		0xFF07 {
			modulo_old := u16(match t.tac & 0b11 {
				0b01 { 16 }
				0b10 { 64 }
				0b11 { 256 }
				else { 1024 }
			}) >> 1
			if t.tac & 0b100 > 0 && t.div & modulo_old > 0 {
				modulo_new := u16(match val & 0b11 {
					0b01 { 16 }
					0b10 { 64 }
					0b11 { 256 }
					else { 1024 }
				}) >> 1
				if val & 0b100 == 0 || t.div & modulo_new == 0 {
					tima, overflow := util.add_8(t.tima, 1, 0)
					t.tima = tima
					t.overflow = overflow > 0
				}
			}
			t.tac = val & 0b111
		}
		else {
			panic('unexpected address for timer: 0x${addr:04X}')
		}
	}
}

module cpu

struct Registers {
mut:
	pc u16
	sp u16
	a  u8
	b  u8
	c  u8
	d  u8
	e  u8
	f  u8
	h  u8
	l  u8
}

enum Flag as u8 {
	z = 0b10000000
	n = 0b01000000
	h = 0b00100000
	c = 0b00010000
}

fn (r &Registers) read_af() u16 {
	return (u16(r.a) << 8) | u16(r.f)
}

fn (r &Registers) read_bc() u16 {
	return (u16(r.b) << 8) | u16(r.c)
}

fn (r &Registers) read_de() u16 {
	return (u16(r.d) << 8) | u16(r.e)
}

fn (r &Registers) read_hl() u16 {
	return (u16(r.h) << 8) | u16(r.l)
}

fn (mut r Registers) write_af(val u16) {
	r.a = u8(val >> 8)
	r.f = u8(val & 0xF0)
}

fn (mut r Registers) write_bc(val u16) {
	r.b = u8(val >> 8)
	r.c = u8(val & 0xF0)
}

fn (mut r Registers) write_de(val u16) {
	r.d = u8(val >> 8)
	r.e = u8(val & 0xF0)
}

fn (mut r Registers) write_hl(val u16) {
	r.h = u8(val >> 8)
	r.l = u8(val & 0xF0)
}

fn (r &Registers) get_flag(f Flag) bool {
	return (r.f & u8(f)) == 1
}

fn (mut r Registers) set_flag(f Flag, val bool) {
	if val {
		r.f |= u8(f)
	} else {
		r.f &= ~u8(f)
	}
}

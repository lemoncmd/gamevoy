module cpu

import peripherals { Peripherals }

fn (mut c Cpu) decode(mut bus Peripherals) {
	if c.ctx.cb {
		c.cb_decode(mut bus)
		return
	}
	match c.ctx.opcode {
		// nop
		0x00 { c.nop(mut bus) }
		// ld
		0x01 { c.ld16(mut bus, Reg16.bc, Imm16{}) }
		0x11 { c.ld16(mut bus, Reg16.de, Imm16{}) }
		0x21 { c.ld16(mut bus, Reg16.hl, Imm16{}) }
		0x31 { c.ld16(mut bus, Reg16.sp, Imm16{}) }
		0x02 { c.ld(mut bus, Indirect.bc, Reg8.a) }
		0x12 { c.ld(mut bus, Indirect.de, Reg8.a) }
		0x22 { c.ld(mut bus, Indirect.hli, Reg8.a) }
		0x32 { c.ld(mut bus, Indirect.hld, Reg8.a) }
		0x0A { c.ld(mut bus, Reg8.a, Indirect.bc) }
		0x1A { c.ld(mut bus, Reg8.a, Indirect.de) }
		0x2A { c.ld(mut bus, Reg8.a, Indirect.hli) }
		0x3A { c.ld(mut bus, Reg8.a, Indirect.hli) }
		0x06 { c.ld(mut bus, Reg8.b, Imm8{}) }
		0x0E { c.ld(mut bus, Reg8.c, Imm8{}) }
		0x16 { c.ld(mut bus, Reg8.d, Imm8{}) }
		0x1E { c.ld(mut bus, Reg8.e, Imm8{}) }
		0x26 { c.ld(mut bus, Reg8.h, Imm8{}) }
		0x2E { c.ld(mut bus, Reg8.l, Imm8{}) }
		0x36 { c.ld(mut bus, Indirect.hl, Imm8{}) }
		0x3E { c.ld(mut bus, Reg8.a, Imm8{}) }
		0x08 { c.ld16(mut bus, Direct16{}, Reg16.sp) }
		0x40 { c.ld(mut bus, Reg8.b, Reg8.b) }
		0x41 { c.ld(mut bus, Reg8.b, Reg8.c) }
		0x42 { c.ld(mut bus, Reg8.b, Reg8.d) }
		0x43 { c.ld(mut bus, Reg8.b, Reg8.e) }
		0x44 { c.ld(mut bus, Reg8.b, Reg8.h) }
		0x45 { c.ld(mut bus, Reg8.b, Reg8.l) }
		0x46 { c.ld(mut bus, Reg8.b, Indirect.hl) }
		0x47 { c.ld(mut bus, Reg8.b, Reg8.a) }
		0x48 { c.ld(mut bus, Reg8.c, Reg8.b) }
		0x49 { c.ld(mut bus, Reg8.c, Reg8.c) }
		0x4A { c.ld(mut bus, Reg8.c, Reg8.d) }
		0x4B { c.ld(mut bus, Reg8.c, Reg8.e) }
		0x4C { c.ld(mut bus, Reg8.c, Reg8.h) }
		0x4D { c.ld(mut bus, Reg8.c, Reg8.l) }
		0x4E { c.ld(mut bus, Reg8.c, Indirect.hl) }
		0x4F { c.ld(mut bus, Reg8.c, Reg8.a) }
		0x50 { c.ld(mut bus, Reg8.d, Reg8.b) }
		0x51 { c.ld(mut bus, Reg8.d, Reg8.c) }
		0x52 { c.ld(mut bus, Reg8.d, Reg8.d) }
		0x53 { c.ld(mut bus, Reg8.d, Reg8.e) }
		0x54 { c.ld(mut bus, Reg8.d, Reg8.h) }
		0x55 { c.ld(mut bus, Reg8.d, Reg8.l) }
		0x56 { c.ld(mut bus, Reg8.d, Indirect.hl) }
		0x57 { c.ld(mut bus, Reg8.d, Reg8.a) }
		0x58 { c.ld(mut bus, Reg8.e, Reg8.b) }
		0x59 { c.ld(mut bus, Reg8.e, Reg8.c) }
		0x5A { c.ld(mut bus, Reg8.e, Reg8.d) }
		0x5B { c.ld(mut bus, Reg8.e, Reg8.e) }
		0x5C { c.ld(mut bus, Reg8.e, Reg8.h) }
		0x5D { c.ld(mut bus, Reg8.e, Reg8.l) }
		0x5E { c.ld(mut bus, Reg8.e, Indirect.hl) }
		0x5F { c.ld(mut bus, Reg8.e, Reg8.a) }
		0x60 { c.ld(mut bus, Reg8.h, Reg8.b) }
		0x61 { c.ld(mut bus, Reg8.h, Reg8.c) }
		0x62 { c.ld(mut bus, Reg8.h, Reg8.d) }
		0x63 { c.ld(mut bus, Reg8.h, Reg8.e) }
		0x64 { c.ld(mut bus, Reg8.h, Reg8.h) }
		0x65 { c.ld(mut bus, Reg8.h, Reg8.l) }
		0x66 { c.ld(mut bus, Reg8.h, Indirect.hl) }
		0x67 { c.ld(mut bus, Reg8.h, Reg8.a) }
		0x68 { c.ld(mut bus, Reg8.l, Reg8.b) }
		0x69 { c.ld(mut bus, Reg8.l, Reg8.c) }
		0x6A { c.ld(mut bus, Reg8.l, Reg8.d) }
		0x6B { c.ld(mut bus, Reg8.l, Reg8.e) }
		0x6C { c.ld(mut bus, Reg8.l, Reg8.h) }
		0x6D { c.ld(mut bus, Reg8.l, Reg8.l) }
		0x6E { c.ld(mut bus, Reg8.l, Indirect.hl) }
		0x6F { c.ld(mut bus, Reg8.l, Reg8.a) }
		0x70 { c.ld(mut bus, Indirect.hl, Reg8.b) }
		0x71 { c.ld(mut bus, Indirect.hl, Reg8.c) }
		0x72 { c.ld(mut bus, Indirect.hl, Reg8.d) }
		0x73 { c.ld(mut bus, Indirect.hl, Reg8.e) }
		0x74 { c.ld(mut bus, Indirect.hl, Reg8.h) }
		0x75 { c.ld(mut bus, Indirect.hl, Reg8.l) }
		// 0x76 is hlt
		0x77 { c.ld(mut bus, Indirect.hl, Reg8.a) }
		0x78 { c.ld(mut bus, Reg8.a, Reg8.b) }
		0x79 { c.ld(mut bus, Reg8.a, Reg8.c) }
		0x7A { c.ld(mut bus, Reg8.a, Reg8.d) }
		0x7B { c.ld(mut bus, Reg8.a, Reg8.e) }
		0x7C { c.ld(mut bus, Reg8.a, Reg8.h) }
		0x7D { c.ld(mut bus, Reg8.a, Reg8.l) }
		0x7E { c.ld(mut bus, Reg8.a, Indirect.hl) }
		0x7F { c.ld(mut bus, Reg8.a, Reg8.a) }
		// inc
		0x03 { c.inc16(mut bus, Reg16.bc) }
		0x13 { c.inc16(mut bus, Reg16.de) }
		0x23 { c.inc16(mut bus, Reg16.hl) }
		0x33 { c.inc16(mut bus, Reg16.sp) }
		0x04 { c.inc(mut bus, Reg8.b) }
		0x0C { c.inc(mut bus, Reg8.c) }
		0x14 { c.inc(mut bus, Reg8.d) }
		0x1C { c.inc(mut bus, Reg8.e) }
		0x24 { c.inc(mut bus, Reg8.h) }
		0x2C { c.inc(mut bus, Reg8.l) }
		0x34 { c.inc(mut bus, Indirect.hl) }
		0x3C { c.inc(mut bus, Reg8.a) }
		// dec
		0x0B { c.dec16(mut bus, Reg16.bc) }
		0x1B { c.dec16(mut bus, Reg16.de) }
		0x2B { c.dec16(mut bus, Reg16.hl) }
		0x3B { c.dec16(mut bus, Reg16.sp) }
		0x05 { c.dec(mut bus, Reg8.b) }
		0x0D { c.dec(mut bus, Reg8.c) }
		0x15 { c.dec(mut bus, Reg8.d) }
		0x1D { c.dec(mut bus, Reg8.e) }
		0x25 { c.dec(mut bus, Reg8.h) }
		0x2D { c.dec(mut bus, Reg8.l) }
		0x35 { c.dec(mut bus, Indirect.hl) }
		0x3D { c.dec(mut bus, Reg8.a) }
		// jr
		0x18 { c.jr(bus) }
		0x20 { c.jr_c(bus, .nz) }
		0x28 { c.jr_c(bus, .z) }
		0x30 { c.jr_c(bus, .nc) }
		0x38 { c.jr_c(bus, .c) }
		// cp
		0xB8 { c.cp(bus, Reg8.b) }
		0xB9 { c.cp(bus, Reg8.c) }
		0xBA { c.cp(bus, Reg8.d) }
		0xBB { c.cp(bus, Reg8.e) }
		0xBC { c.cp(bus, Reg8.h) }
		0xBD { c.cp(bus, Reg8.l) }
		0xBE { c.cp(bus, Indirect.hl) }
		0xBF { c.cp(bus, Reg8.a) }
		0xFE { c.cp(bus, Imm8{}) }
		// pop
		0xC1 { c.pop(mut bus, Reg16.bc) }
		0xD1 { c.pop(mut bus, Reg16.de) }
		0xE1 { c.pop(mut bus, Reg16.hl) }
		0xF1 { c.pop(mut bus, Reg16.af) }
		// push
		0xC5 { c.push(mut bus, Reg16.bc) }
		0xD5 { c.push(mut bus, Reg16.de) }
		0xE5 { c.push(mut bus, Reg16.hl) }
		0xF5 { c.push(mut bus, Reg16.af) }
		// ret
		0xC9 { c.ret(bus) }
		// cb prefix
		0xCB { c.cb_prefixed(mut bus) }
		// call
		0xCD { c.call(mut bus) }
		else { panic('Not implemented: ${c.ctx.opcode:02x}') }
	}
}

fn (mut c Cpu) cb_decode(mut bus Peripherals) {
	match c.ctx.opcode {
		// rl
		0x10 { c.rl(mut bus, Reg8.b) }
		0x11 { c.rl(mut bus, Reg8.c) }
		0x12 { c.rl(mut bus, Reg8.d) }
		0x13 { c.rl(mut bus, Reg8.e) }
		0x14 { c.rl(mut bus, Reg8.h) }
		0x15 { c.rl(mut bus, Reg8.l) }
		0x16 { c.rl(mut bus, Indirect.hl) }
		0x17 { c.rl(mut bus, Reg8.a) }
		// bit
		0x40 { c.bit(bus, 0, Reg8.b) }
		0x41 { c.bit(bus, 0, Reg8.c) }
		0x42 { c.bit(bus, 0, Reg8.d) }
		0x43 { c.bit(bus, 0, Reg8.e) }
		0x44 { c.bit(bus, 0, Reg8.h) }
		0x45 { c.bit(bus, 0, Reg8.l) }
		0x46 { c.bit(bus, 0, Indirect.hl) }
		0x47 { c.bit(bus, 0, Reg8.a) }
		0x48 { c.bit(bus, 1, Reg8.b) }
		0x49 { c.bit(bus, 1, Reg8.c) }
		0x4a { c.bit(bus, 1, Reg8.d) }
		0x4b { c.bit(bus, 1, Reg8.e) }
		0x4c { c.bit(bus, 1, Reg8.h) }
		0x4d { c.bit(bus, 1, Reg8.l) }
		0x4e { c.bit(bus, 1, Indirect.hl) }
		0x4f { c.bit(bus, 1, Reg8.a) }
		0x50 { c.bit(bus, 2, Reg8.b) }
		0x51 { c.bit(bus, 2, Reg8.c) }
		0x52 { c.bit(bus, 2, Reg8.d) }
		0x53 { c.bit(bus, 2, Reg8.e) }
		0x54 { c.bit(bus, 2, Reg8.h) }
		0x55 { c.bit(bus, 2, Reg8.l) }
		0x56 { c.bit(bus, 2, Indirect.hl) }
		0x57 { c.bit(bus, 2, Reg8.a) }
		0x58 { c.bit(bus, 3, Reg8.b) }
		0x59 { c.bit(bus, 3, Reg8.c) }
		0x5a { c.bit(bus, 3, Reg8.d) }
		0x5b { c.bit(bus, 3, Reg8.e) }
		0x5c { c.bit(bus, 3, Reg8.h) }
		0x5d { c.bit(bus, 3, Reg8.l) }
		0x5e { c.bit(bus, 3, Indirect.hl) }
		0x5f { c.bit(bus, 3, Reg8.a) }
		0x60 { c.bit(bus, 4, Reg8.b) }
		0x61 { c.bit(bus, 4, Reg8.c) }
		0x62 { c.bit(bus, 4, Reg8.d) }
		0x63 { c.bit(bus, 4, Reg8.e) }
		0x64 { c.bit(bus, 4, Reg8.h) }
		0x65 { c.bit(bus, 4, Reg8.l) }
		0x66 { c.bit(bus, 4, Indirect.hl) }
		0x67 { c.bit(bus, 4, Reg8.a) }
		0x68 { c.bit(bus, 5, Reg8.b) }
		0x69 { c.bit(bus, 5, Reg8.c) }
		0x6a { c.bit(bus, 5, Reg8.d) }
		0x6b { c.bit(bus, 5, Reg8.e) }
		0x6c { c.bit(bus, 5, Reg8.h) }
		0x6d { c.bit(bus, 5, Reg8.l) }
		0x6e { c.bit(bus, 5, Indirect.hl) }
		0x6f { c.bit(bus, 5, Reg8.a) }
		0x70 { c.bit(bus, 6, Reg8.b) }
		0x71 { c.bit(bus, 6, Reg8.c) }
		0x72 { c.bit(bus, 6, Reg8.d) }
		0x73 { c.bit(bus, 6, Reg8.e) }
		0x74 { c.bit(bus, 6, Reg8.h) }
		0x75 { c.bit(bus, 6, Reg8.l) }
		0x76 { c.bit(bus, 6, Indirect.hl) }
		0x77 { c.bit(bus, 6, Reg8.a) }
		0x78 { c.bit(bus, 7, Reg8.b) }
		0x79 { c.bit(bus, 7, Reg8.c) }
		0x7a { c.bit(bus, 7, Reg8.d) }
		0x7b { c.bit(bus, 7, Reg8.e) }
		0x7c { c.bit(bus, 7, Reg8.h) }
		0x7d { c.bit(bus, 7, Reg8.l) }
		0x7e { c.bit(bus, 7, Indirect.hl) }
		0x7f { c.bit(bus, 7, Reg8.a) }
		else { panic('Not implemented: 0xCB ${c.ctx.opcode:02x}') }
	}
}

fn (mut c Cpu) cb_prefixed(mut bus Peripherals) {
	val := c.read8(bus, Imm8{}) or { return }
	c.ctx.opcode = val
	c.ctx.cb = true
	c.cb_decode(mut bus)
}

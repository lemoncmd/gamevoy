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
		// cb prefix
		0xCB { c.cb_prefixed(mut bus) }
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

module cpu

import peripherals { Peripherals }

fn (mut c Cpu) decode(mut bus Peripherals) {
	if c.ctx.cb {
		c.cb_decode(mut bus)
		return
	}
	/*
	if c.ctx.opcode != 0xFF {
		println('${c.ctx.opcode:x}')
	}*/
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
		0xE0 { c.ld(mut bus, Direct8.dff, Reg8.a) }
		0xE2 { c.ld(mut bus, Indirect.cff, Reg8.a) }
		0xEA { c.ld(mut bus, Direct8.d, Reg8.a) }
		0xF0 { c.ld(mut bus, Reg8.a, Direct8.dff) }
		0xF2 { c.ld(mut bus, Reg8.a, Indirect.cff) }
		0xFA { c.ld(mut bus, Reg8.a, Direct8.d) }
		// 0x76 is halt
		0x77 { c.ld(mut bus, Indirect.hl, Reg8.a) }
		0x78 { c.ld(mut bus, Reg8.a, Reg8.b) }
		0x79 { c.ld(mut bus, Reg8.a, Reg8.c) }
		0x7A { c.ld(mut bus, Reg8.a, Reg8.d) }
		0x7B { c.ld(mut bus, Reg8.a, Reg8.e) }
		0x7C { c.ld(mut bus, Reg8.a, Reg8.h) }
		0x7D { c.ld(mut bus, Reg8.a, Reg8.l) }
		0x7E { c.ld(mut bus, Reg8.a, Indirect.hl) }
		0x7F { c.ld(mut bus, Reg8.a, Reg8.a) }
		// halt
		0x76 { c.halt(bus) }
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
		// rlca
		0x07 { c.rlca(bus) }
		// rrca
		0x0F { c.rrca(bus) }
		// rla
		0x17 { c.rla(bus) }
		// rra
		0x1F { c.rra(bus) }
		// jr
		0x18 { c.jr(bus) }
		0x20 { c.jr_c(bus, .nz) }
		0x28 { c.jr_c(bus, .z) }
		0x30 { c.jr_c(bus, .nc) }
		0x38 { c.jr_c(bus, .c) }
		// add
		0x80 { c.add(bus, Reg8.b) }
		0x81 { c.add(bus, Reg8.c) }
		0x82 { c.add(bus, Reg8.d) }
		0x83 { c.add(bus, Reg8.e) }
		0x84 { c.add(bus, Reg8.h) }
		0x85 { c.add(bus, Reg8.l) }
		0x86 { c.add(bus, Indirect.hl) }
		0x87 { c.add(bus, Reg8.a) }
		0xC6 { c.add(bus, Imm8{}) }
		// adc
		0x88 { c.adc(bus, Reg8.b) }
		0x89 { c.adc(bus, Reg8.c) }
		0x8A { c.adc(bus, Reg8.d) }
		0x8B { c.adc(bus, Reg8.e) }
		0x8C { c.adc(bus, Reg8.h) }
		0x8D { c.adc(bus, Reg8.l) }
		0x8E { c.adc(bus, Indirect.hl) }
		0x8F { c.adc(bus, Reg8.a) }
		0xCE { c.adc(bus, Imm8{}) }
		// sub
		0x90 { c.sub(bus, Reg8.b) }
		0x91 { c.sub(bus, Reg8.c) }
		0x92 { c.sub(bus, Reg8.d) }
		0x93 { c.sub(bus, Reg8.e) }
		0x94 { c.sub(bus, Reg8.h) }
		0x95 { c.sub(bus, Reg8.l) }
		0x96 { c.sub(bus, Indirect.hl) }
		0x97 { c.sub(bus, Reg8.a) }
		0xD6 { c.sub(bus, Imm8{}) }
		// sbc
		0x98 { c.sbc(bus, Reg8.b) }
		0x99 { c.sbc(bus, Reg8.c) }
		0x9A { c.sbc(bus, Reg8.d) }
		0x9B { c.sbc(bus, Reg8.e) }
		0x9C { c.sbc(bus, Reg8.h) }
		0x9D { c.sbc(bus, Reg8.l) }
		0x9E { c.sbc(bus, Indirect.hl) }
		0x9F { c.sbc(bus, Reg8.a) }
		0xDE { c.sbc(bus, Imm8{}) }
		// and
		0xA0 { c.and(bus, Reg8.b) }
		0xA1 { c.and(bus, Reg8.c) }
		0xA2 { c.and(bus, Reg8.d) }
		0xA3 { c.and(bus, Reg8.e) }
		0xA4 { c.and(bus, Reg8.h) }
		0xA5 { c.and(bus, Reg8.l) }
		0xA6 { c.and(bus, Indirect.hl) }
		0xA7 { c.and(bus, Reg8.a) }
		0xE6 { c.and(bus, Imm8{}) }
		// xor
		0xA8 { c.xor(bus, Reg8.b) }
		0xA9 { c.xor(bus, Reg8.c) }
		0xAA { c.xor(bus, Reg8.d) }
		0xAB { c.xor(bus, Reg8.e) }
		0xAC { c.xor(bus, Reg8.h) }
		0xAD { c.xor(bus, Reg8.l) }
		0xAE { c.xor(bus, Indirect.hl) }
		0xAF { c.xor(bus, Reg8.a) }
		0xEE { c.xor(bus, Imm8{}) }
		// or
		0xB0 { c.lor(bus, Reg8.b) }
		0xB1 { c.lor(bus, Reg8.c) }
		0xB2 { c.lor(bus, Reg8.d) }
		0xB3 { c.lor(bus, Reg8.e) }
		0xB4 { c.lor(bus, Reg8.h) }
		0xB5 { c.lor(bus, Reg8.l) }
		0xB6 { c.lor(bus, Indirect.hl) }
		0xB7 { c.lor(bus, Reg8.a) }
		0xF6 { c.lor(bus, Imm8{}) }
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
		// jp
		0xC3 { c.jp(bus) }
		0xC2 { c.jp_c(bus, .nz) }
		0xCA { c.jp_c(bus, .z) }
		0xD2 { c.jp_c(bus, .nc) }
		0xDA { c.jp_c(bus, .c) }
		0xE9 { c.jp_hl(bus) }
		// ret
		0xC0 { c.ret_c(bus, .nz) }
		0xC8 { c.ret_c(bus, .z) }
		0xD0 { c.ret_c(bus, .nc) }
		0xD8 { c.ret_c(bus, .c) }
		0xC9 { c.ret(bus) }
		0xD9 { c.reti(bus) }
		// cb prefix
		0xCB { c.cb_prefixed(mut bus) }
		// call
		0xC4 { c.call_c(mut bus, .nz) }
		0xCC { c.call_c(mut bus, .z) }
		0xD4 { c.call_c(mut bus, .nc) }
		0xDC { c.call_c(mut bus, .c) }
		0xCD { c.call(mut bus) }
		// rst
		0xC7 { c.rst(mut bus, 0x00) }
		0xCF { c.rst(mut bus, 0x08) }
		0xD7 { c.rst(mut bus, 0x10) }
		0xDF { c.rst(mut bus, 0x18) }
		0xE7 { c.rst(mut bus, 0x20) }
		0xEF { c.rst(mut bus, 0x28) }
		0xF7 { c.rst(mut bus, 0x30) }
		0xFF { c.rst(mut bus, 0x38) }
		// di
		0xF3 { c.di(bus) }
		// ei
		0xFB { c.ei(bus) }
		else { panic('instruction not implemented: 0x${c.ctx.opcode:02X}') }
	}
}

fn (mut c Cpu) cb_decode(mut bus Peripherals) {
	match c.ctx.opcode {
		// rlc
		0x00 { c.rlc(mut bus, Reg8.b) }
		0x01 { c.rlc(mut bus, Reg8.c) }
		0x02 { c.rlc(mut bus, Reg8.d) }
		0x03 { c.rlc(mut bus, Reg8.e) }
		0x04 { c.rlc(mut bus, Reg8.h) }
		0x05 { c.rlc(mut bus, Reg8.l) }
		0x06 { c.rlc(mut bus, Indirect.hl) }
		0x07 { c.rlc(mut bus, Reg8.a) }
		// rrc
		0x08 { c.rrc(mut bus, Reg8.b) }
		0x09 { c.rrc(mut bus, Reg8.c) }
		0x0A { c.rrc(mut bus, Reg8.d) }
		0x0B { c.rrc(mut bus, Reg8.e) }
		0x0C { c.rrc(mut bus, Reg8.h) }
		0x0D { c.rrc(mut bus, Reg8.l) }
		0x0E { c.rrc(mut bus, Indirect.hl) }
		0x0F { c.rrc(mut bus, Reg8.a) }
		// rl
		0x10 { c.rl(mut bus, Reg8.b) }
		0x11 { c.rl(mut bus, Reg8.c) }
		0x12 { c.rl(mut bus, Reg8.d) }
		0x13 { c.rl(mut bus, Reg8.e) }
		0x14 { c.rl(mut bus, Reg8.h) }
		0x15 { c.rl(mut bus, Reg8.l) }
		0x16 { c.rl(mut bus, Indirect.hl) }
		0x17 { c.rl(mut bus, Reg8.a) }
		// rr
		0x18 { c.rr(mut bus, Reg8.b) }
		0x19 { c.rr(mut bus, Reg8.c) }
		0x1A { c.rr(mut bus, Reg8.d) }
		0x1B { c.rr(mut bus, Reg8.e) }
		0x1C { c.rr(mut bus, Reg8.h) }
		0x1D { c.rr(mut bus, Reg8.l) }
		0x1E { c.rr(mut bus, Indirect.hl) }
		0x1F { c.rr(mut bus, Reg8.a) }
		// sla
		0x20 { c.sla(mut bus, Reg8.b) }
		0x21 { c.sla(mut bus, Reg8.c) }
		0x22 { c.sla(mut bus, Reg8.d) }
		0x23 { c.sla(mut bus, Reg8.e) }
		0x24 { c.sla(mut bus, Reg8.h) }
		0x25 { c.sla(mut bus, Reg8.l) }
		0x26 { c.sla(mut bus, Indirect.hl) }
		0x27 { c.sla(mut bus, Reg8.a) }
		// sra
		0x28 { c.sra(mut bus, Reg8.b) }
		0x29 { c.sra(mut bus, Reg8.c) }
		0x2A { c.sra(mut bus, Reg8.d) }
		0x2B { c.sra(mut bus, Reg8.e) }
		0x2C { c.sra(mut bus, Reg8.h) }
		0x2D { c.sra(mut bus, Reg8.l) }
		0x2E { c.sra(mut bus, Indirect.hl) }
		0x2F { c.sra(mut bus, Reg8.a) }
		// swap
		0x30 { c.swap(mut bus, Reg8.b) }
		0x31 { c.swap(mut bus, Reg8.c) }
		0x32 { c.swap(mut bus, Reg8.d) }
		0x33 { c.swap(mut bus, Reg8.e) }
		0x34 { c.swap(mut bus, Reg8.h) }
		0x35 { c.swap(mut bus, Reg8.l) }
		0x36 { c.swap(mut bus, Indirect.hl) }
		0x37 { c.swap(mut bus, Reg8.a) }
		// srl
		0x38 { c.srl(mut bus, Reg8.b) }
		0x39 { c.srl(mut bus, Reg8.c) }
		0x3A { c.srl(mut bus, Reg8.d) }
		0x3B { c.srl(mut bus, Reg8.e) }
		0x3C { c.srl(mut bus, Reg8.h) }
		0x3D { c.srl(mut bus, Reg8.l) }
		0x3E { c.srl(mut bus, Indirect.hl) }
		0x3F { c.srl(mut bus, Reg8.a) }
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
		0x4A { c.bit(bus, 1, Reg8.d) }
		0x4B { c.bit(bus, 1, Reg8.e) }
		0x4C { c.bit(bus, 1, Reg8.h) }
		0x4D { c.bit(bus, 1, Reg8.l) }
		0x4E { c.bit(bus, 1, Indirect.hl) }
		0x4F { c.bit(bus, 1, Reg8.a) }
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
		0x5A { c.bit(bus, 3, Reg8.d) }
		0x5B { c.bit(bus, 3, Reg8.e) }
		0x5C { c.bit(bus, 3, Reg8.h) }
		0x5D { c.bit(bus, 3, Reg8.l) }
		0x5E { c.bit(bus, 3, Indirect.hl) }
		0x5F { c.bit(bus, 3, Reg8.a) }
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
		0x6A { c.bit(bus, 5, Reg8.d) }
		0x6B { c.bit(bus, 5, Reg8.e) }
		0x6C { c.bit(bus, 5, Reg8.h) }
		0x6D { c.bit(bus, 5, Reg8.l) }
		0x6E { c.bit(bus, 5, Indirect.hl) }
		0x6F { c.bit(bus, 5, Reg8.a) }
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
		0x7A { c.bit(bus, 7, Reg8.d) }
		0x7B { c.bit(bus, 7, Reg8.e) }
		0x7C { c.bit(bus, 7, Reg8.h) }
		0x7D { c.bit(bus, 7, Reg8.l) }
		0x7E { c.bit(bus, 7, Indirect.hl) }
		0x7F { c.bit(bus, 7, Reg8.a) }
		// res
		0x80 { c.res(mut bus, 0, Reg8.b) }
		0x81 { c.res(mut bus, 0, Reg8.c) }
		0x82 { c.res(mut bus, 0, Reg8.d) }
		0x83 { c.res(mut bus, 0, Reg8.e) }
		0x84 { c.res(mut bus, 0, Reg8.h) }
		0x85 { c.res(mut bus, 0, Reg8.l) }
		0x86 { c.res(mut bus, 0, Indirect.hl) }
		0x87 { c.res(mut bus, 0, Reg8.a) }
		0x88 { c.res(mut bus, 1, Reg8.b) }
		0x89 { c.res(mut bus, 1, Reg8.c) }
		0x8A { c.res(mut bus, 1, Reg8.d) }
		0x8B { c.res(mut bus, 1, Reg8.e) }
		0x8C { c.res(mut bus, 1, Reg8.h) }
		0x8D { c.res(mut bus, 1, Reg8.l) }
		0x8E { c.res(mut bus, 1, Indirect.hl) }
		0x8F { c.res(mut bus, 1, Reg8.a) }
		0x90 { c.res(mut bus, 2, Reg8.b) }
		0x91 { c.res(mut bus, 2, Reg8.c) }
		0x92 { c.res(mut bus, 2, Reg8.d) }
		0x93 { c.res(mut bus, 2, Reg8.e) }
		0x94 { c.res(mut bus, 2, Reg8.h) }
		0x95 { c.res(mut bus, 2, Reg8.l) }
		0x96 { c.res(mut bus, 2, Indirect.hl) }
		0x97 { c.res(mut bus, 2, Reg8.a) }
		0x98 { c.res(mut bus, 3, Reg8.b) }
		0x99 { c.res(mut bus, 3, Reg8.c) }
		0x9A { c.res(mut bus, 3, Reg8.d) }
		0x9B { c.res(mut bus, 3, Reg8.e) }
		0x9C { c.res(mut bus, 3, Reg8.h) }
		0x9D { c.res(mut bus, 3, Reg8.l) }
		0x9E { c.res(mut bus, 3, Indirect.hl) }
		0x9F { c.res(mut bus, 3, Reg8.a) }
		0xA0 { c.res(mut bus, 4, Reg8.b) }
		0xA1 { c.res(mut bus, 4, Reg8.c) }
		0xA2 { c.res(mut bus, 4, Reg8.d) }
		0xA3 { c.res(mut bus, 4, Reg8.e) }
		0xA4 { c.res(mut bus, 4, Reg8.h) }
		0xA5 { c.res(mut bus, 4, Reg8.l) }
		0xA6 { c.res(mut bus, 4, Indirect.hl) }
		0xA7 { c.res(mut bus, 4, Reg8.a) }
		0xA8 { c.res(mut bus, 5, Reg8.b) }
		0xA9 { c.res(mut bus, 5, Reg8.c) }
		0xAA { c.res(mut bus, 5, Reg8.d) }
		0xAB { c.res(mut bus, 5, Reg8.e) }
		0xAC { c.res(mut bus, 5, Reg8.h) }
		0xAD { c.res(mut bus, 5, Reg8.l) }
		0xAE { c.res(mut bus, 5, Indirect.hl) }
		0xAF { c.res(mut bus, 5, Reg8.a) }
		0xB0 { c.res(mut bus, 6, Reg8.b) }
		0xB1 { c.res(mut bus, 6, Reg8.c) }
		0xB2 { c.res(mut bus, 6, Reg8.d) }
		0xB3 { c.res(mut bus, 6, Reg8.e) }
		0xB4 { c.res(mut bus, 6, Reg8.h) }
		0xB5 { c.res(mut bus, 6, Reg8.l) }
		0xB6 { c.res(mut bus, 6, Indirect.hl) }
		0xB7 { c.res(mut bus, 6, Reg8.a) }
		0xB8 { c.res(mut bus, 7, Reg8.b) }
		0xB9 { c.res(mut bus, 7, Reg8.c) }
		0xBA { c.res(mut bus, 7, Reg8.d) }
		0xBB { c.res(mut bus, 7, Reg8.e) }
		0xBC { c.res(mut bus, 7, Reg8.h) }
		0xBD { c.res(mut bus, 7, Reg8.l) }
		0xBE { c.res(mut bus, 7, Indirect.hl) }
		0xBF { c.res(mut bus, 7, Reg8.a) }
		// set
		0xC0 { c.set(mut bus, 0, Reg8.b) }
		0xC1 { c.set(mut bus, 0, Reg8.c) }
		0xC2 { c.set(mut bus, 0, Reg8.d) }
		0xC3 { c.set(mut bus, 0, Reg8.e) }
		0xC4 { c.set(mut bus, 0, Reg8.h) }
		0xC5 { c.set(mut bus, 0, Reg8.l) }
		0xC6 { c.set(mut bus, 0, Indirect.hl) }
		0xC7 { c.set(mut bus, 0, Reg8.a) }
		0xC8 { c.set(mut bus, 1, Reg8.b) }
		0xC9 { c.set(mut bus, 1, Reg8.c) }
		0xCA { c.set(mut bus, 1, Reg8.d) }
		0xCB { c.set(mut bus, 1, Reg8.e) }
		0xCC { c.set(mut bus, 1, Reg8.h) }
		0xCD { c.set(mut bus, 1, Reg8.l) }
		0xCE { c.set(mut bus, 1, Indirect.hl) }
		0xCF { c.set(mut bus, 1, Reg8.a) }
		0xD0 { c.set(mut bus, 2, Reg8.b) }
		0xD1 { c.set(mut bus, 2, Reg8.c) }
		0xD2 { c.set(mut bus, 2, Reg8.d) }
		0xD3 { c.set(mut bus, 2, Reg8.e) }
		0xD4 { c.set(mut bus, 2, Reg8.h) }
		0xD5 { c.set(mut bus, 2, Reg8.l) }
		0xD6 { c.set(mut bus, 2, Indirect.hl) }
		0xD7 { c.set(mut bus, 2, Reg8.a) }
		0xD8 { c.set(mut bus, 3, Reg8.b) }
		0xD9 { c.set(mut bus, 3, Reg8.c) }
		0xDA { c.set(mut bus, 3, Reg8.d) }
		0xDB { c.set(mut bus, 3, Reg8.e) }
		0xDC { c.set(mut bus, 3, Reg8.h) }
		0xDD { c.set(mut bus, 3, Reg8.l) }
		0xDE { c.set(mut bus, 3, Indirect.hl) }
		0xDF { c.set(mut bus, 3, Reg8.a) }
		0xE0 { c.set(mut bus, 4, Reg8.b) }
		0xE1 { c.set(mut bus, 4, Reg8.c) }
		0xE2 { c.set(mut bus, 4, Reg8.d) }
		0xE3 { c.set(mut bus, 4, Reg8.e) }
		0xE4 { c.set(mut bus, 4, Reg8.h) }
		0xE5 { c.set(mut bus, 4, Reg8.l) }
		0xE6 { c.set(mut bus, 4, Indirect.hl) }
		0xE7 { c.set(mut bus, 4, Reg8.a) }
		0xE8 { c.set(mut bus, 5, Reg8.b) }
		0xE9 { c.set(mut bus, 5, Reg8.c) }
		0xEA { c.set(mut bus, 5, Reg8.d) }
		0xEB { c.set(mut bus, 5, Reg8.e) }
		0xEC { c.set(mut bus, 5, Reg8.h) }
		0xED { c.set(mut bus, 5, Reg8.l) }
		0xEE { c.set(mut bus, 5, Indirect.hl) }
		0xEF { c.set(mut bus, 5, Reg8.a) }
		0xF0 { c.set(mut bus, 6, Reg8.b) }
		0xF1 { c.set(mut bus, 6, Reg8.c) }
		0xF2 { c.set(mut bus, 6, Reg8.d) }
		0xF3 { c.set(mut bus, 6, Reg8.e) }
		0xF4 { c.set(mut bus, 6, Reg8.h) }
		0xF5 { c.set(mut bus, 6, Reg8.l) }
		0xF6 { c.set(mut bus, 6, Indirect.hl) }
		0xF7 { c.set(mut bus, 6, Reg8.a) }
		0xF8 { c.set(mut bus, 7, Reg8.b) }
		0xF9 { c.set(mut bus, 7, Reg8.c) }
		0xFA { c.set(mut bus, 7, Reg8.d) }
		0xFB { c.set(mut bus, 7, Reg8.e) }
		0xFC { c.set(mut bus, 7, Reg8.h) }
		0xFD { c.set(mut bus, 7, Reg8.l) }
		0xFE { c.set(mut bus, 7, Indirect.hl) }
		0xFF { c.set(mut bus, 7, Reg8.a) }
		else { panic('instruction not implemented: 0xCB ${c.ctx.opcode:02X}') }
	}
}

fn (mut c Cpu) cb_prefixed(mut bus Peripherals) {
	val := c.read8(bus, Imm8{}) or { return }
	c.ctx.opcode = val
	c.ctx.cb = true
	c.cb_decode(mut bus)
}

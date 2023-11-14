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
		0xCB { c.cb_prefixed(mut bus) }
		else { panic('Not implemented: ${c.ctx.opcode:02x}') }
	}
}

fn (mut c Cpu) cb_decode(mut bus Peripherals) {
	match c.ctx.opcode {
		0x10 { c.rl(mut bus, Reg8.b) }
		else { panic('Not implemented: 0xCB ${c.ctx.opcode:02x}') }
	}
}

fn (mut c Cpu) cb_prefixed(mut bus Peripherals) {
	val := c.read8(bus, Imm8{}) or { return }
	c.ctx.opcode = val
	c.ctx.cb = true
	c.cb_decode(mut bus)
}

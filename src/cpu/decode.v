module cpu

import peripherals { Peripherals }

fn (mut c Cpu) decode(mut bus Peripherals) {
	match c.ctx.opcode {
		0x00 { c.nop(mut bus) }
		else { panic('Not implemented: ${c.ctx.opcode:02x}') }
	}
}

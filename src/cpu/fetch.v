module cpu

import peripherals { Peripherals }

fn (mut c Cpu) fetch(bus &Peripherals) {
	c.ctx.opcode = bus.read(c.regs.pc)
	//	println('pc: ${c.regs.pc:04x}')
	//	println('opcode: ${c.ctx.opcode:02x}')
	//	if c.ctx.opcode == 0xc9 { println('ret') }
	c.regs.pc++
	c.ctx.cb = false
}

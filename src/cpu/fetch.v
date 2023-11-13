module cpu

import peripherals { Peripherals }

fn (mut c Cpu) fetch(bus &Peripherals) {
	c.ctx.opcode = bus.read(c.regs.pc)
	c.regs.pc++
	c.ctx.cb = false
}

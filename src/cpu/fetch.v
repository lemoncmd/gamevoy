module cpu

import peripherals { Peripherals }
import cpu.interrupts

fn (mut c Cpu) fetch(bus &Peripherals) {
	c.ctx.opcode = bus.read(c.interrupts, c.regs.pc)
	// print('\r pc: ${c.regs.pc:04x}')
	// print(' opcode: ${c.ctx.opcode:02x}')
	// if c.ctx.opcode == 0xc9 { println('ret') }
	// if c.ctx.opcode == 0xe6 { println(c.regs) }
	if c.interrupts.ime && c.interrupts.get_interrupts().has(interrupts.all_flags) {
		c.ctx.in_int = true
	} else {
		c.regs.pc++
		c.ctx.in_int = false
	}
	c.ctx.cb = false
}

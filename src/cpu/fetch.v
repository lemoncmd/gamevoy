module cpu

import peripherals { Peripherals }
import cpu.interrupts

fn (mut c Cpu) fetch(bus &Peripherals) {
	c.ctx.opcode = bus.read(c.interrupts, c.regs.pc)
	// println('pc: ${c.regs.pc:04x} sp: ${c.regs.sp:04x}')
	// println('a: ${c.regs.a:02x} b: ${c.regs.b:02x} c: ${c.regs.c:02x} d: ${c.regs.d:02x} e: ${c.regs.e:02x} f: ${c.regs.f:02x} h: ${c.regs.h:02x} l: ${c.regs.l:02x}')
	// println('opcode: ${c.ctx.opcode:02x}')
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

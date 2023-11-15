module cpu

import peripherals { Peripherals }

struct Ctx {
mut:
	opcode  u8
	cb      bool
	rw_step int
	in_step int
	rw_ireg int
	in_ireg int
}

pub struct Cpu {
mut:
	regs Registers
	ctx  Ctx
}

pub fn Cpu.new() Cpu {
	return Cpu{}
}

pub fn (mut c Cpu) init(bus &Peripherals) {
	c.fetch(bus)
}

pub fn (mut c Cpu) emulate_cycle(mut bus Peripherals) {
	c.decode(mut bus)
}

fn (mut c Cpu) rw_go(dst int) {
	c.ctx.rw_step = dst
}

fn (mut c Cpu) in_go(dst int) {
	c.ctx.in_step = dst
}

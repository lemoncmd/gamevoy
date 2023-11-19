module cpu

import peripherals { Peripherals }
import cpu.interrupts { InterruptFlag, Interrupts }

struct Ctx {
mut:
	opcode  u8
	cb      bool
	rw_step int
	in_step int
	rw_ireg int
	in_ireg int
	in_int  bool
}

pub struct Cpu {
mut:
	regs Registers
	ctx  Ctx
pub mut:
	interrupts interrupts.Interrupts
}

pub fn Cpu.new() Cpu {
	return Cpu{}
}

pub fn (mut c Cpu) init(bus &Peripherals) {
	c.fetch(bus)
}

pub fn (mut c Cpu) emulate_cycle(mut bus Peripherals) {
	if c.ctx.in_int {
		c.call_isr(mut bus)
	} else {
		c.decode(mut bus)
	}
}

fn (mut c Cpu) call_isr(mut bus Peripherals) {
	for {
		match c.ctx.in_step {
			0 {
				c.in_go(1)
			}
			1...4 {
				c.push16(mut bus, c.regs.pc) or { return }
				mut highest := InterruptFlag.vblank
				find_highest: for {
					// vfmt off
					$for value in InterruptFlag.values {
						// vfmt on
						if c.interrupts.get_interrupts().has(value.value) {
							highest = value.value
							break find_highest
						}
					}
				}
				c.interrupts.int_flags.clear(highest)
				c.regs.pc = match highest {
					.vblank { 0x0040 }
					.stat { 0x0048 }
					.timer { 0x0050 }
					.serial { 0x0058 }
					.joypad { 0x0060 }
					else { 0x0000 }
				}

				c.in_go(5)
				return
			}
			5 {
				c.interrupts.ime = false
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) rw_go(dst int) {
	c.ctx.rw_step = dst
}

fn (mut c Cpu) in_go(dst int) {
	c.ctx.in_step = dst
}

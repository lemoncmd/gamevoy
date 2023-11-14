module cpu

import peripherals { Peripherals }
import util

fn (mut c Cpu) nop(mut bus Peripherals) {
	c.fetch(bus)
}

fn (mut c Cpu) ld[D, S](mut bus Peripherals, dst D, src S) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read8(bus, src) or { return }
				c.in_go(1)
			}
			1 {
				c.write8(mut bus, dst, u8(c.ctx.in_ireg)) or { return }
				c.in_go(2)
			}
			2 {
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) ld16[D, S](mut bus Peripherals, dst D, src S) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read16(bus, src) or { return }
				c.in_go(1)
			}
			1 {
				c.write16(mut bus, dst, u16(c.ctx.in_ireg)) or { return }
				c.in_go(2)
			}
			2 {
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) cp[S](bus &Peripherals, src S) {
	val := c.read8(bus, src) or { return }
	result, carry := util.sub_8(c.regs.a, val, 0)
	c.regs.set_flag(.zf, result == 0)
	c.regs.set_flag(.nf, true)
	c.regs.set_flag(.hf, (c.regs.a & 0xf) < (val & 0xf))
	c.regs.set_flag(.cf, carry == 1)
}

fn (mut c Cpu) inc[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := val + 1
				c.regs.set_flag(.zf, result == 0)
				c.regs.set_flag(.nf, false)
				c.regs.set_flag(.hf, v & 0xf == 0xf)
				c.ctx.in_ireg = result
				c.in_go(1)
			}
			1 {
				c.write8(mut bus, src, u8(c.ctx.in_ireg)) or { return }
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) inc16[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read16(bus, src) or { return }
				c.ctx.in_ireg = val + 1
				c.in_go(1)
			}
			1 {
				c.write16(mut bus, src, u16(c.ctx.in_ireg)) or { return }
				c.in_go(2)
			}
			2 {
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) dec[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := val - 1
				c.regs.set_flag(.zf, result == 0)
				c.regs.set_flag(.nf, true)
				c.regs.set_flag(.hf, v & 0xf == 0)
				c.ctx.in_ireg = result
				c.in_go(1)
			}
			1 {
				c.write8(mut bus, src, u8(c.ctx.in_ireg)) or { return }
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) dec16[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read16(bus, src) or { return }
				c.ctx.in_ireg = val - 1
				c.in_go(1)
			}
			1 {
				c.write16(mut bus, src, u16(c.ctx.in_ireg)) or { return }
				c.in_go(2)
			}
			2 {
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) rl[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := (val << 1) | u8(c.regs.get_flag(.cf))
				c.regs.set_flag(.zf, result == 0)
				c.regs.set_flag(.nf, false)
				c.regs.set_flag(.hf, false)
				c.regs.set_flag(.cf, v & 0x80 > 0)
				c.ctx.in_ireg = result
				c.in_go(1)
			}
			1 {
				c.write8(mut bus, src, c.ctx.in_ireg) or { return }
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) bit[S](bus &Peripherals, bit u8, src S) {
	mut v := c.read8(bus, src) or { return }
	v &= 1 << bit
	c.regs.set_flag(.zf, v == 0)
	c.regs.set_flag(.nf, false)
	c.regs.set_flag(.hf, true)
	c.fetch(bus)
}

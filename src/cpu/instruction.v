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
	c.regs.set_flag(.z, result == 0)
	c.regs.set_flag(.n, true)
	c.regs.set_flag(.h, (c.regs.a & 0xf) < (val & 0xf))
	c.regs.set_flag(.c, carry == 1)
}

fn (mut c Cpu) inc[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := val + 1
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, v & 0xf == 0xf)
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
				return
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
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, true)
				c.regs.set_flag(.h, v & 0xf == 0)
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
				return
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
				result := (val << 1) | u8(c.regs.get_flag(.c))
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, v & 0x80 > 0)
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
	c.regs.set_flag(.z, v == 0)
	c.regs.set_flag(.n, false)
	c.regs.set_flag(.h, true)
	c.fetch(bus)
}

fn (mut c Cpu) push16(mut bus Peripherals, val u16) ? {
	match c.ctx.in_step {
		1 {
			c.in_go(2)
			return none
		}
		2 {
			c.regs.sp--
			bus.write(c.regs.sp, u8(val >> 8))
			c.in_go(3)
			return none
		}
		3 {
			c.regs.sp--
			bus.write(c.regs.sp, u8(val))
			c.in_go(4)
			return none
		}
		4 {
			return
		}
		else {
			return none
		}
	}
}

fn (mut c Cpu) push(mut bus Peripherals, src Reg16) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read16(bus, src) or { return }
				c.in_go(1)
			}
			1...4 {
				c.push16(mut bus, u16(c.ctx.in_ireg)) or { return }
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) pop16(bus &Peripherals) ?u16 {
	match c.ctx.in_step {
		0 {
			c.ctx.in_ireg = bus.read(c.regs.sp)
			c.regs.sp++
			c.in_go(1)
			return none
		}
		1 {
			c.ctx.in_ireg |= u16(bus.read(c.regs.sp)) << 8
			c.regs.sp++
			c.in_go(2)
			return none
		}
		2 {
			return u16(c.ctx.in_ireg)
		}
		else {
			return none
		}
	}
}

fn (mut c Cpu) pop(mut bus Peripherals, dst Reg16) {
	val := c.pop16(bus) or { return }
	c.write16(mut bus, dst, val) or { return }
	c.in_go(0)
	c.fetch(bus)
}

fn (mut c Cpu) jr(bus &Peripherals) {
	match c.ctx.in_step {
		0 {
			val := c.read8(bus, Imm8{}) or { return }
			c.regs.pc += u16(i8(val))
			c.in_go(1)
		}
		1 {
			c.in_go(0)
			c.fetch(bus)
		}
		else {}
	}
}

fn (c Cpu) cond(cond Cond) bool {
	return match cond {
		.nz { !c.regs.get_flag(.z) }
		.z { c.regs.get_flag(.z) }
		.nc { !c.regs.get_flag(.c) }
		.c { c.regs.get_flag(.c) }
	}
}

fn (mut c Cpu) jr_c(bus &Peripherals, cond Cond) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, Imm8{}) or { return }
				c.in_go(1)
				if c.cond(cond) {
					c.regs.pc += u16(i8(val))
					return
				}
			}
			1 {
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

module cpu

import math.bits
import peripherals { Peripherals }
import cpu.interrupts
import util

fn (mut c Cpu) nop(bus Peripherals) {
	c.fetch(bus)
}

fn (mut c Cpu) stop(bus Peripherals) {
	if c.interrupts.read(0xFF4D) & 1 > 0 {
		c.interrupts.change_double_mode()
	}
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

fn (mut c Cpu) ld_sp_hl(bus &Peripherals) {
	match c.ctx.in_step {
		0 {
			c.regs.sp = c.regs.read_hl()
			c.in_go(1)
		}
		1 {
			c.in_go(0)
			c.fetch(bus)
		}
		else {}
	}
}

fn (mut c Cpu) ld_hl_sp(bus &Peripherals) {
	match c.ctx.in_step {
		0 {
			val := c.read8(bus, Imm8{}) or { return }
			_, carry := util.add_8(u8(c.regs.sp), val, 0)
			c.regs.set_flag(.z, false)
			c.regs.set_flag(.n, false)
			c.regs.set_flag(.h, (u8(c.regs.sp) & 0xF) + (val & 0xF) > 0xF)
			c.regs.set_flag(.c, carry == 1)
			c.regs.write_hl(c.regs.sp + u16(i8(val)))
			c.in_go(1)
		}
		1 {
			c.in_go(0)
			c.fetch(bus)
		}
		else {}
	}
}

fn (mut c Cpu) cp[S](bus &Peripherals, src S) {
	val := c.read8(bus, src) or { return }
	result, carry := util.sub_8(c.regs.a, val, 0)
	c.regs.set_flag(.z, result == 0)
	c.regs.set_flag(.n, true)
	c.regs.set_flag(.h, (c.regs.a & 0xF) < (val & 0xF))
	c.regs.set_flag(.c, carry == 1)
	c.fetch(bus)
}

fn (mut c Cpu) inc[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := val + 1
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, val & 0xF == 0xF)
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
				c.regs.set_flag(.h, val & 0xF == 0)
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

fn (mut c Cpu) push16(mut bus Peripherals, val u16) ? {
	match c.ctx.in_step {
		1 {
			c.in_go(2)
			return none
		}
		2 {
			c.regs.sp--
			bus.write(mut c.interrupts, c.regs.sp, u8(val >> 8))
			c.in_go(3)
			return none
		}
		3 {
			c.regs.sp--
			bus.write(mut c.interrupts, c.regs.sp, u8(val))
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
			c.ctx.in_ireg = bus.read(c.interrupts, c.regs.sp)
			c.regs.sp++
			c.in_go(1)
			return none
		}
		1 {
			c.ctx.in_ireg += u16(bus.read(c.interrupts, c.regs.sp)) << 8
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

fn (mut c Cpu) jp(bus &Peripherals) {
	match c.ctx.in_step {
		0 {
			val := c.read16(bus, Imm16{}) or { return }
			c.regs.pc = val
			c.in_go(1)
		}
		1 {
			c.in_go(0)
			c.fetch(bus)
		}
		else {}
	}
}

fn (mut c Cpu) jp_hl(bus &Peripherals) {
	c.regs.pc = c.regs.read_hl()
	c.fetch(bus)
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

fn (mut c Cpu) jp_c(bus &Peripherals, cond Cond) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read16(bus, Imm16{}) or { return }
				c.in_go(1)
				if c.cond(cond) {
					c.regs.pc = val
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

fn (mut c Cpu) call(mut bus Peripherals) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read16(bus, Imm16{}) or { return }
				c.in_go(1)
			}
			1...4 {
				c.push16(mut bus, c.regs.pc) or { return }
				c.regs.pc = u16(c.ctx.in_ireg)
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) ret(bus &Peripherals) {
	match c.ctx.in_step {
		0...2 {
			val := c.pop16(bus) or { return }
			c.regs.pc = val
			c.in_go(3)
		}
		3 {
			c.in_go(0)
			c.fetch(bus)
		}
		else {}
	}
}

fn (mut c Cpu) call_c(mut bus Peripherals, cond Cond) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read16(bus, Imm16{}) or { return }
				if !c.cond(cond) {
					c.fetch(bus)
					return
				}
				c.in_go(1)
			}
			1...4 {
				c.push16(mut bus, c.regs.pc) or { return }
				c.regs.pc = u16(c.ctx.in_ireg)
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) ret_c(bus &Peripherals, cond Cond) {
	match c.ctx.in_step {
		0...2 {
			if !c.cond(cond) {
				c.in_go(4)
				return
			}
			val := c.pop16(bus) or { return }
			c.regs.pc = val
			c.in_go(3)
		}
		3 {
			c.in_go(4)
		}
		4 {
			c.in_go(0)
			c.fetch(bus)
		}
		else {}
	}
}

fn (mut c Cpu) reti(bus &Peripherals) {
	match c.ctx.in_step {
		0...2 {
			val := c.pop16(bus) or { return }
			c.regs.pc = val
			c.in_go(3)
		}
		3 {
			c.interrupts.ime = true
			c.in_go(0)
			c.fetch(bus)
		}
		else {}
	}
}

fn (mut c Cpu) rst(mut bus Peripherals, addr u8) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = addr
				c.in_go(1)
			}
			1...4 {
				c.push16(mut bus, c.regs.pc) or { return }
				c.regs.pc = u16(c.ctx.in_ireg)
				c.in_go(0)
				c.fetch(bus)
				return
			}
			else {}
		}
	}
}

fn (mut c Cpu) ei(bus &Peripherals) {
	c.fetch(bus)
	c.interrupts.ime = true
}

fn (mut c Cpu) di(bus &Peripherals) {
	c.interrupts.ime = false
	c.fetch(bus)
}

fn (mut c Cpu) halt(bus &Peripherals) {
	if c.interrupts.get_interrupts().has(interrupts.all_flags) {
		c.fetch(bus)
	}
}

fn (mut c Cpu) add[S](bus &Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read8(bus, src) or { return }
				c.in_go(1)
			}
			1 {
				result, carry := util.add_8(c.regs.a, u8(c.ctx.in_ireg), 0)
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, (c.regs.a & 0xF) + (c.ctx.in_ireg & 0xF) > 0xF)
				c.regs.set_flag(.c, carry == 1)
				c.regs.a = result
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

fn (mut c Cpu) add_hl(bus &Peripherals, src Reg16) {
	match c.ctx.in_step {
		0 {
			val := c.read16(bus, src) or { return }
			result, carry := util.add_16(c.regs.read_hl(), val, 0)
			c.regs.set_flag(.n, false)
			c.regs.set_flag(.h, (c.regs.read_hl() & 0x0FFF) + (val & 0x0FFF) > 0x0FFF)
			c.regs.set_flag(.c, carry == 1)
			c.regs.write_hl(result)
			c.in_go(1)
		}
		1 {
			c.in_go(0)
			c.fetch(bus)
		}
		else {}
	}
}

fn (mut c Cpu) add_sp(bus &Peripherals) {
	match c.ctx.in_step {
		0 {
			val := c.read8(bus, Imm8{}) or { return }
			_, carry := util.add_8(u8(c.regs.sp), val, 0)
			c.regs.set_flag(.z, false)
			c.regs.set_flag(.n, false)
			c.regs.set_flag(.h, (u8(c.regs.sp) & 0xF) + (val & 0xF) > 0xF)
			c.regs.set_flag(.c, carry == 1)
			c.regs.sp += u16(i8(val))
			c.in_go(1)
		}
		1 {
			c.in_go(2)
		}
		2 {
			c.in_go(0)
			c.fetch(bus)
		}
		else {}
	}
}

fn (mut c Cpu) adc[S](bus &Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read8(bus, src) or { return }
				c.in_go(1)
			}
			1 {
				result, carry := util.add_8(c.regs.a, u8(c.ctx.in_ireg), u8(c.regs.get_flag(.c)))
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, (c.regs.a & 0xF) + (u8(c.ctx.in_ireg) & 0xF) +
					(u8(c.regs.get_flag(.c))) > 0xF)
				c.regs.set_flag(.c, carry == 1)
				c.regs.a = result
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

fn (mut c Cpu) sub[S](bus &Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read8(bus, src) or { return }
				c.in_go(1)
			}
			1 {
				result, carry := util.sub_8(c.regs.a, u8(c.ctx.in_ireg), 0)
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, true)
				c.regs.set_flag(.h, (c.regs.a & 0xF) < (u8(c.ctx.in_ireg) & 0xF))
				c.regs.set_flag(.c, carry == 1)
				c.regs.a = result
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

fn (mut c Cpu) sbc[S](bus &Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read8(bus, src) or { return }
				c.in_go(1)
			}
			1 {
				result, carry := util.sub_8(c.regs.a, u8(c.ctx.in_ireg), u8(c.regs.get_flag(.c)))
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, true)
				c.regs.set_flag(.h, (c.regs.a & 0xF) < (u8(c.ctx.in_ireg) & 0xF) +
					u8(c.regs.get_flag(.c)))
				c.regs.set_flag(.c, carry == 1)
				c.regs.a = result
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

fn (mut c Cpu) and[S](bus &Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read8(bus, src) or { return }
				c.in_go(1)
			}
			1 {
				result := c.regs.a & u8(c.ctx.in_ireg)
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, true)
				c.regs.set_flag(.c, false)
				c.regs.a = result
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

fn (mut c Cpu) xor[S](bus &Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read8(bus, src) or { return }
				c.in_go(1)
			}
			1 {
				result := c.regs.a ^ u8(c.ctx.in_ireg)
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, false)
				c.regs.a = result
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

fn (mut c Cpu) lor[S](bus &Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				c.ctx.in_ireg = c.read8(bus, src) or { return }
				c.in_go(1)
			}
			1 {
				result := c.regs.a | u8(c.ctx.in_ireg)
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, false)
				c.regs.a = result
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

fn (mut c Cpu) daa(bus &Peripherals) {
	mut correction := u8(0)
	mut cf := false
	if c.regs.get_flag(.c) || (!c.regs.get_flag(.n) && c.regs.a > 0x99) {
		cf = true
		correction |= 0x60
	}
	if c.regs.get_flag(.h) || (!c.regs.get_flag(.n) && c.regs.a & 0x0F > 0x09) {
		correction |= 0x06
	}
	if c.regs.get_flag(.n) {
		c.regs.a -= correction
	} else {
		c.regs.a += correction
	}
	c.regs.set_flag(.z, c.regs.a == 0)
	c.regs.set_flag(.h, false)
	c.regs.set_flag(.c, cf)
	c.fetch(bus)
}

fn (mut c Cpu) cpl(bus &Peripherals) {
	c.regs.a = ~c.regs.a
	c.regs.set_flag(.n, true)
	c.regs.set_flag(.h, true)
	c.fetch(bus)
}

fn (mut c Cpu) scf(bus &Peripherals) {
	c.regs.set_flag(.n, false)
	c.regs.set_flag(.h, false)
	c.regs.set_flag(.c, true)
	c.fetch(bus)
}

fn (mut c Cpu) ccf(bus &Peripherals) {
	c.regs.set_flag(.n, false)
	c.regs.set_flag(.h, false)
	c.regs.set_flag(.c, !c.regs.get_flag(.c))
	c.fetch(bus)
}

fn (mut c Cpu) rlca(bus &Peripherals) {
	carry := c.regs.a & 0b10000000
	c.regs.a = bits.rotate_left_8(c.regs.a, 1)
	c.regs.set_flag(.z, false)
	c.regs.set_flag(.n, false)
	c.regs.set_flag(.h, false)
	c.regs.set_flag(.c, carry > 0)
	c.fetch(bus)
}

fn (mut c Cpu) rla(bus &Peripherals) {
	carry := c.regs.a & 0b10000000
	c.regs.a = c.regs.a << 1 | u8(c.regs.get_flag(.c))
	c.regs.set_flag(.z, false)
	c.regs.set_flag(.n, false)
	c.regs.set_flag(.h, false)
	c.regs.set_flag(.c, carry > 0)
	c.fetch(bus)
}

fn (mut c Cpu) rrca(bus &Peripherals) {
	carry := c.regs.a & 1
	c.regs.a = bits.rotate_left_8(c.regs.a, -1)
	c.regs.set_flag(.z, false)
	c.regs.set_flag(.n, false)
	c.regs.set_flag(.h, false)
	c.regs.set_flag(.c, carry > 0)
	c.fetch(bus)
}

fn (mut c Cpu) rra(bus &Peripherals) {
	carry := c.regs.a & 1
	c.regs.a = c.regs.a >> 1 | u8(c.regs.get_flag(.c)) << 7
	c.regs.set_flag(.z, false)
	c.regs.set_flag(.n, false)
	c.regs.set_flag(.h, false)
	c.regs.set_flag(.c, carry > 0)
	c.fetch(bus)
}

fn (mut c Cpu) rlc[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := bits.rotate_left_8(val, 1)
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, val & 0x80 > 0)
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

fn (mut c Cpu) rrc[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := bits.rotate_left_8(val, -1)
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, val & 1 > 0)
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

fn (mut c Cpu) rl[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := val << 1 | u8(c.regs.get_flag(.c))
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, val & 0x80 > 0)
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

fn (mut c Cpu) rr[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := val >> 1 | u8(c.regs.get_flag(.c)) << 7
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, val & 1 > 0)
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

fn (mut c Cpu) sla[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := val << 1
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, val & 0x80 > 0)
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

fn (mut c Cpu) sra[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := u8(i8(val) >> 1)
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, val & 1 > 0)
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

fn (mut c Cpu) swap[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := val >> 4 | val << 4
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, false)
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

fn (mut c Cpu) srl[S](mut bus Peripherals, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				result := val >> 1
				c.regs.set_flag(.z, result == 0)
				c.regs.set_flag(.n, false)
				c.regs.set_flag(.h, false)
				c.regs.set_flag(.c, val & 1 > 0)
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

fn (mut c Cpu) bit[S](bus &Peripherals, bit u8, src S) {
	mut v := c.read8(bus, src) or { return }
	v &= 1 << bit
	c.regs.set_flag(.z, v == 0)
	c.regs.set_flag(.n, false)
	c.regs.set_flag(.h, true)
	c.fetch(bus)
}

fn (mut c Cpu) res[S](mut bus Peripherals, bit u8, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				c.ctx.in_ireg = val & ~(1 << bit)
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

fn (mut c Cpu) set[S](mut bus Peripherals, bit u8, src S) {
	for {
		match c.ctx.in_step {
			0 {
				val := c.read8(bus, src) or { return }
				c.ctx.in_ireg = val | 1 << bit
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

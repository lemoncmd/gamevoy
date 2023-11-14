module cpu

import peripherals { Peripherals }

enum Reg8 {
	a
	b
	c
	d
	e
	h
	l
}

enum Reg16 {
	af
	bc
	de
	hl
	sp
}

struct Imm8 {}

struct Imm16 {}

enum Indirect {
	bc
	de
	hl
	cff
	hld
	hli
}

enum Direct8 {
	d
	dff
}

struct Direct16 {}

enum Cond {
	nz
	z
	nc
	c
}

fn (mut c Cpu) read8[T](bus &Peripherals, src T) ?u8 {
	$if T is Reg8 {
		return match Reg8(src) {
			.a { c.regs.a }
			.b { c.regs.b }
			.c { c.regs.c }
			.d { c.regs.d }
			.e { c.regs.e }
			.h { c.regs.h }
			.l { c.regs.l }
		}
	} $else $if T is Imm8 {
		match c.ctx.rw_step {
			0 {
				c.ctx.rw_ireg = bus.read(c.regs.pc)
				c.regs.pc++
				c.rw_go(1)
				return none
			}
			1 {
				c.rw_go(0)
				return u8(c.ctx.rw_ireg)
			}
			else {}
		}
		return none
	} $else $if T is Indirect {
		match c.ctx.rw_step {
			0 {
				c.ctx.rw_ireg = match Indirect(src) {
					.bc {
						bus.read(c.regs.read_bc())
					}
					.de {
						bus.read(c.regs.read_de())
					}
					.hl {
						bus.read(c.regs.read_hl())
					}
					.cff {
						bus.read(0xFF00 | u16(c.regs.c))
					}
					.hld {
						addr := c.regs.read_hl()
						c.regs.write_hl(addr - 1)
						bus.read(addr)
					}
					.hli {
						addr := c.regs.read_hl()
						c.regs.write_hl(addr + 1)
						bus.read(addr)
					}
				}
				c.rw_go(1)
				return none
			}
			1 {
				c.rw_go(0)
				return u8(c.ctx.rw_ireg)
			}
			else {}
		}
		return none
	} $else $if T is Direct8 {
		match c.ctx.rw_step {
			0 {
				c.ctx.rw_ireg = bus.read(c.regs.pc)
				c.regs.pc++
				c.rw_go(1)
				if src == Direct8.dff {
					c.ctx.rw_ireg |= 0xFF00
					c.rw_go(2)
				}
				return none
			}
			1 {
				c.ctx.rw_ireg |= u32(bus.read(c.regs.pc)) << 8
				c.regs.pc++
				c.rw_go(2)
				return none
			}
			2 {
				c.ctx.rw_ireg = bus.read(u16(c.ctx.rw_ireg))
				c.rw_go(3)
				return none
			}
			3 {
				c.rw_go(0)
				return u8(c.ctx.rw_ireg)
			}
			else {}
		}
		return none
	} $else {
		$compile_error('unexpected type for read8')
	}
}

fn (mut c Cpu) write8[T](mut bus Peripherals, dst T, val u8) ? {
	$if T is Reg8 {
		match Reg8(dst) {
			.a { c.regs.a = val }
			.b { c.regs.b = val }
			.c { c.regs.c = val }
			.d { c.regs.d = val }
			.e { c.regs.e = val }
			.h { c.regs.h = val }
			.l { c.regs.l = val }
		}
	} $else $if T is Indirect {
		match c.ctx.rw_step {
			0 {
				match Indirect(dst) {
					.bc {
						bus.write(c.regs.read_bc(), val)
					}
					.de {
						bus.write(c.regs.read_de(), val)
					}
					.hl {
						bus.write(c.regs.read_hl(), val)
					}
					.cff {
						bus.write(0xFF00 | u16(c.regs.c), val)
					}
					.hld {
						addr := c.regs.read_hl()
						c.regs.write_hl(addr - 1)
						bus.write(addr, val)
					}
					.hli {
						addr := c.regs.read_hl()
						c.regs.write_hl(addr + 1)
						bus.write(addr, val)
					}
				}
				c.rw_go(1)
				return none
			}
			1 {
				c.rw_go(0)
				return
			}
			else {
				return none
			}
		}
	} $else $if T is Direct8 {
		match c.ctx.rw_step {
			0 {
				c.ctx.rw_ireg = bus.read(c.regs.pc)
				c.regs.pc++
				c.rw_go(1)
				if dst == Direct8.dff {
					c.ctx.rw_ireg |= 0xFF00
					c.rw_go(2)
				}
				return none
			}
			1 {
				c.ctx.rw_ireg |= u32(bus.read(c.regs.pc)) << 8
				c.regs.pc++
				c.rw_go(2)
				return none
			}
			2 {
				bus.write(u16(c.ctx.rw_ireg), val)
				c.rw_go(3)
				return none
			}
			3 {
				c.rw_go(0)
				return
			}
			else {
				return none
			}
		}
	} $else {
		$compile_error('unexpected type for write8')
	}
}

fn (mut c Cpu) read16[T](bus &Peripherals, src T) ?u16 {
	$if T is Reg16 {
		return match Reg16(src) {
			.af { c.regs.read_af() }
			.bc { c.regs.read_bc() }
			.de { c.regs.read_de() }
			.hl { c.regs.read_hl() }
			.sp { c.regs.sp }
		}
	} $else $if T is Imm16 {
		match c.ctx.rw_step {
			0 {
				c.ctx.rw_ireg = bus.read(c.regs.pc)
				c.regs.pc++
				c.rw_go(1)
				return none
			}
			1 {
				c.ctx.rw_ireg |= u32(bus.read(c.regs.pc)) << 8
				c.regs.pc++
				c.rw_go(2)
				return none
			}
			2 {
				c.rw_go(0)
				return u16(c.ctx.rw_ireg)
			}
			else {}
		}
		return none
	} $else $if T is Direct16 {
		match c.ctx.rw_step {
			0 {
				c.ctx.rw_ireg = bus.read(c.regs.pc)
				c.regs.pc++
				c.rw_go(1)
				return none
			}
			1 {
				c.ctx.rw_ireg |= u32(bus.read(c.regs.pc)) << 8
				c.regs.pc++
				c.rw_go(2)
				return none
			}
			2 {
				c.ctx.rw_ireg |= u32(bus.read(u16(c.ctx.rw_ireg))) << 16
				c.rw_go(3)
				return none
			}
			3 {
				c.ctx.rw_ireg |= u32(bus.read(u16(c.ctx.rw_ireg))) << 24
				c.rw_go(4)
				return none
			}
			4 {
				c.rw_go(0)
				return u16(c.ctx.rw_ireg >> 16)
			}
			else {}
		}
		return none
	} $else {
		$compile_error('unexpected type for read16')
	}
}

fn (mut c Cpu) write16[T](mut bus Peripherals, dst T, val u16) ? {
	$if T is Reg16 {
		match Reg16(dst) {
			.af { c.regs.write_af(val) }
			.bc { c.regs.write_bc(val) }
			.de { c.regs.write_de(val) }
			.hl { c.regs.write_hl(val) }
			.sp { c.regs.sp = val }
		}
	} $else $if T is Direct16 {
		match c.ctx.rw_step {
			0 {
				c.ctx.rw_ireg = bus.read(c.regs.pc)
				c.regs.pc++
				c.rw_go(1)
				return none
			}
			1 {
				c.ctx.rw_ireg |= u32(bus.read(c.regs.pc)) << 8
				c.regs.pc++
				c.rw_go(2)
				return none
			}
			2 {
				bus.write(u16(c.ctx.rw_ireg), u8(val))
				c.rw_go(3)
				return none
			}
			3 {
				bus.write(u16(c.ctx.rw_ireg), u8(val >> 8))
				c.rw_go(4)
				return none
			}
			4 {
				c.rw_go(0)
				return
			}
			else {
				return none
			}
		}
	} $else {
		$compile_error('unexpected type for read16')
	}
}

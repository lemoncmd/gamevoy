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

fn (mut c Cpu) read8[T](_ &Peripherals, src T) ?u8 {
	$if T is Reg8 {
		return match src {
			.a { c.regs.a }
			.b { c.regs.b }
			.c { c.regs.c }
			.d { c.regs.d }
			.e { c.regs.e }
			.h { c.regs.h }
			.l { c.regs.l }
		}
	} $else {
		$compile_error('unexpected type for read8')
	}
}

fn (mut c Cpu) write8[T](mut _ Peripherals, dst T, val u8) ? {
	$if T is Reg8 {
		match dst {
			.a { c.regs.a = val }
			.b { c.regs.b = val }
			.c { c.regs.c = val }
			.d { c.regs.d = val }
			.e { c.regs.e = val }
			.h { c.regs.h = val }
			.l { c.regs.l = val }
		}
	} $else {
		$compile_error('unexpected type for write8')
	}
}

fn (mut c Cpu) read16[T](_ &Peripherals, src T) ?u16 {
	$if T is Reg16 {
		return match src {
			.af { c.regs.read_af() }
			.bc { c.regs.read_bc() }
			.de { c.regs.read_de() }
			.hl { c.regs.read_hl() }
			.sp { c.regs.sp }
		}
	} $else {
		$compile_error('unexpected type for read16')
	}
}

fn (mut c Cpu) write16[T](mut _ Peripherals, dst T, val u16) {
	$if T is Reg16 {
		return match src {
			.af { c.regs.write_af(val) }
			.bc { c.regs.write_bc(val) }
			.de { c.regs.write_de(val) }
			.hl { c.regs.write_hl(val) }
			.sp { c.regs.sp = val }
		}
	} $else {
		$compile_error('unexpected type for read16')
	}
}

module cpu

import peripherals { Peripherals }
import peripherals.bootrom { BootRom }

fn test_operand_read8() {
	br := BootRom.new([0x100]u8{})
	pp := Peripherals.new(br)
	mut c := Cpu.new()
	f := false
	if f {
		c.read8(pp, Reg8.a)
		c.read8(pp, Imm8{})
		c.read8(pp, Indirect.bc)
		c.read8(pp, Direct8.d)
	}
}

fn test_operand_write8() {
	br := BootRom.new([0x100]u8{})
	mut pp := Peripherals.new(br)
	mut c := Cpu.new()
	f := false
	if f {
		c.write8(mut pp, Reg8.a, 3)
		c.write8(mut pp, Indirect.bc, 3)
		c.write8(mut pp, Direct8.d, 3)
	}
}

fn test_operand_read16() {
	br := BootRom.new([0x100]u8{})
	pp := Peripherals.new(br)
	mut c := Cpu.new()
	f := false
	if f {
		c.read16(pp, Reg16.af)
		c.read16(pp, Imm16{})
		c.read16(pp, Direct16{})
	}
}

fn test_operand_write16() {
	br := BootRom.new([0x100]u8{})
	mut pp := Peripherals.new(br)
	mut c := Cpu.new()
	f := false
	if f {
		c.write16(mut pp, Reg16.af, 3)
		c.write16(mut pp, Direct16{}, 3)
	}
}

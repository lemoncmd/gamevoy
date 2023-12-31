module interrupts

@[flag]
pub enum InterruptFlag as u8 {
	vblank
	stat
	timer
	serial
	joypad
}

pub const all_flags = (fn () InterruptFlag {
	mut f := InterruptFlag.vblank
	$for value in InterruptFlag.values {
		f.set(value.value)
	}
	return f
}())

pub struct Interrupts {
pub mut:
	int_flags  InterruptFlag
	int_enable InterruptFlag
	ime        bool
	double     u8
	stop_count u16
}

pub fn (mut i Interrupts) irq(f InterruptFlag) {
	i.int_flags.set(f)
}

pub fn (i &Interrupts) read(addr u16) u8 {
	return match addr {
		0xFF0F { u8(i.int_flags) }
		0xFFFF { u8(i.int_enable) }
		0xFF4D { i.double }
		else { panic('unexpected address for interrupts: 0x${addr:04X}') }
	}
}

pub fn (mut i Interrupts) write(addr u16, val u8) {
	match addr {
		0xFF0F { i.int_flags = unsafe { InterruptFlag(val) } }
		0xFFFF { i.int_enable = unsafe { InterruptFlag(val) } }
		0xFF4D { i.double = (i.double & 0x80) | (val & 1) }
		else { panic('unexpected address for interrupts: 0x${addr:04X}') }
	}
}

pub fn (mut i Interrupts) change_double_mode() {
	i.double = u8(i.double & 0x80 == 0) << 7
}

pub fn (i &Interrupts) get_interrupts() InterruptFlag {
	return i.int_flags & i.int_enable
}

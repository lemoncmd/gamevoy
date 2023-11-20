module joypad

import cpu.interrupts { Interrupts }

pub enum Button {
	down
	up
	left
	right
	start
	@select
	b
	a
}

fn (b Button) to_direction() u8 {
	return match b {
		.down { 0b1000 }
		.up { 0b100 }
		.left { 0b10 }
		.right { 0b1 }
		else { 0 }
	}
}

fn (b Button) to_action() u8 {
	return match b {
		.start { 0b1000 }
		.@select { 0b100 }
		.b { 0b10 }
		.a { 0b1 }
		else { 0 }
	}
}

pub struct Joypad {
mut:
	mode      u8
	action    u8 = 0xFF
	direction u8 = 0xFF
}

pub fn Joypad.new() Joypad {
	return Joypad{}
}

pub fn (j &Joypad) read() u8 {
	mut ret := 0xCF | j.mode
	if ret & 0x10 == 0 {
		ret &= j.direction
	}
	if ret & 0x20 == 0 {
		ret &= j.action
	}
	return ret
}

pub fn (mut j Joypad) write(_ u16, val u8) {
	j.mode = 0x30 & val
}

pub fn (mut j Joypad) button_down(mut ints Interrupts, button Button) {
	j.direction &= ~button.to_direction()
	j.action &= ~button.to_action()
	ints.irq(.joypad)
}

pub fn (mut j Joypad) button_up(button Button) {
	j.direction |= button.to_direction()
	j.action |= button.to_action()
}

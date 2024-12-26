module apu

import math

struct Channel4 {
mut:
	length_timer    u8
	dac_enabled     bool
	enabled         bool
	length_enabled  bool
	frequency_timer u16

	period_timer   u8
	current_volume u8

	initial_volume u8
	is_upwards     bool
	period         u8

	lfsr         u16
	shift_amount usize
	width_mode   bool
	divisor_code u16
}

@[inline]
fn (mut c Channel4) emulate_t_cycle() {
	if c.frequency_timer == 0 {
		c.frequency_timer = math.max(c.divisor_code << 4, 8) << c.shift_amount

		xor := (c.lfsr & 0b01) ^ ((c.lfsr & 0b10) >> 1)
		c.lfsr = (c.lfsr >> 1) | (xor << 14)
		if c.width_mode {
			c.lfsr &= ~(1 << 6)
			c.lfsr |= xor << 6
		}
	}
	c.frequency_timer--
}

fn (mut c Channel4) length() {
	if c.length_enabled && c.length_timer > 0 {
		c.length_timer--
		c.enabled = c.enabled && c.length_timer > 0
	}
}

fn (mut c Channel4) envelope() {
	if c.period != 0 {
		if c.period_timer > 0 {
			c.period_timer--
		}

		if c.period_timer == 0 {
			c.period_timer = c.period

			if c.current_volume < 0xF && c.is_upwards {
				c.current_volume++
			} else if c.current_volume > 0x0 && !c.is_upwards {
				c.current_volume--
			}
		}
	}
}

fn (c &Channel4) dac_output() u8 {
	return if c.dac_enabled && c.enabled {
		u8(c.lfsr & 1) * c.current_volume
	} else {
		0
	}
}

fn (c &Channel4) read_nr4x(x u16) u8 {
	return match x {
		0 { 0xFF }
		1 { 0xFF }
		2 { (c.initial_volume << 4) | (u8(c.is_upwards) << 3) | c.period }
		3 { (u8(c.shift_amount) << 4) | (u8(c.width_mode) << 3) | u8(c.divisor_code) }
		4 { (u8(c.length_enabled) << 6) | 0b1011_1111 }
		else { 0xFF }
	}
}

fn (mut c Channel4) write_nr4x(x u16, val u8) {
	match x {
		0 {}
		1 {
			c.length_timer = 64 - (val & 0x3f)
		}
		2 {
			c.is_upwards = val & 0x08 > 0
			c.initial_volume = val >> 4
			c.period = val & 0x07
			c.dac_enabled = val & 0b11111000 > 0
			c.enabled = c.enabled && c.dac_enabled
		}
		3 {
			c.shift_amount = (val >> 4) & 0x0F
			c.width_mode = val & 0x08 > 0
			c.divisor_code = val & 0x07
		}
		4 {
			c.length_enabled = val & 0x40 > 0
			if c.length_timer == 0 {
				c.length_timer = 64
			}
			trigger := val & 0x80 > 0
			if trigger && c.dac_enabled {
				c.enabled = true
			}
			if trigger {
				c.lfsr = 0x7FFF
				c.period_timer = c.period
				c.current_volume = c.initial_volume
			}
		}
		else {}
	}
}

fn (mut c Channel4) emulate_fs_cycle(fs u8) {
	if fs & 0b1 == 0 {
		c.length()
	}
	if fs == 7 {
		c.envelope()
	}
}

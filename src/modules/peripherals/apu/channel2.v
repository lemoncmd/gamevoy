module apu

struct Channel2 {
mut:
	length_timer       u8
	dac_enabled        bool
	enabled            bool
	frequency          u16
	length_enabled     bool
	frequency_timer    u16
	wave_duty_position usize

	wave_duty_pattern u8
	period_timer      u8
	current_volume    u8

	initial_volume u8
	is_upwards     bool
	period         u8
}

@[inline]
fn (mut c Channel2) emulate_t_cycle() {
	if c.frequency_timer == 0 {
		c.frequency_timer = (2048 - c.frequency) * 4
		c.wave_duty_position = (c.wave_duty_position + 1) & 7
	}
	c.frequency_timer--
}

fn (mut c Channel2) length() {
	if c.length_enabled && c.length_timer > 0 {
		c.length_timer--
		c.enabled = c.enabled && c.length_timer > 0
	}
}

fn (mut c Channel2) envelope() {
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

fn (c &Channel2) dac_output() u8 {
	return if c.dac_enabled && c.enabled {
		wave_duty[c.wave_duty_pattern][c.wave_duty_position] * c.current_volume
	} else {
		0
	}
}

fn (c &Channel2) read_nr2x(x u16) u8 {
	return match x {
		1 { (c.wave_duty_pattern << 6) | 0b0011_1111 }
		2 { (c.initial_volume << 4) | (u8(c.is_upwards) << 3) | c.period }
		3 { 0xFF }
		4 { (u8(c.length_enabled) << 6) | 0b1011_1111 }
		else { 0xFF }
	}
}

fn (mut c Channel2) write_nr2x(x u16, val u8) {
	match x {
		1 {
			c.wave_duty_pattern = (val >> 6) & 0b11
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
			c.frequency = (c.frequency & 0x0700) | u16(val)
		}
		4 {
			c.frequency = (c.frequency & 0xFF) | (u16(val & 0x07) << 8)
			c.length_enabled = val & 0x40 > 0
			if c.length_timer == 0 {
				c.length_timer = 64
			}
			trigger := val & 0x80 > 0
			if trigger && c.dac_enabled {
				c.enabled = true
				c.period_timer = c.period
				c.current_volume = c.initial_volume
			}
		}
		else {}
	}
}

fn (mut c Channel2) emulate_fs_cycle(fs u8) {
	if fs & 0b1 == 0 {
		c.length()
	}
	if fs == 7 {
		c.envelope()
	}
}

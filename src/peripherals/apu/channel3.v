module apu

import math

struct Channel3 {
mut:
	length_timer       u16
	dac_enabled        bool
	enabled            bool
	frequency          u16
	length_enabled     bool
	frequency_timer    u16
	wave_duty_position usize

	output_level u8
	volume_shift u8
	wave_ram     [0x10]u8
}

@[inline]
fn (mut c Channel3) emulate_t_cycle() {
	if c.frequency_timer == 0 {
		c.frequency_timer = (2048 - c.frequency) * 2
		c.wave_duty_position = (c.wave_duty_position + 1) & 31
	}
	c.frequency_timer--
}

fn (mut c Channel3) length() {
	if c.length_enabled && c.length_timer > 0 {
		c.length_timer--
		c.enabled = c.enabled && c.length_timer > 0
	}
}

fn (c &Channel3) dac_output() u8 {
	return if c.dac_enabled && c.enabled {
		(0xF & (c.wave_ram[c.wave_duty_position >> 1] >> ((c.wave_duty_position & 1) << 2))) >> c.volume_shift
	} else {
		0
	}
}

fn (c &Channel3) read_nr3x(x u16) u8 {
	return match x {
		0 { (u8(c.dac_enabled) << 7) | 0x7F }
		1 { 0xFF }
		2 { (c.output_level << 5) | 0x9F }
		3 { 0xFF }
		4 { (u8(c.length_enabled) << 6) | 0b1011_1111 }
		else { 0xFF }
	}
}

fn (mut c Channel3) write_nr3x(x u16, val u8) {
	match x {
		0 {
			c.dac_enabled = val & 0x80 > 0
			c.enabled = c.enabled && c.dac_enabled
		}
		1 {
			c.length_timer = 256 - u16(val)
		}
		2 {
			c.output_level = (val >> 5) & 0x03
			c.volume_shift = math.min(c.output_level - 1, 4)
		}
		3 {
			c.frequency = (c.frequency & 0x0700) | u16(val)
		}
		4 {
			c.frequency = (c.frequency & 0xFF) | (u16(val & 0x07) << 8)
			c.length_enabled = val & 0x40 > 0
			if c.length_timer == 0 {
				c.length_timer = 256
			}
			trigger := val & 0x80 > 0
			if trigger && c.dac_enabled {
				c.enabled = true
			}
		}
		else {}
	}
}

fn (mut c Channel3) emulate_fs_cycle(fs u8) {
	if fs & 0b1 == 0 {
		c.length()
	}
}

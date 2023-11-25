module apu

const wave_duty = [
	[u8(0), 0, 0, 0, 0, 0, 0, 1]!,
	[u8(0), 0, 0, 0, 0, 0, 1, 1]!,
	[u8(0), 0, 0, 0, 1, 1, 1, 1]!,
	[u8(0), 0, 1, 1, 1, 1, 1, 1]!,
]!

pub const samples = 512

pub const sample_rate = 48000

const cpu_clock_hz = 4_194_304

pub struct Apu {
mut:
	enabled  bool
	nr50     u8
	nr51     u8
	cycles   u32
	fs       u8
	channel1 Channel1
	channel2 Channel2
	channel3 Channel3
	channel4 Channel4
pub mut:
	samples       [1024]f32
	sample_idx    usize
	samples_ready [1024]f32
}

pub fn Apu.new() Apu {
	return Apu{}
}

pub fn (mut a Apu) emulate_cycle() {
	for _ in 0 .. 4 {
		a.cycles++

		a.channel1.emulate_t_cycle()
		a.channel2.emulate_t_cycle()
		a.channel3.emulate_t_cycle()
		a.channel4.emulate_t_cycle()

		if a.cycles & 0x1FFF == 0 {
			a.channel1.emulate_fs_cycle(a.fs)
			a.channel2.emulate_fs_cycle(a.fs)
			a.channel3.emulate_fs_cycle(a.fs)
			a.channel4.emulate_fs_cycle(a.fs)
			a.cycles = 0
			a.fs = (a.fs + 1) & 7
		}

		if a.cycles % (apu.cpu_clock_hz / apu.sample_rate) == 0 {
			left_sample := (((a.nr51 >> 7) & 0b1) * a.channel4.dac_output() +
				((a.nr51 >> 6) & 0b1) * a.channel3.dac_output() +
				((a.nr51 >> 5) & 0b1) * a.channel2.dac_output() +
				((a.nr51 >> 4) & 0b1) * a.channel1.dac_output())
			right_sample := (((a.nr51 >> 3) & 0b1) * a.channel4.dac_output() +
				((a.nr51 >> 2) & 0b1) * a.channel3.dac_output() +
				((a.nr51 >> 1) & 0b1) * a.channel2.dac_output() +
				((a.nr51 >> 0) & 0b1) * a.channel1.dac_output())
			a.samples[a.sample_idx * 2] = f32(i32((a.nr50 >> 4) & 0x7) * i32(left_sample) - 210) / 210.0
			a.samples[a.sample_idx * 2 + 1] = f32(i32(a.nr50 & 0x7) * i32(right_sample) - 210) / 210.0
			a.sample_idx++
		}

		if a.sample_idx >= apu.samples {
			unsafe { vmemcpy(&a.samples_ready, &a.samples, sizeof(a.samples)) }
			a.sample_idx = 0
		}
	}
}

pub fn (a &Apu) read(addr u16) u8 {
	return match addr {
		0xFF10...0xFF14 {
			a.channel1.read_nr1x(addr - 0xFF10)
		}
		0xFF15...0xFF19 {
			a.channel2.read_nr2x(addr - 0xFF15)
		}
		0xFF1A...0xFF1E {
			a.channel3.read_nr3x(addr - 0xFF1A)
		}
		0xFF1F...0xFF23 {
			a.channel4.read_nr4x(addr - 0xFF1F)
		}
		0xFF24 {
			a.nr50
		}
		0xFF25 {
			a.nr51
		}
		0xFF26 {
			u8(a.channel1.enabled) | (u8(a.channel2.enabled) << 1) | (u8(a.channel3.enabled) << 2) | (u8(a.channel4.enabled) << 3) | 0x70 | (u8(a.enabled) << 7)
		}
		0xFF27...0xFF2F {
			0xFF
		}
		0xFF30...0xFF3F {
			a.channel3.wave_ram[addr - 0xFF30]
		}
		0xFF76 {
			a.channel1.dac_output() | (a.channel2.dac_output() << 4)
		}
		0xFF77 {
			a.channel3.dac_output() | (a.channel4.dac_output() << 4)
		}
		else {
			panic('unexpected address for apu: 0x${addr:04X}')
		}
	}
}

pub fn (mut a Apu) write(addr u16, _val u8) {
	mut val := _val
	if !a.enabled && addr !in [0xFF11, 0xFF16, 0xFF1B, 0xFF20, 0xFF26] && !(0xFF30 <= addr
		&& addr <= 0xFF3F) {
		return
	}
	if !a.enabled && addr in [0xFF11, 0xFF16, 0xFF20] {
		val &= 0b0011_1111
	}

	match addr {
		0xFF10...0xFF14 {
			a.channel1.write_nr1x(addr - 0xFF10, val)
		}
		0xFF15...0xFF19 {
			a.channel2.write_nr2x(addr - 0xFF15, val)
		}
		0xFF1A...0xFF1E {
			a.channel3.write_nr3x(addr - 0xFF1A, val)
		}
		0xFF1F...0xFF23 {
			a.channel4.write_nr4x(addr - 0xFF1F, val)
		}
		0xFF24 {
			a.nr50 = val
		}
		0xFF25 {
			a.nr51 = val
		}
		0xFF26 {
			enabled := val & 0x80 > 0
			if !enabled && a.enabled {
				for addr2 in 0xFF10 .. 0xFF26 {
					a.write(addr2, 0x00)
				}
			} else if enabled && !a.enabled {
				a.fs = 0
				a.channel1.wave_duty_position = 0
				a.channel2.wave_duty_position = 0
				a.channel3.wave_duty_position = 0
			}
			a.enabled = enabled
		}
		0xFF27...0xFF2F {}
		0xFF30...0xFF3F {
			a.channel3.wave_ram[addr - 0xFF30] = val
		}
		else {
			panic('unexpected address for apu: 0x${addr:04X}')
		}
	}
}

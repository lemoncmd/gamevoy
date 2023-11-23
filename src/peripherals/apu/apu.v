module apu

import math.unsigned

const wave_duty = [
	[f32(0.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0]!,
	[f32(0.0), 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0]!,
	[f32(0.0), 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0]!,
	[f32(0.0), 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]!,
]!

pub const samples = 512

pub const sample_rate = 48000

const cpu_clock_hz = 4_194_304

pub struct Apu {
mut:
	enabled  bool
	nr50     u8
	nr51     u8
	cycles   unsigned.Uint128
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

const one = unsigned.uint128_from_64(1)

pub fn Apu.new() Apu {
	return Apu{}
}

pub fn (mut a Apu) emulate_cycle() {
	for _ in 0 .. 4 {
		a.cycles += apu.one

		a.channel1.emulate_t_cycle()
		a.channel2.emulate_t_cycle()
		a.channel3.emulate_t_cycle()
		a.channel4.emulate_t_cycle()

		if a.cycles.and_64(0x1FFF).is_zero() {
			a.channel1.emulate_fs_cycle(a.fs)
			a.channel2.emulate_fs_cycle(a.fs)
			a.channel3.emulate_fs_cycle(a.fs)
			a.channel4.emulate_fs_cycle(a.fs)
			a.cycles = unsigned.uint128_zero
			a.fs = (a.fs + 1) & 7
		}

		if a.cycles.mod_64(apu.cpu_clock_hz / apu.sample_rate) == 0 {
			left_sample := (f32((a.nr51 >> 7) & 0b1) * a.channel4.dac_output() +
				f32((a.nr51 >> 6) & 0b1) * a.channel3.dac_output() +
				f32((a.nr51 >> 5) & 0b1) * a.channel2.dac_output() +
				f32((a.nr51 >> 4) & 0b1) * a.channel1.dac_output()) / 4.0
			right_sample := (f32((a.nr51 >> 3) & 0b1) * a.channel4.dac_output() +
				f32((a.nr51 >> 2) & 0b1) * a.channel3.dac_output() +
				f32((a.nr51 >> 1) & 0b1) * a.channel2.dac_output() +
				f32((a.nr51 >> 0) & 0b1) * a.channel1.dac_output()) / 4.0
			a.samples[a.sample_idx * 2] = (f32((a.nr50 >> 4) & 0x7) / 7.0) * left_sample
			a.samples[a.sample_idx * 2 + 1] = (f32(a.nr50 & 0x7) / 7.0) * right_sample
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
			a.channel1.dac_output_val() | (a.channel2.dac_output_val() << 4)
		}
		0xFF77 {
			a.channel3.dac_output_val() | (a.channel4.dac_output_val() << 4)
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

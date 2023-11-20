module apu

import math.unsigned

const wave_duty = [
	[f32(0.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0]!,
	[f32(0.0), 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0]!,
	[f32(0.0), 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0]!,
	[f32(0.0), 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]!,
]!

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
}

const one = unsigned.uint128_from_64(1)

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
	}
}

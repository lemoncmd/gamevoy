module gameboy

import peripherals.apu
import sokol.audio

fn (mut g Gameboy) init_audio() {
	audio.setup(
		num_channels: 2
		sample_rate: apu.sample_rate
		buffer_frames: apu.samples
		user_data: &g
		stream_userdata_cb: fn (buffer &f32, num_frames int, num_channels int, mut g Gameboy) {
			unsafe { vmemcpy(buffer, &g.peripherals.apu.samples_ready, num_frames * num_channels * sizeof[f32]()) }
		}
	)
}

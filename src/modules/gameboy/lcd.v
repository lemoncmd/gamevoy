module gameboy

import math
import gg
import sokol.sapp

const cpu_clock_hz = 4_194_304

const m_cycle_clock = 4

const ratio = 4

fn (mut g Gameboy) init_gg() {
	g.gg = gg.new_context(
		width:         160 * ratio
		height:        144 * ratio
		create_window: true
		window_title:  'gamevoy'
		init_fn:       fn (mut g Gameboy) {
			if mut gg_ctx := g.gg {
				g.image_idx = gg_ctx.new_streaming_image(160, 144, 4,
					pixel_format: .rgba8
					min_filter:   .nearest
					mag_filter:   .nearest
				)
			}
		}
		frame_fn:      fn (mut g Gameboy) {
			if mut gg_ctx := g.gg {
				gg_ctx.begin()
			}
			mut not_rendered := true
			fps := math.max(int(0.5 + 1.0 / sapp.frame_duration()), 60)
			for _ in 0 .. (cpu_clock_hz / m_cycle_clock) / fps {
				if g.emulate_cycle() {
					not_rendered = false
				}
			}
			if not_rendered {
				if mut gg_ctx := g.gg {
					mut istream_image := gg_ctx.get_cached_image_by_idx(g.image_idx)
					size := gg.window_size()
					gg_ctx.draw_image(0, 0, size.width, size.height, istream_image)
				}
			}
			if mut gg_ctx := g.gg {
				gg_ctx.end()
			}
		}
		quit_fn:       fn (_ &gg.Event, g &Gameboy) {
			g.save()
			g.quit_audio()
		}
		keydown_fn:    on_key_down
		keyup_fn:      on_key_up
		user_data:     &g
	)
}

fn (mut g Gameboy) draw_lcd(pixels []u8) {
	if mut gg_ctx := g.gg {
		mut istream_image := gg_ctx.get_cached_image_by_idx(g.image_idx)
		istream_image.update_pixel_data(&pixels[0])
		size := gg.window_size()
		gg_ctx.draw_image(0, 0, size.width, size.height, istream_image)
	}
}

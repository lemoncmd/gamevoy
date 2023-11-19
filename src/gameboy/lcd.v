module gameboy

import gg

const cpu_clock_hz = 4_194_304

const m_cycle_clock = 4

fn (mut g Gameboy) init_gg() {
	g.gg = gg.new_context(
		width: 160 * 4
		height: 144 * 4
		create_window: true
		window_title: 'gamevoy'
		init_fn: fn (mut g Gameboy) {
			if mut gg_ctx := g.gg {
				g.image_idx = gg_ctx.new_streaming_image(160, 144, 4, pixel_format: .rgba8)
			}
		}
		frame_fn: fn (mut g Gameboy) {
			if mut gg_ctx := g.gg {
				gg_ctx.begin()
			}
			mut not_rendered := true
			for _ in 0 .. (gameboy.cpu_clock_hz / gameboy.m_cycle_clock) / 60 {
				if g.emulate_cycle() {
					not_rendered = false
					break
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
		user_data: &g
	)
}

fn (mut g Gameboy) draw_lcd(pixels []u8) {
	if mut gg_ctx := g.gg {
		/*
		for x in 0..160 {
			for y in 0..144 {
				print(pixels[x+y*160]/64)
			}
			println('')
		}*/
		rgba_pixels := []u8{len: 160 * 144 * 4, init: pixels[index / 4]}
		mut istream_image := gg_ctx.get_cached_image_by_idx(g.image_idx)
		istream_image.update_pixel_data(&rgba_pixels[0])
		size := gg.window_size()
		gg_ctx.draw_image(0, 0, size.width, size.height, istream_image)
	}
}

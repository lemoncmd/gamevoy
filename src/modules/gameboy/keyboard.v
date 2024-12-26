module gameboy

import gg
import peripherals.joypad { Button }

fn key2joy(keycode gg.KeyCode) ?Button {
	return match keycode {
		.up { .up }
		.down { .down }
		.left { .left }
		.right { .right }
		.z { .a }
		.x { .b }
		.c { .start }
		.v { .@select }
		else { none }
	}
}

fn on_key_down(c gg.KeyCode, _ gg.Modifier, mut g Gameboy) {
	if c == .escape {
		if gg_ctx := g.gg {
			gg_ctx.quit()
		}
	}
	if c == .enter {
		g.save()
	}
	if b := key2joy(c) {
		g.on_key_down(b)
	}
}

fn on_key_up(c gg.KeyCode, _ gg.Modifier, mut g Gameboy) {
	if b := key2joy(c) {
		g.on_key_up(b)
	}
}

module gameboy

import gg
import peripherals.joypad { Button }

fn key2joy(keycode gg.KeyCode) ?Button {
	return match keycode {
		.up { .up }
		.down { .down }
		.left { .left }
		.right { .right }
		._2 { .@select }
		._1 { .start }
		.backspace { .b }
		.enter { .a }
		.z { .a }
		.x { .b }
		else { none }
	}
}

fn on_key_down(c gg.KeyCode, _ gg.Modifier, mut data Gameboy) {
	if c == .escape {
		data.quit()
	}
	if b := key2joy(c) {
		data.on_key_down(b)
	}
}

fn on_key_up(c gg.KeyCode, _ gg.Modifier, mut data Gameboy) {
	if b := key2joy(c) {
		data.on_key_up(b)
	}
}

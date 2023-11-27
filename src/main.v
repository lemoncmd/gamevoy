module main

import flag
import os
import peripherals.bootrom
import peripherals.cartridge
import gameboy

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('gamevoy')
	fp.version('v0.1.0')
	fp.description('game boy color emulator in V')
	fp.skip_executable()
	fp.limit_free_args_to_exactly(1)!
	fp.arguments_description('CartridgeROM')
	is_cgb := !fp.bool('use-gameboy', `g`, false, 'use gameboy bootrom and ppu instead of gameboy color compat mode')
	custom_bootrom := fp.string('bootrom', `b`, '', 'use custom bootrom file')
	cartridge_file_name := fp.finalize() or {
		println(fp.usage())
		return
	}[0]

	default_bootrom := if is_cgb {
		$embed_file('bootroms/cgb_boot.bin')
	} else {
		$embed_file('bootroms/dmg_boot.bin')
	}.to_bytes()
	b := bootrom.BootRom.new(if custom_bootrom == '' {
		default_bootrom
	} else {
		os.read_bytes(custom_bootrom)!
	})

	assert cartridge_file_name.ends_with('.gb') || cartridge_file_name.ends_with('.gbc'), 'file extention must be .gb or .gbc'
	save_file_name := cartridge_file_name.all_before_last('.') + '.sav'

	cartridge_data := os.read_bytes(cartridge_file_name)!
	c := cartridge.Cartridge.new(cartridge_data, is_cgb)
	mut g := gameboy.Gameboy.new(b, c, save_file_name)
	g.run()!
}

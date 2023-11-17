module cartridge

struct CartridgeHeader {
	entry_point     [4]u8
	logo            [48]u8
	title           [11]u8
	maker           [4]u8
	cgb_flag        u8
	new_licensee    [2]u8
	sgb_flag        u8
	cartridge_type  u8
	rom_size        u8
	sram_size       u8
	destination     u8
	old_license     u8
	game_version    u8
	header_checksum u8
	global_checksum [2]u8
}

fn (c &CartridgeHeader) check_sum() {
	mut sum := u8(0)
	data := &u8(&c.entry_point[0])
	for i in 0x34 .. 0x4D {
		sum = sum - unsafe { data[i] } - 1
	}
	assert sum == c.header_checksum, 'checksum validation failed'
}

fn (c &CartridgeHeader) rom_size() int {
	assert c.rom_size <= 0x08, 'invalid rom size: ${c.rom_size}'
	return 1 << (15 + c.rom_size)
}

fn (c &CartridgeHeader) sram_size() int {
	return match c.sram_size {
		0x00 { 0 }
		0x01 { 0x800 }
		0x02 { 0x2000 }
		0x03 { 0x8000 }
		0x04 { 0x20000 }
		0x05 { 0x10000 }
		else { panic('invalid sram size: ${c.sram_size}') }
	}
}

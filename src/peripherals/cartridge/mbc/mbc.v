module mbc

struct NoMbc {}

struct Mbc1 {
mut:
	low_bank    u8 = 0b00001
	high_bank   u8
	bank_mode   bool
	rom_banks   int
	sram_enable bool
}

pub type Mbc = Mbc1 | NoMbc

pub fn Mbc.new(cartridge_type u8, rom_banks int) Mbc {
	return match cartridge_type {
		0x00, 0x08, 0x09 {
			NoMbc{}
		}
		0x01...0x03 {
			Mbc1{
				rom_banks: rom_banks
			}
		}
		else {
			panic('not supported mbc: 0x${cartridge_type:02X}')
		}
	}
}

pub fn (mut m Mbc) write(addr u16, val u8) {
	match mut m {
		NoMbc {}
		Mbc1 {
			match addr {
				0x0000...0x1FFF {
					m.sram_enable = val & 0xF == 0xA
				}
				0x2000...0x3FFF {
					m.low_bank = if val & 0b11111 != 0b00000 {
						val & 0b11111
					} else {
						0b00001
					}
				}
				0x4000...0x5FFF {
					m.high_bank = val & 0b11
				}
				0x6000...0x7FFF {
					m.bank_mode = val & 0b1 > 0
				}
				else {
					panic('unexpected address for mbc: 0x${addr:04X}')
				}
			}
		}
	}
}

pub fn (m &Mbc) get_addr(addr u16) int {
	return match m {
		NoMbc {
			addr
		}
		Mbc1 {
			match addr {
				0x0000...0x3FFF {
					if m.bank_mode {
						(int(m.high_bank) << 19) | (addr & 0x3FFF)
					} else {
						addr & 0x3FFF
					}
				}
				0x4000...0x7FFF {
					(int(m.high_bank) << 19) | ((int(m.low_bank) & (m.rom_banks - 1)) << 14) | (addr & 0x3FFF)
				}
				0xA000...0xBFFF {
					if m.bank_mode {
						(int(m.high_bank) << 13) | (addr & 0x1FFF)
					} else {
						addr & 0x3FFF
					}
				}
				else {
					panic('unexpected address for cartridge: 0x${addr:04X}')
				}
			}
		}
	}
}

pub fn (m &Mbc) sram_enable() bool {
	return match m {
		NoMbc { true }
		Mbc1 { m.sram_enable }
	}
}

pub fn (m &Mbc) str() string {
	return match m {
		NoMbc { 'NO MBC' }
		Mbc1 { 'MBC1' }
	}
}

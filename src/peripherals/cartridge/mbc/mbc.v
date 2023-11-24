module mbc

import peripherals.cartridge.rtc { Rtc }

struct NoMbc {}

struct Mbc1 {
mut:
	low_bank    u8 = 0b00001
	high_bank   u8
	bank_mode   bool
	rom_banks   int
	sram_enable bool
}

struct Mbc3 {
mut:
	low_bank     u8 = 0b00001
	high_bank    u8
	has_rtc      bool
	will_latched bool
	rom_banks    int
	sram_enable  bool
}

struct Mbc30 {
mut:
	low_bank     u8 = 0b00001
	high_bank    u8
	has_rtc      bool
	will_latched bool
	rom_banks    int
	sram_enable  bool
}

struct Mbc5 {
mut:
	low_bank    u16 = 0b00001
	high_bank   u8
	rom_banks   int
	sram_enable bool
}

pub type Mbc = Mbc1 | Mbc3 | Mbc30 | Mbc5 | NoMbc

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
		0x0F...0x13 {
			if rom_banks == 128 {
				Mbc30{
					rom_banks: rom_banks
					has_rtc: cartridge_type <= 0x10
				}
			} else {
				Mbc3{
					rom_banks: rom_banks
					has_rtc: cartridge_type <= 0x10
				}
			}
		}
		0x19...0x1E {
			Mbc5{
				rom_banks: rom_banks
			}
		}
		else {
			panic('not supported mbc: 0x${cartridge_type:02X}')
		}
	}
}

pub fn (mut m Mbc) write(addr u16, val u8, mut r Rtc) {
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
		Mbc3 {
			match addr {
				0x0000...0x1FFF {
					if val == 0x0A {
						m.sram_enable = true
					}
					if val == 0x00 {
						m.sram_enable = false
					}
				}
				0x2000...0x3FFF {
					m.low_bank = if val & 0x7F != 0 {
						val & 0x7F
					} else {
						1
					}
				}
				0x4000...0x5FFF {
					if val < 4 {
						m.high_bank = val
					} else if m.has_rtc && 0x8 <= val && val <= 0xC {
						m.high_bank = val
					}
				}
				0x6000...0x7FFF {
					if m.will_latched && val == 1 {
						r.latch()
					}
					m.will_latched = val == 0
				}
				else {
					panic('unexpected address for mbc: 0x${addr:04X}')
				}
			}
		}
		Mbc30 {
			match addr {
				0x0000...0x1FFF {
					if val == 0x0A {
						m.sram_enable = true
					}
					if val == 0x00 {
						m.sram_enable = false
					}
				}
				0x2000...0x3FFF {
					m.low_bank = if val != 0 {
						val
					} else {
						1
					}
				}
				0x4000...0x5FFF {
					if val < 8 {
						m.high_bank = val
					} else if m.has_rtc && 0x8 <= val && val <= 0xC {
						m.high_bank = val
					}
				}
				0x6000...0x7FFF {
					if m.will_latched && val == 1 {
						r.latch()
					}
					m.will_latched = val == 0
				}
				else {
					panic('unexpected address for mbc: 0x${addr:04X}')
				}
			}
		}
		Mbc5 {
			match addr {
				0x0000...0x1FFF {
					m.sram_enable = val & 0xF == 0xA
				}
				0x2000...0x2FFF {
					m.low_bank = (m.low_bank & 0x100) | u16(val)
				}
				0x3000...0x3FFF {
					m.low_bank = (m.low_bank & 0x0FF) | (u16(val) << 8)
				}
				0x4000...0x5FFF {
					m.high_bank = val & 0xF
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
			int(addr)
		}
		Mbc1 {
			match addr {
				0x0000...0x3FFF {
					if m.bank_mode {
						(u32(m.high_bank) << 19) | u32(addr & 0x3FFF)
					} else {
						addr & 0x3FFF
					}
				}
				0x4000...0x7FFF {
					(u32(m.high_bank) << 19) | ((u32(m.low_bank) & u32(m.rom_banks - 1)) << 14) | u32(addr & 0x3FFF)
				}
				0xA000...0xBFFF {
					if m.bank_mode {
						(int(m.high_bank) << 13) | (addr & 0x1FFF)
					} else {
						addr & 0x1FFF
					}
				}
				else {
					panic('unexpected address for cartridge: 0x${addr:04X}')
				}
			}
		}
		Mbc3, Mbc30 {
			match addr {
				0x0000...0x3FFF {
					int(addr & 0x3FFF)
				}
				0x4000...0x7FFF {
					((u32(m.low_bank) & u32(m.rom_banks - 1)) << 14) | u32(addr & 0x3FFF)
				}
				0xA000...0xBFFF {
					if Mbc(m).rtc_enable() {
						int(m.high_bank - 8)
					} else {
						(int(m.high_bank) << 13) | int(addr & 0x1FFF)
					}
				}
				else {
					panic('unexpected address for cartridge: 0x${addr:04X}')
				}
			}
		}
		Mbc5 {
			match addr {
				0x0000...0x3FFF {
					int(addr & 0x3FFF)
				}
				0x4000...0x7FFF {
					((u32(m.low_bank) & u32(m.rom_banks - 1)) << 14) | u32(addr & 0x3FFF)
				}
				0xA000...0xBFFF {
					(int(m.high_bank) << 13) | (addr & 0x1FFF)
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
		Mbc1, Mbc3, Mbc30, Mbc5 { m.sram_enable }
	}
}

pub fn (m &Mbc) rtc_enable() bool {
	return match m {
		Mbc3, Mbc30 { m.has_rtc && m.sram_enable && (0x8 <= m.high_bank && m.high_bank <= 0xC) }
		else { false }
	}
}

pub fn (m &Mbc) str() string {
	return match m {
		NoMbc { 'NO MBC' }
		Mbc1 { 'MBC1' }
		Mbc3 { 'MBC3' }
		Mbc30 { 'MBC30' }
		Mbc5 { 'MBC5' }
	}
}

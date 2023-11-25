module serial

import cpu.interrupts { Interrupts }

pub struct Serial {
mut:
	data      u8
	control   u8
	send_data ?u8
	recv_data ?u8
}

pub fn Serial.new() Serial {
	return Serial{}
}

pub fn (s &Serial) read(addr u16) u8 {
	return match addr {
		0xFF01 { s.data }
		0xFF02 { s.control }
		else { panic('unexpected address for serial: 0x${addr:04X}') }
	}
}

pub fn (mut s Serial) write(addr u16, val u8) {
	match addr {
		0xFF01 {
			s.data = val
		}
		0xFF02 {
			s.control = val
			if s.is_master() && s.control & 0x80 > 0 {
				s.send_data = s.data
			}
		}
		else {
			panic('unexpected address for serial: 0x${addr:04X}')
		}
	}
}

pub fn (mut s Serial) emulate_cycle(mut ints Interrupts) {
	if _ := s.send_data {
		s.recv_data = 0xFF
		s.send_data = none
	}
	if recv_data := s.recv_data {
		s.data = recv_data
		s.control &= 0x7F
		ints.irq(.serial)
	}
}

fn (s &Serial) is_master() bool {
	return s.control & 1 > 0
}

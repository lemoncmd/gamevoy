module rtc

import encoding.binary

pub struct Rtc {
mut:
	rtc         [5]u8
	latched_rtc [5]u8
	latched     bool
	milli       i64
	last_utc    i64
}

pub fn Rtc.new() Rtc {
	mut r := Rtc{}
	r.rtc[4] = 0b0100_0000
	r.latched_rtc[4] = 0b0100_0000
	return r
}

pub fn (r &Rtc) read(addr int) u8 {
	val := r.latched_rtc[addr]
	return match addr {
		0, 1 { val & 0x3F }
		2 { val & 0x1F }
		3 { val }
		4 { val & 0xC1 }
		else { panic('unexpected address for rtc: ${addr}') }
	}
}

pub fn (mut r Rtc) write(addr int, val u8) {
	r.rtc[addr] = match addr {
		0, 1 { val & 0x3F }
		2 { val & 0x1F }
		3 { val }
		4 { val & 0xC1 }
		else { panic('unexpected address for rtc: ${addr}') }
	}
	r.copy_to_latched_rtc()
}

pub fn (mut r Rtc) latch() {
	r.latched = !r.latched
}

fn (r &Rtc) is_halted() bool {
	return (r.rtc[4] >> 6) & 1 > 0
}

fn (mut r Rtc) copy_to_latched_rtc() {
	for i in 0 .. 5 {
		r.latched_rtc[i] = r.rtc[i]
	}
}

pub fn (r &Rtc) save() []u8 {
	mut data := []u8{len: 48}
	for i in 0 .. 5 {
		data[i * 4] = r.rtc[i]
		data[i * 4 + 20] = r.latched_rtc[i]
	}
	binary.little_endian_put_u64_at(mut data, u64(r.last_utc) / 1000, 40)
	return data
}

pub fn (mut r Rtc) load(_data []u8) {
	mut data := _data.clone()
	if data.len == 44 {
		data << [u8(0), 0, 0, 0]
	}
	for i in 0 .. 5 {
		r.rtc[i] = data[i * 4]
		r.latched_rtc[i] = data[i * 4 + 20]
	}
	r.last_utc = i64(binary.little_endian_u64_at(data, 40)) * 1000
}

fn (mut r Rtc) add_and_validate_time(add_sec i64) {
	sec := i64(r.rtc[0]) + add_sec
	add_min := if r.rtc[0] >= 60 {
		r.rtc[0] = u8(sec) & 0x3F
		0
	} else {
		r.rtc[0] = u8(sec % 60)
		sec / 60
	}
	min := i64(r.rtc[1]) + add_min
	add_hour := if r.rtc[1] >= 60 {
		r.rtc[1] = u8(min) & 0x3F
		0
	} else {
		r.rtc[1] = u8(min % 60)
		min / 60
	}
	hour := i64(r.rtc[2]) + add_hour
	add_day := if r.rtc[2] >= 24 {
		r.rtc[2] = u8(hour) & 0x1F
		0
	} else {
		r.rtc[2] = u8(hour % 24)
		hour / 24
	}
	day_l := i64(r.rtc[3]) + add_day
	r.rtc[3] = u8(day_l)
	day_h := i64(r.rtc[4] & 1) + day_l / 256
	r.rtc[4] = (r.rtc[4] & 0xFE) | u8(day_h & 1)
	if day_h > 1 {
		r.rtc[4] |= 1 << 7
	}
}

pub fn (mut r Rtc) emulate_cycle(utc i64) {
	r.milli += utc - r.last_utc
	if r.is_halted() {
		r.milli %= 1000
		r.last_utc = utc
		return
	}
	r.last_utc = utc
	if r.milli >= 1000 {
		sec := r.milli / 1000
		r.milli %= 1000
		r.add_and_validate_time(sec)
		if !r.latched {
			r.copy_to_latched_rtc()
		}
	}
}

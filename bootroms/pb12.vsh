mut source := get_raw_stdin()
assert source.len <= 0x4000
for i_ in 0 .. source.len {
	i := source.len - i_ - 1
	if source[i] != 0 {
		break
	}
	source.trim(i)
}

mut literals := []u8{}
mut bits := 0
mut control := 0
mut prev0 := u16(-1)
mut prev1 := u16(-1)
for j := 0; true; j++ {
	b := source[j] or {
		if bits == 0 {
			break
		}
		0
	}
	bits += 2
	if prev0 == b || prev1 == b {
		control <<= 1
		control |= 1
		control <<= 1
		if b == prev1 {
			control |= 1
		}
	} else {
		control <<= 2
		p := u8(prev1)
		opts := [
			p | ((p << 1) & 0xFF),
			p & (p << 1),
			p | ((p >> 1) & 0xFF),
			p & (p >> 1),
		]
		i := opts.index(b)
		if i == -1 {
			literals << b
		} else {
			control |= 1
			bits += 2
			control <<= 2
			control |= i
		}
	}
	prev0 = prev1
	prev1 = b
	if bits >= 8 {
		outctl := u8(control >> (bits - 8))
		assert outctl != 1
		print_character(outctl)
		for l in literals {
			print_character(l)
		}
		bits -= 8
		control &= (1 << bits) - 1
		literals = []
	}
}
print_character(1)

module util

pub fn add_8(x u8, y u8, carry u8) (u8, u8) {
	sum16 := u16(x) + u16(y) + u16(carry)
	sum := u8(sum16)
	carry_out := u8(sum16 >> 8)
	return sum, carry_out
}

pub fn add_16(x u16, y u16, carry u16) (u16, u16) {
	sum16 := u32(x) + u32(y) + u32(carry)
	sum := u16(sum16)
	carry_out := u16(sum16 >> 16)
	return sum, carry_out
}

pub fn sub_8(x u8, y u8, borrow u8) (u8, u8) {
	diff := x - y - borrow
	borrow_out := ((~x & y) | (~(x ^ y) & diff)) >> 7
	return diff, borrow_out
}

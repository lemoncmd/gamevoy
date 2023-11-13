module cpu

import peripherals { Peripherals }

fn (mut c Cpu) nop(mut bus Peripherals) {
	c.fetch(bus)
}

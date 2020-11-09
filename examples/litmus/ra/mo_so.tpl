// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y, z;

fn proca {
	local a, b;
	x.store(2);
	a = y.load();
}

fn procb {
	local c;
	y.store(1);
	c = z.load();
}

fn procc {
	local d;
	z.store(1);
	x.store(1);
	d = x.load();
	verify(d);
}


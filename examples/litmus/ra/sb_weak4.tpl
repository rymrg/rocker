// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra.
max_value 2;
global x, y, z;

fn proca {
	local r;
	x.store(1);
	r = z.load();
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
}

fn procc {
	local r;
	z.store(1);
}


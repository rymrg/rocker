// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra.
max_value 2;
global x, y, z;

fn proca {
	local r;
	x.store(1);
	z.store(1);
	z.store(1);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
}


// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y, z;

fn proca {
	local r;
	x.store(1);
	r = y.load();
	z.store(r);
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
}


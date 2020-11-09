// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y, z;

fn proca {
	local r, b;
	x.store(1);
	r = y.load();
	z.store(1);
}

fn procb {
	local r,t;
	y.store(1);
	r = x.load();
	t = z.load();
	x.store(1);
	if (t) {
		r = 2;
	}
}


// ROBUSTNESS wegr: not: ra.
max_value 1;
global x, y, z;

fn proca {
	local r, b;
	x.store(1);
	r = y.load();
	if (r) {
		b = 1;
	} else {
		b = 0;
	}
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
}


// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y;

fn proca {
	local r;
	y.store(1);
	r = x.load();
	verify(r);
}

fn procb {
	local r;
	x.store(1);
}

fn procc {
	local r;
	r = x.load();
	r = y.load();
}

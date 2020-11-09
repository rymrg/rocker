// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y, z;

fn proca {
	local r;
	x.store(1);
	r = y.load();
	r = CAS(z,0,2);
}

fn procb {
	local r;
	z.store(1);
	y.store(1);
	r = x.load();
}


// ROBUSTNESS wegr: not: ra.
max_value 1;
global x, y, k, z;
fn proca {
	local r;
	x.store(1);
	r = y.load();
	z.store(1);
	r = k.load();
}

fn procb {
	local r;
	y.store(1);
	k.store(1);
	x.store(1);
	r = z.load();
}


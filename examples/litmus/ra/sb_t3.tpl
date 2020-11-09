// ROBUSTNESS wegr: not: ra.
max_value 1;
global x, y, k;
fn proca {
	local r,r2;
	x.store(1);
	r = k.load();
	r2 = y.load();
	verify(r);
}

fn procb {
	local r;
	y.store(1);
	k.store(1);
	r = x.load();
}


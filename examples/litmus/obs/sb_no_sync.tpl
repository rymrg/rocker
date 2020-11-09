// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y, z, k;

fn proca {
	local r,b;
	x.store(1);
	r = x.load();
	z.store(1);
	b = k.load();
	//assert(b == 1);
	verify(b);
}

fn procb {
	local a,b;
	y.store(1);
	a = x.load();
	k.store(1);
	b = z.load();
	//assert(b == 1);
	verify(b);
}


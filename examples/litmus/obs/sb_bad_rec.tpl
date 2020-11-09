// ROBUSTNESS wegr: not: ra.
max_value 2;
global z, k, x, y;

fn proca {
	local r;
	z.store(1);
	x.store(1);
	r = y.load();
	k.store(r+1);
}

fn procb {
	local b,c,d;
	y.store(1);
	b = x.load();
	c = z.load();
	d = k.load();
	if (d == 1){
		assert(c == 1);
	}
}


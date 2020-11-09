// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra.
max_value 2;
global x, y, z, k;

fn proca {
	local a, b;
	a = k.load();
	if (a == 1){
			x.store(1);
			b = y.load();
	}
}

fn procb {
	local c;
	y.store(1);
	c = z.load();
}

fn procc {
	local d;
	z.store(1);
	k.store(1);
	d = x.load();
	verify(d);
}


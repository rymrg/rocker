// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra,rlx.
max_value 2;
global x, y, z;

fn proca {
	local r;
	x.store(1);
	r = y.load();
	z.store(1);
}

fn procb {
	local b,c,d;
	y.store(1);
	b = x.load();
	c = z.load();
	b = 2;
	//b = x.load();
	verify(b);
}


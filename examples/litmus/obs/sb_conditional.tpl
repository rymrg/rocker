// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra. not: rlx.
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
	if (t) {
		r = 2;
		x.store(1);
	}
}


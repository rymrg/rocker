// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
max_value 5;
global x, y, z;
track z: 5;

fn proca {
	local r;
	x.store(1);
	r = y.load();
	z.store(1);
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
	wait(z, 5);
	r = x.load();
	verify(r);
}


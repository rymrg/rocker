// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra,rlx.
max_value 2;
global x, y;

fn proca {
	local r;
	x.store(1);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
	r = 2;
	//r = x.load();
	verify(r);
}


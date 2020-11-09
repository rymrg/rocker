// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra.
max_value 2;
global x, y;

fn proca {
	x.store(1);
}

fn procb {
	local a,b;
	a = x.load();
	fence;
	b = y.load();
}

fn procc {
	local c,d;
	c = y.load();
	d = x.load();
}

fn procd {
	y.store(1);
}

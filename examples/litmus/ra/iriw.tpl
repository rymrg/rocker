// ROBUSTNESS wegr: not: ra.
max_value 1;
global x, y;

fn proca {
	x.store(1);
}

fn procb {
	local a,b;
	a = x.load();
	b = y.load();
	verify(b);
}

fn procc {
	local c,d;
	c = y.load();
	d = x.load();
}

fn procd {
	y.store(1);
}

// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra.
max_value 2;
global x, y, z, l, j;

fn proca {
	local r;
	y.store(1);
	r = x.load();
}

fn procb {
	local r;
	x.store(1);
	r = y.load();
	r = z.load();
	r = l.load();
}
fn procc {
	local r;
	BCAS(j,1,1);
	z.store(1);
	r = x.load();
}
fn procd {
	local r;
	l.store(1);
	j.store(1);
}

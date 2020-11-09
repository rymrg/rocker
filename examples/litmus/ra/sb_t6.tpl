// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra.
max_value 1;
global x, y, k, j;
fn proca {
	local r;
	x.store(1);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	k.store(1);
	j.store(1);
	r = x.load();
}

fn procc {
	local r;
	k.store(1);
	j.store(1);
}

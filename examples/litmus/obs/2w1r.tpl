// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y;

fn proca {
	local r;
	x.store(1);
	y.store(2);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	x.store(2);
	r = x.load();
}


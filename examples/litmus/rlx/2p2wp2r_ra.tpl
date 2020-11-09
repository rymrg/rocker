// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
max_value 2;
global x, y;

fn proca {
	local a;
	x.store(1, rel);
	y.store(2, rel);
	a = y.load(acq);
}

fn procb {
	local a;
	y.store(1, rel);
	x.store(2, rel);
	a = x.load(acq);
}


// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
max_value 1;
global x, y;

fn proca {
	local r;
	x.store(1, rel);
	r = y.load(acq);
}

fn procb {
	local r;
	y.store(1, rel);
	r = x.load(acq);
}


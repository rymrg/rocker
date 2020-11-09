// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x, y;

fn proca {
	x.store(1, rlx);
	fence(acq_rel);
	y.store(1, rlx);
}

fn procb {
	local a,b;
	a = y.load(rlx);
	fence(acq_rel);
	b = x.load(rlx);
}


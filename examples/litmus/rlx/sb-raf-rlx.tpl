// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
max_value 2;
global x, y;

fn proca {
	local a;
	fence(rel);
	x.store(1, rlx);
	fence(acq);
	a = y.load(rlx);
}

fn procb {
	local b;
	fence(rel);
	y.store(1, rlx);
	fence(acq);
	b = x.load(rlx);
}


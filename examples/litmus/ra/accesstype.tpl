// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y;

fn proca {
	local a;
	a = x.load(rlx);
	a = x.load(acq);
	x.store(0, rel);
	x.store(1+1-3*2, rlx);
	y.store(2);
}

fn procb {
	y.store(1);
	x.store(2);
}


// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: rlx.
max_value 2;
global x, y, f;
track f: 0;

fn proca {
	local r;
	x.store(1);
	r = CAS(f, 0, 0, acq, rlx);
//	r = y.load();
}

fn procb {
	local r;
//	y.store(1);
	r = CAS(f, 0, 0, acq, rlx);
	r = x.load();
}

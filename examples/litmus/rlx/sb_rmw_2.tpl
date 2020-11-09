// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x, y, f;

fn proca {
	local r;
	x.store(1);
	r = FADD(f, 0, acq, rel);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	r = FADD(f, 0, acq, rel);
	r = x.load();
}

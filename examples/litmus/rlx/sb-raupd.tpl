// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x, y;

fn proca {
	local a;
	x.store(1, rel);
	fence(upd);
	//a = y.load(acq);
}

fn procb {
	local b;
	y.store(1, rel);
	fence(upd);
	b = x.load(acq);
}


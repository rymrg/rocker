// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x, y;

fn proca {
	x.store(1, rel);
}

fn procb {
	local a,b;
	a = x.load(acq);
	fence(seq_cst);
	b = y.load(acq);
}

fn procc {
	local c,d;
	c = y.load(acq);
	fence(seq_cst);
	d = x.load(acq);
}

fn procd {
	y.store(1, rel);
}

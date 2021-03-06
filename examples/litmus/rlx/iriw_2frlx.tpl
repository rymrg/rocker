// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x, y;

fn proca {
	x.store(1, rel);
}

fn procb {
	local a,b;
	a = x.load(rlx);
	fence(seq_cst);
	b = y.load(rlx);
}

fn procc {
	local c,d;
	c = y.load(rlx);
	fence(seq_cst);
	d = x.load(rlx);
}

fn procd {
	y.store(1, rel);
}

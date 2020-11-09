// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
max_value 2;
global x, y;

fn proca {
	x.store(1, rlx);
}

fn procb {
	local a,b;
	a = x.load(rlx);
	b = y.load(rlx);
}

fn procc {
	local c,d;
	c = y.load(rlx);
	fence(seq_cst);
	d = x.load(rlx);
}

fn procd {
	y.store(1, rlx);
}

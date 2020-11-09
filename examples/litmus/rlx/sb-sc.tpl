// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x, y;

fn proca {
	local a;
	x.store(1, rlx);
	fence(seq_cst);
	a = y.load(rlx);
}

fn procb {
	local b;
	y.store(1, rlx);
	fence(seq_cst);
	b = x.load(rlx);
}


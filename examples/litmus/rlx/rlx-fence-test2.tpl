// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: ra. not: rlx.
max_value 2;
global x, y, z;

fn proca {
	local a;
	a = y.load(rlx);
	fence(seq_cst);
	x.store(1, rlx);
}

fn procb {
	local a;
	x.store(2, rlx);
	y.store(1, rlx);
}


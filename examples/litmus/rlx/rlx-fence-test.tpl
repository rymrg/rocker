// ROBUSTNESS egr: robust: rlx.
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
	fence(seq_cst);
	z.store(1, rlx);
}

fn procc {
	local a;
	a = z.load(rlx);
	fence(seq_cst);
	y.store(1, rlx);
}

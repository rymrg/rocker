// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: ra. not: rlx.

// This program is not robust with the current definition on SC fence in C11.
// It is robust if you compile SC fences to
// fence(acq); f.FADD(0, acq_rel); fence(rel)
// where f is a distinguishedotherwise-unused location.

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
	y.store(1, rlx);
}

// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: rlx.
max_value 3;
global x, y;

fn proca {
	x.store(1,rlx);
	y.store(1,rel);
}

fn procb {
	local a;
	a = FADD(y, 2, rlx, rlx);
}

fn procc {
	local a,b;
	a = y.load(rlx);
	b = x.load(rlx);
}

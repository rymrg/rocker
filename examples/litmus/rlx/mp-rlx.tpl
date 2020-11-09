// ROBUSTNESS egr: robust: ra. not: rlx.
// ROBUSTNESS wegr: robust: rlx.
max_value 2;
global x, y;

fn proca {
	x.store(1, rlx);
	y.store(1, rlx);
}

fn procb {
	local a,b;
	a = y.load(rlx);
	b = x.load(rlx);
}


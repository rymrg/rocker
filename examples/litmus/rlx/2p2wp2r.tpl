// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
max_value 2;
global x, y;

fn proca {
	local a;
	x.store(1, rlx);
	y.store(2, rlx);
	a = y.load(rlx);
}

fn procb {
	local a;
	y.store(1, rlx);
	x.store(2, rlx);
	a = x.load(rlx);
}


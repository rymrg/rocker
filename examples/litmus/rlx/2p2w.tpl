// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
max_value 2;
global x, y;

fn proca {
	x.store(1, rlx);
	y.store(2, rlx);
}

fn procb {
	y.store(1, rlx);
	x.store(2, rlx);
}


// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
max_value 2;
global x, y;

fn proca {
	x.store(1, rel);
	y.store(2, rel);
}

fn procb {
	y.store(1, rel);
	x.store(2, rel);
}


// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x, y;

fn proca {
	x.store(1, rel);
	y.store(1, rel);
}

fn procb {
	local a,b;
	a = y.load(acq);
	b = x.load(acq);
}


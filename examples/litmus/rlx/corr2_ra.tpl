// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x;

fn proca {
	x.store(1, rel);
}

fn procb {
	x.store(2, rel);
}

fn procc {
	local a,b;
	a = x.load(acq);
	b = x.load(acq);
}

fn procd {
	local a,b;
	a = x.load(acq);
	b = x.load(acq);
}


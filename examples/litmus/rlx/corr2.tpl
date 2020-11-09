// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x;

fn proca {
	x.store(1, rlx);
}

fn procb {
	x.store(2, rlx);
}

fn procc {
	local a,b;
	a = x.load(rlx);
	b = x.load(rlx);
}

fn procd {
	local a,b;
	a = x.load(rlx);
	b = x.load(rlx);
}


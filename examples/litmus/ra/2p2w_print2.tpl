// ROBUSTNESS egr: robust: rlx.
max_value 2;
global x;

fn proca {
	local r;
	r = 2;
	x.store(1);
	verify(r);
}

fn procb {
	local r;
	r = 1;
	verify(r);
	x.store(2);
}


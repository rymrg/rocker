// ROBUSTNESS egr: robust: ra,rlx.
max_value 20;
global x, y;

fn proca {
	local r;
	r = CAS(x, 0, 1, acq, rel);
	r = y.load(rlx);

}

fn procb {
	local r;
	y.store(1, rlx);
	r = FADD(x, 2*r+1, acq, rel);
}


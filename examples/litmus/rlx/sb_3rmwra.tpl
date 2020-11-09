// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
max_value 20;
global x, y;

fn proca {
	local r;
	x.store(1,rel);
	r = y.load(acq);

}

fn procb {
	local r;
	r = CAS(y, 0, 1, acq, rel);
	r = FADD(x, 2*r+1, acq, rel);
}


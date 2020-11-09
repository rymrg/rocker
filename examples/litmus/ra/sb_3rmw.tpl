// ROBUSTNESS wegr: not: ra.
max_value 20;
global x, y;

fn proca {
	local r;
	x.store(1);
	r = y.load();

}

fn procb {
	local r;
	r = CAS(y, 0, 1);
	r = FADD(x, 2*r+1);
}


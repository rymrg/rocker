// ROBUSTNESS egr: robust: ra.
max_value 20;
global x, y;

fn proca {
	local r;
	r = CAS(x, 0, 1);
	r = y.load();

}

fn procb {
	local r;
	y.store(1);
	r = FADD(x, 2*r+1);
}


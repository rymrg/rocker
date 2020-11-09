// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y;
track y: 0,1,2;

fn proca {
	local r;
	x.store(1);
	r = y.load();
	r = CAS(y,2,2);
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
}


// ROBUST
max_value 2;
global x, y, f;
track f: 0;

fn proca {
	local r;
	x.store(1);
	r = CAS(f, 0, 0);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	r = CAS(f, 0, 0);
	r = x.load();
}

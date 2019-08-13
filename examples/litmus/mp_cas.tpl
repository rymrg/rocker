// ROBUST
max_value 2;
global x, y;

fn proca {
	local r;
	r = CAS(x,0,1);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	x.store(2);
}


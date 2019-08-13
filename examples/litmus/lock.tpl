// ROBUST
max_value 2;
global x;

fn proca {
	local r;
	lck:
	r = CAS(x,0,1);
	if (r != 0) goto lck;
	x.store(0);
}

fn procb {
	local r;
	lck:
	r = CAS(x,0,1);
	if (r != 0) goto lck;
	x.store(0);
}


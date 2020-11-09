// ROBUSTNESS wegr: not: ra.
max_value 2;
global x,y,z,k;

fn proca {
	local r,r2;
	x.store(1);
	k.store(1);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	r = z.load();
}

fn procc {
	local r,r2;
	z.store(1);
	r = k.load();
	if (r == 0){
			r2 = x.load();
			verify(r2);
	}
}

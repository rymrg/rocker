// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: ra.
max_value 2;
global x,y,z,k;

fn proca {
	local r,r2;
	r = k.load();
	if (r){
			x.store(1);
			r = y.load();
			fence;
			r=7;
			verify(r);
	}
}

fn procb {
	local r;
	y.store(1);
	r = z.load();
}

fn procc {
	local r;
	z.store(1);
	k.store(1);
	r = x.load();
	fence;
	verify(r);
}

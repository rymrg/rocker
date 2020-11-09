// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y, z, k;

fn proca {
	local r;
	k.store(1);
	x.store(1);
	wait(y, 0);
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
	z.store(1);
}

fn proc {
	x.store(2);
}

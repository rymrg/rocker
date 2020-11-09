// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y, z;

fn proca {
	local r;
	x.store(1);
	wait(y, 0);
	z.store(1);
}

fn procb {
	local a,b;
	y.store(1);
	a = x.load();
	a = 2;
	b = z.load();
	if (b){
		x.store(1);
	}
}


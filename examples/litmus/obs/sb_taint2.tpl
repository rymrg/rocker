// ROBUSTNESS wegr: not: ra.
max_value 3;
global x, y, z;

fn proca {
	local r;
	x.store(1);
	z.store(1);
	z.store(2);
	wait(y, 0);
	z.store(3);
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


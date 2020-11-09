// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.
max_value 2;
global x, y, z, k;

track y: 0,1,2;

fn proca {
	local r;
	x.store(1);
	wait(y, 0);
	k.store(1);
	z.store(1, rel);
}

fn procb {
	local a,b;
	wait(k,1);
	y.store(1);
	a = x.load();
	a = 2;
	b = z.load(acq);
	if (b == 1){
		x.store(1);
	}
}


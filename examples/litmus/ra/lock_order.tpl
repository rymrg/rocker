// ROBUSTNESS egr: robust: ra.
max_value 2;
global x, y, z;

fn proca{
	local a;
	lock(x);
	unlock(x);
	a = x.load();
}

fn procb{
	local b;
	x.store(1);
	lock(x);
	unlock(x);
}

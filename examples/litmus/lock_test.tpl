// ROBUST
max_value 2;
global x, y, z;

fn proca{
	local a;
	lock(x);
	y.store(1);
	a = z.load();
	unlock(x);
}

fn procb{
	local a;
	lock(x);
	z.store(1);
	a = y.load();
	unlock(x);
}

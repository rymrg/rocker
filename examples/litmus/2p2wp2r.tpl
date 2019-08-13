// NOTROBUST
max_value 2;
global x, y;

fn proca {
	local a;
	x.store(1);
	y.store(2);
	a = y.load();
}

fn procb {
	local a;
	y.store(1);
	x.store(2);
	a = x.load();
}


// NOTROBUST
max_value 1;
global x, y;

fn proca {
	local r;
	x.store(1);
	r = y.load();
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
}


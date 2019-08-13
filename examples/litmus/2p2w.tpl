// NOTROBUST
max_value 2;
global x, y;

fn proca {
	x.store(1);
	y.store(2);
}

fn procb {
	y.store(1);
	x.store(2);
}


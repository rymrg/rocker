// ROBUSTNESS egr: robust: ra.
max_value 2;
global x, y;

fn proca {
	x.store(1);
	y.store(1);
}

fn procb {
	local a,b;
	a = y.load();
	b = x.load();
}


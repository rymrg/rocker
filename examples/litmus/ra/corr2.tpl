// ROBUSTNESS egr: robust: ra.
max_value 2;
global x;

fn proca {
	x.store(1);
}

fn procb {
	x.store(2);
}

fn procc {
	local a,b;
	a = x.load();
	b = x.load();
}

fn procd {
	local a,b;
	a = x.load();
	b = x.load();
}


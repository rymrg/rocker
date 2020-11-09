// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y;

fn proca {
	local r;
	x.store(1);
	wait(y,0);
}

fn procb {
	local r;
	y.store(1);
	wait(x,0);
}


// ROBUSTNESS wegr: not: ra.
max_value 2;
global x, y;
track x: all;
track y: all;

fn proca {
	local r, b;
	x.store(1);
	wait(y, 0);
}

fn procb {
	local r,t;
	y.store(1);
	wait(x, 0);
}

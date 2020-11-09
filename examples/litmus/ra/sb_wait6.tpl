// ROBUSTNESS egr: not: ra.
// ROBUSTNESS wegr: robust: rlx.
max_value 2;
global x, y;
track y: 0,1,2;

fn proca {
	local r;
	x.store(1);
	r = y.load();
	wait(y,2);
}

fn procb {
	local r;
	y.store(1);
	r = x.load();
}


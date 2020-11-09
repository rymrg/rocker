// ROBUSTNESS egr: robust: rlx.
max_value 2;
global x, y;

fn proca {
	local r, b;
	x.store(1);
	wait(y, 1);
}

fn procb {
	local r,t;
	y.store(1);
	wait(x, 1);
}


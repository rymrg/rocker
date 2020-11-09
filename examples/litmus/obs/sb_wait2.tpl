// ROBUSTNESS egr: robust: rlx.
max_value 2;
global x, y;
track x: 0,1;
track y: all;

fn proca {
	local r, b;
	x.store(1);
	wait(y, 0);
}

fn procb {
	local r,t;
	y.store(1);
	wait(x, 1);
}

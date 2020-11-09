// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
max_value 1;
global x, y;

fn proca {
	local a;
	x.store(1, rel);
	BCAS(y,0,1, acq, rel);
	//wait (y,0);
}

fn procb {
	local a;
	y.store(1, rel);
	BCAS(x,0,1, acq, rel);
	//wait (x,0);
}



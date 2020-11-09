// ROBUSTNESS wegr: not: ra.
max_value 1;
global x, y;

fn proca {
	local a;
	x.store(1);
	BCAS(y,0,1);
	//wait (y,0);
}

fn procb {
	local a;
	y.store(1);
	BCAS(x,0,1);
	//wait (x,0);
}



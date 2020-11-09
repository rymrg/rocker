// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
max_value 1;
global x, y;

fn t1{
	local a, b;
	l:
	a = CAS(x, 0, 1, acq, rel);
	if (a != 0) goto l;
	x.store(0, rel);
	b = y.load(acq);
}

fn t2{
	local c;
	l:
	y.store(1, rel);
	c = CAS(x, 0, 1, acq, rel);
	if (c != 0) goto l;
}

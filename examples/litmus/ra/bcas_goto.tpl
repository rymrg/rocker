// ROBUSTNESS wegr: not: ra.
max_value 1;
global x, y;

fn t1{
	local a, b;
	l:
	a = CAS(x, 0, 1);
	if (a != 0) goto l;
	x.store(0);
	b = y.load();
}

fn t2{
	local c;
	l:
	y.store(1);
	c = CAS(x, 0, 1);
	if (c != 0) goto l;
}

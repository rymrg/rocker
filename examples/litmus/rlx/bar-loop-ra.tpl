// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
global x, y;

fn f1{
	local a;
	x.store(1, rel);
	again:
	a = y.load(acq);
	if (a != 1) goto again;
}

fn f2{
	local a;
	y.store(1, rel);
	again:
	a = x.load(acq);
	if (a != 1) goto again;
}

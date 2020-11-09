// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.
global x, y;

fn f1{
	local a;
	x.store(1, rlx);
	again:
	a = y.load(rlx);
	if (a != 1) goto again;
}

fn f2{
	local a;
	y.store(1, rlx);
	again:
	a = x.load(rlx);
	if (a != 1) goto again;
}

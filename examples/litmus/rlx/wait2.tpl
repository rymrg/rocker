// ROBUSTNESS egr: not: ra,rlx.
// ROBUSTNESS wegr: not: ra,rlx.

// will be robust in "value" mode
// or if we add value tracking as in wait3.tpl

max_value 2;
global x,y;

fn f1{
	local a;
	x.store(1);
	wait(y, 1);
}

fn f2{
	local a;
	a = x.load();
	y.store(a);
	a = x.load();
	y.store(a);
}

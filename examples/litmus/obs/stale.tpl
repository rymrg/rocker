// ROBUSTNESS egr: robust: ra,rlx.
// ROBUSTNESS wegr: robust: ra,rlx.

// This example shows why we need all the RMW counter parts

max_value 3;
global x,y;

fn thread1{
	local t;
	wait(y, 1, acq);
	t = FADD(x, 1, rlx, rlx);
}

fn thread2{
	local t;
	x.store(1);
	x.store(1);
	y.store(1,rel);
}

fn thread3{
	local t;
	t = FADD(x,1,rlx,rlx);
}

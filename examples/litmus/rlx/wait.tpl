// ROBUSTNESS egr: robust: ra,rlx.
max_value 2;
global x,y;
track y: 1;

fn f1{
	local a;
	y.store(1);
	a = x.load();
}

fn f2{
	local a;
	x.store(1);
	wait(y, 1);
}

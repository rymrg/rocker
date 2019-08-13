// ROBUST
max_value 2;
global x,y;
track y: 1;

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
